;-------------------------------------------------------------------------------------------------------------------
; Scene Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateScene()
;
; eax => return scene address
;

CreateScene:
    enter 0, 0

    call LL_Create

    leave
    ret

;
; DeleteScene(&scene)
; [ebp+8] scene
; 
;

DeleteScene:
    enter 0, 0
    push ebx

    ; Clean up scene
    mov ebx, [ebp+8]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node data
    mov eax, dword [ebx + Node.content]                 ; esi contains base address of gameobject
    mov ebx, [ebx + Node.next]                          ; Cache next address

    ; DeleteGameobject(&object)
    push eax                                            ; Delete the gameobject
    call DeleteGameObject 
    add esp, 4                   

    jmp .NextNode                                       ; Loop through all nodes

    .FinishedList:

    ; Delete the scene
    push dword [ebp+8]                       
    call LL_Delete
    add esp, 4

    pop ebx
    leave
    ret

;
; AddGameObjectToScene(&scene, &gameobject)
; [ebp+8] scene
; [ebp+12] gameobject
;

AddGameObjectToScene:
    enter 0, 0

    ; LL_Add(&list, &object)
    push dword [ebp+12]
    push dword [ebp+8]
    call LL_Add
    add esp, 8

    leave
    ret

;
; RemoveGameObjectFromScene(&scene, &gameobject)
; [ebp+8] scene
; [ebp+12] gameobject
;

RemoveGameObjectFromScene:
    enter 0, 0

    ; LL_Remove(&list, &object)
    push dword [ebp+12]
    push dword [ebp+8]
    call LL_Remove
    add esp, 8

    leave
    ret

;
; UpdateScene(&scene)
; [epb+8] scene
;

UpdateScene:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov eax, dword [ebx + Node.content]                 ; esi contains base address of data
    mov ebx, [ebx + Node.next]                          ; Cache next address

    ; Update(&object)
    push dword [eax + Gameobject.objectData]
    call [eax + Gameobject.update]
    add esp, 4

    jmp .NextNode                                       ; Loop through all nodes

    .FinishedList:

    pop ebx
    leave
    ret

;
; RenderScene(&scene)
; [epb+8] scene
;

RenderScene:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov eax, dword [ebx + Node.content]                 ; esi contains base address of data
    mov ebx, [ebx + Node.next]                          ; Cache next address

    ; Render(&object)
    push dword [eax + Gameobject.objectData]
    call [eax + Gameobject.render]
    add esp, 4

    jmp .NextNode                                       ; Loop through all nodes

    .FinishedList:

    pop ebx
    leave
    ret