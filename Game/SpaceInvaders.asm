;-------------------------------------------------------------------------------------------------------------------
; Space Invaders Clone - (c) Robbe Mahieu
; High Score: 8670
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

cpu x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "engine.inc"

%define HL_FRIENDLY         C_HITLAYER_1
%define HL_ENEMY            C_HITLAYER_2
%define HL_ENEMYPROJECTILE  C_HITLAYER_3

%include "./GameManager.asm"
%include "./Score.asm"
%include "./Bullet.asm"
%include "./Player.asm"
%include "./AlienManager.asm"
%include "./Alien.asm"
%include "./Ufo.asm"
%include "./Earth.asm"
%include "./Menu.asm"

; Constants and Data

WindowWidth equ 651                                     ; Window width constant
WindowHeight equ 744                                    ; Window height constant

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
    add esp,  20

    call InitializeGame

    call [RunEngine]
    push eax                                            ; Store message code

    call CleanupGame

    pop eax                                             ; Restore message code
    call [CleanupEngine]