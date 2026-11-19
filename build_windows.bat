@echo off
echo ========================================================
echo   LandLord Remastered - Windows Desktop Build Script
echo ========================================================
echo.

echo [1/3] Enabling Windows desktop support in Flutter...
flutter config --enable-windows-desktop

echo [2/3] Fetching project packages...
flutter pub get

echo [3/3] Compiling release Windows executable...
flutter build windows --release

echo.
echo ========================================================
echo   Build Complete!
echo   Executable location:
echo   build\windows\x64\runner\Release\landlord_app.exe
echo ========================================================
pause
