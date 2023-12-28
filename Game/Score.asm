;-------------------------------------------------------------------------------------------------------------------
; Score Functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "engine.inc"

; Constants and Data

struc Score
    ; Owner
    .Gameobject resd 1

    ; UI
    .Textbox      resd 1
endstruc

section .data
ScoreAmount dd 0
ScoreTextformat db "Score: %08d", 0

section .bss

ScoreTextBuffer resb 20

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------


;
; CreateScore(&scene, y, size)
; [ebp+8] scene
; [ebp+12] y
; [ebp+16] size
; 
; eax => Gameobject address
;

CreateScore:
    enter 0, 0
    push ebx

    push Score_size                                     ; Create Score struct
    call [MemoryAlloc]
    add esp, 4
    mov ebx, eax                   

    ; CreateGameobject(&scene, &data, &update, &render, &destroy)
    push ScoreDestroy
    push ScoreRender
    push ScoreUpdate
    push ebx
    push dword [ebp+8]
    call CreateGameObject
    add esp, 20
    mov dword [ebx + Score.Gameobject], eax             ; Cache gameobject address

    ; Additional Setup

    ; CreateTextbox(&text,x, y, width, height, color, size, justification)   ; Textbox
    push dword [TEXT_JUSTIFY_CENTER]
    push dword[ebp+16]
    push dword [COLOR_WHITE]
    push dword [ebp+16]
    push WindowWidth
    push dword [ebp+12]
    push 0
    push ScoreTextBuffer
    call CreateTextbox
    add esp, 32
    mov [ebx + Score.Textbox], eax                      ; Cache the textbox 

    push 0                                              ; Make sure the text is up to date
    call ScoreAdd
    add esp, 4

    mov eax, dword [ebx + Score.Gameobject]             ; Return gameobject address

    pop ebx
    leave
    ret

;
; ScoreUpdate(&object)
; [ebp+8] object
;

ScoreUpdate:
    enter 0, 0
    leave
    ret

;
; ScoreRender(&object)
; [ebp+8] object
;

ScoreRender:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; SetTextboxText(&object, &text)                    ; Update the text
    push ScoreTextBuffer        
    push dword [ebx + Score.Textbox]
    call SetTextboxText
    add esp, 8

    push dword [ebx + Score.Textbox]
    call TextboxRender
    add esp, 4

    pop ebx
    leave
    ret

;
; ScoreDestroy(&object)
; [ebp+8] object
;

ScoreDestroy:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; DestroyTextbox(&textbox)
    push dword [ebx + Score.Textbox]
    call DestroyTextbox
    add esp, 4

    pop ebx
    leave
    ret

;
; ScoreAdd(amount)
; [ebp+8] amount
;

ScoreAdd:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Cache the amount      
    add dword [ScoreAmount], eax                        ; Update the score

    ; wsprintfA(&string, &format, extra variables)      ; Update text string
    push dword [ScoreAmount]
    push ScoreTextformat
    push ScoreTextBuffer
    call wsprintfA
    add esp, 12       

    leave
    ret

;
; ScoreReset()
;

ScoreReset:
    enter 0, 0

    mov eax, dword [ScoreAmount]                        ; Negate the score
    neg eax

    ; ScoreAdd(amount)
    push eax                                            ; Substract it from the current score
    call ScoreAdd
    add esp, 4

    leave
    ret