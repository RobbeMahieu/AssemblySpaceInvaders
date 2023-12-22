;-------------------------------------------------------------------------------------------------------------------
; Gameobject Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

struc Gameobject
    .update: resd 1
    .render: resd 1
    .destroy: resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateGameObject(&init, &update, &render, &destroy)
; [ebp+8] init
; [ebp+12] update
; [ebp+16] render
; [ebp+20] destroy
;
; eax => Return address
;

CreateGameObject:
    enter 0, 0
    push ebx

    ; MemoryAlloc(size)                                 ; Get memory block
    push Gameobject_size
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax                                        ; Cache the address in ebx

    ; Fill in fields
    mov eax, [ebp+12]
    mov [ebx + Gameobject.update], eax                  ; Fill in update function
    mov eax, [ebp+16]
    mov [ebx + Gameobject.render], eax                  ; Fill in render function
    mov eax, [ebp+20]
    mov [ebx + Gameobject.destroy], eax                 ; Fill in destroy function

    call dword [ebp+8]                                  ; Initialize gameobject

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

    ; MemoryFree(&object)
    push dword [ebp+8]
    call [MemoryFree]
    add esp, 4

    leave
    ret