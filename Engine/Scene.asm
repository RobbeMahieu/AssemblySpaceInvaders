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

    push DeleteGameObject
    push dword [ebp+8]
    call LL_ForEach
    add esp, 8

    ; Delete the scene
    push dword [ebp+8]                       
    call LL_Delete
    add esp, 4

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

    ; LL_Remove(&scene, &object, destroyObject)
    push 1
    push dword [ebp+12]
    push dword [ebp+8]
    call LL_Remove
    add esp, 12

    leave
    ret

;
; UpdateScene(&scene)
; [epb+8] scene
;

UpdateScene:
    enter 0, 0

    push UpdateGameObject
    push dword [ebp+8]
    call LL_ForEach
    add esp, 8

    leave
    ret

;
; RenderScene(&scene)
; [epb+8] scene
;

RenderScene:
    enter 0, 0

    push RenderGameObject
    push dword [ebp+8]
    call LL_ForEach
    add esp, 8

    leave
    ret