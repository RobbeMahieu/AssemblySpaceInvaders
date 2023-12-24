;-------------------------------------------------------------------------------------------------------------------
; Alien Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

AlienWidth equ 30
AlienHeight equ 25
AlienMoveDownCount equ 10
AlienSpeed equ 50

AlienOffset equ 15
AlienRows equ 5
AlienColumns equ 11

struc Alien
    .Xpos resd 1
    .Ypos resd 1
    .Width resd 1
    .Height resd 1
    .Speed resd 1
    .JumpTimer resd 1
    .MoveDownCounter resd 1
endstruc

section .data
AlienJumpTime dd 0x3f800000                             ; 1.0f
AlienJump dd 5

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateAlien(x, y)
; [ebp+8] x
; [ebp+12] y
; 
; eax => Gameobject address
;

CreateAlien:
    enter 0, 0
    push ebx
    push esi

    push Alien_size                                     ; Create Alien struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov dword [ebx + Alien.Width], AlienWidth           ; Width                                  
    mov dword [ebx + Alien.Height], AlienHeight         ; Height
    mov dword [ebx + Alien.JumpTimer], 0                ; JumpTimer
    mov dword [ebx + Alien.Speed], AlienSpeed           ; Speed

    mov eax, [ebp+8]                                    ; Xpos 
    mov dword [ebx + Alien.Xpos], eax
    fild dword [ebx + Alien.Xpos]                       ; Convert to float
    fstp dword [ebx + Alien.Xpos]                                  

    mov eax, [ebp+12]                                   ; Ypos 
    mov dword [ebx + Alien.Ypos], eax
    fild dword [ebx + Alien.Ypos]                       ; Convert to float
    fstp dword [ebx + Alien.Ypos]                              

    mov eax, AlienMoveDownCount                         ; Start at half (aliens start in the middle)
    shr eax, 1
    mov dword [ebx + Alien.MoveDownCounter], eax        ; MoveDownCounter

    ; CreateGameobject(&data, &update, &render, &destroy)
    push AlienDestroy
    push AlienRender
    push AlienUpdate
    push ebx
    call CreateGameObject
    add esp, 16

    pop esi
    pop ebx
    leave
    ret

;
; AlienUpdate(&object)
; [ebp+8] object
;

AlienUpdate:
    ; [ebp-4] float stack temporary
    enter 4, 0
    push ebx

    mov ebx, [ebp+8]                                    ; Cache object in ebx

    ; Sub elapsedSec to jumpTimer
    fld dword [ebx + Alien.JumpTimer]                   ; Load jump timer in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax

    fadd dword [ebp-4]                                  ; Add to the timer
    fstp dword [ebx + Alien.JumpTimer]                  ; Store the result
    
    ; Check jump condition
    fld dword [AlienJumpTime]                           ; Put jumptime in float stack
    fcomp dword [ebx + Alien.JumpTimer]                 ; JumpTime < Alien jumptimer?
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    ja .UpdateRet                                       ; I can finally compare now

    .Jump:
    fld dword [AlienJumpTime]                           ; Reset JumpTimer
    fsub dword [ebx + Alien.JumpTimer]
    fstp dword [ebx + Alien.JumpTimer] 

    ; Check if alien has to move down a row
    add dword [ebx + Alien.MoveDownCounter], 1          ; Increase MoveDownCounter
    cmp dword [ebx + Alien.MoveDownCounter], AlienMoveDownCount
    jle .NoRowDown

    .RowDown:
    mov dword [ebx + Alien.MoveDownCounter], 0          ; Reset counter

    mov dword [ebp-4], AlienOffset                      ; Update Ypos
    fild dword [ebp-4]
    fadd dword [ebx + Alien.Ypos]
    fstp dword [ebx + Alien.Ypos]
    
    neg dword [AlienJump]                               ; Invert Jump
    jmp .UpdateRet

    .NoRowDown:       
    fild dword [AlienJump]                              ; Update Xpos
    fadd dword [ebx + Alien.Xpos]
    fstp dword [ebx + Alien.Xpos]

    .UpdateRet:
    pop ebx
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
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; Convert to int
    fld dword [ebx + Alien.Xpos]
    fistp dword [ebp-4]
    fld dword [ebx + Alien.Ypos]
    fistp dword [ebp-8]

    ; FillRectangle(x, y, width, height, color)
    push dword [COLOR_WHITE]                                    
    push dword [ebx + Alien.Height]
    push dword [ebx + Alien.Width]
    push dword [ebp-8]
    push dword [ebp-4]
    call [FillRectangle]
    add esp, 20

    pop ebx
    leave
    ret

;
; AlienDestroy(&object)
; [ebp+8] object
;

AlienDestroy:
    enter 0, 0

    leave
    ret


;
; LayOutAlienGrid()
;

LayOutAlienGrid:
    ; Local variables
    ; [ebp-4] x offset
    ; [ebp-8] y offset
    ; [ebp-12] row
    ; [ebp-16] col
    ; [ebp-20] xpos
    ; [ebp-24] ypos
    enter 24, 0
    push ebx
    push esi

    ; Calculate starting X
    mov dword [ebp-4], AlienOffset                          ; Offset for one alien
    add dword [ebp-4], AlienWidth                           ; 1 space = alien + offset
    mov eax, AlienColumns                                   ; Total width of alien grid = cols * space
    mul dword [ebp-4]
    sub eax, AlienOffset                                    ; This is one offset too much (last one doesn't need it)
    mov ebx, WindowWidth                                    ; Substract this from the total width
    sub ebx, eax
    shr ebx, 1                                              ; And divide the leftover space by two => starting x

    ; Calculate starting Y
    mov dword [ebp-8], AlienOffset                          ; Offset for one alien
    add dword [ebp-8], AlienHeight                          ; 1 space = alien + offset
    mov esi, 50

    ; Loop to create the grid
    mov dword [ebp-12], 0                                   ; Reset row count
    mov dword [ebp-24], esi                                 ; Reset y pos
    .NewRow:

    mov dword [ebp-16], 0                                   ; Reset col count
    mov dword [ebp-20], ebx                                 ; Reset x pos
    .NewCol:

    ; CreateAlien(x, y)
    push dword [ebp-24]
    push dword [ebp-20]
    call CreateAlien
    add esp, 8

    mov eax, [ebp-4]                                        ; Increase x pos
    add [ebp-20], eax
    inc dword [ebp-16]                      
    cmp dword [ebp-16], AlienColumns
    jne .NewCol

    mov eax, [ebp-8]                                        ; Increase y pos
    add [ebp-24], eax
    inc dword [ebp-12]                      
    cmp dword [ebp-12], AlienRows
    jne .NewRow

    pop esi
    pop ebx
    leave
    ret