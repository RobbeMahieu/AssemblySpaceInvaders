SET BUILD_FOLDER=%~p0Build
SET ENGINE_FOLDER=%~p0Engine
SET GAME_FOLDER=%~p0Game

rd /S /q %BUILD_FOLDER%
mkdir %BUILD_FOLDER%

cd %ENGINE_FOLDER%
nasm -fwin32 AssemblyGame.asm -o %BUILD_FOLDER%\AssemblyGame.obj

cd %BUILD_FOLDER%
GoLink AssemblyGame.obj user32.dll kernel32.dll

AssemblyGame.exe

PAUSE