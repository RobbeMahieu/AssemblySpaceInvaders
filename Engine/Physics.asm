;-------------------------------------------------------------------------------------------------------------------
; Hitbox functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

section .bss
PhysicsObjects resd 1

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; InitPhysics()
;

InitPhysics:
    enter 0, 0

    ; Create list of physicsObjects
    call LL_Create
    mov dword [PhysicsObjects], eax

    leave
    ret

;
; CleanupPhysics()
;

CleanupPhysics:
    enter 0, 0

    ; LL_Delete(&list)                                  ; Clean up the rest of the physicsObjects
    push dword [PhysicsObjects]                                
    call LL_Delete
    add esp, 4

    leave
    ret

;
; RegisterHitbox(&hitbox)
; [ebp+8] hitbox
;

RegisterHitbox:
    enter 0, 0

    ; LL_Add(&list, &data)
    push dword [ebp+8]
    push dword [PhysicsObjects]
    call LL_Add
    add esp, 8

    leave
    ret

;
; UnregisterHitbox(&hitbox)
; [ebp+8] hitbox
;

UnregisterHitbox:
    enter 0, 0

    ; LL_Remove(&list, &data)
    push dword [ebp+8]
    push dword [PhysicsObjects]
    call LL_Remove
    add esp, 8

    leave
    ret

;
; HandlePhysics()
;

HandlePhysics:
    enter 0, 0

    leave
    ret