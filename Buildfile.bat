SET BUILD_FOLDER=%~p0Build
SET ENGINE_FOLDER=%~p0Engine
SET RESOURCES_FOLDER=%~p0Resources
SET GAME_FOLDER=%~p0Game
SET PROJECT_NAME=SpaceInvaders
SET ENGINE_NAME=Engine

:: Clean Build Folder
cd %BUILD_FOLDER%
del /q *.exe

:: Copy Resources
if not exist %BUILD_FOLDER%\Resources mkdir %BUILD_FOLDER%\Resources
xcopy %RESOURCES_FOLDER% %BUILD_FOLDER%\Resources /E /Q /D /Y

:: Build Engine
cd %ENGINE_FOLDER%
nasm -f win32 %ENGINE_NAME%.asm -o %BUILD_FOLDER%\%ENGINE_NAME%.obj   

cd %BUILD_FOLDER%
GoLink %ENGINE_NAME%.obj user32.dll kernel32.dll Gdi32.dll /dll

:: Build game
cd %GAME_FOLDER%
nasm -f win32 %PROJECT_NAME%.asm -o %BUILD_FOLDER%\%PROJECT_NAME%.obj   

cd %BUILD_FOLDER%
GoLink %PROJECT_NAME%.obj user32.dll kernel32.dll Gdi32.dll Engine.dll

:: Remove .obj files
del /q *.obj

:: Execute project
%PROJECT_NAME%.exe