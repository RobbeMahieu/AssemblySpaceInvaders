;-------------------------------------------------------------------------------------------------------------------
; Space Invaders Clone - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

cpu x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "engine.inc"
%include "./Gameobject.asm"
%include "./Player.asm"

; Constants and Data

WindowWidth equ 640                                     ; Window width constant
WindowHeight equ 480                                    ; Window height constant

section .data

AppName db "Space Invaders", 0                          ; Window title

section .bss
Player resd 1                                           ; Player

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
    call [LoadEngine]
    add esp, 20

    ; CreateGameObject(&init, &update, &render, &destroy)
    push PlayerDestroy
    push PlayerRender
    push PlayerUpdate
    push PlayerInit
    call CreateGameObject
    add esp, 16
    mov dword [Player], eax                             ; Cache player address

    call [RunEngine]

    mov eax, dword [Player]
    call dword [eax + Gameobject.destroy]

    call [CleanupEngine]

;
; Update()
;

Update:
    enter 0, 0


    mov eax, dword [Player]
    call dword [eax + Gameobject.update]

    leave
    ret

;
; Render()
;

Render:
    enter 0, 0

    mov eax, dword [Player]
    call dword [eax + Gameobject.render]

    call [CalculateFPS]
    push dword [formatDecimal]
    push eax
    call [DebugPrintValue]
    add esp, 8

    leave
    ret