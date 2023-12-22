;-------------------------------------------------------------------------------------------------------------------
; Linked List functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc LinkedList
    .start resd 1
    .end resd 1
    .count resd 1
endstruc

struc Node
    .content:   resd 1
    .next:     resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; LL_Create()
; 
; eax => address of the created list
;

LL_Create:
    enter 0, 0

    ; MemoryAlloc( size)                                ; Allocate memory
    push LinkedList_size
    call MemoryAlloc
    add esp, 4

    leave
    ret

;
; LL_Delete(&list)
; [ebp+8] list
;

LL_Delete:
    enter 0, 0
    push ebx
    push esi
    push edi

    mov esi, [ebp+8]                                    ; Cache list base address
    cmp dword [esi + LinkedList.count], 0               ; Check if there are elements to clear
    jz .ElementsCleared

    ; Remove elements
    mov edi, [esi + LinkedList.start]                   ; Get first node address

    .RemoveElement:
    mov ebx, [edi + Node.next]                          ; Cache the next address

    ; MemoryFree(&object)                               ; Deallocate data
    push dword [edi + Node.content]
    call MemoryFree
    add esp, 4

    ; MemoryFree(&object)                               ; Deallocate node
    push edi
    call MemoryFree
    add esp, 4

    cmp ebx, 0                                          ; If all elements are cleared
    jz .ElementsCleared

    mov edi, ebx                                        ; Cache the next node
    jmp .RemoveElement

    .ElementsCleared:
    ; MemoryFree(&object)                               ; Deallocate list
    push esi
    call MemoryFree
    add esp, 4

    pop edi
    pop esi
    pop ebx
    leave
    ret
;
; LL_Add(&list, &data)
; [ebp+8] list
; [ebp+12] data
;

LL_Add:
    enter 0, 0
    
    ; MemoryAlloc(size)                                 ; Create the node
    push Node_size
    call MemoryAlloc
    add esp, 4

    ; Fill in node data
    mov ecx, [ebp+12]                                   ; Cache data base address
    mov [eax + Node.content], ecx                       ; Store the data in the node

    ; Add it to the list
    mov edx, [ebp+8]                                    ; Cache list base address
    mov ecx, [edx + LinkedList.end]                     ; Cache ending address

    mov [edx + LinkedList.end], eax                     ; Update list ending address
    add dword [edx + LinkedList.count], 1               ; Increment count

    cmp dword [edx + LinkedList.count], 1
    je .Empty                                           ; Check if list is empty

    .NotEmpty:   
    mov [ecx + Node.next], eax                          ; Update last node address
    jmp .LL_AddRet

    .Empty:
    mov [edx + LinkedList.start], eax                   ; Update list start address
    jmp .LL_AddRet

    .LL_AddRet:
    leave
    ret