;-------------------------------------------------------------------------------------------------------------------
; Linked List functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc LinkedList
    .start resd 1
    .count resd 1
    .end resd 1
endstruc

struc Node
    .content:   resd 1
    .next:     resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

; Return address of created list in eax
LL_Create:
    enter 0, 0

    ; Allocate memory
    push LinkedList_size
    push HEAP_ZERO_MEMORY
    push dword [Heap]
    call HeapAlloc                                      ; return address in eax

    leave
    ret

; LL_Delete(list)
; [ebp+8] list
LL_Delete:
    enter 0, 0
    push ebx
    push esi

    mov esi, [ebp+8]                                    ; Cache list base address
    cmp dword [esi + LinkedList.count], 0               ; Check if there are elements to clear
    jz .ElementsCleared

    ; Remove elements
    mov eax, [esi + LinkedList.start]                   ; Get first node address

    .RemoveElement:
    mov ebx, [eax + Node.next]                          ; Cache the next address

    ; Deallocate memory
    push eax
    push 0
    push dword [Heap]
    call HeapFree

    cmp ebx, 0                                          ; If all elements are cleared
    jz .ElementsCleared

    mov eax, ebx                                        ; Cache the next node
    jmp .RemoveElement

    .ElementsCleared:
    ; Deallocate memory
    push esi
    push 0
    push dword [Heap]
    call HeapFree

    pop esi
    pop ebx
    leave
    ret

; LL_Add(list, data)
; [ebp-8] list
; [ebp-12] data
LL_Add:
    enter 0, 0
    
    ; Create the node
    push Node_size
    push HEAP_ZERO_MEMORY
    push dword [Heap]
    call HeapAlloc                                      ; Return address in eax

    ; Fill in node data
    mov ecx, [ebp-12]                                   ; Cache data base address
    mov [eax + Node.content], ecx                          ; Store the data in the node

    ; Add it to the list
    mov edx, [ebp-8]                                    ; Cache list base address
    mov ecx, [edx + LinkedList.end]                     ; Cache ending address
    mov [edx + LinkedList.end], eax                     ; Update list ending address
    add dword [edx + LinkedList.count], 1                     ; Increment count

    cmp dword [edx + LinkedList.count], 0
    jz .Empty                                           ; Check if list is empty

    .NotEmpty:
    mov [ecx + Node.next], eax                          ; Update last node address
    jmp .LL_AddRet

    .Empty:
    mov [edx + LinkedList.start], eax                  ; Update list start address
    jmp .LL_AddRet

    .LL_AddRet:
    leave
    ret