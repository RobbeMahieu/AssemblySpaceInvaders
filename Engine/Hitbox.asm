;-------------------------------------------------------------------------------------------------------------------
; Hitbox functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc Hitbox
    ; Bounds
    .Xpos:          resd 1
    .Ypos:          resd 1
    .Width:         resd 1
    .Height:        resd 1

    ; Callbacks
    .OnHit:         resd 1
    .OnHitting:     resd 1
    .OnHitEnd:      resd 1

    ; Layers
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateHitbox(x, y, width, height, &onHit, &onHitting, &onHitEnd)
; [ebp+8] x
; [ebp+12] y
; [ebp+16] width
; [ebp+20] height
; [ebp+24] onHit
; [ebp+28] onHitting
; [ebp+32] onHitEnd
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

    ; SetHitboxCallbacks(&hitbox, &onHit, &onHitting, &onHitEnd)   ; Fill in the callbacks
    push dword [ebp+32]
    push dword [ebp+28]
    push dword [ebp+24]
    push ebx
    call SetHitboxBounds
    add esp, 20

    pop ebx
    leave
    ret

;
; DeleteHitbox(&hitbox)
; [ebp+8] hitbox
;

DeleteHitbox:
    enter 0, 0

    ; MemoryFree(&object)                               ; Deallocate hitbox
    push dword [ebp+8]
    call MemoryFree
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

;
; SetHitboxCallbacks(&hitbox, &onHit, &onHitting, &onHitEnd)
; [ebp+8] hitbox
; [ebp+12] onHit
; [ebp+16] onHitting
; [ebp+20] onHitEnd
;

SetHitboxCallbacks:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Cache hitbox in eax

    ; Update the fields
    mov edx, [ebp+12]                                   ; onHit
    mov [eax + Hitbox.OnHit], edx
    mov edx, [ebp+16]                                   ; onHitting
    mov [eax + Hitbox.OnHitting], edx
    mov edx, [ebp+20]                                   ; onHitEnd
    mov [eax + Hitbox.OnHitEnd], edx

    leave
    ret