;-------------------------------------------------------------------------------------------------------------------
; File module - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Includes
%include "windows.inc"

; Constants and Data

;-------------------------------------------------------------------------------------------------------------------
section .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

;
; ReadFromFile(&path, &buffer, length)
; [ebp+8] path
; [ebp+12] buffer
; [ebp+16] length
;

ReadFromFile:
    ; Local variables
    ; [ebp-4] bytesRead
    enter 4, 0
    push ebx

    ; CreateFileA(&path, access, sharemode, security, disposition, flags, template) ; Get the file handle
    push 0
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_ALWAYS
    push 0
    push 0
    push GENERIC_READ + GENERIC_WRITE
    push dword [ebp+8]
    call CreateFileA
    mov ebx, eax                                        ; Store the file handle

    lea eax, [ebp-4]

    ; ReadFile(fileHandle, &buffer, length, bytesRead, overlap)     ; Read from the file
    push 0
    push eax
    push dword [ebp+16]
    push dword [ebp+12]
    push ebx
    call ReadFile

    ; CloseHandle(handle)                               ; Close the file again
    push ebx
    call CloseHandle

    pop ebx
    leave
    ret

;
; WriteToFile(&path, &buffer, length)
; [ebp+8] path
; [ebp+12] buffer
; [ebp+16] length
;

WriteToFile:
    ; Local variables
    ; [ebp-4] bytesRead
    enter 4, 0
    push ebx

    ; CreateFileA(&path, access, sharemode, security, disposition, flags, template) ; Get the file handle
    push 0
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_ALWAYS
    push 0
    push 0
    push GENERIC_READ + GENERIC_WRITE
    push dword [ebp+8]
    call CreateFileA
    mov ebx, eax                                        ; Store the file handle

    lea eax, [ebp-4]

    ; WriteFile(fileHandle, &buffer, length, bytesRead, overlap)     ; Read from the file
    push 0
    push eax
    push dword [ebp+16]
    push dword [ebp+12]
    push ebx
    call WriteFile

    ; CloseHandle(handle)                               ; Close the file again
    push ebx
    call CloseHandle

    pop ebx
    leave
    ret