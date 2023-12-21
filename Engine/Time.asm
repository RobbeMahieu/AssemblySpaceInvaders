;-------------------------------------------------------------------------------------------------------------------
; Time module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
section .data
PreviousTickCount dq 0
CurrentTickCount  dq 0
TickFrequency  dq 0
ElapsedSec dd 0 

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; Init Time
;

InitTime:
    enter 0, 0

    push TickFrequency                                  ; Store high performance clock frequency
    call QueryPerformanceFrequency

    leave
    ret

;
; CalculateElapsedTime
; 

CalculateElapsedTime:
    enter 0, 0

    push CurrentTickCount                               ; Get current tick count
    call QueryPerformanceCounter

    mov eax, [CurrentTickCount]                         ; Store current ticks in edx:eax
    mov edx, [CurrentTickCount+4]

    mov esi, [PreviousTickCount]                        ; Store current ticks in esi:edi
    mov edi, [PreviousTickCount+4]

    sub eax, esi                                        ; Subtract 64 bit number
    sbb edx, edi                                        ; edx:eax contains difference

    mov ecx, 1000000                                    ; Store divisor in ecx
    mov edi, edx                                        ; Copy highest part to edi
    mul ecx                                             ; Convert lowest to µs
    mov esi, eax                                        ; Save part result
    mov eax, edi                                        ; Get ready highest part
    mov edi, edx                                        ; Save overflow
    mul ecx                                             ; Convert highest to µs
    add edi, edx                                        ; Add it to the overflow

    mov eax, esi                                        ; Store in correct registers for division
    mov edx, edi
    div dword[TickFrequency]                            ; Divide by frequency

    push eax                                            ; Load the time to float register 0
    fild dword [esp]
    add esp, 4  
    push ecx                                            ; Load divisor to float register 1
    fild dword [esp]
    add esp, 4
    fdiv st0, st1                                       ; Convert time to seconds
    fstp dword [ElapsedSec]                             ; Save the float to elapsedSec

    mov eax, [CurrentTickCount]                         ; Update previous value
    mov [PreviousTickCount] , eax
    mov eax, [CurrentTickCount+4]
    mov [PreviousTickCount+4] , eax

    leave
    ret