;-------------------------------------------------------------------------------------------------------------------
; Graphics module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
section .bss
HDC resd 1

; Predefined colors
%define COLOR_BLACK     0x00000000
%define COLOR_WHITE     0x00FFFFFF
%define COLOR_RED       0x000000FF
%define COLOR_GREEN     0x0000FF00
%define COLOR_BLUE      0x00FF0000
%define COLOR_CYAN      0x00FFFF00
%define COLOR_MAGENTA   0x00FF00FF
%define COLOR_YELLOW    0x0000FFFF

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

; DrawString(text, x, y, width, height, color)
; [ebp+8] text
; [ebp+12] x
; [ebp+16] y
; [ebp+20] width
; [ebp+24] height
; [ebp+28] color
DrawString:
    ; Local variables
    ; [ebp-16] RECT
    enter 16, 0
    push ebx

    ; Create rectangle
    lea ebx, [ebp-16]                                   ; Cache rect address

    mov eax, [ebp+12]
    mov [ebx+0], eax                                    ; Fill left

    add eax, [ebp+20]                                   ; Calculate right
    mov [ebx+8], eax                                    ; Fill right
    mov eax, [ebp+16]
    mov [ebx+4], eax                                    ; Fill top
    add eax, [ebp+24]                                   ; Calculate bottom
    mov [ebx+12], eax                                   ; Fill bottom

    ; SetTextColor(HDC, Color)
    push dword [ebp+28]
    push dword [HDC]
    call SetTextColor

    ; SetBkMode(HDC, mode)
    push TRANSPARENT
    push dword [HDC]
    call SetBkMode

    ; DrawText(HDC, text, length, rect, format)
    push 0
    push ebx
    push -1
    push dword [ebp+8]
    push dword [HDC]
    call DrawTextA

    pop ebx
    leave
    ret
