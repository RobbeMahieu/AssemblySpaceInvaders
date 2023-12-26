;-------------------------------------------------------------------------------------------------------------------
; Alien Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

AlienWidth equ 30
AlienHeight equ 25
AlienMoveDownCount equ 9

AlienOffset equ 15
AlienRows equ 5
AlienColumns equ 11

struc AlienManager
    ; Owner
    .Gameobject resd 1
endstruc

section .data
AlienJumpTime dd 0x3f000000                             ; 0.5f
AlienJumpTimer dd 0                                     ; 0.0f
AlienJumpDistance dd 5
AlienMoveDownCounter dd 0
AlienList dd 0                                          ; All aliens currently alive

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateAlienManager(&scene)
; [ebp+8] scene
; 
; eax => Gameobject address
;

CreateAlienManager:
    enter 0, 0
    push ebx

    push AlienManager_size                              ; Create Alien struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax

    ; Fill in fields                     
    mov eax, AlienMoveDownCount                         ; Start at half (aliens start in the middle)
    shr eax, 1
    inc eax                                             
    mov dword [AlienMoveDownCounter], eax               ; MoveDownCounter

    ; CreateGameobject(&render, &data, &update, &render, &destroy)
    push AlienManagerDestroy
    push AlienManagerRender
    push AlienManagerUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20

    ; Create alien list
    call LL_Create
    mov [AlienList], eax
    
    ; Spawn Aliens
    push dword [ebp+8]
    call LayOutAlienGrid
    add esp, 4

    pop ebx
    leave
    ret

;
; AlienManagerUpdate(&object)
; [ebp+8] object
;

AlienManagerUpdate:
    ; [ebp-4] float stack temporary
    enter 4, 0
    push ebx

    ; Sub elapsedSec to jumpTimer
    fld dword [AlienJumpTimer]                          ; Load jump timer in float stack
    call [GetElapsed]                                   ; Get ElapsedSec
    mov [ebp-4], eax

    fadd dword [ebp-4]                                  ; Add to the timer
    fstp dword [AlienJumpTimer]                         ; Store the result
    
    ; Check jump condition
    fld dword [AlienJumpTime]                           ; Put jumptime in float stack
    fcomp dword [AlienJumpTimer]                        ; JumpTime < Alien jumptimer?
    fstsw ax                                            ; Copy compare flags to ax (only 16 bit)
    fwait
    sahf                                                ; Transfer ax codes to status register
    ja .UpdateRet                                       ; I can finally compare now

    .Jump:
    fld dword [AlienJumpTime]                           ; Reset JumpTimer
    fsub dword [AlienJumpTimer]
    fstp dword [AlienJumpTimer] 

    ; Check if alien has to move down a row
    inc dword [AlienMoveDownCounter]                    ; Increase MoveDownCounter
    cmp dword [AlienMoveDownCounter], AlienMoveDownCount
    jle .NoRowDown

    .RowDown:
    mov dword [AlienMoveDownCounter], 0                 ; Reset counter
    neg dword [AlienJumpDistance]                       ; Invert Jump

    ; LL_ForEach(&list, &callback)
    push AlienMoveDown
    push dword [AlienList]
    call LL_ForEach
    add esp, 8

    jmp .UpdateHitbox

    .NoRowDown:
    ; LL_ForEach(&list, &callback)
    push AlienJump
    push dword [AlienList]
    call LL_ForEach
    add esp, 8       

    .UpdateHitbox:
    ; LL_ForEach(&list, &callback)
    push AlienUpdateHitbox
    push dword [AlienList]
    call LL_ForEach
    add esp, 8 

    .UpdateRet:
    pop ebx
    leave
    ret

;
; AlienRender(&object)
; [ebp+8] object
;

AlienManagerRender:
    enter 0, 0
    leave
    ret

;
; AlienManagerDestroy(&object)
; [ebp+8] object
;

AlienManagerDestroy:
    enter 0, 0
    leave
    ret

;
; LayOutAlienGrid(&scene)
; [ebp+8] scene
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

    ; CreateAlien(&scene, x, y)
    push dword [ebp-24]
    push dword [ebp-20]
    push dword [ebp+8]
    call CreateAlien
    add esp, 12

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

;
; CheckAliensLeft
;

CheckAliensLeft:
    enter 0, 0

    mov eax, [AlienList]
    cmp dword [eax + LinkedList.count], 0
    jne .StillAliens

    .AllAliensDied:
    push WIN_SCENE
    call SwapScene
    add esp, 4

    .StillAliens:
    leave
    ret