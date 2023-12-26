;-------------------------------------------------------------------------------------------------------------------
; Input module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data
PRESS equ 0
HOLD equ 1
RELEASE equ 2

KEY_A equ       30
KEY_D equ       32
KEY_SPACE equ   57

%define IN_KEYSTROKEMASK    0x00FF0000
%define IN_KEYSTROKESHIFT   16
%define IN_KEYSTATEMASK     0x80000000
%define IN_KEYSTATESHIFT    31
%define IN_REPEATCOUNTMASK  0x0000FFFF

section .bss
CurrentInputState resb 32
PreviousInputState resb 32
Actions resd 1

struc Action
    .keycode:       resd 1
    .state:         resd 1
    .callback:      resd 1
    .callbackData:  resd 1
endstruc

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Code
;-------------------------------------------------------------------------------------------------------------------

;
; InitInput()
;

InitInput:
    enter 0, 0

    ; Clear states
    mov dword [PreviousInputState], 0
    mov dword [PreviousInputState+4], 0
    mov dword [PreviousInputState+8], 0
    mov dword [PreviousInputState+12], 0
    mov dword [PreviousInputState+16], 0
    mov dword [PreviousInputState+20], 0
    mov dword [PreviousInputState+24], 0
    mov dword [PreviousInputState+28], 0

    mov dword [CurrentInputState], 0
    mov dword [CurrentInputState+4], 0
    mov dword [CurrentInputState+8], 0
    mov dword [CurrentInputState+12], 0
    mov dword [CurrentInputState+16], 0
    mov dword [CurrentInputState+20], 0
    mov dword [CurrentInputState+24], 0
    mov dword [CurrentInputState+28], 0

    ; Create actions linked list
    call LL_Create
    mov dword [Actions], eax

    leave
    ret

;
; CleanupInput()
;

CleanupInput:
    enter 0, 0

    push dword [Actions]                                ; LL_Delete(&list)
    call LL_Delete
    add esp, 4

    leave
    ret
;
; UpdateInput(Keystroke)
; [ebp+8] Keystroke
;

UpdateInput:
    enter 0, 0
    push ebx
    push edi

    ; Get repeat count
    mov eax, IN_REPEATCOUNTMASK
    and eax, [ebp+8]
    cmp eax, 1                                          ; Repeat more than once? Skip message
    jg .UpdateInputRet

    ; Get keystroke in eax
    mov eax, IN_KEYSTROKEMASK
    and eax, [ebp+8]
    shr eax, IN_KEYSTROKESHIFT                          ; Shift bits over

    ; Get state
    mov ecx, IN_KEYSTATEMASK
    and ecx, [ebp+8]
    shr ecx, IN_KEYSTATESHIFT                           ; Shift bits over
    xor ecx, 1                                          ; invert the pressed state (pressed = 1)

    ; Manipulate flags in correct position
    mov edi, 8                                          ; Get the correct byte
    div edi                                             ; eax / 8 => byte number is eax, offset in the byte is edx
    mov ebx, 1                                          ; Create bitmask

    .ShiftBits:                                         ; Put bits at correct position in byte
    cmp edx, 0
    jz .DoneShifting

    shl ecx, 1                                          ; Shift state
    shl ebx, 1                                          ; Shift mask

    sub edx, 1
    jmp .ShiftBits

    .DoneShifting:                                      ; Save the state
    lea edx, [CurrentInputState + eax]                  ; Store address

    xor ebx, 0xFFFFFFFF                                 ; Invert bitmask (keep everything but the bit)
    and dword [edx], ebx                                ; Unset bit
    or dword [edx], ecx                                 ; Set it to the new state

    .UpdateInputRet:
    pop edi
    pop ebx
    leave
    ret

;
; HandleInput()
;

HandleInput:
    ; Local variables
    ; [ebp-4] current keystate
    ; [ebp-8] previous keystate
    enter 8, 0
    push ebx
    push esi
    push edi

    ; Check all bound actions
    mov ebx, [Actions]
    mov ebx, [ebx + LinkedList.start]                   ; ebx contains base address of node

    .NextNode:
    cmp ebx, 0
    jz .FinishedList

    ; Load node
    mov esi, dword [ebx + Node.content]                 ; esi contains base address of data
    mov eax, dword[esi + Action.keycode]                ; eax contains keycode

    ; Manipulate state in correct position
    mov edi, 8                                          ; Get the correct byte
    mov edx, 0                                          ; Clear high dword
    div edi                                             ; eax / 8 => byte number is eax, offset in the byte is edx

    mov edi, [CurrentInputState + eax]                  ; edi contains current state
    mov ecx, [PreviousInputState + eax]                 ; ecx contains previous state

    .ShiftBits:                                         ; Put bits at correct position in byte
    cmp edx, 0
    jz .DoneShifting

    shr edi, 1                                       
    shr ecx, 1 

    sub edx, 1
    jmp .ShiftBits

    .DoneShifting:
    and edi, 1
    and ecx, 1
    mov [ebp-4], edi                                    ; Track current state
    mov [ebp-8], ecx                                    ; Track previous state

    lea edx, .StateCheck                                ; edx contains jump address
    mov ecx, dword[esi + Action.state]                  ; Jump address offset
    shl ecx, 1                                          ; Instructions are 2 bytes long, so double the offset
    add edx, ecx                                        ; Calculate correct address
    jmp edx

    .StateCheck:                                        ; Jump table
    jmp .Press
    jmp .Hold
    jmp .Release

    .Press:
    cmp dword [ebp-4], 1                                ; Pressed this state
    jne .LoadNextNode

    cmp dword [ebp-8], 0                                ; Pressed previous state
    jne .LoadNextNode
    je .ActionTriggered

    .Hold:
    cmp dword [ebp-4], 1                                ; Pressed this state
    jne .LoadNextNode

    cmp dword [ebp-8], 1                                ; Pressed previous state
    jne .LoadNextNode
    je .ActionTriggered

    .Release:
    cmp dword [ebp-4], 0                                ; Pressed this state
    jne .LoadNextNode

    cmp dword [ebp-8], 1                                ; Pressed previous state
    jne .LoadNextNode
    je .ActionTriggered

    .ActionTriggered:
    push dword [esi + Action.callbackData]
    call [esi + Action.callback]
    add esp, 4

    .LoadNextNode:
    mov ebx, [ebx + Node.next]

    jmp .NextNode

    .FinishedList:
    ; Update previous input to current input
    mov edx, [CurrentInputState]
    mov [PreviousInputState], edx
    mov edx, [CurrentInputState+4]
    mov [PreviousInputState+4], edx
    mov edx, [CurrentInputState+8]
    mov [PreviousInputState+8], edx
    mov edx, [CurrentInputState+12]
    mov [PreviousInputState+12], edx
    mov edx, [CurrentInputState+16]
    mov [PreviousInputState+16], edx
    mov edx, [CurrentInputState+20]
    mov [PreviousInputState+20], edx
    mov edx, [CurrentInputState+24]
    mov [PreviousInputState+24], edx
    mov edx, [CurrentInputState+28]
    mov [PreviousInputState+28], edx

    pop edi
    pop esi
    pop ebx
    leave
    ret

;
; AddAction(Keycode, state, &callback, &callbackData)
; [ebp+8] Keycode
; [ebp+12] Keystate
; [ebp+16] Callback
; [ebp+20] CallbackData
;

AddAction:
    enter 0, 0
    push ebx

    ; MemoryAlloc(size)                                 ; Create new action
    push Action_size
    call MemoryAlloc
    add esp, 4
    mov ebx, eax                                        ; Cache given memory address

    mov eax, [ebp+8]
    mov [ebx + Action.keycode], eax                     ; Fill in keycode
    mov eax, [ebp+12]
    mov [ebx + Action.state], eax                       ; Fill in state
    mov eax, [ebp+16]
    mov [ebx + Action.callback], eax                    ; Fill in callback
    mov eax, [ebp+20]
    mov [ebx + Action.callbackData], eax                ; Fill in callbackData

    ; LL_Add(&list, &data)                              ; Add it to the list
    push ebx
    push dword [Actions]
    call LL_Add
    add esp, 8

    mov eax, ebx

    pop ebx
    leave
    ret

;
; RemoveAction(&action)
; [ebp+8] action
;

RemoveAction:
    enter 0, 0
    push ebx

    mov ebx, [ebp+8]    

    ; LL_Remove(&list, &object)                         ; Remove it from the list
    push ebx
    push dword [Actions]
    call LL_Remove
    add esp, 8

    pop ebx
    leave
    ret