;-------------------------------------------------------------------------------------------------------------------
; Hitbox functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc Hitbox
    ; Owner
    .Owner:         resd 1

    ; Bounds
    .Xpos:          resd 1
    .Ypos:          resd 1
    .Width:         resd 1
    .Height:        resd 1

    ; Callbacks
    .OnHit:         resd 1
    .Layer:         resd 1
    .HitLayers:     resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateHitbox(x, y, width, height, &onHit, layer, hitLayers)
; [ebp+8] x
; [ebp+12] y
; [ebp+16] width
; [ebp+20] height
; [ebp+24] onHit
; [ebp+28] layer
; [ebp+32] hitlayers
;
; eax => return hitbox address
;

CreateHitbox:
    enter 0, 0
    push ebx

    ; MemoryAlloc(size)                                 ; Allocate memory
    push Hitbox_size
    call MemoryAlloc
    add esp, 4
    mov ebx, eax                                        ; Cache address in ebx

    ; SetHitboxBounds(&object, x, y, width, height)     ; Fill in the bounds
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    push ebx
    call SetHitboxBounds
    add esp, 20

    ; Fill in other fields
    mov edx, [ebp+24]                                   ; onHit
    mov [ebx + Hitbox.OnHit], edx
    mov edx, [ebp+28]                                   ; layer
    mov [ebx + Hitbox.Layer], edx
    mov edx, [ebp+32]                                   ; hitLayers
    mov [ebx + Hitbox.HitLayers], edx

    ; RegisterHitbox(&hitbox)                           ; Add it to the physics objects
    push ebx
    call RegisterHitbox
    add esp, 4

    mov eax, ebx                                        ; Store address back in eax

    pop ebx
    leave
    ret

;
; DeleteHitbox(&hitbox)
; [ebp+8] hitbox
;

DeleteHitbox:
    enter 0, 0

    ; UnregisterHitbox(&hitbox)                        ; Remove it from the physics objects
    push dword [ebp+8]
    call UnregisterHitbox
    add esp, 4
    
    leave
    ret

;
; SetHitboxBounds(&hitbox, x, y, width, height)
; [ebp+8] hitbox
; [ebp+12] x
; [ebp+16] y
; [ebp+20] width
; [ebp+24] height
;

SetHitboxBounds:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Cache hitbox in eax

    ; Update the fields
    mov edx, [ebp+12]                                   ; Xpos
    mov [eax + Hitbox.Xpos], edx
    mov edx, [ebp+16]                                   ; Ypos
    mov [eax + Hitbox.Ypos], edx
    mov edx, [ebp+20]                                   ; Width
    mov [eax + Hitbox.Width], edx
    mov edx, [ebp+24]                                   ; Height
    mov [eax + Hitbox.Height], edx

    leave
    ret