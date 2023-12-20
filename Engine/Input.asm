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

%define IN_KEYSTROKEMASK    0x00FF0000
%define IN_KEYSTROKESHIFT   16
%define IN_KEYSTATEMASK     0x80000000
%define IN_KEYSTATESHIFT    31

section .bss
CurrentInputState resb 32
PreviousInputState resb 32

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

InitInput:
    enter 0, 0

    mov dword [PreviousInputState], 0
    mov dword [PreviousInputState+4], 0
    mov dword [PreviousInputState+8], 0
    mov dword [PreviousInputState+12], 0
    mov dword [PreviousInputState+16], 0
    mov dword [PreviousInputState+20], 0
    mov dword [PreviousInputState+24], 0
    mov dword [PreviousInputState+28], 0

    mov dword [CurrentInputState], 0
    mov dword [CurrentInputState+4], 0
    mov dword [CurrentInputState+8], 0
    mov dword [CurrentInputState+12], 0
    mov dword [CurrentInputState+16], 0
    mov dword [CurrentInputState+20], 0
    mov dword [CurrentInputState+24], 0
    mov dword [CurrentInputState+28], 0

    leave
    ret

; HandleInput(Keystroke)
; [ebp+8] Keystroke
UpdateInput:
    enter 0, 0
    push ebx
    push edi

    ; Get keystroke in eax
    mov eax, IN_KEYSTROKEMASK
    and eax, [ebp+8]
    shr eax, IN_KEYSTROKESHIFT                          ; Shift bits over

    ; Get state
    mov ecx, IN_KEYSTATEMASK
    and ecx, [ebp+8]
    shr ecx, IN_KEYSTATESHIFT                           ; Shift bits over
    xor ecx, 1                                          ; invert the pressed state (pressed = 1)

    ; Manipulate flags in correct position
    mov edi, 8                                          ; Get the correct byte
    div edi                                             ; eax / 8 => byte number is eax, offset in the byte is edx
    mov ebx, 1                                          ; Create bitmask

    .ShiftBits:                                         ; Put bits at correct position in byte
    cmp edx, 0
    jz .DoneShifting

    shl ecx, 1                                       
    shl ebx, 1 

    sub edx, 1
    jmp .ShiftBits

    .DoneShifting:                                      ; Save the state
    lea edx, [CurrentInputState]                        ; store address
    add edx, eax                                        ; add offset

    xor ebx, 0xFFFFFFFF                                 ; Invert bitmask (keep everything but the bit)
    and dword [edx], ebx                                ; Unset bit
    or dword [edx], ecx                                 ; Set it to the new state

    pop edi
    pop ebx
    leave
    ret

HandleInput:
    enter 0, 0

    ; Check all bound actions

    ; Update previous input to current input
    lea edx, [CurrentInputState]
    mov [PreviousInputState], edx
    lea edx, [CurrentInputState+4]
    mov [PreviousInputState+4], edx
    lea edx, [CurrentInputState+8]
    mov [PreviousInputState+8], edx
    lea edx, [CurrentInputState+12]
    mov [PreviousInputState+12], edx
    lea edx, [CurrentInputState+16]
    mov [PreviousInputState+16], edx
    lea edx, [CurrentInputState+20]
    mov [PreviousInputState+20], edx
    lea edx, [CurrentInputState+24]
    mov [PreviousInputState+24], edx
    lea edx, [CurrentInputState+28]
    mov [PreviousInputState+28], edx

    leave
    ret
