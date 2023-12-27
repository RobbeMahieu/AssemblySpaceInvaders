;-------------------------------------------------------------------------------------------------------------------
; Alien Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

struc Alien
    ; Owner
    .Gameobject resd 1

    ; Image
    .Sprite     resd 1

    ; Bounds
    .Xpos resd 1
    .Ypos resd 1
    .Width resd 1
    .Height resd 1
    .Hitbox resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateAlien(&scene, x, y, &sprite)
; [ebp+8] scene
; [ebp+12] x
; [ebp+16] y
; [ebp+20] sprite
; 
; eax => Gameobject address
;

CreateAlien:
    enter 0, 0
    push ebx
    push esi

    push Alien_size                                     ; Create Alien struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Alien.Width], AlienWidth           ; Width                                  
    mov dword [ebx + Alien.Height], AlienHeight         ; Height
    mov eax, [ebp+20]                                   ; Sprite
    mov dword [ebx + Alien.Sprite], eax            

    mov eax, [ebp+12]                                   ; Xpos 
    mov dword [ebx + Alien.Xpos], eax
    fild dword [ebx + Alien.Xpos]                       ; Convert to float
    fstp dword [ebx + Alien.Xpos]                                

    mov eax, [ebp+16]                                   ; Ypos 
    mov dword [ebx + Alien.Ypos], eax
    fild dword [ebx + Alien.Ypos]                       ; Convert to float
    fstp dword [ebx + Alien.Ypos]                              

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push AlienDestroy
    push AlienRender
    push AlienUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Alien.Gameobject], eax             ; Cache gameobject address

    ; CreateHitbox(x, y, width, height, &onHit, layer, hitLayers)  ; Add a hitbox
    push HL_FRIENDLY
    push HL_ENEMY
    push 0
    push dword [ebx + Alien.Height]
    push dword [ebx + Alien.Width]
    push dword [ebx + Alien.Ypos]
    push dword [ebx + Alien.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Alien.Hitbox], eax                 ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Set reference to owner in hitbox

    ; LL_Add(&scene, &object)
    push ebx
    push dword [AlienList]
    call [LL_Add]
    add esp, 8

    mov eax, dword [ebx + Alien.Gameobject]             ; Return gameobject address

    pop esi
    pop ebx
    leave
    ret

;
; AlienUpdate(&object)
; [ebp+8] object
;

AlienUpdate:
    enter 0, 0
    leave
    ret

;
; AlienRender(&object)
; [ebp+8] object
;

AlienRender:
    ; [ebp-4] XposInt
    ; [ebp-8] YposInt
    enter 8, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [ebx + Alien.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Alien.Ypos]
    fistp dword [ebp-8]

    ; DrawImage(&image, x, y, width, height)
    push dword [ebx + Alien.Height]
    push dword [ebx + Alien.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    push dword [ebx + Alien.Sprite]
    call DrawImage
    add esp, 20

    pop ebx
    leave
    ret

;
; AlienDestroy(&object)
; [ebp+8] object
;

AlienDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DeleteHitbox(&hitbox)
    push dword [ebx + Alien.Hitbox]
    call DeleteHitbox
    add esp, 4

    ; LL_Remove(&scene, &object)
    push ebx
    push dword [AlienList]
    call [LL_Remove]
    add esp, 8

    pop ebx
    leave
    ret

;
; AlienJump(&object)
; [ebp+8] object
;

AlienJump:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    fild dword [AlienJumpDistance]                       ; Update Xpos
    fadd dword [ebx + Alien.Xpos]
    fstp dword [ebx + Alien.Xpos]

    pop ebx
    leave
    ret

;
; AlienMoveDown(&object)
; [ebp+8] object
;

AlienMoveDown:
    ; Local variables
    ; [ebp-4] temp float storage
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]

    mov dword [ebp-4], AlienOffset                      ; Update Ypos
    fild dword [ebp-4]
    fadd dword [ebx + Alien.Ypos]
    fstp dword [ebx + Alien.Ypos]

    pop ebx
    leave
    ret

;
; AlienUpdateHitbox(&object)
; [ebp+8] object
;

AlienUpdateHitbox:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; SetHitboxBounds(&hitbox, x, y, width, height)     ; Update HitboxPosition
    push dword [ebx + Alien.Height]
    push dword [ebx + Alien.Width]
    push dword [ebx + Alien.Ypos]
    push dword [ebx + Alien.Xpos]
    push dword [ebx + Alien.Hitbox]
    call SetHitboxBounds
    add esp, 20

    pop ebx
    leave
    ret