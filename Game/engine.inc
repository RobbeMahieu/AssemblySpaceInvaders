; Engine
extern LoadEngine
extern RunEngine
extern CleanupEngine

; Memory
extern MemoryAlloc
extern MemoryFree

; Debug
extern DebugValue
extern DebugPrintValue

extern formatDecimal
extern formatHex

; Graphics
extern COLOR_BLACK
extern COLOR_WHITE
extern COLOR_RED
extern COLOR_GREEN
extern COLOR_BLUE
extern COLOR_CYAN
extern COLOR_MAGENTA
extern COLOR_YELLOW

extern FillRectangle
extern DrawString

; Input
extern PRESS
extern HOLD
extern RELEASE

extern KEY_A
extern KEY_D
extern KEY_SPACE

extern AddAction

; Linked List
extern LL_Create
extern LL_Delete
extern LL_Add
extern LL_Remove

%define LinkedList.start 0
%define LinkedList.end 4
%define LinkedList.count 8

%define Node.content 0
%define Node.next 4

; Time
extern CalculateFPS
extern GetElapsed
