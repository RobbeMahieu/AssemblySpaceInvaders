;-------------------------------------------------------------------------------------------------------------------
; Bullet Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

BulletWidth equ     3
BulletHeight equ    21

struc Bullet
    ; Owner
    .Gameobject resd 1

    ; Bounds
    .Xpos       resd 1
    .Ypos       resd 1
    .Width      resd 1
    .Height     resd 1
    .Hitbox     resd 1

    ; Properties
    .Speed      resd 1
    .Lifetime   resd 1
    .Color      resd 1
endstruc

section .data

BulletLifetime dd 5.0

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateBullet(&scene, x, y, speed, color, layer, hitlayers)
; [ebp+8] scene
; [ebp+12] x
; [ebp+16] y
; [ebp+20] speed
; [ebp+24] color
; [ebp+28] layer
; [ebp+32] hitLayers
; 
; eax => Gameobject address
;

CreateBullet:
    enter 0, 0
    push ebx

    push Bullet_size                                    ; Create Bullet struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Bullet.Width], BulletWidth         ; Width                                  
    mov dword [ebx + Bullet.Height], BulletHeight       ; Height
    mov eax, dword [BulletLifetime]
    mov dword [ebx + Bullet.Lifetime], eax              ; Lifetime
    mov eax, [ebp+20]
    mov dword [ebx + Bullet.Speed], eax                 ; Speed
    mov eax, [ebp+24]
    mov dword [ebx + Bullet.Color], eax                 ; Speed

    ; Calculate xpos
    mov eax, dword [ebx + Bullet.Width]                 ; Width
    shr eax, 1                                          ; Divide by 2 
    mov dword [ebx + Bullet.Xpos], eax
    fld dword [ebp+12]                                  ; Load center xpos
    fisub dword [ebx + Bullet.Xpos]                     ; Substract half the width
    fstp dword [ebx + Bullet.Xpos]                      ; Store the calculated Xpos

    mov eax, [ebp+16]                                   ; Ypos 
    mov dword [ebx + Bullet.Ypos], eax                              

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push BulletDestroy
    push BulletRender
    push BulletUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20

    mov dword [ebx + Bullet.Gameobject], eax            ; Store reference to the owning gameobject

    ; CreateHitbox(x, y, width, height, &onHit, layer, hitLayers)  ; Add a hitbox
    push dword [ebp+32]
    push dword [ebp+28]
    push OnBulletHit
    push dword [ebx + Bullet.Height]
    push dword [ebx + Bullet.Width]
    push dword [ebx + Bullet.Ypos]
    push dword [ebx + Bullet.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Bullet.Hitbox], eax                ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Store owner in hitbox

    mov eax, [ebx + Bullet.Gameobject]                  ; Return gameobject address

    pop ebx
    leave
    ret

;
; BulletUpdate(&object)
; [ebp+8] object
;

BulletUpdate:
    ; [ebp-4] float stack temporary
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]                                    ; Cache object in ebx

    ; Sub elapsedSec from lifetime
    fld dword [ebx + Bullet.Lifetime]                   ; Load lifetime in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax

    fsub dword [ebp-4]                                  ; Substract from the timer
    fstp dword [ebx + Bullet.Lifetime]                  ; Store the result
    
    ; Check lifetime condition
    fld dword [ebx + Bullet.Lifetime]                   ; Put lifetime in float stack
    ftst                                                ; Lifetime < 0 ?
    ffreep st0                                          ; Clear float registers
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    jbe .Despawn                                        ; I can finally compare now
    ja .Move

    .Despawn:
    ; BulletDespawn(&bullet)
    push ebx
    call BulletDespawn
    add esp, 4
    jmp .UpdateRet

    .Move:
    fild dword [ebx + Bullet.Speed]

    call [GetElapsed]                                       ; Get ElapsedSec
    mov [ebp-4], eax

    fmul dword [ebp-4]                                      ; Update Ypos
    fadd dword [ebx + Bullet.Ypos]
    fstp dword [ebx + Bullet.Ypos]

    ; SetHitboxBounds(&hitbox, x, y, width, height)         ; Update HitboxPosition
    push dword [ebx + Bullet.Height]
    push dword [ebx + Bullet.Width]
    push dword [ebx + Bullet.Ypos]
    push dword [ebx + Bullet.Xpos]
    push dword [ebx + Bullet.Hitbox]
    call SetHitboxBounds
    add esp, 20

    .UpdateRet:
    pop ebx
    leave
    ret

;
; BulletRender(&object)
; [ebp+8] object
;

BulletRender:
    ; [ebp-4] XposInt
    ; [ebp-8] YposInt
    enter 8, 0

    mov eax, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [eax + Bullet.Xpos]
    fistp dword [ebp-4]
    fld dword [eax + Bullet.Ypos]
    fistp dword [ebp-8]

    ; FillRectangle(x, y, width, height, color)
    push dword [eax + Bullet.Color]                                    
    push dword [eax + Bullet.Height]
    push dword [eax + Bullet.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    call [FillRectangle]
    add esp, 20

    leave
    ret

;
; BulletDestroy(&object)
; [ebp+8] object
;

BulletDestroy:
    enter 0, 0

    mov eax, [ebp+8]

    ; DeleteHitbox(&hitbox)
    push dword [eax + Bullet.Hitbox]
    call DeleteHitbox
    add esp, 4

    leave
    ret

;
; BulletDespawn(&bullet)
; [ebp+8] bullet
;

BulletDespawn:
    enter 0, 0

    mov eax, [ebp+8]

    ; DestroyGameObject(&object)
    push dword [eax + Bullet.Gameobject]
    call DestroyGameObject
    add esp, 4

    leave
    ret

;
; OnBulletHit(&hitboxBullet, &hitboxOther)
; [ebp+8] hitboxBullet
; [ebp+12] hitboxOther
;

OnBulletHit:
    enter 0, 0

    mov eax, [ebp+8]   

    ; BulletDespawn(&bullet)
    push dword [eax + Hitbox.Owner] 
    call BulletDespawn
    add esp, 4

    leave
    ret