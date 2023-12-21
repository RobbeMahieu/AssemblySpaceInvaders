;-------------------------------------------------------------------------------------------------------------------
; Debug functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
 extern MessageBoxA
 extern wsprintfA

; Constants and Data
section .data
caption db "Register Value", 0
formatDecimal db "%d", 0                                ; Format string decimal
formatHex db "0x%08x", 0                                ; Format string hex

section .bss
buffer resb 50

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

; DebugValue(value, format)
; [ebp+8] value
; [ebp+12] format
DebugValue:
    enter 0,0
    push eax
    push ecx
    push edx
    
    push dword [ebp+8]
    push dword [ebp+12]
    push buffer
    call wsprintfA
    add esp, 12 

    push 0                                              ; Style
    push caption                                        ; Caption
    push buffer                                         ; Message
    push 0                                              ; hWnd     
    call MessageBoxA

    pop edx
    pop ecx
    pop eax
    leave
    ret

; DebugPrintValue(value, format)
; [ebp+8] value
; [ebp+12] format
DebugPrintValue:
    enter 0, 0
    push eax
    push ecx
    push edx

    ; Create string
    push dword [ebp+8]
    push dword [ebp+12]
    push buffer
    call wsprintfA
    add esp, 12

    ; DrawString(text, x, y, width, height, color)
    push COLOR_RED
    push 60
    push 480
    push 420
    push 5
    push buffer
    call DrawString
    add esp, 24

    pop edx
    pop ecx
    pop eax
    leave
    ret