;-------------------------------------------------------------------------------------------------------------------
; Debug functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
section .data
caption db "Debug", 0
formatDecimal db "%d", 0                                ; Format string decimal
formatHex db "0x%08x", 0                                ; Format string hex
DebugEnabled dd 0                                       ; If debugs will show

section .bss
buffer resb 50                                          ; Max 50 characters

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; EnableDebug(enabled)
; [ebp+8] enabled
;
EnableDebug:
    enter 0, 0

    mov eax, [ebp+8]
    mov dword [DebugEnabled], eax

    leave
    ret

;
; DebugValue(value, &format)
; [ebp+8] value
; [ebp+12] format
;

DebugValue:
    enter 0,0
    push eax                                            ; Debug functions cannot change registers, so store them
    push ecx
    push edx

    cmp dword [DebugEnabled], 0
    je .Done
    
    ; wsprintfA(&string, &format, extra variables)
    push dword [ebp+8]
    push dword [ebp+12]
    push buffer
    call wsprintfA
    add esp, 12 

    ; MessageBoxA(hWnd, &message, &caption, style)
    push 0
    push caption
    push buffer
    push 0 
    call MessageBoxA

    .Done:
    pop edx                                             ; Reset register states
    pop ecx
    pop eax
    leave
    ret

;
; DebugPrintValue(value, &format)
; [ebp+8] value
; [ebp+12] format
;

DebugPrintValue:
    enter 0, 0
    push eax                                            ; Debug functions cannot change registers, so store them
    push ecx
    push edx

    cmp dword [DebugEnabled], 0
    je .Done

    ; wsprintfA(&string, &format, extra variables)
    push dword [ebp+8]
    push dword [ebp+12]
    push buffer
    call wsprintfA
    add esp, 12

    mov eax, dword [WindowHeight]                       ; Calculate y position
    sub eax, 45                                         ; Bottom ScreenOffset


    ; DrawString(&text, x, y, width, height, color)
    push COLOR_RED
    push 60
    push 480
    push eax
    push 5
    push buffer
    call DrawString
    add esp, 24

    .Done:
    pop edx                                             ; Reset register states
    pop ecx
    pop eax
    leave
    ret