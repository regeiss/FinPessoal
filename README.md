# FinPessoal

A comprehensive personal finance management iOS application built with SwiftUI and Firebase, designed to help users track their income, expenses, budgets, and financial goals.

## 📱 Overview

FinPessoal is a modern iOS app that provides complete financial management capabilities with an intuitive interface optimized for both iPhone and iPad. The app leverages Firebase for authentication and data storage, offering real-time synchronization across devices.

## ✨ Features

### Core Features
- **Account Management**: Track multiple accounts (checking, savings, credit cards)
- **Transaction Tracking**: Record income, expenses, and transfers with detailed categorization
- **Budget Management**: Set and monitor budgets by category with customizable periods (weekly, monthly, quarterly, yearly)
- **Goal Setting**: Create and track financial goals with progress visualization
- **Dashboard**: Real-time financial overview with statistics and charts
- **Reports & Analytics**: Comprehensive financial reports and spending analysis
- **Categories & Subcategories**: Organize transactions with 10 main categories and 40+ subcategories

### Advanced Features
- **Credit Card Management**: Track credit card expenses and limits
- **Loan Tracking**: Monitor loan balances and payments
- **Transaction Import**: Import transactions from external sources
- **Custom Categories**: Create and manage custom transaction categories
- **Multi-Period Budgets**: Support for weekly, monthly, quarterly, and yearly budget periods
- **Smart Filtering**: Advanced search and filtering by date, category, type, and amount
- **Localization**: Full Portuguese (Brazil) localization support

### User Experience
- **Onboarding Flow**: Smooth introduction for new users
- **Google & Apple Sign-In**: Secure authentication with major providers
- **iPad Optimization**: Three-column layout for enhanced iPad experience
- **Dark Mode**: Full support for system appearance settings
- **Responsive Design**: Adaptive layouts for all iOS device sizes
- **Help & Support**: In-app help system with contextual guidance

## 🏗️ Architecture

### Design Patterns
- **MVVM (Model-View-ViewModel)**: Clear separation of concerns
- **Repository Pattern**: Abstracted data layer for easy testing and maintenance
- **State Management**: SwiftUI's StateObject/ObservableObject with EnvironmentObjects
- **Dependency Injection**: Mock repositories for development and testing

### Project Structure
```
FinPessoal/
├── Code/
│   ├── Features/              # Feature-based modules
│   │   ├── Account/           # Account management
│   │   ├── Auth/              # Authentication
│   │   ├── Budget/            # Budget tracking
│   │   ├── Categories/        # Category management
│   │   ├── CreditCard/        # Credit card features
│   │   ├── Dashboard/         # Main dashboard
│   │   ├── Goals/             # Financial goals
│   │   ├── Help/              # Help system
│   │   ├── Loan/              # Loan management
│   │   ├── OnBoarding/        # Onboarding flow
│   │   ├── Reports/           # Reports and analytics
│   │   └── Transaction/       # Transaction management
│   ├── Core/                  # Core services
│   │   ├── Firebase/          # Firebase integration
│   │   └── Repository/        # Repository protocols
│   ├── Configuration/         # App configuration
│   │   ├── Base/              # Base configurations
│   │   └── Constants/         # App constants and enums
│   └── Utils/                 # Utility classes and extensions
├── SupportingFiles/           # Localization and assets
│   └── Localizable.xcstrings  # Localized strings
└── FinPessoalTests/           # Comprehensive test suite
    ├── Models/                # Model tests
    ├── ViewModels/            # ViewModel tests
    ├── Navigation/            # Navigation tests
    ├── Repositories/          # Repository tests
    └── Performance/           # Performance tests
```

## 🚀 Getting Started

### Prerequisites
- macOS 14.0+ (Sonoma) or later
- Xcode 15.0+ or later
- iOS 18.0+ SDK
- CocoaPods or Swift Package Manager
- Firebase account (for production use)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/FinPessoal.git
cd FinPessoal
```

2. Install dependencies:
```bash
# Dependencies are managed via Swift Package Manager
# They will be automatically resolved when you open the project in Xcode
```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Add it to the project root

4. Open the project:
```bash
open FinPessoal.xcodeproj
```

5. Build and run:
   - Select your target device or simulator
   - Press Cmd+R or click the Run button

### Development Mode

The app supports mock repositories for development without Firebase:

```swift
// Enable mock mode in your environment
let useMockData = true

// Configure in FinPessoalApp.swift
@StateObject private var financeViewModel = FinanceViewModel(
    repository: useMockData ? MockFinanceRepository() : FirebaseFinanceRepository()
)
```

## 🧪 Testing

### Running Tests

```bash
# Run all unit tests
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all UI tests
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  -only-testing:FinPessoalUITests

# Run specific test class
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal \
  -only-testing:FinPessoalTests/BudgetViewModelTests
```

### Test Coverage
- **Unit Tests**: 150+ tests covering models, ViewModels, and business logic
- **UI Tests**: End-to-end user flow testing
- **Performance Tests**: Benchmarks for large datasets (10,000+ records)
- **Integration Tests**: Component interaction validation
- **Code Coverage Target**: 80%+

See [FinPessoalTests/README.md](FinPessoalTests/README.md) for detailed testing documentation.

## 📊 Transaction Categories

### Main Categories
1. **Food** (🍴) - Restaurants, groceries, delivery, coffee, etc.
2. **Transport** (🚗) - Fuel, public transport, taxi, parking, maintenance
3. **Entertainment** (🎮) - Movies, games, concerts, sports, streaming
4. **Healthcare** (⚕️) - Doctor, pharmacy, dental, hospital, therapy
5. **Shopping** (🛍️) - Clothing, electronics, home goods, beauty
6. **Bills** (📄) - Electricity, water, internet, phone, subscriptions
7. **Salary** (💰) - Primary job, freelance, bonus, commission
8. **Investment** (📈) - Stocks, bonds, real estate, cryptocurrency
9. **Housing** (🏠) - Rent, mortgage, repairs, furniture, utilities
10. **Other** (❓) - Fees, donations, education, pets, miscellaneous

### Subcategories
Each category includes 4-6 detailed subcategories for precise transaction tracking, totaling 40+ subcategory options.

## 💾 Technologies

### Core Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **Swift 5.9+**: Latest Swift features and async/await

### Backend & Services
- **Firebase Authentication**: Google & Apple Sign-In
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Crash reporting and monitoring

### Development Tools
- **Xcode 15+**: IDE and interface builder
- **Swift Package Manager**: Dependency management
- **XCTest**: Unit and UI testing framework
- **Git**: Version control

## 🎨 Design

### UI/UX Features
- **Native SwiftUI**: Leverages latest SwiftUI capabilities
- **System Colors**: Adapts to user's system appearance
- **SF Symbols**: Rich iconography with semantic meanings
- **Accessibility**: VoiceOver support and accessibility traits
- **Responsive Layouts**: Adapts to all device sizes and orientations
- **Gesture Support**: Natural touch interactions

### Color Scheme
- Dynamic colors that adapt to light/dark mode
- Category-specific colors for visual organization
- Budget status indicators (normal/warning/exceeded)
- Semantic colors for income (green) and expenses (red)

## 🌍 Localization

Currently supported languages:
- **Portuguese (Brazil)**: Complete translation (pt_BR)

The app uses `Localizable.xcstrings` for easy localization management and supports adding new languages through Xcode's localization system.

## 🔐 Security

- **Secure Authentication**: Firebase Auth with OAuth providers
- **Data Privacy**: User data isolated per account
- **Cloud Security**: Firestore security rules
- **No Local Storage of Credentials**: Auth tokens managed by Firebase SDK
- **HTTPS Only**: All network communication encrypted

## 📈 Performance

### Optimization Features
- Lazy loading for large transaction lists
- Efficient Firestore queries with indexing
- Memory-efficient currency formatting
- Optimized search and filtering algorithms
- Background data synchronization

### Benchmarks
- Transaction filtering: < 200ms for 10,000 records
- Data loading: < 500ms for initial sync
- UI navigation: < 100ms between screens
- Memory usage: < 50MB with large datasets

## 🛠️ Configuration

### Build Configurations
- **Debug**: Development with mock data support
- **Release**: Production build with optimizations

### Environment Variables
Configure in scheme settings:
- `UITEST_DISABLE_ANIMATIONS`: Disable animations for testing
- `UITEST_MOCK_AUTH`: Enable mock authentication
- `UITEST_MOCK_DATA`: Use mock data instead of Firebase

## 📝 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

### Current Version
- **Version**: 1.0.0 (Unreleased)
- **Last Updated**: October 2025
- **iOS Support**: iOS 18.0+

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Swift style guide and conventions
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR
- Use meaningful commit messages

## 📄 License

This project is proprietary software. All rights reserved.

## 👤 Author

**Roberto Edgar Geiss**

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- SwiftUI community for best practices
- SF Symbols for comprehensive iconography
- Open source community for inspiration

## 📞 Support

For questions, issues, or feature requests:
- Open an issue on GitHub
- Check the in-app Help section
- Review the [test documentation](FinPessoalTests/README.md)

---

**Built with ❤️ using SwiftUI and Firebase**
