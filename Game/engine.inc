; Engine
extern LoadEngine
extern RunEngine
extern CleanupEngine

; Memory
extern MemoryAlloc
extern MemoryFree

; Debug
extern DebugValue
extern DebugString
extern DebugPrintValue
extern EnableDebug

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

extern TEXT_JUSTIFY_LEFT
extern TEXT_JUSTIFY_RIGHT
extern TEXT_JUSTIFY_TOP
extern TEXT_JUSTIFY_BOTTOM
extern TEXT_JUSTIFY_CENTER

extern FillRectangle
extern DrawString
extern LoadImage
extern DrawImage
extern DeleteImage

; Input
extern PRESS
extern HOLD
extern RELEASE

extern KEY_A
extern KEY_D
extern KEY_SPACE

extern AddAction
extern RemoveAction

; Linked List
extern LL_Create
extern LL_Delete
extern LL_Add
extern LL_Remove
extern LL_ForEach
extern LL_Random

%define LinkedList.start    0
%define LinkedList.end      4
%define LinkedList.count    8

%define Node.content        0
%define Node.next           4

; Time
extern CalculateFPS
extern GetElapsed
extern RandomInRange
extern RandomInRangeContinous

; Physics
extern CreateHitbox
extern DeleteHitbox
extern SetHitboxBounds

%define Hitbox.Owner        0
%define Hitbox.Xpos         4
%define Hitbox.Ypos         8
%define Hitbox.Width        12
%define Hitbox.Height       16
%define Hitbox.OnHit        20
%define Hitbox.Layer        24
%define Hitbox.HitLayers    28

%define C_HITLAYER_1    0x00000001
%define C_HITLAYER_2    0x00000002
%define C_HITLAYER_3    0x00000004
%define C_HITLAYER_4    0x00000008
%define C_HITLAYER_5    0x00000010
%define C_HITLAYER_6    0x00000020
%define C_HITLAYER_7    0x00000040
%define C_HITLAYER_8    0x00000080

; Scene
extern CreateScene
extern DeleteScene
extern UpdateScene
extern RenderScene

extern CreateGameObject
extern DestroyGameObject

%define Gameobject.scene        0
%define Gameobject.objectData   4
%define Gameobject.update       8
%define Gameobject.render       12
%define Gameobject.destroy      16
%define Gameobject.destroyFlag  20

; Textbox
extern CreateTextbox
extern DestroyTextbox
extern SetTextboxBounds
extern SetTextboxText
extern TextboxRender
extern wsprintfA

; File
extern ReadFromFile
extern WriteToFile