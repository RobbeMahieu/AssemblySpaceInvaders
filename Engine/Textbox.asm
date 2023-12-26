;-------------------------------------------------------------------------------------------------------------------
; Textbox functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc Textbox
    ; Owner
    .Owner:         resd 1

    ; Bounds
    .Xpos:          resd 1
    .Ypos:          resd 1
    .Width:         resd 1
    .Height:        resd 1

    ; Properties
    .TextString:    resd 1
    .Color:         resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; CreateTextbox(&text,x, y, width, height, color)
; [ebp+8] text
; [ebp+12] x
; [ebp+16] y
; [ebp+20] width
; [ebp+24] height
; [ebp+28] color
;
; eax => return Textbox address
;

CreateTextbox:
    enter 0, 0
    push ebx

    ; MemoryAlloc(size)                                 ; Allocate memory
    push Textbox_size
    call MemoryAlloc
    add esp, 4
    mov ebx, eax                                        ; Cache address in ebx

    ; SetTextboxBounds(&object, x, y, width, height)    ; Fill in the bounds
    push dword [ebp+24]
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push ebx
    call SetTextboxBounds
    add esp, 20

    ; Fill in other fields
    mov edx, [ebp+8]                                    ; Text
    mov [ebx + Textbox.TextString], edx
    mov edx, [ebp+28]                                   ; Color
    mov [ebx + Textbox.Color], edx

    mov eax, ebx                                        ; Store address back in eax

    pop ebx
    leave
    ret

;
; DestroyTextbox(&Textbox)
; [ebp+8] Textbox
;

DestroyTextbox:
    enter 0, 0    

    ; MemoryFree(&object)                               ; Free memory
    push dword [ebp+8]
    call MemoryFree
    add esp, 4 

    leave
    ret

;
; SetTextboxBounds(&Textbox, x, y, width, height)
; [ebp+8] Textbox
; [ebp+12] x
; [ebp+16] y
; [ebp+20] width
; [ebp+24] height
;

SetTextboxBounds:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Cache Textbox in eax

    ; Update the fields
    mov edx, [ebp+12]                                   ; Xpos
    mov [eax + Textbox.Xpos], edx
    mov edx, [ebp+16]                                   ; Ypos
    mov [eax + Textbox.Ypos], edx
    mov edx, [ebp+20]                                   ; Width
    mov [eax + Textbox.Width], edx
    mov edx, [ebp+24]                                   ; Height
    mov [eax + Textbox.Height], edx

    leave
    ret

;
; SetTextboxText(&object, &text)
; [ebp+8] object
; [ebp+12] text
;

SetTextboxText:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Cache Textbox in eax
    mov [eax + Textbox.TextString], edx

    leave
    ret

;
; TextboxRender(&object)
; [ebp+8] object
;

TextboxRender:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]                                        ; Object data in ebx

    ; DrawString(&text, x, y, width, height, color)
    push dword [ebx + Textbox.Color]                                    
    push dword [ebx + Textbox.Height]
    push dword [ebx + Textbox.Width]
    push dword [ebx + Textbox.Ypos]
    push dword [ebx + Textbox.Xpos]
    push dword [ebx + Textbox.TextString]
    call DrawString
    add esp, 24

    pop ebx
    leave
    ret