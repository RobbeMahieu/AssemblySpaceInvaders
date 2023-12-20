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
; HandleInput(Keystroke)
; [ebp+8] Keystroke
UpdateInput:
    enter 0, 0

    ; Get keystroke in eax
    mov eax, 0x00FF0000                                 ; Mask
    and eax, [ebp+8]
    shr eax, 16                                         ; Shift bits over

    ; Get state in ebx
    mov edx, 0xC0000000                                 ; Mask
    and edx, [ebp+8]
    shr edx, 30                                         ; Shift bits over
    mov ecx, 0x00000001
    and ecx, edx                                        ; Cache keystate in ecx
    shr edx, 1                                          ; cache held in edx

    ; Save the state
    shl ecx, eax                                        ; Put bit at correct position
    or [InputState], ecx                                ; Save keystate
    shl edx, eax                                        ; Put bit at correct position
    or [InputHeld], edx                                 ; Save held state

    leave
    ret