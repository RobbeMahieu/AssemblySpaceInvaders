;-------------------------------------------------------------------------------------------------------------------
; Linked List functions - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

struc LinkedList
    .start      resd 1
    .end        resd 1
    .count      resd 1
endstruc

struc Node
    .content:   resd 1
    .next:      resd 1
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

    ; LL_ForEach(&list, &callback)
    push DeleteNode                                     ; Deallocate leftover nodes
    push dword [ebp+8]
    call LL_ForEach
    add esp, 8

    ; MemoryFree(&object)                               ; Deallocate list
    push dword [ebp+8]
    call MemoryFree
    add esp, 4

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

;
; LL_Remove(&list, &object, destroyObject)
; [ebp+8] list
; [ebp+12] object
; [ebp+16] destroyObject
;

LL_Remove:
    enter 0, 0
    push ebx
    push esi
    push edi

    ; Find object in list
    mov edi, [ebp+8]                                    ; Cache list base address
    mov ebx, [edi + LinkedList.start]                   ; ebx contains base address of node
    mov esi, 0                                          ; esi contains previous node address

    .NextNode:
    cmp ebx, 0
    jz .Done                                            ; Element not in list

    ; Find node
    mov eax, [ebx + Node.content]                       ; Cache node object
    cmp eax, [ebp+12]
    je .FoundObject

    mov esi, ebx                                        ; Update previous node
    mov ebx, [ebx + Node.next]                          ; Cache next address
    jmp .NextNode

    .FoundObject:
    mov eax, [ebx + Node.next]                          ; Put next node address in eax
    sub dword [edi + LinkedList.count], 1               ; Decrease count

    cmp esi, 0                                          ; Is it the first node?
    jne .NotFirst

    .First:
    mov [edi + LinkedList.start], eax                   ; Update list start address 
    jmp .Continue   

    .NotFirst:
    mov [esi + Node.next], eax                          ; Update previous node address

    .Continue:
    cmp ebx, [edi + LinkedList.end]                     ; Is it the last node ?
    jne .NotEnd

    .End:
    mov [edi + LinkedList.end], esi                     ; Set previous node as end

    .NotEnd:
    cmp dword [ebp+16], 1
    jne .DestroyNode

    ; MemoryFree(&object)                               ; Deallocate data
    push dword [ebx + Node.content]
    call MemoryFree
    add esp, 4

    .DestroyNode:
    ; MemoryFree(&object)                               ; Deallocate node
    push ebx
    call MemoryFree
    add esp, 4

    .Done:
    pop edi
    pop esi
    pop ebx
    leave
    ret

;
; LL_DeleteNode(&node)
; [ebp+8] node
;

DeleteNode:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]

    ; MemoryFree(&object)                               ; Deallocate data
    push dword [ebx + Node.content]
    call MemoryFree
    add esp, 4

    ; MemoryFree(&object)                               ; Deallocate node
    push ebx
    call MemoryFree
    add esp, 4 

    pop ebx
    leave
    ret

;
; LL_ForEach(&list, &callback)
; [ebp+8] list
; [ebp+12] callback
;

LL_ForEach:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node data
    mov eax, dword [ebx + Node.content]                 ; eax contains base address of content
    mov ebx, [ebx + Node.next]                          ; Cache next address

    ; callback(&object)
    push eax
    call dword [ebp+12] 
    add esp, 4                   

    jmp .NextNode                                       ; Loop through all nodes

    .FinishedList:
    pop ebx
    leave
    ret

;
; LL_Random(&list)
; [ebp+8] list
;
; eax => data of random node
;

LL_Random:
    enter 0, 0
    push ebx

    mov eax, [ebp+8]
    mov ebx, [eax + LinkedList.start]                   ; ebx contains base address of node

    ; RandomInRange(min, exclusiveMax)                  ; Get random number between 0 and listcount
    push dword [eax + LinkedList.count]                 
    push 0
    call RandomInRange
    add esp, 8

    ; Get random node
    .NextNode:
    cmp eax, 0
    je .Done

    mov ebx, [ebx + Node.next]                          ; Cache next address
    dec eax
    jmp .NextNode

    .Done:
    mov eax, dword [ebx + Node.content]                 ; eax contains base address of content

    pop ebx
    leave
    ret