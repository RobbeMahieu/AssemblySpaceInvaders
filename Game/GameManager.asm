;-------------------------------------------------------------------------------------------------------------------
; Game Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and data

MENU_SCENE equ 0
GAME_SCENE equ 1
LOSE_SCENE equ 2

section .data

ActiveScene dd 0
NewScene dd 0
SceneIndex dd 0

MenuTitle db "SPACE INVADERS!", 0
MenuMessage db "Press SPACE to start...", 0
LoseTitle db "GAME OVER", 0
LoseMessage db "Press SPACE to retry...", 0

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; InitializeGame()
;

InitializeGame:
    enter 0, 0

    call LoadHighScore

    mov dword [SceneIndex], MENU_SCENE                  ; Set up starting scene
    call LoadScene

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

    cmp dword [NewScene], 1                             ; Check if scene needs to change
    jne .Done

    call LoadScene                                      ; Load new scene
    mov dword [NewScene], 0                             ; Set bool to false

    .Done:
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

    ; Clean up scene
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
    call CreatePlayer                                   ; CreatePlayer(&scene)   
    call CreateEarth                                    ; CreateEarth(&scene)   
    call CreateAlienManager                             ; CreateAlienManager(&scene)
    add esp, 4

    ; CreateScore(&scene, y, size)
    push 25
    push 0
    push ebx
    call CreateScore 
    add esp, 12

    ; Reset game
    call ScoreReset                                     ; Reset the score at the beginning of a game

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

    ; CreateMenu(&scene, &title, &message)
    push MenuMessage
    push MenuTitle
    push ebx
    call CreateMenu
    add esp, 12

    mov eax, ebx                                        ; Put scene address as return

    pop ebx
    leave
    ret

;
; CreateLoseScene
;

CreateLoseScene:
    enter 0, 0
    push ebx

    ; Save Highscore if necessary
    call SaveHighScore

    ; Create menu scene
    call [CreateScene]
    mov ebx, eax

    ; CreateMenu(&scene, &title, &message)
    push LoseMessage
    push LoseTitle
    push ebx
    call CreateMenu 
    add esp, 12

    ; CreateScore(&scene, y, size)
    push 20
    push 240
    push ebx
    call CreateScore 
    add esp, 12

    mov eax, ebx                                        ; Put scene address as return

    pop ebx
    leave
    ret

;
; SwapScene(sceneIndex)
; [ebp+8] index
;

SwapScene:
    enter 0, 0

    cmp dword [NewScene], 1                             ; Skip if in the middle of a scene swap
    je .Done

    mov dword [NewScene], 1                             ; Set bool true
    mov eax, [ebp+8]
    mov dword [SceneIndex], eax                         ; Save new scene index

    .Done:
    leave
    ret

;
; LoadScene()
;

LoadScene:
    enter 0, 0

    cmp dword [ActiveScene], 0                          ; Only deallocate scene if it exists
    je .MemoryReleased

    ; DeleteScene(&scene)                               ; Clear the current scene
    push dword [ActiveScene]
    call DeleteScene
    add esp, 4

    .MemoryReleased:
    lea edx, .SceneSwitch                               ; edx contains jump address
    mov ecx, dword[SceneIndex]                          
    lea edx, [edx + ecx*2]                              ; Instructions are 2 bytes long, so double the offset
    jmp edx

    .SceneSwitch:                                       ; Jump table
    jmp .Menu
    jmp .Game
    jmp .Lose

    .Menu:                                              ; Load Menu scene
    call CreateMenuScene           
    jmp .SwitchEnd

    .Game:                                              ; Load Game scene
    call CreateGameScene
    jmp .SwitchEnd

    .Lose:                                              ; Load Lose scene
    call CreateLoseScene                  
    jmp .SwitchEnd

    .SwitchEnd:
    mov dword [ActiveScene], eax 

    leave
    ret