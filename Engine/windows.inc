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

%define WNDCLASSEX_SIZE 48

%define CS_HREDRAW 2
%define CS_VREDRAW 1

%define IDI_APPLICATION 32512
%define IDC_ARROW 32512

%define WS_OVERLAPPED   0x00000000
%define WS_CAPTION      0x00C00000
%define WS_SYSMENU      0x00080000
%define WS_THICKFRAME   0x00040000
%define WS_MINIMIZEBOX  0x00020000
%define WS_MAXIMIZEBOX  0x00010000
%define WS_VISIBLE      0x10000000
%define WS_OVERLAPPEDWINDOW	(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)

%define CW_USEDEFAULT 0x80000000

%define WM_DESTROY 0x0002