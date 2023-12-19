;-------------------------------------------------------------------------------------------------------------------
; Graphics module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
section .bss
HDC resd 1

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

; FillRectangle(x, y, width, height, color)
FillRectangle:
    ; Local variables
    ; [ebp-4] Brush
    ; [ebp-8] Pen
    ; [ebp-12] OldBrush
    ; [ebp-16] OldPen
    enter 16, 0

    ; CreateSolidBrush(color)
    push dword [ebp+16]
    call CreateSolidBrush
    mov [ebp-4], eax

    ; CreatePen(mode, thickness, color)
    push dword [ebp+16]
    push 1
    push PS_SOLID
    call CreatePen
    mov [ebp-8], eax

    ; SelectObject(DC, Object)                          ; Swap brush
    push dword [ebp-4]
    push HDC
    call SelectObject
    mov [ebp-12], eax

    ; SelectObject(DC, Object)                          ; Swap pen
    push dword [ebp-8]
    push HDC
    call SelectObject
    mov [ebp-16], eax

    mov eax, [ebp]
    add dword [ebp+8], eax                              ; Calculate right
    mov eax, [ebp+4]
    add dword [ebp+12], eax                             ; Calculate bottom

    ; Rectangle(HDC, left, top, right, bottom)          ; Draw Rectangle
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [ebp+4]
    push dword [ebp]
    push HDC
    call Rectangle

    ; SelectObject(DC, Object)                          ; Swap back brush
    push dword [ebp-12]
    push HDC
    call SelectObject

    ; SelectObject(DC, Object)                          ; Swap back pen
    push dword [ebp-16]
    push HDC
    call SelectObject

    ; Clean up temp objects
    push dword [ebp-4]                                  ; Delete brush
    call DeleteObject   
    push dword [ebp-8]                                  ; Delete pen
    call DeleteObject                                       

    leave
    ret