;-------------------------------------------------------------------------------------------------------------------
; Space Invaders Clone - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

cpu x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "engine.inc"
%include "./Bullet.asm"
%include "./Player.asm"
%include "./Alien.asm"

; Constants and Data

WindowWidth equ 560                                     ; Window width constant
WindowHeight equ 640                                    ; Window height constant

section .data

AppName db "Space Invaders", 0                          ; Window title

section .bss
Scene resd 1                                            ; List of gameobjects

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

    ; Create game scene
    call [CreateScene]
    mov dword [Scene], eax

    ; Create game scene
    push dword [Scene]                                  ; Put game scene on the stack
    call CreatePlayer                                   ; CreatePlayer()   
    call LayOutAlienGrid                                ; LayOutAlienGrid()
    add esp, 4

    call [RunEngine]
    push eax                                            ; Store message code

    push dword [Scene]                                  ; Clean up scene
    call DeleteScene
    add esp, 4

    pop eax                                             ; Restore message code
    call [CleanupEngine]

;
; Update()
;

Update:
    enter 0, 0

    push dword [Scene]                                  ; Update scene
    call UpdateScene
    add esp, 4

    leave
    ret

;
; Render()
;

Render:
    enter 0, 0

    push dword [Scene]                                  ; Render scene
    call RenderScene
    add esp, 4

    ; Debug FPS
    call [CalculateFPS]
    push dword [formatDecimal]
    push eax
    ;call [DebugPrintValue]
    add esp, 8

    leave
    ret