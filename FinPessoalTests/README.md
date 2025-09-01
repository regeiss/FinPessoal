# FinPessoal Testing Suite

This comprehensive testing suite provides extensive coverage for the FinPessoal iOS personal finance app. The tests ensure code quality, performance, and user experience across all major features and platforms.

## 📋 Test Overview

### Coverage Areas
- **Unit Tests**: Data models, ViewModels, repositories, and utilities
- **Integration Tests**: Component interactions and data flow
- **UI Tests**: User flows, navigation, and interface interactions
- **Performance Tests**: Large dataset handling and memory usage
- **Device-Specific Tests**: iPad three-column layout functionality

### Test Statistics
- **Total Test Files**: 12
- **Estimated Test Count**: 150+ individual tests
- **Code Coverage Target**: 80%+
- **Platforms Tested**: iPhone, iPad

## 🏗️ Test Structure

```
FinPessoalTests/
├── README.md                          # This file
├── TestConfiguration.swift            # Shared test utilities and factories
├── FinPessoalTests.swift              # Main test suite and smoke tests
├── Models/                            # Data model tests
│   ├── AccountTests.swift             # Account model validation
│   ├── TransactionTests.swift         # Transaction model validation
│   └── UserTests.swift                # User model validation
├── ViewModels/                        # MVVM ViewModel tests
│   ├── AccountViewModelTests.swift    # Account management logic
│   └── TransactionViewModelTests.swift # Transaction management logic
├── Navigation/                        # Navigation and routing tests
│   └── NavigationStateTests.swift     # iPad three-column navigation
├── Repositories/                      # Data layer tests
│   └── MockRepositoryTests.swift      # Repository pattern validation
└── Performance/                       # Performance and scalability tests
    └── PerformanceTests.swift         # Benchmarks and memory tests

FinPessoalUITests/
├── FinPessoalUITests.swift            # Main UI test suite
├── OnboardingUITests.swift            # First-run experience
├── AuthenticationUITests.swift        # Login/logout flows
└── iPadNavigationUITests.swift        # Three-column layout functionality
```

## 🧪 Test Categories

### 1. Model Tests
**Files**: `Models/AccountTests.swift`, `Models/TransactionTests.swift`, `Models/UserTests.swift`

Tests data model integrity, validation, and serialization:
- Model initialization and property validation
- Dictionary conversion (to/from Firebase format)
- Edge cases (zero amounts, empty strings, etc.)
- Computed properties (formatted currency, dates)
- Enum functionality and display properties

**Key Test Cases**:
```swift
func testAccountInitialization()
func testFormattedBalance()
func testToDictionary()
func testFromDictionaryWithInvalidData()
```

### 2. ViewModel Tests
**Files**: `ViewModels/AccountViewModelTests.swift`, `ViewModels/TransactionViewModelTests.swift`

Tests business logic and state management:
- CRUD operations with mock repositories
- Data loading and error handling
- Search and filtering functionality
- Statistics calculation
- UI state management (loading, selection, etc.)
- Device-specific behavior (iPad vs iPhone)

**Key Test Cases**:
```swift
func testLoadAccountsSuccess()
func testTransactionFilteringPerformance()
func testStatisticsCalculation()
func testSelectAccountOniPad()
```

### 3. Navigation Tests
**Files**: `Navigation/NavigationStateTests.swift`

Tests navigation state management and iPad three-column layout:
- Tab and sidebar navigation
- Detail view selection and clearing
- State synchronization between columns
- Navigation flow integrity
- Reactive updates and Combine publishers

**Key Test Cases**:
```swift
func testSelectSidebarItemClearsDetailSelection()
func testThreeColumnNavigationFlow()
func testNavigationStateUpdates()
```

### 4. Repository Tests
**Files**: `Repositories/MockRepositoryTests.swift`

Tests data access layer and repository pattern:
- Mock repository functionality
- Error simulation and handling
- Data persistence simulation
- Async operation handling
- Performance with large datasets

### 5. Performance Tests
**Files**: `Performance/PerformanceTests.swift`

Benchmarks and scalability testing:
- Large dataset processing (10,000+ records)
- Memory usage monitoring
- Currency formatting performance
- Search and filtering optimization
- Concurrent operations

**Sample Benchmark**:
```swift
func testTransactionFilteringPerformance() {
    measure {
        // Filter 10,000 transactions
        viewModel.searchQuery = "food"
    }
}
```

### 6. UI Tests
**Files**: `FinPessoalUITests/*.swift`

End-to-end user flow testing:
- **Onboarding**: First-run experience and skip functionality
- **Authentication**: Google/Apple Sign-In with mock responses
- **iPad Navigation**: Three-column layout interaction
- **Accessibility**: VoiceOver and accessibility trait validation

## 🚀 Running Tests

### Command Line
```bash
# Run all unit tests
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all UI tests
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -only-testing:FinPessoalUITests

# Run specific test class
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/AccountTests

# Run performance tests
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/PerformanceTests
```

### Xcode
1. **Unit Tests**: Cmd+U or Product → Test
2. **Specific Tests**: Navigate to test file and click diamond icon
3. **Test Navigator**: Cmd+6 to view all tests
4. **Coverage Report**: Product → Show Code Coverage

### Test Targets
- **FinPessoalTests**: Unit, integration, and performance tests
- **FinPessoalUITests**: End-to-end UI automation tests

## 📊 Test Configuration

### Mock Data
The test suite uses comprehensive mock data through `TestConfiguration.swift`:

```swift
// Create sample data
let accounts = TestConfiguration.createSampleAccounts()     // 5 accounts
let transactions = TestConfiguration.createSampleTransactions() // 8 transactions
let budgets = TestConfiguration.createSampleBudgets()      // 3 budgets

// Custom test data
let account = TestConfiguration.createTestAccount(
    name: "Custom Account",
    balance: 2500.0
)
```

### Environment Variables
UI tests support environment configuration:
- `UITEST_DISABLE_ANIMATIONS=1`: Disable animations for faster tests
- `UITEST_MOCK_AUTH=1`: Enable mock authentication
- `UITEST_MOCK_DATA=1`: Use mock data instead of Firebase
- `UITEST_RESET_STATE=1`: Reset app state between tests

### Test Devices
Tests are configured for multiple device types:
- **iPhone**: iPhone 16, iPhone 16 Plus, iPhone 16 Pro
- **iPad**: iPad Pro 13-inch (M4), iPad Air 11-inch (M3)
- **Simulator**: iOS 18.0+ required

## 📈 Performance Benchmarks

### Expected Performance Metrics
- **Model Serialization**: < 1ms per 1,000 objects
- **ViewModel Data Loading**: < 500ms for 10,000 transactions
- **UI Navigation**: < 100ms between screens
- **Search Filtering**: < 200ms for 10,000 records
- **Memory Usage**: < 50MB for large datasets

### Performance Test Examples
```swift
func testLargeDatasetPerformance() {
    measure {
        let transactions = createLargeTransactionDataset(count: 10000)
        viewModel.processTransactions(transactions)
    }
}
```

## 🐛 Debugging Tests

### Common Issues
1. **Async Test Failures**: Use `await` properly and set appropriate timeouts
2. **UI Test Timing**: Add waits for elements: `element.waitForExistence(timeout: 5)`
3. **Mock Data Issues**: Verify mock repositories are configured correctly
4. **Device-Specific Failures**: Check device type conditions in tests

### Debug Helpers
```swift
// Print debug information
print("Navigation State: \(navigationState.debugDescription)")

// Breakpoint in test
XCTAssertTrue(condition) // Add breakpoint here

// Async debugging
let result = try await waitForAsync(timeout: 10) {
    return await viewModel.fetchData()
}
```

## 📱 Device-Specific Testing

### iPad Three-Column Layout
Special focus on testing the iPad's three-column navigation:
- Column width responsiveness
- Detail view presentation (no modals)
- Navigation state synchronization
- Back button functionality
- Rapid navigation stability

### iPhone Tab Bar
Standard iPhone navigation testing:
- Tab bar functionality
- Modal presentations
- Navigation stack management

## 🔧 Maintenance

### Adding New Tests
1. Follow the existing naming convention: `TestClassNameTests.swift`
2. Use `TestConfiguration` helper methods for mock data
3. Add performance tests for new features processing large datasets
4. Include both success and failure test cases
5. Test iPad-specific behavior separately

### Updating Tests
1. Update test data when models change
2. Maintain performance benchmarks as features evolve
3. Keep UI tests synchronized with interface changes
4. Update mock repositories when repository interfaces change

## 📝 Best Practices

### Test Writing
- **AAA Pattern**: Arrange, Act, Assert
- **Single Responsibility**: One test, one concern
- **Descriptive Names**: Clear test method names
- **Independent Tests**: No test dependencies
- **Mock External Dependencies**: Use mock repositories

### Performance
- Use `measure` blocks for performance tests
- Test with realistic data sizes
- Monitor memory usage with `measureMetrics`
- Set appropriate timeouts for async operations

### UI Testing
- Use accessibility identifiers for reliable element selection
- Wait for elements before interacting: `waitForExistence`
- Test both iPhone and iPad layouts
- Verify error states and edge cases

## 🎯 Quality Metrics

### Code Coverage Target
- **Models**: 95%+ coverage
- **ViewModels**: 85%+ coverage
- **Navigation**: 90%+ coverage
- **Overall**: 80%+ coverage

### Test Success Criteria
- All tests pass on CI/CD pipeline
- Performance tests within acceptable limits
- UI tests pass on multiple device sizes
- No memory leaks in performance tests
- Error handling tests cover edge cases

---

This comprehensive test suite ensures the FinPessoal app maintains high quality, performs well with large datasets, and provides an excellent user experience across iPhone and iPad devices.