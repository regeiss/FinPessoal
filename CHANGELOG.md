# Changelog

All notable changes to the FinPessoal iOS app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - October 2025
- Comprehensive test suite for BudgetEnum with period calculations and display properties (2025-10-26)
- Comprehensive test suite for TransactionEnum including subcategories, colors, and sorting (2025-10-26)
- Comprehensive test suite for BudgetViewModel with validation and creation tests (2025-10-26)
- BudgetDetailSheet view for displaying detailed budget information with visual progress (2025-10-23)
- TransactionSubcategory enum with 40+ subcategories across all transaction categories (2025-10-23)
- Transaction category sorting functionality with logical ordering (2025-10-23)
- SwiftUI color support for transaction categories (2025-10-23)
- BudgetPeriod enum properties: icons, display names, and next period calculation (2025-10-17)
- Help texts for account and loan features (2025-10-08)
- Updated help section and category handling (2025-10-07)

### Changed - October 2025
- Enhanced TransactionCategory enum with subcategories property and Comparable conformance (2025-10-23)
- Enhanced TransactionType enum with icon property (2025-10-23)
- Updated TransactionTests to include tests for new enum properties (subcategories, colors, sorting) (2025-10-26)
- Updated README.md with comprehensive project documentation (2025-10-26)
- Updated FinPessoalTests/README.md with new test files and coverage details (2025-10-26)

### Added - October 2025
- Category management screen (2025-10-05)

### Added - September 2025
- App theming with dynamic colors (2025-10-01)
- Category and subcategory management (2025-09-29)
- Credit Card and Loan features (2025-09-27)
- Categories management feature (2025-09-23, 2025-09-19)
- Transaction categories and subcategories (2025-09-18)
- Transaction import functionality - closes #2 (2025-09-17)
- Help texts for transaction management (2025-09-15)
- Help and support feature (2025-09-14)
- Reports feature (2025-09-13)
- Budget category management feature (2025-09-12)
- Goal management feature (2025-09-10)
- Budget screen (2025-09-08)
- iPad three-column layout and tests (2025-09-01)

### Changed - September 2025
- Moved category related files to Categories feature (2025-09-25)
- Improved goal card layout and responsiveness (2025-09-11)
- Renamed "Goals" tab to "Budgets" (2025-09-08)
- Improved main tab navigation and transaction handling (2025-09-07)
- Improved iPad UI and added localization (2025-09-03)
- Enhanced dashboard and theme settings (2025-09-02)
- Improved transaction filtering and mock data setup (2025-09-01)

### Added - August 2025
- Account and transaction management (2025-08-31)
- Google and Apple Sign-In integration (2025-08-27)
- Improved app UI and localization support (2025-08-24)
- Onboarding flow for new users (2025-08-19, 2025-08-20)
- User authentication and account creation (2025-08-19)
- Firebase integration (2025-08-17)
- Mock authentication and finance repositories (2025-08-17)
- Financial data models and repository (2025-08-17)
- Account and transaction management features (2025-08-16)
- Mock authentication for development (2025-08-14)

### Changed - August 2025
- Refactored onboarding and tab bar labels (2025-08-23)
- Refactored dashboard UI text keys (2025-08-23)
- Refactored app for improved user experience (2025-08-23)
- Renamed OnBoardingView to OnBoardingScreen (2025-08-19)
- Removed loading and error handling from methods (2025-08-19)
- Refactored authentication and UI details (2025-08-18)
- Refactored app architecture (2025-08-18)
- Refactored authentication feature (2025-08-14)

### Fixed - August 2025
- Data filtering and Apple Auth issues (2025-08-18)
- Added authentication error handling (2025-08-17)

## [1.0.0] - 2025-08-13

### Added
- Initial release of FinPessoal
- Core personal finance management features
- User authentication
- Transaction tracking
- Budget management
- Dashboard with financial statistics
- Multi-platform support (iPhone/iPad)

---

## Change Categories

This changelog uses the following categories:
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes
