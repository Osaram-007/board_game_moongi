# Board Game Moongi - Setup Guide

## 🚀 Flutter Installation & Development Setup

### 1. Install Flutter SDK

#### Option A: Using Flutter Installer (Recommended)
1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
2. Extract to: `C:\src\flutter`
3. Add to PATH:
   ```cmd
   setx PATH "%PATH%;C:\src\flutter\bin"
   ```

#### Option B: Using Chocolatey
```cmd
choco install flutter
```

### 2. Verify Installation
Open a new Command Prompt/PowerShell and run:
```cmd
flutter doctor
```

### 3. Install Android Studio
1. Download from: https://developer.android.com/studio
2. Install with default settings
3. During setup, ensure these components are installed:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator

### 4. Accept Android Licenses
```cmd
flutter doctor --android-licenses
```

### 5. Project Setup Commands

Navigate to your project directory and run these commands:

```cmd
cd C:\Users\athar\OneDrive\Documents\GitHub\board_game_moongi

# Install dependencies
flutter pub get

# Generate Isar models
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test
```

### 6. Development Commands

#### For Development
```cmd
flutter run --debug
```

#### For Testing
```cmd
flutter test
flutter test --coverage
```

#### For Production Build
```cmd
flutter build apk --release
flutter build appbundle --release
```

### 7. Troubleshooting

#### If Flutter is not recognized:
1. Close and reopen your terminal
2. Check PATH: `echo %PATH%`
3. Verify Flutter: `flutter --version`

#### If build_runner fails:
1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Run: `flutter pub run build_runner build --delete-conflicting-outputs`

#### Common Issues:
- **Android SDK not found**: Set ANDROID_HOME environment variable
- **Device not found**: Enable USB debugging on your phone or start an emulator
- **Build errors**: Run `flutter doctor` to diagnose issues

### 8. Environment Variables

Add these to your system environment variables:
```
FLUTTER_HOME=C:\src\flutter
ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
PATH=%PATH%;%FLUTTER_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools
```

### 9. Quick Start Script

Create a file `setup.bat` with these contents:
```batch
@echo off
echo Setting up Board Game Moongi...
cd /d "C:\Users\athar\OneDrive\Documents\GitHub\board_game_moongi"
echo Installing dependencies...
flutter pub get
echo Generating models...
flutter pub run build_runner build --delete-conflicting-outputs
echo Running app...
flutter run
pause
```

### 10. VS Code Setup (Optional)

1. Install VS Code
2. Install Flutter extension
3. Install Dart extension
4. Open project in VS Code: `code .`
5. Press F5 to run the app

## 🎯 Ready to Run

Once setup is complete, you can run the app with:
```cmd
flutter run
```

The app will launch on your connected device or emulator!
