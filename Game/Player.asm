;-------------------------------------------------------------------------------------------------------------------
; Player Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

PlayerWidth equ 50
PlayerHeight equ 20
PlayerStartSpeed equ 200
BulletStartBulletSpeed equ -200

struc Player
    ; Owner
    .Gameobject resd 1

    ; Bounds
    .Xpos resd 1
    .Ypos resd 1
    .Width resd 1
    .Height resd 1
    .Hitbox resd 1

    ; Speed
    .Speed resd 1

    ; Bullet
    .BulletSpeed resd 1
    .AccuBulletDelay resd 1

    ; Actions
    .MoveLeftAction resd 1
    .MoveRightAction resd 1
    .ShootAction resd 1

endstruc

section .data

BulletDelay dd 0.75

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreatePlayer(&scene)
; [ebp+8] scene
; 
; eax => Gameobject address
;

CreatePlayer:
    enter 0, 0
    push ebx

    push Player_size                                    ; Create player struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Player.Width], PlayerWidth         ; Width                                  
    mov dword [ebx + Player.Height], PlayerHeight       ; Height
    mov dword [ebx + Player.Speed], PlayerStartSpeed    ; Speed
    mov dword [ebx + Player.BulletSpeed], BulletStartBulletSpeed    ; Bullet speed
    mov dword [ebx + Player.AccuBulletDelay], 0         ; Accumulated bullet delay

    mov dword [ebx + Player.Xpos], WindowWidth          ; Calculate Xpos
    sub dword [ebx + Player.Xpos], PlayerWidth          
    shr dword [ebx + Player.Xpos], 1                    ; divide by 2
    fild dword [ebx + Player.Xpos]                      ; Convert to float
    fstp dword [ebx + Player.Xpos]                      ; Xpos                               

    mov dword [ebx + Player.Ypos], WindowHeight         ; Calculate Ypos
    sub dword [ebx + Player.Ypos], PlayerHeight          
    sub dword [ebx + Player.Ypos], 50                   ; Offset (Also include top menu bar)
    fild dword [ebx + Player.Ypos]                      ; Convert to float
    fstp dword [ebx + Player.Ypos]                      ; Ypos                              

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push PlayerDestroy
    push PlayerRender
    push PlayerUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Player.Gameobject], eax            ; Cache gameobject address

    ; Additional Setup

    ; CreateHitbox(x, y, width, height, &onHit, &onHitting, &onHitEnd)  ; Add a hitbox
    push 0
    push HL_FRIENDLY
    push 0
    push dword [ebx + Player.Height]
    push dword [ebx + Player.Width]
    push dword [ebx + Player.Ypos]
    push dword [ebx + Player.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Player.Hitbox], eax                ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Store owner in hitbox

    ; AddAction(key, state, callback, data)             ; Move left
    push ebx
    push MoveLeft
    push dword [HOLD]
    push dword [KEY_A]
    call [AddAction]
    add esp, 16
    mov dword [ebx + Player.MoveLeftAction], eax        ; Store the action address

    ; AddAction(key, state, callback, data)             ; Move right
    push ebx        
    push MoveRight
    push dword [HOLD]
    push dword [KEY_D]
    call [AddAction]
    add esp, 16
    mov dword [ebx + Player.MoveRightAction], eax       ; Store the action address

    ; AddAction(key, state, callback, data)             ; Shoot
    push ebx
    push Shoot
    push dword [PRESS]
    push dword [KEY_SPACE]
    call [AddAction]
    add esp, 16
    mov dword [ebx + Player.ShootAction], eax           ; Store the action address

    mov eax, dword [ebx + Player.Gameobject]            ; Return gameobject address

    pop ebx
    leave
    ret

;
; PlayerUpdate(&object)
; [ebp+8] object
;

PlayerUpdate:
    ; Local variables
    ; [ebp-4] temp float storage
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]

    ; Add elapsedSec to bulletDelay
    fld dword [ebx + Player.AccuBulletDelay]            ; Load jump timer in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax
    fadd dword [ebp-4]                                  ; Add to the timer
    fstp dword [ebx + Player.AccuBulletDelay]           ; Store the result

    ; Limit player range
    fld dword [ebx + Player.Xpos]                       ; Load Xpos in float stack
    ftst                                                ; Xpos < 0 ?
    ffreep st0                                          ; Clear float stack
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    jae .CheckRightSide                                 ; I can finally compare now

    .LimitLeftSide:
    mov dword [ebx + Player.Xpos], 0                    ; Xpos = 0

    .CheckRightSide: 
    fld dword [ebx + Player.Xpos]                       ; Load Xpos in float stack        
    mov dword [ebp-4], WindowWidth             
    fiadd dword [ebx + Player.Width]                    ; St0 = Xpos + width
    ficomp dword[ebp-4]                                 ; St0 > windowWidth ?
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    jbe .DoneLimit                                      ; I can finally compare now

    .LimitRightSide:
    fild dword[ebp-4] 
    fisub dword [ebx + Player.Width]
    fstp dword [ebx + Player.Xpos]                      ; Xpos = WindowWidth - playerWidth

    .DoneLimit:
    ; SetHitboxBounds(&hitbox, x, y, width, height)     ; Update HitboxPosition
    push dword [ebx + Player.Height]
    push dword [ebx + Player.Width]
    push dword [ebx + Player.Ypos]
    push dword [ebx + Player.Xpos]
    push dword [ebx + Player.Hitbox]
    call SetHitboxBounds
    add esp, 20

    pop ebx
    leave
    ret

;
; PlayerRender(&object)
; [ebp+8] object
;

PlayerRender:
    ; [ebp-4] XposInt
    ; [ebp-8] YposInt
    enter 8, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [ebx + Player.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Player.Ypos]
    fistp dword [ebp-8]

    ; FillRectangle(x, y, width, height, color)
    push dword [COLOR_GREEN]                                    
    push dword [ebx + Player.Height]
    push dword [ebx + Player.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    call [FillRectangle]
    add esp, 20

    pop ebx
    leave
    ret

;
; PlayerDestroy(&object)
; [ebp+8] object
;

PlayerDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DeleteHitbox(&hitbox)
    push dword [ebx + Player.Hitbox]
    call DeleteHitbox
    add esp, 4

    ; RemoveAction(&hitbox)                                 ; Delete move left action
    push dword [ebx + Player.MoveLeftAction]
    call RemoveAction
    add esp, 4

    ; RemoveAction(&hitbox)                                 ; Delete move right action
    push dword [ebx + Player.MoveRightAction]
    call RemoveAction
    add esp, 4

    ; RemoveAction(&hitbox)                                 ; Delete shoor action
    push dword [ebx + Player.ShootAction]
    call RemoveAction
    add esp, 4

    pop ebx
    leave
    ret

;
; MoveLeft(&object)
; [ebp+8] object
;

MoveLeft:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    fild dword [ebx + Player.Speed]
    fchs                                                    ; Invert Speed

    call [GetElapsed]                                       ; Get ElapsedSec
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [ebx + Player.Xpos]
    fstp dword [ebx + Player.Xpos]

    pop ebx
    leave
    ret

;
; MoveRight(&object)
; [ebp+8] object
;

MoveRight:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    fild dword [ebx + Player.Speed]

    call [GetElapsed]                                       ; Get ElapsedSec
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [ebx + Player.Xpos]
    fstp dword [ebx + Player.Xpos]

    pop ebx
    leave
    ret

;
; Shoot(&object)
; [ebp+8] object
;

Shoot:
    ; Local variables
    ; [ebp-4] temp float address
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]

    ; Check it delay has passed
    fld dword [ebx + Player.AccuBulletDelay]            ; Load accumulated time
    fcomp dword [BulletDelay]                           ; AccuBulletDelay > BulletDelay ?
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    jbe .ShootRet                                       ; I can finally compare now

    .CanShoot:
    mov dword [ebx + Player.AccuBulletDelay], 0         ; Reset Delay

    ; Calculate xpos
    mov eax, dword [ebx + Player.Width]                 ; Calculate Xpos
    shr eax, 1                                          ; divide by 2
    mov [ebp-4], eax                                         
    fild dword [ebp-4]                                  ; Convert to float
    fadd dword [ebx + Player.Xpos]    
    fstp dword [ebp-4]                                  ; Bullet Xpos    

    mov eax, [ebx + Player.Gameobject]
    mov eax, [ebx + Gameobject.scene]

    ; CreateBullet(&scene, x, y, speed, color)
    push dword [COLOR_GREEN]
    push dword [ebx + Player.BulletSpeed]
    push dword [ebx + Player.Ypos]
    push dword [ebp-4]
    push dword [eax]
    call CreateBullet
    add esp, 20

    .ShootRet:
    pop ebx
    leave
    ret