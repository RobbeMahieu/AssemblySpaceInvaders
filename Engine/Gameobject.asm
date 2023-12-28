;-------------------------------------------------------------------------------------------------------------------
; Gameobject Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc Gameobject
    .scene: resd 1
    .objectData: resd 1
    .update: resd 1
    .render: resd 1
    .destroy: resd 1
    .destroyFlag: resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateGameObject(&scene, &data, &update, &render, &destroy)
; [ebp+8] scene
; [ebp+12] data
; [ebp+16] update
; [ebp+20] render
; [ebp+24] destroy
;
; eax => Return address
;

CreateGameObject:
    enter 0, 0
    push ebx

    ; MemoryAlloc(size)                                 ; Get memory block
    push Gameobject_size
    call MemoryAlloc
    add esp, 4
    mov ebx, eax                                        ; Cache the address in ebx

    ; Fill in fields
    mov eax, [ebp+8]
    mov [ebx + Gameobject.scene], eax                   ; Link scene to gameobject
    mov eax, [ebp+12]                                    
    mov [ebx + Gameobject.objectData], eax              ; Link data to gameobject
    mov eax, [ebp+16]
    mov [ebx + Gameobject.update], eax                  ; Fill in update function
    mov eax, [ebp+20]
    mov [ebx + Gameobject.render], eax                  ; Fill in render function
    mov eax, [ebp+24]
    mov [ebx + Gameobject.destroy], eax                 ; Fill in destroy function
    mov dword [ebx + Gameobject.destroyFlag], 0         ; Clear destroyFlag

    ; AddGameObjectToScene(&scene, &gameobject)         ; Add it to the scene
    push ebx                                            
    push dword [ebp+8]
    call AddGameObjectToScene
    add esp, 8

    mov eax, ebx                                        ; Put address as return value

    pop ebx
    leave
    ret

;
; DeleteGameObject(&object)
; [ebp+8] object
;

DeleteGameObject:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]                                    ; Cache the object address

    ; Destroy(&object)                                  ; Call the destroy function              
    push dword [ebx + Gameobject.objectData]
    call [ebx + Gameobject.destroy]
    add esp, 4 

    ; MemoryFree(&object)                               ; Free the data
    push dword [ebx + Gameobject.objectData]
    call MemoryFree
    add esp, 4

    ; RemoveGameObjectFromScene(&scene, &gameobject)    ; Remove it from the scene
    push ebx
    push dword [ebx + Gameobject.scene]
    call RemoveGameObjectFromScene
    add esp, 8

    pop ebx
    leave
    ret

;
; UpdateGameObject(&object)
; [ebp+8] object
;

UpdateGameObject:
    enter 0, 0

    ; Update(&object)
    mov eax, [ebp+8]
    push dword [eax + Gameobject.objectData]
    call [eax + Gameobject.update]
    add esp, 4

    leave
    ret

;
; RenderGameObject(&object)
; [ebp+8] object
;

RenderGameObject:
    enter 0, 0

    ; Update(&object)
    mov eax, [ebp+8]
    push dword [eax + Gameobject.objectData]
    call [eax + Gameobject.render]
    add esp, 4

    leave
    ret

;
; DestroyGameObject(&gameObject)
; [ebp+8] gameobject
;

DestroyGameObject:
    enter 0, 0

    mov eax, [ebp+8]
    mov dword [eax + Gameobject.destroyFlag], 1         ; Set the destroyflag

    leave
    ret

;
; CheckedDeleteGameObject(&gameObject)
; [ebp+8] gameobject
;

CheckedDeleteGameObject:
    enter 0, 0

    mov eax, [ebp+8]
    cmp dword [eax + Gameobject.destroyFlag], 1         ; Set the destroyflag
    jne .Done

    push eax
    call DeleteGameObject
    add esp, 4

    .Done:
    leave
    ret