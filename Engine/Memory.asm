;-------------------------------------------------------------------------------------------------------------------
; Memory module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
 HEAP_ZERO_MEMORY equ 0x00000008

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

    ; HeapFree(Heap, settings, object)                  ; Deallocate memory
    push dword [ebp+8]
    push 0
    push dword [Heap]
    call HeapFree

    leave
    ret