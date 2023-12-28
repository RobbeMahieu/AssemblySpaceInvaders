;-------------------------------------------------------------------------------------------------------------------
; Game Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and data

MENU_SCENE equ 0
GAME_SCENE equ 1
WIN_SCENE equ 2
LOSE_SCENE equ 3

section .data
ActiveScene dd 0
NewScene dd 0
SceneIndex dd 0

MenuTitle db "SPACE INVADERS!", 0
MenuMessage db "Press SPACE to start...", 0
WinTitle db "YOU WIN!", 0
WinMessage db "Press SPACE to play again...", 0
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

    mov dword [NewScene], MENU_SCENE
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

    ; CreateMenu(&scene, &title, &message)
    push MenuMessage
    push MenuTitle
    push ebx                                            ; Put scene on the stack
    call CreateMenu                                     ; CreateMenu()   
    add esp, 12

    mov eax, ebx                                        ; Put scene address as return

    pop ebx
    leave
    ret

;
; CreateWinScene
;

CreateWinScene:
    enter 0, 0
    push ebx

    ; Create menu scene
    call [CreateScene]
    mov ebx, eax

    ; CreateMenu(&scene, &title, &message)
    push WinMessage
    push WinTitle
    push ebx                                            ; Put scene on the stack
    call CreateMenu                                     ; CreateMenu()   
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

    ; Create menu scene
    call [CreateScene]
    mov ebx, eax

    ; CreateMenu(&scene, &title, &message)
    push LoseMessage
    push LoseTitle
    push ebx                                            ; Put scene on the stack
    call CreateMenu                                     ; CreateMenu()   
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
    shl dword[SceneIndex], 1                            ; Instructions are 2 bytes long, so double the offset
    add edx, dword[SceneIndex]                          ; Calculate correct address
    jmp edx

    .SceneSwitch:                                       ; Jump table
    jmp .Menu
    jmp .Game
    jmp .Win
    jmp .Lose

    .Menu:                                              ; Load Menu scene
    call CreateMenuScene           
    jmp .SwitchEnd

    .Game:                                              ; Load Game scene
    call CreateGameScene
    jmp .SwitchEnd

    .Win:                                               ; Load Win scene
    call CreateWinScene                  
    jmp .SwitchEnd

    .Lose:                                              ; Load Lose scene
    call CreateLoseScene                  
    jmp .SwitchEnd

    .SwitchEnd:
    mov dword [ActiveScene], eax 

    leave
    ret