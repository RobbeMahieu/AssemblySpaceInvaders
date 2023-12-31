;-------------------------------------------------------------------------------------------------------------------
; Memory module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

section .data

HeapAllocatedSize dd 0
MemoryLeakMessage dd "Memory Leak detected!", 0

section .bss

Heap resd 1                                             ; Heap handle

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; InitMemory
;

InitMemory:
    enter 0, 0

    call GetProcessHeap                                 ; Get the heap handle
    mov [Heap], eax

    leave
    ret

;
; MemoryAlloc(size)
; [ebp+8] size
;
; eax => address to the memory
;

MemoryAlloc:
    enter 0, 0

    mov eax, [ebp+8]                                    ; Increase allocated size
    add dword [HeapAllocatedSize], eax

    ; HeapAlloc(Heap, settings, size)                   ; Allocate memory
    push dword [ebp+8]
    push HEAP_ZERO_MEMORY
    push dword [Heap]
    call HeapAlloc

    leave
    ret

;
; MemoryFree(&object)
; [ebp+8] object
;

MemoryFree:
    enter 0, 0

    push dword [ebp+8]
    push 0
    push dword [Heap]
    call HeapSize

    sub dword [HeapAllocatedSize], eax                  ; Decrease allocated size

    ; HeapFree(Heap, settings, object)                  ; Deallocate memory
    push dword [ebp+8]
    push 0
    push dword [Heap]
    call HeapFree                                 
    
    leave
    ret

;
; CleanupMemory()
;

CleanupMemory:
    enter 0, 0

    cmp dword [HeapAllocatedSize], 0
    je .Done

    ; DebugString(&string)
    push MemoryLeakMessage                              ; Memory leaks detected!    
    call DebugString
    add esp, 4

    ; DebugValue(format, value)
    push formatDecimal                                  ; Memory leak amount
    push dword [HeapAllocatedSize]
    call DebugValue
    add esp, 8

    .Done:
    leave
    ret