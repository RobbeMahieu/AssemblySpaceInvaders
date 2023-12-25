;-------------------------------------------------------------------------------------------------------------------
; Physics Module - (c) Robbe Mahieu
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
    push ebx
    push esi
    push edi

    mov ebx, [PhysicsObjects]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov edi, dword [ebx + Node.content]                 ; edi contains base address of data
    mov ebx, [ebx + Node.next]                          ; Cache next address

    ; Check collisions on this node
    mov esi, ebx                                        ; esi contains the next node address

    .NextOther:
    cmp esi, 0
    jz .NextNode

    ; Load node
    mov edx, dword [esi + Node.content]                 ; edx contains base address of data
    mov esi, [esi + Node.next]                          ; Cache next address

    ; RectCollision(&hitbox1, &hitbox2)
    push edx
    push edi
    call RectCollision
    add esp, 8

    jmp .NextOther                                       ; Loop through all nodes

    .FinishedList: 
    mov ebx, [PhysicsObjects]
    push formatDecimal
    push dword [ebx + LinkedList.count] 
    call DebugPrintValue
    add esp, 8

    pop edi
    pop esi   
    pop ebx
    leave
    ret

;
; RectCollision(&hitbox1, &hitbox2)
; [ebp+8] hitbox1
; [ebp+12] hitbox2
;

RectCollision:
    ; Local variables
    ; [ebp-4] XposInt1
    ; [ebp-8] YposInt2
    ; [ebp-12] XposInt2
    ; [ebp-16] YposInt2
    enter 16, 0
    push ebx
    push esi

    mov ebx, [ebp+8]                                    ; ebx contains hitbox1
    mov esi, [ebp+12]                                   ; esi contains hitbox2

    ; Convert float to int
    fld dword [ebx + Hitbox.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Hitbox.Ypos]
    fistp dword [ebp-8]
    fld dword [esi + Hitbox.Xpos]
    fistp dword [ebp-12]
    fld dword [esi + Hitbox.Ypos]
    fistp dword [ebp-16]

    ; Conditions
    mov eax, [ebp-4]                            
    add eax, [ebx + Hitbox.Width]
    cmp eax, [ebp-12]                                   ; X1 + Width < X2 => no collision
    jl .CollisionHandlingDone

    mov eax, [ebp-12]                            
    add eax, [esi + Hitbox.Width]
    cmp eax, [ebp-4]                                    ; X2 + Width < X1 => no collision
    jl .CollisionHandlingDone

    mov eax, [ebp-8]                            
    add eax, [ebx + Hitbox.Height]
    cmp eax, [ebp-16]                                   ; Y1 + Height < Y2 => no collision
    jl .CollisionHandlingDone

    mov eax, [ebp-16]                            
    add eax, [esi + Hitbox.Height]
    cmp eax, [ebp-8]                                    ; Y2 + Height < Y1 => no collision
    jl .CollisionHandlingDone

    .Collision:

    .OnHit:
    cmp dword [ebx + Hitbox.OnHit], 0
    je .OnHitOther

    call [ebp + Hitbox.OnHit]

    .OnHitOther:
    cmp dword [esi + Hitbox.OnHit], 0
    je .CollisionHandlingDone

    call [esi + Hitbox.OnHit]

    .CollisionHandlingDone:
    pop esi
    pop ebx
    leave
    ret