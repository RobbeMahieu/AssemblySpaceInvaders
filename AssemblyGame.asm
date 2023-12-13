;-------------------------------------------------------------------------------------------------------------------
; Assembly Game - (c) Robbe Mahieu
; nasm -fwin64 AssemblyGame.asm
; ld -o AssemblyGame.exe C:\Windows\System32\user32.dll C:\Windows\System32\kernel32.dll AssemblyGame.obj
;-------------------------------------------------------------------------------------------------------------------

; Compiler directives and includes

CPU x64                                                 ; Limit instructions to only x64 instructions

; Includes
extern GetModuleHandleA
extern GetCommandLineA
extern ExitProcess
extern LoadIconA
extern LoadCursorA
extern RegisterClassExA
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern PostQuitMessage
extern CreateWindowExA
extern DefWindowProcA

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

MainEntry:
    PUSH 0                                              ; Get instance handle of our app (0 = this)
    CALL [GetModuleHandleA]                             ; Return value in eax
    MOV dword [hInstance], eax                          ; cache return value to hInstance

    CALL [GetCommandLineA]                              ; Get command line pointer in eax
    MOV dword [CommandLine], eax                        ; cache the value to CommandLine

    ; Call WinMain(hInstance, 0, CommandLine, SW_SHOWDEFAULT)
    PUSH 10
    PUSH dword [CommandLine]
    PUSH 0
    PUSH dword [hInstance]
    CALL WinMain

    ; Put whatever WindowMain returned on the stack and exit
    PUSH eax
    CALL [ExitProcess]

;
; WinMain Function
;

WinMain:
    ; Reserve local variables
    ; [ebp-48] WNDCLASSEX
    ; [ebp-72] MSG
    ; [ebp-76] HWND
    enter 76,0  

    ; Load ebx with WNDCLASSEX struct address
    lea ebx, [ebp-48]

    ; Fill in WNDCLASSEX
    mov dword [ebx+00], 48                              ; Struct size
    mov dword [ebx+04], 3                               ; Window style
    mov dword [ebx+08], WndProc                         ; Windows message callback function
    mov dword [ebx+12], 0                               ; Extra class data
    mov dword [ebx+16], 0                               ; Extra window data

    mov eax, hInstance                                  ; Put window handle in eax
    mov dword [ebx+20], eax                             ; hInstance ref

    mov dword [ebx+32], 5 + 1                           ; Default brush color
    mov dword [ebx+36], 0                               ; App menu
    mov dword [ebx+40], ClassName                       ; Class Name

    push dword 32512                                    ; Load default icon
    push dword 0
    call [LoadIconA]
    mov dword [ebx+24], eax                             ; Normal Icon handle
    mov dword [ebx+44], eax                             ; Small Icon handle

    push dword 32512                                    ; Load default cursor
    push dword 0
    call [LoadCursorA]

    mov dword [ebx+28], eax                             ; Cursor

    push ebx                                            ; Register the window
    call [RegisterClassExA]                 

    ; CreateWindowEx(0, ClassName, Title, WS_OVERLAPPEDWINDOW, x, y, width, height, parentHandle, menuHandle, hInstance, NULL)
    push dword 0
    push dword hInstance
    push dword 0
    push dword 0
    push dword WindowHeight
    push dword WindowWidth
    push dword 0x80000000                               ; CW_USEDEFAULT
    push dword 0x80000000                               ; CW_USEDEFAULT
    push dword 0x00 | 0xC00000 | 0x80000 | 0x40000 | 0x20000 | 0x10000 | 0x10000000  ; WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push dword AppName
    push dword ClassName
    push dword 0
    call [CreateWindowExA]

    ; Check if window was successfully created
    CMP eax, 0
    JE WinMainRet                                       ; Failed

    mov dword [ebp-76], eax                             ; Move the window handle to the local variable

    ; Force update the window UpdateWindow(HWND)
    push dword [ebp-76]
    call [UpdateWindow]

MessageLoop:
    ; GetMessage(MSG, 0, 0, 0)
    push dword 0
    push dword 0
    push dword 0
    lea eax, [ebp-72]
    push eax
    call [GetMessageA]                                  ; Get message from the thread

    cmp eax, 0                                          ; Message == 0? Stop
    jz DoneMessages

    ; TranslateMessage(MSG)
    lea eax, [ebp-72]
    push eax
    call [TranslateMessage]

    ; DispatchMessage(MSG)
    lea eax, [ebp-72]
    push eax
    call [DispatchMessageA]

    JMP MessageLoop

DoneMessages:
    lea ebx, [ebp-72]                                   ; Save msg.wParam to eax   
    mov eax, dword [ebx+08]

WinMainRet:
    leave                                               ; Clear local variable
    ret

;
; WndProc Function
; 

WndProc:
    enter 0,0
    
    mov eax, dword [ebp+12]                             ; Get second parameter
    CMP eax, 2                                          ; Check if it's WM_DESTROY
    JNE NotWMDestroy                                    

    ; On WM_DESTROY
    PUSH 0;
    CALL [PostQuitMessage]
    XOR eax, eax

    leave
    ret

NotWMDestroy:
    
    ; DefWindowProcA()
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+08]
    call [DefWindowProcA]

    leave
    ret