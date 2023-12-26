;-------------------------------------------------------------------------------------------------------------------
; Earth Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data
EarthHeight equ 75

struc Earth
    ; Owner
    .Gameobject resd 1

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
; CreateEarth(&scene)
; [ebp+8] scene
; 
; eax => Gameobject address
;

CreateEarth:
    enter 0, 0
    push ebx

    push Earth_size                                     ; Create Earth struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Earth.Width], WindowWidth          ; Width                                  
    mov dword [ebx + Earth.Height], EarthHeight         ; Height
    mov dword [ebx + Earth.Xpos], 0                     ; Xpos

    mov dword [ebx + Earth.Ypos], WindowHeight          ; Calculate Ypos
    sub dword [ebx + Earth.Ypos], EarthHeight          
    sub dword [ebx + Earth.Ypos], 20                    ; Offset (Also include top menu bar)
    fild dword [ebx + Earth.Ypos]                       ; Convert to float
    fstp dword [ebx + Earth.Ypos]                       ; Ypos                              

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push EarthDestroy
    push EarthRender
    push EarthUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Earth.Gameobject], eax             ; Cache gameobject address

    ; Additional Setup

    ; CreateHitbox(x, y, width, height, &onHit, &onHitting, &onHitEnd)  ; Add a hitbox
    push HL_ENEMY
    push HL_FRIENDLY
    push OnEarthReached
    push dword [ebx + Earth.Height]
    push dword [ebx + Earth.Width]
    push dword [ebx + Earth.Ypos]
    push dword [ebx + Earth.Xpos]
    call CreateHitbox
    add esp, 28
    mov dword [ebx + Earth.Hitbox], eax                 ; Store the hitbox address
    mov dword [eax + Hitbox.Owner], ebx                 ; Store owner in hitbox

    mov eax, dword [ebx + Earth.Gameobject]             ; Return gameobject address

    pop ebx
    leave
    ret

;
; EarthUpdate(&object)
; [ebp+8] object
;

EarthUpdate:
    enter 0, 0
    leave
    ret

;
; EarthRender(&object)
; [ebp+8] object
;

EarthRender:
    enter 0, 0
    leave
    ret

;
; EarthDestroy(&object)
; [ebp+8] object
;

EarthDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DeleteHitbox(&hitbox)
    push dword [ebx + Earth.Hitbox]
    call DeleteHitbox
    add esp, 4

    pop ebx
    leave
    ret

;
; OnEarthReached(&hitbox, &hitboxOther)
; [ebp+8] hitbox
; [ebp+12] hitboxOther
;

OnEarthReached:
    enter 0, 0
   
    push LOSE_SCENE
    call SwapScene
    add esp, 4

    leave
    ret
