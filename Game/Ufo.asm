;-------------------------------------------------------------------------------------------------------------------
; Ufo Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

UfoSpeed equ 100
UfoPoints equ 200
UfoWidth equ 48
UfoHeight equ 32
UfoYpos equ 50

struc Ufo
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
    .Lifetime   resd 1
    .Speed      resd 1
endstruc

section .data

UfoImage db "Resources\Sprites\ufo.bmp", 0
UfoLifetime db 10.0

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateUfo(&scene)
; [ebp+8] scene
; 
; eax => Gameobject address
;

CreateUfo:
    enter 0, 0
    push ebx

    push Ufo_size                                       ; Create Ufo struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields   
    mov dword [ebx + Ufo.Width], UfoWidth              
    mov dword [ebx + Ufo.Height], UfoHeight         
    mov dword [ebx + Ufo.Points], UfoPoints  
    mov dword [ebx + Ufo.Speed], UfoSpeed              
    mov eax, dword [UfoLifetime]
    mov dword [ebx + Ufo.Lifetime], eax                 ; Lifetime

    mov dword [ebx + Ufo.Xpos], -UfoWidth               ; Xpos 
    fild dword [ebx + Ufo.Xpos]                         ; Convert to float
    fstp dword [ebx + Ufo.Xpos]                                

    mov dword [ebx + Ufo.Ypos], UfoYpos                 ; Ypos
    fild dword [ebx + Ufo.Ypos]                         ; Convert to float
    fstp dword [ebx + Ufo.Ypos]                              

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push UfoDestroy
    push UfoRender
    push UfoUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Ufo.Gameobject], eax             ; Cache gameobject address

    ; CreateHitbox(x, y, width, height, &onHit, layer, hitLayers)  ; Add a hitbox
    push HL_FRIENDLY
    push HL_ENEMY
    push OnUfoHit
    push dword [ebx + Ufo.Height]
    push dword [ebx + Ufo.Width]
    push dword [ebx + Ufo.Ypos]
    push dword [ebx + Ufo.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Ufo.Hitbox], eax                   ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Set reference to owner in hitbox

    ; LoadImage(&path)
    push UfoImage
    call LoadImage
    add esp, 4
    mov dword [ebx + Ufo.Sprite], eax

    mov eax, dword [ebx + Ufo.Gameobject]             ; Return gameobject address

    pop ebx
    leave
    ret

;
; UfoUpdate(&object)
; [ebp+8] object
;

UfoUpdate:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]

    ; Sub elapsedSec from lifetime
    fld dword [ebx + Ufo.Lifetime]                      ; Load lifetime in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax
    fsub dword [ebp-4]                                  ; Substract from the timer
    fstp dword [ebx + Ufo.Lifetime]                     ; Store the result
    
    ; Check lifetime condition
    fld dword [ebx + Ufo.Lifetime]                      ; Put lifetime in float stack
    ftst                                                ; Lifetime < 0 ?
    ffreep st0                                          ; Clear float registers
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    jbe .Despawn                                        ; I can finally compare now
    ja .Move

    .Despawn:
    ; DestroyGameObject(&object)
    push dword [ebx + Ufo.Gameobject]
    call DestroyGameObject
    add esp, 4
    jmp .UpdateRet

    .Move:
    ; Move to the right
    mov ebx, [ebp+8]                                        ; Object data in ebx

    call [GetElapsed]                                       ; Get ElapsedSec
    mov [ebp-4], eax

    fild dword [ebx + Ufo.Speed]                            ; Update Xpos
    fmul dword [ebp-4]
    fadd dword [ebx + Ufo.Xpos]
    fstp dword [ebx + Ufo.Xpos]

    push ebx                                                ; Update hitbox
    call UfoUpdateHitbox
    add esp, 4

    .UpdateRet:
    pop ebx
    leave
    ret

;
; UfoRender(&object)
; [ebp+8] object
;

UfoRender:
    ; [ebp-4] XposInt
    ; [ebp-8] YposInt
    enter 8, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [ebx + Ufo.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Ufo.Ypos]
    fistp dword [ebp-8]

    ; DrawImage(&image, x, y, width, height)
    push dword [ebx + Ufo.Height]
    push dword [ebx + Ufo.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    push dword [ebx + Ufo.Sprite]
    call DrawImage
    add esp, 20

    pop ebx
    leave
    ret

;
; UfoDestroy(&object)
; [ebp+8] object
;

UfoDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DeleteHitbox(&hitbox)
    push dword [ebx + Ufo.Hitbox]
    call DeleteHitbox
    add esp, 4

    ; DeleteImage(&path)
    push dword [ebx + Ufo.Sprite]
    call DeleteImage
    add esp, 4

    pop ebx
    leave
    ret

;
; UfoUpdateHitbox(&object)
; [ebp+8] object
;

UfoUpdateHitbox:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; SetHitboxBounds(&hitbox, x, y, width, height)     ; Update HitboxPosition
    push dword [ebx + Ufo.Height]
    push dword [ebx + Ufo.Width]
    push dword [ebx + Ufo.Ypos]
    push dword [ebx + Ufo.Xpos]
    push dword [ebx + Ufo.Hitbox]
    call SetHitboxBounds
    add esp, 20

    pop ebx
    leave
    ret

;
; OnUfoHit(&hitbox, &hitboxOther)
; [ebp+8] hitbox
; [ebp+12] hitboxOther
;

OnUfoHit:
    enter 0, 0
    push ebx

    mov eax, [ebp+8]
    mov ebx, [eax + Hitbox.Owner]

    ; ScoreAdd(amount)                                  ; Add the amount to the totalScore
    push dword [ebx + Ufo.Points]
    call ScoreAdd
    add esp, 4   

    ; DestroyGameObject(&object)
    push dword [ebx + Ufo.Gameobject] 
    call DestroyGameObject
    add esp, 4

    pop ebx
    leave
    ret