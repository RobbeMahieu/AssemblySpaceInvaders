;-------------------------------------------------------------------------------------------------------------------
; Menu Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

struc Menu
    ; Owner
    .Gameobject resd 1

    ; UI
    .Title      resd 1
    .Message    resd 1

    ; Actions
    .Select     resd 1

    ;Properties
    .Activated resd 1
    .ActivationAccuDelay resd 1
endstruc

section .data

ActivationDelay dd 0.2

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------


;
; CreateMenu(&scene, &title, &message)
; [ebp+8] scene
; [ebp+12] title
; [ebp+16] message
; 
; eax => Gameobject address
;

CreateMenu:
    enter 0, 0
    push ebx

    push Menu_size                                      ; Create Menu struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fiels
    mov dword [ebx + Menu.ActivationAccuDelay], 0       ; Activation delay                   
    mov dword [ebx + Menu.Activated], 0                 ; Activation bool                   

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push MenuDestroy
    push MenuRender
    push MenuUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Menu.Gameobject], eax              ; Cache gameobject address

    ; Additional Setup

    ; CreateTextbox(&text,x, y, width, height, color, size, justification)   ; Title
    push dword [TEXT_JUSTIFY_CENTER]
    push 40
    push dword [COLOR_WHITE]
    push WindowHeight
    push WindowWidth
    push 200
    push 0
    push dword [ebp+12]
    call CreateTextbox
    add esp, 32
    mov [ebx + Menu.Title], eax                         ; Cache the title textbox 

    ; CreateTextbox(&text,x, y, width, height, color, size, justification)   ; Message
    push dword [TEXT_JUSTIFY_CENTER]
    push 20
    push dword [COLOR_WHITE]
    push WindowHeight
    push WindowWidth
    push 300
    push 0
    push dword [ebp+16]
    call CreateTextbox
    add esp, 32
    mov [ebx + Menu.Message], eax                       ; Cache the message textbox 

    mov eax, dword [ebx + Menu.Gameobject]              ; Return gameobject address

    pop ebx
    leave
    ret

;
; MenuUpdate(&object)
; [ebp+8] object
;

MenuUpdate:
    ; Local variables
    ; [ebp-4] temp float storage
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]
    cmp dword [ebx + Menu.Activated], 1
    je .Done

    ; Add elapsedSec to ActivationAccuDelay
    fld dword [ebx + Menu.ActivationAccuDelay]          ; Load jump timer in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax
    fadd dword [ebp-4]                                  ; Add to the timer
    fstp dword [ebx + Menu.ActivationAccuDelay]         ; Store the result

    ; Check activation condition
    fld dword [ActivationDelay]                         ; Put ActivationDelay in float stack
    fcomp dword [ebx + Menu.ActivationAccuDelay]        ; ActivationDelay <= ActivationAccuDelay?
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    ja .Done                                            ; I can finally compare now

    .Activate:
    mov dword [ebx + Menu.Activated], 1                 ; Activation bool 

    ; AddAction(key, state, callback, data)             ; Menu Select
    push ebx
    push MenuOnSelect
    push dword [PRESS]
    push dword [KEY_SPACE]
    call [AddAction]
    add esp, 16
    mov dword [ebx + Menu.Select], eax                  ; Store the action address

    .Done:
    pop ebx
    leave
    ret

;
; MenuRender(&object)
; [ebp+8] object
;

MenuRender:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    push dword [ebx + Menu.Title]
    call TextboxRender
    add esp, 4

    cmp dword [ebx + Menu.Activated], 1
    jne .Done

    push dword [ebx + Menu.Message]
    call TextboxRender
    add esp, 4

    .Done:
    pop ebx
    leave
    ret

;
; MenuDestroy(&object)
; [ebp+8] object
;

MenuDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DestroyTextbox(&textbox)
    push dword [ebx + Menu.Title]
    call DestroyTextbox
    add esp, 4

    ; DestroyTextbox(&textbox)
    push dword [ebx + Menu.Message]
    call DestroyTextbox
    add esp, 4

    cmp dword [ebx + Menu.Activated], 1
    jne .Done

    ; RemoveAction(&action)                                 ; Delete select action
    push dword [ebx + Menu.Select]
    call RemoveAction
    add esp, 4

    .Done:
    pop ebx
    leave
    ret

;
; MenuOnSelect()
;

MenuOnSelect:
    enter 0, 0

    push GAME_SCENE
    call SwapScene
    add esp, 4

    leave
    ret
