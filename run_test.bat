@echo off
echo ========================================
echo Flutter Environment Test App
echo ========================================
echo.
echo Current Directory: %CD%
echo Flutter Path: C:\flutter\bin\flutter.bat
echo.

REM Change to the project directory
cd /d "d:\projects\Yusic"

echo Checking Flutter environment...
C:\flutter\bin\flutter.bat doctor --android-licenses

echo.
echo Running Flutter app on Chrome...
echo App will open at: http://localhost:8082
echo.
echo Press Ctrl+C to stop the app
echo ========================================

C:\flutter\bin\flutter.bat run -d chrome --web-port=8082

pause