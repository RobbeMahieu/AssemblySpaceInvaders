;-------------------------------------------------------------------------------------------------------------------
; Player Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data
PlayerSpeed equ 50                                      ; Speed

section .data
Xpos dd 0.0                                             ; Xpos
Ypos dd 100.0                                           ; Ypos
Width dd 300                                            ; Player width
Height dd 200                                           ; Player height

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; PlayerInit()
;

PlayerInit:
    enter 0, 0

    push MoveLeft
    push dword [HOLD]
    push dword [KEY_A]
    call [AddAction]
    add esp, 12

    push MoveRight
    push dword [HOLD]
    push dword [KEY_D]
    call [AddAction]
    add esp, 12

    leave
    ret

;
; PlayerUpdate()
;

PlayerUpdate:
    enter 0, 0

    leave
    ret

;
; PlayerRender()
;

PlayerRender:
    ; [ebp-4] XposInt
    ; [ebp-8] YposInt
    enter 8, 0

    fld dword [Xpos]
    fistp dword [ebp-4]
    fld dword [Ypos]
    fistp dword [ebp-8]

    push dword [COLOR_CYAN]                                    
    push dword [Height]
    push dword [Width]
    push dword [ebp-8]
    push dword [ebp-4]
    call [FillRectangle]
    add esp, 20

    leave
    ret

;
; PlayerDestroy()
;

PlayerDestroy:
    enter 0, 0

    leave
    ret

;
; MoveLeft()
;

MoveLeft:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0

    mov dword [ebp-4], -PlayerSpeed
    fild dword [ebp-4]

    call [GetElapsed]
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [Xpos]
    fstp dword [Xpos]

    leave
    ret

;
; MoveRight()
;

MoveRight:
    ; Local variables
    ; [ebp-4] Speed
    enter 4, 0

    mov dword [ebp-4], PlayerSpeed
    fild dword [ebp-4]

    call [GetElapsed]
    mov [ebp-4], eax

    fmul dword [ebp-4]
    fadd dword [Xpos]
    fstp dword [Xpos]

    leave
    ret