;-------------------------------------------------------------------------------------------------------------------
; Input module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
%define PRESS   0
%define HOLD    1
%define RELEASE 3

section .bss
InputState resb 32
InputHeld resb 32

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

InitInput:
    enter 0, 0

    mov dword [InputState], 0
    mov dword [InputHeld], 0

    leave
    ret

; HandleInput(Keystroke)
; [ebp+8] Keystroke
UpdateInput:
    enter 0, 0
    push ebx
    push esi
    push edi

    ; Get keystroke in eax
    mov eax, 0x00FF0000                                 ; Mask
    and eax, [ebp+8]
    shr eax, 16                                         ; Shift bits over

    ; Get state
    mov esi, 0xC0000000                                 ; Mask
    and esi, [ebp+8]
    shr esi, 30                                         ; Shift bits over
    mov ecx, 0x00000001
    and ecx, esi                                        ; Cache keystate in ecx
    shr esi, 1                                          ; cache held in edx

    ; Save the state
    mov edi, 8                                          ; Get the correct byte
    div edi                                             ; eax / 8 => byte number is eax, offset in the byte is edx
    mov ebx, 1                                          ; Create mask
    xor ecx, 1

    .ShiftBits:                                         ; Put bits at correct position in byte
    cmp edx, 0
    jz .DoneShifting

    shl ecx, 1
    shl esi, 1                                          
    shl ebx, 1 

    sub edx, 1
    jmp .ShiftBits

    .DoneShifting:
    lea edx, [InputState]                               ; store address
    add edx, eax                                        ; add offset

    xor dword [edx], ebx                                ; Unset bit
    or dword [edx], ecx                                 ; Set it to the new state

    lea edx, [InputHeld]                                ; store address
    add edx, eax                                        ; add offset

    xor dword [edx], ebx                                ; Unset bit
    or dword [edx], esi                                 ; Set it to the new state

    pop edi
    pop esi
    pop ebx
    leave
    ret