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

AppName db "Space Invaders", 0                         ; Window title

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

global START
START:

    ; LoadEngine(name, width, height)
    push WindowHeight
    push WindowWidth
    push AppName
    call LoadEngine

    push dword[formatHex]
    push dword [COLOR_BLUE]
    call DebugValue
    add esp, 8

    call RunEngine
    call CleanupEngine
