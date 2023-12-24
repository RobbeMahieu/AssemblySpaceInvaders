;-------------------------------------------------------------------------------------------------------------------
; Bullet Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

BulletWidth equ 7
BulletHeight equ 30

struc Bullet
    .Xpos resd 1
    .Ypos resd 1
    .Width resd 1
    .Height resd 1
    .Speed resd 1
    .Lifetime resd 1
    .Color resd 1
endstruc

section .data
BulletLifetime dd 5.0


;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateBullet(x, y, speed, color)
; [ebp+8] x
; [ebp+12] y
; [ebp+16] speed
; [ebp+20] color
; 
; eax => Gameobject address
;

CreateBullet:
    enter 0, 0
    push ebx
    push esi

    push Bullet_size                                    ; Create Bullet struct
    call [MemoryAlloc]
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Bullet.Width], BulletWidth         ; Width                                  
    mov dword [ebx + Bullet.Height], BulletHeight       ; Height
    mov dword [ebx + Bullet.Lifetime], BulletLifetime   ; Lifetime
    mov eax, [ebp+16]
    mov dword [ebx + Bullet.Speed], eax                 ; Speed
    mov eax, [ebp+20]
    mov dword [ebx + Bullet.Color], eax                 ; Speed

    mov eax, [ebp+8]                                    ; Xpos 
    mov dword [ebx + Bullet.Xpos], eax                               

    mov eax, [ebp+12]                                   ; Ypos 
    mov dword [ebx + Bullet.Ypos], eax                              

    ; CreateGameobject(&data, &update, &render, &destroy)
    push BulletDestroy
    push BulletRender
    push BulletUpdate
    push ebx
    call CreateGameObject
    add esp, 16

    pop esi
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
    fld dword [ebx + Bullet.Lifetime]                   ; Load jump timer in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax

    fsub dword [ebp-4]                                  ; Add to the timer
    fstp dword [ebx + Bullet.Lifetime]                  ; Store the result
    
    ; Check lifetime condition
    fld dword [ebx + Bullet.Lifetime]                   ; Put lifetime in float stack
    ftst                                                ; Lifetime < 0 ?
    ffreep st0                                          ; Clear float registers
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    ja .Despawn                                        ; I can finally compare now
    jbe .Move

    .Despawn:
    jmp .UpdateRet

    .Move:
    fild dword [ebx + Bullet.Speed]

    call [GetElapsed]                                       ; Get ElapsedSec
    mov [ebp-4], eax

    fmul dword [ebp-4]                                      ; Update Ypos
    fadd dword [ebx + Bullet.Ypos]
    fstp dword [ebx + Bullet.Ypos]

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
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [ebx + Bullet.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Bullet.Ypos]
    fistp dword [ebp-8]

    ; FillRectangle(x, y, width, height, color)
    push dword [ebx + Bullet.Color]                                    
    push dword [ebx + Bullet.Height]
    push dword [ebx + Bullet.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    call [FillRectangle]
    add esp, 20

    pop ebx
    leave
    ret

;
; BulletDestroy(&object)
; [ebp+8] object
;

BulletDestroy:
    enter 0, 0

    leave
    ret


