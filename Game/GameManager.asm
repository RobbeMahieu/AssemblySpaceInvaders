;-------------------------------------------------------------------------------------------------------------------
; Game Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and data

MENU_SCENE equ 0
GAME_SCENE equ 1

section .data
ActiveScene dd 0

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; InitializeGame()
;

InitializeGame:
    enter 0, 0

    push MENU_SCENE
    call SwapScene
    add esp, 4

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
    call CreateMenu                                     ; CreateMenu()   
    add esp, 4

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

    cmp dword [ActiveScene], 0                          ; Only deallocate scene if it exists
    je .MemoryReleased

    ; DeleteScene(&scene)                               ; Clear the current scene
    push dword [ActiveScene]
    call DeleteScene
    add esp, 4

    .MemoryReleased:
    lea edx, .SceneSwitch                               ; edx contains jump address
    shl dword[ebp+8], 1                                 ; Instructions are 2 bytes long, so double the offset
    add edx, dword[ebp+8]                               ; Calculate correct address
    jmp edx

    .SceneSwitch:                                       ; Jump table
    jmp .Menu
    jmp .Game

    .Menu:                                              ; Load Menu scene
    call CreateMenuScene           
    mov dword [ActiveScene], eax         
    jmp .SwitchEnd

    .Game:                                              ; Load Game scene
    call CreateGameScene
    mov dword [ActiveScene], eax
    jmp .SwitchEnd

    .SwitchEnd:
    leave
    ret