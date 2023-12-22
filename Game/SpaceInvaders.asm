;-------------------------------------------------------------------------------------------------------------------
; Space Invaders Clone - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

cpu x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "engine.inc"

; Constants and Data

WindowWidth equ 640                                     ; Window width constant
WindowHeight equ 480                                    ; Window height constant

section .data

AppName db "Space Invaders", 0                          ; Window title
Xpos dd 0                                               ; Xpos (temp)
XposInt dd 0


;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

global START
START:

    ; LoadEngine(name, width, height)
    push Render
    push Update
    push WindowHeight
    push WindowWidth
    push AppName
    call LoadEngine
    add esp, 20

    ; Testing
    push MoveLeft
    push dword [HOLD]
    push dword [KEY_A]
    call AddAction
    add esp, 12

    push MoveRight
    push dword [HOLD]
    push dword [KEY_D]
    call AddAction
    add esp, 12

    call RunEngine
    call CleanupEngine

;
; Update()
;

Update:
    enter 0, 0

    fld dword [Xpos]
    fist dword [XposInt]

    push dword [formatHex]
    push dword [Xpos]
    call DebugPrintValue
    add esp, 8

    leave
    ret

;
; Render()
;

Render:
    enter 0, 0

    push dword [COLOR_CYAN]                                    
    push 200
    push 300
    push 100
    push dword [XposInt]
    call FillRectangle
    add esp, 20

    ;call CalculateFPS
    ;push dword [formatDecimal]
    ;push eax
    ;call DebugPrintValue
    ;add esp, 8

    leave
    ret

MoveLeft:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0

    mov dword [ebp-4], -50
    fild dword [ebp-4]

    call GetElapsed
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [Xpos]
    fstp dword [Xpos]

    leave
    ret

MoveRight:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0

    mov dword [ebp-4], 50
    fild dword [ebp-4]

    call GetElapsed
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [Xpos]
    fstp dword [Xpos]

    leave
    ret