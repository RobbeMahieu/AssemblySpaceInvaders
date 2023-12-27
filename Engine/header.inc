; Engine
global LoadEngine
export LoadEngine
global RunEngine
export RunEngine
global CleanupEngine
export CleanupEngine

; Memory
global MemoryAlloc
export MemoryAlloc
global MemoryFree
export MemoryFree

; Debug
global DebugValue
export DebugValue
global DebugPrintValue
export DebugPrintValue
global EnableDebug
export EnableDebug

global formatDecimal
export formatDecimal
global formatHex
export formatHex

; Graphics
global COLOR_BLACK
export COLOR_BLACK
global COLOR_WHITE
export COLOR_WHITE
global COLOR_RED
export COLOR_RED
global COLOR_GREEN
export COLOR_GREEN
global COLOR_BLUE
export COLOR_BLUE
global COLOR_CYAN
export COLOR_CYAN
global COLOR_MAGENTA
export COLOR_MAGENTA
global COLOR_YELLOW
export COLOR_YELLOW

global TEXT_JUSTIFY_LEFT
export TEXT_JUSTIFY_LEFT
global TEXT_JUSTIFY_RIGHT
export TEXT_JUSTIFY_RIGHT
global TEXT_JUSTIFY_TOP
export TEXT_JUSTIFY_TOP
global TEXT_JUSTIFY_BOTTOM
export TEXT_JUSTIFY_BOTTOM
global TEXT_JUSTIFY_CENTER
export TEXT_JUSTIFY_CENTER

global FillRectangle
export FillRectangle
global DrawString
export DrawString

; Input
global PRESS
export PRESS
global HOLD
export HOLD
global RELEASE
export RELEASE

global KEY_A
export KEY_A
global KEY_D
export KEY_D
global KEY_SPACE
export KEY_SPACE

global AddAction
export AddAction
global RemoveAction
export RemoveAction


; Linked List
global LL_Create
export LL_Create
global LL_Delete
export LL_Delete
global LL_Add
export LL_Add
global LL_Remove
export LL_Remove
global LL_ForEach
export LL_ForEach

; Time
global CalculateFPS
export CalculateFPS
global GetElapsed
export GetElapsed

; Physics
global CreateHitbox
export CreateHitbox
global DeleteHitbox
export DeleteHitbox
global SetHitboxBounds
export SetHitboxBounds

; Scene
global CreateScene
export CreateScene
global DeleteScene
export DeleteScene
global UpdateScene
export UpdateScene
global RenderScene
export RenderScene

global CreateGameObject
export CreateGameObject
global DeleteGameObject
export DeleteGameObject

; Textbox
global CreateTextbox
export CreateTextbox
global DestroyTextbox
export DestroyTextbox
global SetTextboxBounds
export SetTextboxBounds
global SetTextboxText
export SetTextboxText
global TextboxRender
export TextboxRender