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
; [ebp+8] x
; [ebp+12] y
; [ebp+16] width
; [ebp+20] height
; [ebp+24] color
FillRectangle:
    ; Local variables
    ; [ebp-4] Brush
    ; [ebp-8] Pen
    ; [ebp-12] OldBrush
    ; [ebp-16] OldPen
    enter 16, 0

    ; CreateSolidBrush(color)
    push dword [ebp+24]
    call [CreateSolidBrush]
    mov [ebp-4], eax

    ; CreatePen(mode, thickness, color)
    push dword [ebp+24]
    push 1
    push PS_SOLID
    call [CreatePen]
    mov [ebp-8], eax

    ; SelectObject(DC, Object)                          ; Swap brush
    push dword [ebp-4]
    push dword [HDC]
    call [SelectObject]
    mov [ebp-12], eax

    ; SelectObject(DC, Object)                          ; Swap pen
    push dword [ebp-8]
    push dword [HDC]
    call [SelectObject]
    mov [ebp-16], eax

    mov eax, [ebp+8]
    add dword [ebp+16], eax                             ; Calculate right
    mov eax, [ebp+12]
    add dword [ebp+20], eax                             ; Calculate bottom

    ; Rectangle(HDC, left, top, right, bottom)          ; Draw Rectangle
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    push dword [HDC]
    call [Rectangle]

    ; SelectObject(DC, Object)                          ; Swap back brush
    push dword [ebp-12]
    push dword [HDC]
    call [SelectObject]

    ; SelectObject(DC, Object)                          ; Swap back pen
    push dword [ebp-16]
    push dword [HDC]
    call [SelectObject]

    ; Clean up temp objects
    push dword [ebp-4]                                  ; Delete brush
    call [DeleteObject]   
    push dword [ebp-8]                                  ; Delete pen
    call [DeleteObject]                                       

    leave
    ret