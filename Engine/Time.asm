;-------------------------------------------------------------------------------------------------------------------
; Time module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
%define TARGET_FPS 60

section .data
PreviousTickCount dq 0
CurrentTickCount  dq 0
TickFrequency  dq 0
ElapsedSec dd 0 
CounterIncreasPerFrame dd 0
SecConversionConst dd 1000000.0

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

    mov eax, [TickFrequency]                            ; Calculate counter increase per frame
    mov edx, [TickFrequency+4]
    mov ecx, TARGET_FPS
    div ecx
    mov [CounterIncreasPerFrame], eax

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
    fdiv dword [SecConversionConst]                     ; Convert time to µs
    fstp dword [ElapsedSec]                             ; Save the float to elapsedSec

    mov eax, [CurrentTickCount]                         ; Update previous value
    mov [PreviousTickCount] , eax
    mov eax, [CurrentTickCount+4]
    mov [PreviousTickCount+4] , eax

    leave
    ret

;
; Calculate FPS
;
CalculateFPS:
    ; Local variables
    ; [ebp-4] Calculated FPS
    enter 4, 0

    fld1
    fdiv dword [ElapsedSec]
    fistp dword [ebp-4]
    mov eax, dword [ebp-4]                              ; Store result in eax

    leave
    ret

;
; LockFramerate
;

LockFramerate:
    enter 0, 0
    push ebx

    mov ebx, [CounterIncreasPerFrame]                   ; Calculate target tick count
    add ebx, [CurrentTickCount]

    .Stall:
    push CurrentTickCount                               ; Get current tick count
    call QueryPerformanceCounter

    cmp [CurrentTickCount], ebx
    jle .Stall

    .EndStall:
    pop ebx
    leave
    ret