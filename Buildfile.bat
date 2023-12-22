SET BUILD_FOLDER=%~p0Build
SET ENGINE_FOLDER=%~p0Engine
SET GAME_FOLDER=%~p0Game
SET PROJECT_NAME=SpaceInvaders
SET ENGINE_NAME=Engine


:: Build Engine
rd /S /q %BUILD_FOLDER%
mkdir %BUILD_FOLDER%

cd %ENGINE_FOLDER%
nasm -f win32 %ENGINE_NAME%.asm -o %BUILD_FOLDER%\%ENGINE_NAME%.obj   

cd %BUILD_FOLDER%
GoLink %ENGINE_NAME%.obj user32.dll kernel32.dll Gdi32.dll /dll

:: Build and Launch game

cd %GAME_FOLDER%
nasm -f win32 %PROJECT_NAME%.asm -o %BUILD_FOLDER%\%PROJECT_NAME%.obj   

cd %BUILD_FOLDER%
GoLink %PROJECT_NAME%.obj user32.dll kernel32.dll Gdi32.dll Engine.dll

%PROJECT_NAME%.exe