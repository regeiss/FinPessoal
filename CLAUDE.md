# Claude Code Configuration

## Project Information
- **Project Type**: iOS Swift App (Personal Finance Manager)
- **Main Target**: FinPessoal
- **Xcode Project**: FinPessoal.xcodeproj

## Development Commands
- **Build**: Use Xcode or `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`
- **Test**: Use Xcode or `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15'`

## Architecture
- **Pattern**: MVVM with Repository Pattern
- **State Management**: StateObject/ObservableObject with EnvironmentObjects
- **Navigation**: NavigationState with SwiftUI NavigationView
- **Backend**: Firebase (Auth, Firestore, Analytics, Crashlytics)
- **Mock Support**: Configurable mock repositories for development/testing

## Key Features
- User Authentication (Firebase Auth with Google Sign-In)
- Personal Finance Tracking
- Transactions Management
- Budget Management
- Goals Setting
- Dashboard with Statistics
- Reports and Analytics
- Multi-platform support (iPhone/iPad)

## Project Structure
- `Code/Features/`: Feature-based modules (Account, Auth, Budget, Dashboard, etc.)
- `Code/Core/`: Core services (Firebase, Repository protocols)
- `Code/Configuration/`: App configuration and constants
- `Code/Utils/`: Utility classes and extensions
- `SupportingFiles/`: Localization and assets

## Current Status
- Main branch with recent onboarding and UI improvements
- Firebase integration configured
- Mock data support for development
- Localization support (Localizable.xcstrings)