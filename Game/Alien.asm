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
    .Xpos       resd 1
    .Ypos       resd 1
    .Width      resd 1
    .Height     resd 1
    .Hitbox     resd 1

    ; Properties
    .Points     resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateAlien(&scene, x, y, width, height, points, &sprite)
; [ebp+8] scene
; [ebp+12] x
; [ebp+16] y
; [ebp+20] width
; [ebp+24] height
; [ebp+28] points
; [ebp+32] sprite
; 
; eax => Gameobject address
;

CreateAlien:
    enter 0, 0
    push ebx

    push Alien_size                                     ; Create Alien struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields   
    mov eax, [ebp+20]                                   ; Width
    mov dword [ebx + Alien.Width], eax              
    mov eax, [ebp+24]                                   ; Height
    mov dword [ebx + Alien.Height], eax         
    mov eax, [ebp+28]                                   ; Points
    mov dword [ebx + Alien.Points], eax 
    mov eax, [ebp+32]                                   ; Sprite
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
    push OnAlienHit
    push dword [ebx + Alien.Height]
    push dword [ebx + Alien.Width]
    push dword [ebx + Alien.Ypos]
    push dword [ebx + Alien.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Alien.Hitbox], eax                 ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Set reference to owner in hitbox

    ; AddAlienToManager(&alien)                         ; Add the alien to the manager
    push ebx
    call AddAlienToManager
    add esp, 4

    mov eax, dword [ebx + Alien.Gameobject]             ; Return gameobject address

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

    mov eax, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [eax + Alien.Xpos]
    fistp dword [ebp-4]
    fld dword [eax + Alien.Ypos]
    fistp dword [ebp-8]

    ; DrawImage(&image, x, y, width, height)
    push dword [eax + Alien.Height]
    push dword [eax + Alien.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    push dword [eax + Alien.Sprite]
    call DrawImage
    add esp, 20

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

    ; DeleteAlienFromManager(&alien)
    push ebx
    call DeleteAlienFromManager
    add esp, 4

    pop ebx
    leave
    ret

;
; AlienJump(&object)
; [ebp+8] object
;

AlienJump:
    enter 0, 0

    mov eax, [ebp+8]

    fild dword [AlienJumpDistance]                       ; Update Xpos
    fadd dword [eax + Alien.Xpos]
    fstp dword [eax + Alien.Xpos]

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

    mov eax, [ebp+8]

    mov dword [ebp-4], AlienOffset                      ; Update Ypos
    fild dword [ebp-4]
    fadd dword [eax + Alien.Ypos]
    fstp dword [eax + Alien.Ypos]

    leave
    ret

;
; AlienUpdateHitbox(&object)
; [ebp+8] object
;

AlienUpdateHitbox:
    enter 0, 0

    mov eax, [ebp+8]

    ; SetHitboxBounds(&hitbox, x, y, width, height)     ; Update HitboxPosition
    push dword [eax + Alien.Height]
    push dword [eax + Alien.Width]
    push dword [eax + Alien.Ypos]
    push dword [eax + Alien.Xpos]
    push dword [eax + Alien.Hitbox]
    call SetHitboxBounds
    add esp, 20

    leave
    ret

;
; OnAlienHit(&hitbox, &hitboxOther)
; [ebp+8] hitbox
; [ebp+12] hitboxOther
;
;

OnAlienHit:
    enter 0, 0
    push ebx

    mov eax, [ebp+8]
    mov ebx, [eax + Hitbox.Owner]

    ; ScoreAdd(amount)                                  ; Add the amount to the totalScore
    push dword [ebx + Alien.Points]
    call ScoreAdd
    add esp, 4   

    ; DestroyGameObject(&other)
    push dword [ebx + Alien.Gameobject] 
    call DestroyGameObject
    add esp, 4

    pop ebx
    leave
    ret

;
; AlienShoot(&alien)
; [ebp+8] alien
;

AlienShoot:
    ; Local variables
    ; [ebp-4] center x coord
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]

    ; Calculate xpos
    mov eax, dword [ebx + Alien.Width]                  ; Calculate Xpos
    shr eax, 1                                          ; divide by 2
    mov [ebp-4], eax                                         
    fild dword [ebp-4]                                  ; Convert to float
    fadd dword [ebx + Alien.Xpos]    
    fstp dword [ebp-4]                                  ; Bullet Xpos

    mov eax, [ebx + Alien.Gameobject]
    mov eax, [eax + Gameobject.scene]

    ; CreateBullet(&scene, x, y, speed, color, layer, hitLayers)
    push HL_FRIENDLY
    push HL_ENEMYPROJECTILE
    push dword [COLOR_WHITE]
    push AlienBulletSpeed
    push dword [ebx + Alien.Ypos] 
    push dword [ebp-4]
    push eax
    call CreateBullet
    add esp, 28

    .ShootRet:
    pop ebx
    leave
    ret