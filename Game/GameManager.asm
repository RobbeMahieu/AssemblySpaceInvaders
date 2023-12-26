;-------------------------------------------------------------------------------------------------------------------
; Game Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"


section .bss
GameScene resd 1
ActiveScene resd 1

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; InitializeGame()
;

InitializeGame:
    enter 0, 0

    ; Create game scene
    call [CreateScene]
    mov dword [GameScene], eax

    ; Create game scene
    push dword [GameScene]                              ; Put game scene on the stack
    call CreatePlayer                                   ; CreatePlayer()   
    call CreateEarth                                    ; CreateEarth()   
    call LayOutAlienGrid                                ; LayOutAlienGrid()
    add esp, 4

    mov eax, dword [GameScene]                          ; Set current scene as the active one
    mov dword [ActiveScene], eax

    leave
    ret

;
; UpdateGame()
;

UpdateGame:
    enter 0, 0

    push dword [ActiveScene]                            ; Update scene
    call UpdateScene
    add esp, 4

    leave
    ret

;
; RenderGame()
;

RenderGame:
    enter 0, 0

    push dword [ActiveScene]                            ; Render scene
    call RenderScene
    add esp, 4

    ; Debug FPS
    call [CalculateFPS]
    push dword [formatDecimal]
    push eax
    call [DebugPrintValue]
    add esp, 8

    leave
    ret

;
; CleanupGame()
;
CleanupGame:
    enter 0, 0

    ; Clean up all scenes
    push dword [GameScene]                                  
    call DeleteScene
    add esp, 4

    leave
    ret