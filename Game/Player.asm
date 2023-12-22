;-------------------------------------------------------------------------------------------------------------------
; Player Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data
struc Player
    .Xpos resd 1
    .Ypos resd 1
    .Width resd 1
    .Height resd 1
    .Speed resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreatePlayer(x,y,width, height, speed)
; [ebp+8] x
; [ebp+12] y
; [ebp+16] width
; [ebp+20] height
; [ebp+24] speed
; 
; eax => Gameobject address
;

CreatePlayer:
    enter 0, 0
    push ebx

    push Player_size                                    ; Create player struct
    call [MemoryAlloc]
    mov ebx, eax

    ; Fill in fields
    mov eax, [ebp+8]                                    
    mov [ebx + Player.Xpos], eax                        ; Xpos
    mov eax, [ebp+12]                                    
    mov [ebx + Player.Ypos], eax                        ; Ypos
    mov eax, [ebp+16]                                    
    mov [ebx + Player.Width], eax                       ; Width
    mov eax, [ebp+20]                                    
    mov [ebx + Player.Height], eax                      ; Height
    mov eax, [ebp+24]                                    
    mov [ebx + Player.Speed], eax                       ; Speed

    ; CreateGameobject(&data, &update, &render, &destroy)
    push PlayerDestroy
    push PlayerRender
    push PlayerUpdate
    push ebx
    call CreateGameObject
    add esp, 16
    mov ebx, eax                                        ; Cache gameobject address

    ; Additional Setup
    push MoveLeft
    push dword [HOLD]
    push dword [KEY_A]
    ;call [AddAction]
    add esp, 12

    push MoveRight
    push dword [HOLD]
    push dword [KEY_D]
    ;call [AddAction]
    add esp, 12

    mov eax, ebx                                        ; Return gameobject address

    pop ebx
    leave
    ret

;
; PlayerUpdate(&object)
; [ebp+8] object
;

PlayerUpdate:
    enter 0, 0
    push ebx

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
    push dword [COLOR_CYAN]                                    
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