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

    ; Create actions linked list
    call [LL_Create]
    mov dword [Scene], eax

    ; CreatePlayer(x, y, width, height, speed)
    push 50
    push 200
    push 300
    push 0x42c80000                                     ; 100.0f
    push 0x00000000                                     ; 0.0f
    call CreatePlayer
    add esp, 20

    ; Add it to the scene
    push eax                                            
    push dword [Scene]
    call LL_Add
    add esp, 8

    call [RunEngine]
    push eax                                            ; Put return message on the stack

    ; Clean up scene
    mov ebx, [Scene]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; DeleteGameobject(&object)
    push dword [ebx + Node.content]                     ; Delete the gameobject
    call DeleteGameObject 
    add esp, 4                   

    .LoadNextNode:
    mov ebx, [ebx + Node.next]
    jmp .NextNode

    .FinishedList:
    ; Delete the scene
    push dword [Scene]                          
    call LL_Delete
    add esp, 4

    pop eax                                             ; Get message back from the stack

    call [CleanupEngine]

;
; Update()
;

Update:
    enter 0, 0

    ; Update the scene
    mov ebx, [Scene]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov esi, dword [ebx + Node.content]                 ; esi contains base address of data

    ; Update(&object)
    push dword [esi + Gameobject.objectData]
    call [esi + Gameobject.update]
    add esp, 4

    .LoadNextNode:
    mov ebx, [ebx + Node.next]
    jmp .NextNode

    .FinishedList:
    leave
    ret

;
; Render()
;

Render:
    enter 0, 0

    ; Render the scene
    mov ebx, [Scene]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov esi, dword [ebx + Node.content]                 ; esi contains base address of data

    ; Update(&object)
    push dword [esi + Gameobject.objectData]
    call [esi + Gameobject.render]
    add esp, 4

    .LoadNextNode:
    mov ebx, [ebx + Node.next]
    jmp .NextNode

    .FinishedList:

    ; Debug FPS
    call [CalculateFPS]
    push dword [formatDecimal]
    push eax
    call [DebugPrintValue]
    add esp, 8

    leave
    ret