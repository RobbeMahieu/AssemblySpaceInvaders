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
formatString db "%d", 0                               ; Format string for a 32-bit hexadecimal value

section .bss
buffer resb 50

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

DebugValue:
    enter 0,0
    
    push dword [ebp+8]
    push formatString
    push buffer
    call wsprintfA 

    push 0                                              ; Style
    push caption                                        ; Caption
    push buffer                                         ; Message
    push 0                                              ; hWnd     
    call MessageBoxA

    leave
    ret