;-------------------------------------------------------------------------------------------------------------------
; Assembly Game - (c) Robbe Mahieu
; 
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

CPU x64                                                 ; Limit instructions to only x64 instructions

; Includes
%include "windows.inc" 

; Constants and Data

WindowWidth equ 640                                     ; Window width constant
WindowHeight equ 480                                    ; Window height constant

SECTION .data

ClassName db "WindowClass", 0                           ; Window class name
AppName db "Assembly Game", 0                           ; Window title

SECTION .bss

hInstance resd 1                                        ; Instance handle
CommandLine resd 1                                      ; Pointer to the launching cmd

;-------------------------------------------------------------------------------------------------------------------
SECTION .text                                           ; Program start
;-------------------------------------------------------------------------------------------------------------------

global START
START:
    push 0                                              ; Get instance handle of our app (0 = this)
    call [GetModuleHandleA]                             ; Return value in eax
    mov [hInstance], eax                                ; cache return value to hInstance

    call [GetCommandLineA]                              ; Get command line pointer in eax
    mov [CommandLine], eax                              ; cache the value to CommandLine

    ; Call WinMain(hInstance, 0, CommandLine, SW_SHOWDEFAULT)
    push SW_SHOWDEFAULT
    push dword [CommandLine]
    push 0
    push dword [hInstance]
    call WinMain
    add esp, 16                                         ; Clear parameters from stack

    ; Put whatever WinMain returned on the stack and exit
    push eax
    call [ExitProcess]

;
; WinMain Function
;

WinMain:
    ; Reserve local variables
    ; [ebp-28] HWND
    enter 4,0  

    ; Initialization
    call InitWindow

    CMP eax, 0                                          ; Check if window was successfully created
    JE .WinMainReturn                                   ; Failed
    mov [ebp-4], eax                                    ; Move the window handle to the local variable

    push dword [ebp-4]                                  ; Force update the window UpdateWindow(HWND)
    call [UpdateWindow]

    ; Update loop
    push dword [ebp-4]
    call UpdateLoop
    add esp, 4

    ; Cleanup
    .WinMainReturn:
    leave
    ret

;
; Init Window
;

InitWindow:
    ; Reserve local variables
    ; [ebp-48] WNDCLASSEX
    enter 48,0  
   
    ; Fill in WNDCLASSEX
    lea ebx, [ebp-48]                                   ; Load ebx with WNDCLASSEX struct address
    mov dword [ebx+00], WNDCLASSEX_SIZE                 ; Struct size
    mov dword [ebx+04], CS_HREDRAW + CS_VREDRAW         ; Window style
    mov dword [ebx+08], WndProc                         ; Windows message callback function
    mov dword [ebx+12], 0                               ; Extra class data
    mov dword [ebx+16], 0                               ; Extra window data
    mov dword [ebx+20], hInstance                       ; hInstance ref

    mov dword [ebx+32], 0                               ; Background color
    mov dword [ebx+36], 0                               ; App menu
    mov dword [ebx+40], ClassName                       ; Class Name

    push IDI_APPLICATION                                ; Load default icon
    push 0
    call [LoadIconA]
    mov [ebx+24], eax                                   ; Normal Icon handle
    mov [ebx+44], eax                                   ; Small Icon handle

    push IDC_ARROW                                      ; Load default cursor
    push 0
    call [LoadCursorA]

    mov [ebx+28], eax                                   ; Cursor

    push ebx                                            ; Register the window
    call [RegisterClassExA]                 

    ; CreateWindowEx(0, ClassName, Title, Window style, x, y, width, height, parentHandle, menuHandle, hInstance, NULL)
    push 0
    push hInstance
    push 0
    push 0
    push WindowHeight
    push WindowWidth
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push AppName
    push ClassName
    push 0
    call [CreateWindowExA]                              ; HWND in eax

    leave
    ret

;
; Update Loop
;

UpdateLoop:
    ; Reserve local variables
    ; [ebp-24] MSG
    enter 24, 0

    mov ecx, [esp+4]                                    ; Get HWND parameter
    lea ebx, [ebp-24]                                   ; Cache message address in ebx

    .PeekMessage:
    ; PeekMessage(MSG, HWND, 0, 0, remove msg)
    push PM_REMOVE
    push 0
    push 0
    push 0
    push ebx
    call [PeekMessageA]                                 ; Get message from the thread

    cmp eax, 0                                          ; Is there a message
    jz .GameLoop

    ; Decode message
    cmp dword [ebx+4], WM_QUIT                          ; Message == WM_QUIT => Done
    je .UpdateLoopRet

    push ebx                                            ; TranslateMessage(MSG)
    call [TranslateMessage]
    push ebx                                            ; DispatchMessage(MSG)
    call [DispatchMessageA]

    JMP .PeekMessage

    .GameLoop:
    NOP
    JMP .PeekMessage

    .UpdateLoopRet:                                  
    mov eax, [ebx+08]                                   ; Save msg.wParam to eax

    leave
    ret

;
; WndProc Function
; 

WndProc:
    enter 0, 0

    mov eax, [ebp+12]                                   ; Get second parameter
    CMP eax, WM_DESTROY
    JNE .NotWMDestroy                                    

    ; On WM_DESTROY
    PUSH 0;
    CALL [PostQuitMessage]
    XOR eax, eax

    leave
    ret

.NotWMDestroy:
    
    ; DefWindowProcA()
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+08]
    call [DefWindowProcA]

    leave
    ret