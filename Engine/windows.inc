%ifndef WINDOWS_INC
%define WINDOWS_INC

extern GetModuleHandleA
extern ExitProcess
extern LoadIconA
extern LoadCursorA
extern RegisterClassExA
extern UpdateWindow
extern GetMessageA
extern PeekMessageA
extern TranslateMessage
extern DispatchMessageA
extern PostQuitMessage
extern CreateWindowExA
extern DefWindowProcA  
extern MessageBoxA
extern CreateSolidBrush
extern CreatePen
extern Rectangle
extern DeleteObject
extern GetDC
extern ReleaseDC
extern GetClientRect
extern CreateCompatibleDC
extern CreateCompatibleBitmap
extern DeleteDC
extern SelectObject
extern BitBlt
extern wsprintfA
extern SetTextColor
extern CreateFontA
extern DrawTextA
extern LoadImageA
extern SetBkMode
extern GetProcessHeap
extern HeapAlloc
extern HeapFree
extern HeapSize
extern QueryPerformanceFrequency
extern QueryPerformanceCounter
extern CreateFileA
extern ReadFile
extern WriteFile
extern CloseHandle

%define WNDCLASSEX_SIZE     48

%define SW_SHOWDEFAULT      10

%define CS_HREDRAW          2
%define CS_VREDRAW          1

%define IDI_APPLICATION     32512
%define IDC_ARROW           32512

%define WS_OVERLAPPED       0x00000000
%define WS_CAPTION          0x00C00000
%define WS_SYSMENU          0x00080000
%define WS_THICKFRAME       0x00040000
%define WS_MINIMIZEBOX      0x00020000
%define WS_MAXIMIZEBOX      0x00010000
%define WS_VISIBLE          0x10000000
%define WS_OVERLAPPEDWINDOW	(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
%define WS_NORESIZE         (WS_OVERLAPPED | WS_SYSMENU | WS_CAPTION | WS_MINIMIZEBOX)

%define CW_USEDEFAULT       0x80000000

%define WM_DESTROY          0x0002
%define WM_QUIT             0x0012
%define WM_KEYDOWN          0x0100
%define WM_SYSKEYDOWN       0x0104
%define WM_KEYUP            0x0101
%define WM_SYSKEYUP         0x0105

%define PM_REMOVE           1h

%define SRCCOPY             0x00CC0020
%define BLACKNESS           0x00000042
%define TRANSPARENT         1
%define OPAQUE              2

%define PS_SOLID            0

%define DT_LEFT             0x00000000
%define DT_TOP              0x00000000       
%define DT_CENTER           0x00000001
%define DT_RIGHT            0x00000002
%define DT_BOTTOM           0x00000008

%define IMAGE_BITMAP        0x00000000
%define LR_LOADFROMFILE     0x00000010

%define HEAP_ZERO_MEMORY    0x00000008

%define MAX_PATH            260

%define FILE_ATTRIBUTE_NORMAL   0x00000080

%define OPEN_ALWAYS             0x00000004

%define GENERIC_READ            0x80000000
%define GENERIC_WRITE           0x40000000

; Include guard
%endif  