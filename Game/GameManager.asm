;-------------------------------------------------------------------------------------------------------------------
; Game Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

section .bss
ActiveScene resd 1

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; InitializeGame()
;

InitializeGame:
    enter 0, 0

    call CreateMenuScene
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
    push dword [ActiveScene]                                  
    call DeleteScene
    add esp, 4

    leave
    ret

;
; CreateGameScene()
;
; eax => gamescene address
;

CreateGameScene:
    enter 0, 0
    push ebx

    ; Create game scene
    call [CreateScene]
    mov ebx, eax

    ; Create game scene
    push ebx                                            ; Put scene on the stack
    call CreatePlayer                                   ; CreatePlayer()   
    call CreateEarth                                    ; CreateEarth()   
    call CreateAlienManager                             ; CreateAlienManager()
    add esp, 4

    mov eax, ebx                                        ; Put scene address as return

    pop ebx
    leave
    ret

;
; CreateMenuScene
;

CreateMenuScene:
    enter 0, 0
    push ebx

    ; Create menu scene
    call [CreateScene]
    mov ebx, eax

    ; Create menu scene
    push ebx                                            ; Put scene on the stack
    call CreatePlayer                                   ; CreatePlayer()   
    add esp, 4

    mov eax, ebx                                        ; Put scene address as return

    pop ebx
    leave
    ret
