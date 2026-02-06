@echo off
echo ========================================
echo Roomix Release Build Script
echo ========================================
echo.
echo Cleaning previous build...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building release APK...
call flutter build apk --release

echo.
echo ========================================
echo Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================
pause
