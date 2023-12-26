;-------------------------------------------------------------------------------------------------------------------
; Space Invaders Clone - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

cpu x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "engine.inc"

%define HL_FRIENDLY C_HITLAYER_1
%define HL_ENEMY C_HITLAYER_2

%include "./GameManager.asm"
%include "./Bullet.asm"
%include "./Player.asm"
%include "./Alien.asm"
%include "./Earth.asm"

; Constants and Data

WindowWidth equ 560                                     ; Window width constant
WindowHeight equ 640                                    ; Window height constant

section .data

AppName db "Space Invaders", 0                          ; Window title

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

global START
START:

    ; LoadEngine(name, width, height)
    push RenderGame
    push UpdateGame
    push WindowHeight
    push WindowWidth
    push AppName
    call [LoadEngine]
    add esp, 20

    call InitializeGame

    call [RunEngine]
    push eax                                            ; Store message code

    call CleanupGame

    pop eax                                             ; Restore message code
    call [CleanupEngine]