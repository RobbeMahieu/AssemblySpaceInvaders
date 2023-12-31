;-------------------------------------------------------------------------------------------------------------------
; Time module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
%define TARGET_FPS 69

section .data

PreviousTickCount dq 0
CurrentTickCount  dq 0
TickFrequency  dq 0
ElapsedSec dd 0 
CounterIncreasPerFrame dd 0

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
    mov edx, [TickFrequency+4]                          ; edx:eax contains frequency
    mov ecx, TARGET_FPS
    div ecx
    mov [CounterIncreasPerFrame], eax

    leave
    ret

;
; GetElapsed
;
GetElapsed:
    enter 0, 0

    mov eax, dword [ElapsedSec]

    leave
    ret

;
; CalculateElapsedTime
; 

CalculateElapsedTime:
    ; Local variables
    ; [ebp-4] float storage
    enter 4, 0
    push esi
    push edi

    push CurrentTickCount                               ; Get current tick count
    call QueryPerformanceCounter

    mov eax, [CurrentTickCount]                         ; Store current ticks in edx:eax
    mov edx, [CurrentTickCount+4]

    mov esi, [PreviousTickCount]                        ; Store previous ticks in esi:edi
    mov edi, [PreviousTickCount+4]

    sub eax, esi                                        ; Subtract 64 bit number
    sbb edx, edi                                        ; edx:eax contains difference

    cmp edx, 0
    je .DifferenceGood
    mov eax, 0xFFFFFFFF                                 ; Limit the max tick difference. Max difference is 0xFFFF FFFF / frequency 

    .DifferenceGood:
    mov dword [ebp-4], eax                                 
    fild dword [ebp-4]                                  ; Load the time to float register 0
    fidiv dword[TickFrequency]                          ; Convert time to seconds
    fstp dword [ElapsedSec]                             ; Save the float to elapsedSec

    mov eax, [CurrentTickCount]                         ; Update previous value
    mov [PreviousTickCount] , eax
    mov eax, [CurrentTickCount+4]
    mov [PreviousTickCount+4] , eax

    pop edi
    pop esi
    leave
    ret

;
; Calculate FPS
;
; eax => Calculated FPS
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

;
; RandomInRange(min, exclusiveMax)
; [ebp+8] min
; [ebp+12] max
;
; eax => randomNumber
;

RandomInRange:
    enter 0, 0

    mov eax, [CurrentTickCount]                     ; Get tickcount in edx:eax
    mov edx, [CurrentTickCount+4]
    mov ecx, [ebp+12]                               ; max in ecx
    sub ecx, [ebp+8]                                ; ecx contains max - min
    xor edx, edx                                    ; Zero edx for division
    div ecx                                         ; eax / ecx => remainder in edx
    add edx, [ebp+8]                                ; This is our random number
    mov eax, edx

    leave
    ret

;
; RandomInRangeContinous(min, exclusiveMax, precision)
; [ebp+8] min
; [ebp+12] max
; [ebp+16] precision
;
; eax => randomNumber
;

RandomInRangeContinous:
    ; Local variables
    ; [ebp-4] result
    enter 4, 0

    mov eax, [ebp+8]
    mul dword [ebp+16]
    mov ecx, eax                                        ; esi contains minimum*precision
                                          
    mov eax, [ebp+12]
    mul dword [ebp+16]
    mov edx, eax                                        ; edi contains maximum*precision

    ; RandomInRange(min, exclusiveMax)
    push edx
    push ecx
    call RandomInRange
    add esp, 8
    mov [ebp-4], eax                                    ; Random number

    fild dword [ebp-4]                                  ; Turn number into float
    fidiv dword [ebp+16]                                ; Divide back by precision
    fstp dword [ebp-4]
    mov eax, [ebp-4]                                    ; Set value as return value in eax

    leave
    ret