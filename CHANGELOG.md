# Changelog

All notable changes to the FinPessoal iOS app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed - October 2025
- **Fixed ML/AI compilation warnings** (2025-10-29)
  - Build succeeded with only minor unused variable warnings
  - All ML algorithms compile and run correctly

- **Fixed Financial Analytics compilation errors** (2025-10-29)
  - Fixed Transaction mutability issue by creating new instances instead of mutating
  - Fixed TransactionCategory enum case names (.transport instead of .transportation, .healthcare instead of .health)
  - Fixed Budget property references (.budgetAmount instead of .limit)
  - Fixed Goal targetDate optional binding (targetDate is not optional)
  - All analytics code now compiles successfully
- **Fixed MoreScreen navigation title not displaying on initial load (iPhone)** (2025-10-28)
  - Removed NavigationView wrapper that was conflicting with NavigationStack
  - Navigation title now displays correctly when first opening More screen
  - Title previously only appeared when navigating back from subviews
- **Fixed BillsScreen iPad layout to use full width** (2025-10-28)
  - Removed NavigationView wrapper that was causing layout constraints on iPad
  - Added frame modifiers to ensure full width/height usage
  - BillsScreen now properly fills available space like other screens on iPad

### Added - October 2025
- **ML/AI Financial Insights System** (2025-10-29)
  - Created FinancialAIService with machine learning algorithms
  - **Expense Prediction**: Predicts next 3 months expenses using linear regression and seasonal analysis
  - **Anomaly Detection**: Detects unusual transactions using Z-score statistical analysis
  - **Smart Budget Suggestions**: Recommends optimal budgets based on percentile analysis
  - **Personalized Advice**: Generates tailored financial recommendations across 6 categories
  - AIInsightsScreen with beautiful UI for ML insights
  - Confidence scoring for predictions and suggestions
  - Trend analysis (increasing/decreasing/stable)
  - Seasonality factors for more accurate predictions
  - Potential duplicate transaction detection
  - Unusual timing detection (late night transactions)
  - Frequency spike detection
  - Income stability analysis
  - Expense-to-income ratio monitoring
  - Subscription spending aggregation
  - Added 52 Portuguese localization strings for AI features
  - Integrated into More screen as "IA Financeira"

- **Financial Analytics & Insights System** (2025-10-29)
  - Created FinancialAnalyticsService with intelligent analysis capabilities
  - Automatic transaction categorization based on description patterns
  - Spending pattern detection with trend analysis (increasing/decreasing/stable)
  - Budget overrun prediction with daily average projections
  - Financial insight generation across spending, budgets, goals, and savings
  - Risk level assessment (low/medium/high/critical) for budgets
  - Recurring subscription detection
  - Unusual spending detection (transactions > 3x average)
  - Smart recommendations based on spending behavior
  - InsightsScreen with visual cards for patterns, predictions, and insights
  - Filter insights by category (spending, budget, goals, savings)
  - Added 48 Portuguese localization strings for insights
  - Integrated insights into More screen navigation

### Changed - October 2025
- **Standardized add buttons to simple plus icon in navigation bars** (2025-10-28)
  - Changed TransactionsScreen add button from "plus.circle.fill" to "plus"
  - Changed AccountsView add button from "plus.circle.fill" to "plus"
  - Changed LoansScreen add button from "plus.circle.fill" to "plus"
  - Changed CreditCardsScreen add button from "plus.circle.fill" to "plus"
  - Changed BudgetsScreen add button from text "Adicionar" to "plus" icon
  - All navigation bar add buttons now use consistent simple plus icon
  - Note: BillsScreen and GoalScreen already used "plus" icon
- **Updated Portuguese localization for Bills feature** (2025-10-28)
  - Changed "Contas" to "Pagamentos" for all bills-related strings
  - Updated tab.bills, sidebar.bills, and bills.title translations
  - Updated all bill-related UI strings (add, delete, empty state, notifications)
  - Updated descriptions to reflect new terminology
- **Fixed navigation titles visibility on iPhone** (2025-10-28)
  - Wrapped all tab contents in NavigationStack in iPhoneMainView
  - Navigation titles now properly display for Dashboard, Accounts, Transactions, Bills, and More screens
  - Fixed issue where navigation titles were defined but not visible due to missing NavigationStack wrapper
- **Added navigation title to TransactionsScreen** (2025-10-28)
  - Added localized navigation title "tab.transactions" to transactions screen
  - Completes navigation title consistency across all main screens
- **Updated README.md with comprehensive documentation** (2025-10-27)
  - Added Bills Management System section with detailed feature descriptions
  - Added Smart Notifications System documentation
  - Updated project structure to reflect Bills and Notifications modules
  - Updated test coverage numbers (200+ tests)
  - Added UserNotifications to technology stack
  - Updated navigation information (iPhone 5-tab design)
  - Added sample bills information for development

### Fixed - October 2025
- Fixed missing Portuguese translations in Bills feature (2025-10-27)
  - Added translation for common.category → "Categoria"
  - Added translation for common.subcategory → "Subcategoria"
  - Added translation for common.none → "Nenhuma"
  - Fixed account dropdown to use translated account type names
  - Changed mockAccounts to computed property for proper localization
  - Fixed "Dia do Vencimento" dropdown to show "Dia 1", "Dia 2", etc.
  - Fixed "Lembrete" dropdown to show "1 dia antes", "2 dias antes", etc.
- Fixed compilation errors in Bills feature (2025-10-27)
  - Added missing error cases to FirebaseError enum (documentNotFound, databaseError)
  - Updated FirebaseError.invalidData to accept error message parameter
  - Fixed AuthError usage in FirebaseBillRepository (changed userNotAuthenticated to noCurrentUser)
  - Fixed Goal property reference in NotificationManager (percentageAchieved to progressPercentage)
  - Removed duplicate StatCard struct from BillsScreen
  - Added Bills case to MainTabView switch statement
  - Fixed Model+Extensions to include error messages in FirebaseError.invalidData calls

### Added - October 2025
- **Bills Management System** - Complete recurring bills tracking functionality (2025-10-26)
  - Bill model with status tracking (paid, overdue, due soon, upcoming)
  - Auto-calculation of next due dates based on billing day
  - Bill reminders with configurable days before due
  - BillsViewModel with filtering, search, and statistics
  - BillsScreen with swipe actions and status cards
  - AddBillScreen with comprehensive form validation
  - BillDetailView with payment actions and history
  - BillRepository protocol with Mock and Firebase implementations
  - 5 sample bills in MockBillRepository for development
  - Integration with NotificationManager for automatic reminders
  - 56 Portuguese localization strings for bills feature
  - Comprehensive BillTests with 20+ test cases
- **Smart Notifications System** with native iOS UserNotifications framework (2025-10-26)
  - NotificationManager singleton for centralized notification handling
  - Budget alerts when spending exceeds threshold (80%, 90%, 100%)
  - Bill reminders for recurring transactions (3 days before due)
  - Goal progress notifications at milestones (25%, 50%, 75%, 90%, 100%)
  - Suspicious activity alerts for large expenses (>1000)
  - Daily financial summary notifications
  - Interactive notification actions (View, Review, Dismiss)
  - Notification categories for different alert types
  - Complete Portuguese localization for all notifications
- AppDelegate for handling notification callbacks and user interactions
- NotificationManager integration in BudgetViewModel and TransactionViewModel
- Comprehensive NotificationManager test suite with 20+ test cases (2025-10-26)
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
- **Added navigation titles to all main screens** (2025-10-27)
  - Added navigation title to AccountsView (Contas)
  - Added navigation title to DashboardScreen (Dashboard/Painel)
  - Added navigation title to GoalScreen (Metas)
  - Added navigation title to ReportsScreen (Relatórios)
  - Added navigation title to BudgetsScreen (Orçamentos)
  - All screens now display proper titles in navigation bar
- **Reorganized iPhone navigation for better UX** (2025-10-27)
  - Removed Budgets tab from iPhone bottom tab bar
  - Moved Budgets to More screen to reduce tab clutter
  - iPhone tabs now: Dashboard, Accounts, Transactions, Bills, More
- **Enhanced More screen with additional navigation options** (2025-10-27)
  - Added Budgets link to More screen for primary access
  - Added Bills link to More screen for quick access
  - Reorganized More screen items for better user flow
- **Integrated Bills into app navigation** (2025-10-26)
  - Added bills tab to iPhone main navigation (between Transactions and Budgets)
  - Added bills to iPad sidebar navigation
  - Added BillsDetailView for iPad 3-column layout
  - Added tab.bills and sidebar.bills localization strings
- Added createBillRepository() factory method to AppConfiguration (2025-10-26)
- Enhanced NotificationManager with bill-specific reminder methods (2025-10-26)
- Integrated NotificationManager into app lifecycle with permission request (2025-10-26)
- BudgetViewModel now schedules/updates/cancels budget alerts automatically (2025-10-26)
- TransactionViewModel now schedules bill reminders and suspicious activity alerts (2025-10-26)
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
