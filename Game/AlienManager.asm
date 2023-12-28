;-------------------------------------------------------------------------------------------------------------------
; Alien Manager Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

AlienWidth equ 36
AlienHeight equ 24
AlienMoveDownCount equ 9

AlienOffset equ 16
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

Alien1SpritePath db "Resources\Sprites\alien1.bmp", 0
Alien1Sprite dd 0
Alien2SpritePath db "Resources\Sprites\alien2.bmp", 0
Alien2Sprite dd 0
Alien3SpritePath db "Resources\Sprites\alien3.bmp", 0
Alien3Sprite dd 0

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

    push AlienManager_size                              ; Create AlienManager struct
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

    ; Load sprites
    push Alien1SpritePath
    call LoadImage
    add esp, 4
    mov dword [Alien1Sprite], eax

    push Alien2SpritePath
    call LoadImage
    add esp, 4
    mov dword [Alien2Sprite], eax

    push Alien3SpritePath
    call LoadImage
    add esp, 4
    mov dword [Alien3Sprite], eax

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

    ; Delete sprites
    push dword [Alien1Sprite]
    call DeleteImage
    add esp, 4

    push dword [Alien2Sprite]
    call DeleteImage
    add esp, 4

    push dword [Alien3Sprite]
    call DeleteImage
    add esp, 4

    ; LL_ForEach(&list, &callback)                      ; Delete leftover aliens
    push DeleteAlienFromManager
    push dword [AlienList]
    call LL_ForEach
    add esp, 8 

    ; Delete the list itself
    push dword [AlienList]
    call LL_Delete
    add esp, 4

    leave
    ret

;
; DeleteAlienFromManager(&alien)
; [ebp+8] alien
;

DeleteAlienFromManager:
    enter 0, 0

    ; LL_Remove(&scene, &object, destroyObject)
    push 0
    push dword [ebp+8]
    push dword [AlienList]
    call LL_Remove
    add esp, 12

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
    ; [ebp-28] jmp address
    enter 28, 0
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

    lea edx, .SwitchTable                                   ; edx contains jump address
    mov ecx, dword[ebp-12]                                  ; Jump address offset
    inc ecx                                                 ; First row should only appear once
    shr ecx, 1                                              ; I only want to change every 2 rows
    shl ecx, 1                                              ; Instructions are 2 bytes long, so double the offset
    add edx, ecx                                            ; Calculate correct address
    mov [ebp-28], edx

    .NewCol:
    jmp dword[ebp-28]                                       ; Create correct alien

    .SwitchTable:
    jmp .Alien1
    jmp .Alien2
    jmp .Alien3

    .Alien1:
    ; CreateAlien(&scene, x, y, &sprite)
    push dword [Alien1Sprite]
    push dword [ebp-24]
    push dword [ebp-20]
    push dword [ebp+8]
    call CreateAlien
    add esp, 16
    jmp .CreatedAlien

    .Alien2:
    ; CreateAlien(&scene, x, y, &sprite)
    push dword [Alien2Sprite]
    push dword [ebp-24]
    push dword [ebp-20]
    push dword [ebp+8]
    call CreateAlien
    add esp, 16
    jmp .CreatedAlien

    .Alien3:
    ; CreateAlien(&scene, x, y, &sprite)
    push dword [Alien3Sprite]
    push dword [ebp-24]
    push dword [ebp-20]
    push dword [ebp+8]
    call CreateAlien
    add esp, 16
    jmp .CreatedAlien

    .CreatedAlien:
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