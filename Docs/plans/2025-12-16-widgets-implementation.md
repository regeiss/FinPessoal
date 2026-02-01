# FinPessoal Widget Suite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add comprehensive iOS widgets (Home Screen, Lock Screen, Live Activities) to display financial data at a glance.

**Architecture:** Widget Extension with App Groups for data sharing. Main app syncs data to shared UserDefaults; widgets read from cache with background Firebase refresh. Live Activities triggered by push notifications and local events.

**Tech Stack:** WidgetKit, ActivityKit, App Groups, SwiftUI, Firebase

---

## Phase 1: Project Setup

### Task 1.1: Create Widget Extension Target

**Files:**
- Create: `FinPessoalWidgets/FinPessoalWidgets.swift`
- Create: `FinPessoalWidgets/FinPessoalWidgetsBundle.swift`
- Modify: `FinPessoal.xcodeproj/project.pbxproj`

**Step 1: Add Widget Extension via Xcode**

Run in Xcode:
1. File → New → Target
2. Select "Widget Extension"
3. Product Name: `FinPessoalWidgets`
4. Uncheck "Include Live Activity" (we'll add manually)
5. Uncheck "Include Configuration App Intent"
6. Finish

Expected: New folder `FinPessoalWidgets/` created with template files

**Step 2: Verify extension builds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoalWidgets -destination 'platform=iOS Simulator,name=iPhone 15' build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add FinPessoalWidgets extension target"
```

---

### Task 1.2: Configure App Groups

**Files:**
- Create: `FinPessoal/FinPessoal.entitlements` (if not exists)
- Create: `FinPessoalWidgets/FinPessoalWidgets.entitlements`
- Modify: `FinPessoal.xcodeproj/project.pbxproj`

**Step 1: Add App Group capability to main app**

In Xcode:
1. Select FinPessoal target
2. Signing & Capabilities → + Capability → App Groups
3. Add group: `group.com.finpessoal.shared`

**Step 2: Add App Group capability to widget extension**

In Xcode:
1. Select FinPessoalWidgets target
2. Signing & Capabilities → + Capability → App Groups
3. Add same group: `group.com.finpessoal.shared`

**Step 3: Verify entitlements files exist**

Run: `ls -la FinPessoal/*.entitlements FinPessoalWidgets/*.entitlements`

Expected: Both entitlements files listed with App Groups

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: configure App Groups for widget data sharing"
```

---

### Task 1.3: Create Shared Framework for Models

**Files:**
- Create: `Shared/Models/WidgetData.swift`
- Create: `Shared/Models/AccountSummary.swift`
- Create: `Shared/Models/BudgetSummary.swift`
- Create: `Shared/Models/BillSummary.swift`
- Create: `Shared/Models/GoalSummary.swift`
- Create: `Shared/Models/CardSummary.swift`
- Create: `Shared/Models/TransactionSummary.swift`

**Step 1: Create Shared folder structure**

Run: `mkdir -p /Users/robertoedgargeiss/ProjetosIOS/FinPessoal/Shared/Models`

**Step 2: Create WidgetData model**

Create file `Shared/Models/WidgetData.swift`:

```swift
import Foundation

struct WidgetData: Codable {
  let lastUpdated: Date
  let totalBalance: Decimal
  let monthlyIncome: Decimal
  let monthlyExpenses: Decimal
  let accounts: [AccountSummary]
  let budgets: [BudgetSummary]
  let upcomingBills: [BillSummary]
  let goals: [GoalSummary]
  let creditCards: [CardSummary]
  let recentTransactions: [TransactionSummary]

  static let empty = WidgetData(
    lastUpdated: Date(),
    totalBalance: 0,
    monthlyIncome: 0,
    monthlyExpenses: 0,
    accounts: [],
    budgets: [],
    upcomingBills: [],
    goals: [],
    creditCards: [],
    recentTransactions: []
  )
}
```

**Step 3: Create AccountSummary model**

Create file `Shared/Models/AccountSummary.swift`:

```swift
import Foundation

struct AccountSummary: Codable, Identifiable {
  let id: String
  let name: String
  let type: String
  let balance: Decimal
  let currency: String
}
```

**Step 4: Create BudgetSummary model**

Create file `Shared/Models/BudgetSummary.swift`:

```swift
import Foundation

struct BudgetSummary: Codable, Identifiable {
  let id: String
  let name: String
  let category: String
  let categoryIcon: String
  let spent: Decimal
  let limit: Decimal

  var percentage: Double {
    guard limit > 0 else { return 0 }
    return Double(truncating: (spent / limit * 100) as NSDecimalNumber)
  }

  var isOverBudget: Bool {
    spent > limit
  }

  var remaining: Decimal {
    max(0, limit - spent)
  }
}
```

**Step 5: Create BillSummary model**

Create file `Shared/Models/BillSummary.swift`:

```swift
import Foundation

struct BillSummary: Codable, Identifiable {
  let id: String
  let name: String
  let amount: Decimal
  let dueDate: Date
  let status: String
  let categoryIcon: String

  var daysUntilDue: Int {
    Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
  }

  var isOverdue: Bool {
    status == "overdue"
  }
}
```

**Step 6: Create GoalSummary model**

Create file `Shared/Models/GoalSummary.swift`:

```swift
import Foundation

struct GoalSummary: Codable, Identifiable {
  let id: String
  let name: String
  let currentAmount: Decimal
  let targetAmount: Decimal
  let targetDate: Date?
  let categoryIcon: String

  var percentage: Double {
    guard targetAmount > 0 else { return 0 }
    return min(100, Double(truncating: (currentAmount / targetAmount * 100) as NSDecimalNumber))
  }

  var remaining: Decimal {
    max(0, targetAmount - currentAmount)
  }

  var isCompleted: Bool {
    currentAmount >= targetAmount
  }
}
```

**Step 7: Create CardSummary model**

Create file `Shared/Models/CardSummary.swift`:

```swift
import Foundation

struct CardSummary: Codable, Identifiable {
  let id: String
  let name: String
  let currentBalance: Decimal
  let creditLimit: Decimal
  let dueDate: Date?
  let brand: String

  var availableCredit: Decimal {
    max(0, creditLimit - currentBalance)
  }

  var utilizationPercentage: Double {
    guard creditLimit > 0 else { return 0 }
    return Double(truncating: (currentBalance / creditLimit * 100) as NSDecimalNumber)
  }
}
```

**Step 8: Create TransactionSummary model**

Create file `Shared/Models/TransactionSummary.swift`:

```swift
import Foundation

struct TransactionSummary: Codable, Identifiable {
  let id: String
  let description: String
  let amount: Decimal
  let date: Date
  let type: String
  let category: String
  let categoryIcon: String

  var isExpense: Bool {
    type == "expense"
  }
}
```

**Step 9: Add files to both targets in Xcode**

In Xcode:
1. Drag `Shared/` folder into project navigator
2. Check both "FinPessoal" and "FinPessoalWidgets" targets

**Step 10: Build to verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' build`

Expected: BUILD SUCCEEDED

**Step 11: Commit**

```bash
git add -A
git commit -m "feat: add shared widget data models"
```

---

## Phase 2: Shared Data Layer

### Task 2.1: Create SharedDataManager

**Files:**
- Create: `Shared/Services/SharedDataManager.swift`
- Test: `FinPessoalTests/Shared/SharedDataManagerTests.swift`

**Step 1: Create test file**

Create file `FinPessoalTests/Shared/SharedDataManagerTests.swift`:

```swift
import XCTest
@testable import FinPessoal

final class SharedDataManagerTests: XCTestCase {

  var sut: SharedDataManager!

  override func setUp() {
    super.setUp()
    sut = SharedDataManager.shared
    sut.clearData()
  }

  override func tearDown() {
    sut.clearData()
    super.tearDown()
  }

  func test_saveAndLoadWidgetData_success() {
    // Given
    let testData = WidgetData(
      lastUpdated: Date(),
      totalBalance: 1000.50,
      monthlyIncome: 5000,
      monthlyExpenses: 3000,
      accounts: [
        AccountSummary(id: "1", name: "Checking", type: "checking", balance: 1000.50, currency: "BRL")
      ],
      budgets: [],
      upcomingBills: [],
      goals: [],
      creditCards: [],
      recentTransactions: []
    )

    // When
    sut.saveWidgetData(testData)
    let loaded = sut.loadWidgetData()

    // Then
    XCTAssertEqual(loaded.totalBalance, testData.totalBalance)
    XCTAssertEqual(loaded.accounts.count, 1)
    XCTAssertEqual(loaded.accounts.first?.name, "Checking")
  }

  func test_loadWidgetData_whenEmpty_returnsEmptyData() {
    // When
    let loaded = sut.loadWidgetData()

    // Then
    XCTAssertEqual(loaded.totalBalance, 0)
    XCTAssertTrue(loaded.accounts.isEmpty)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FinPessoalTests/SharedDataManagerTests`

Expected: FAIL - SharedDataManager not found

**Step 3: Create SharedDataManager**

Create file `Shared/Services/SharedDataManager.swift`:

```swift
import Foundation
import WidgetKit

final class SharedDataManager {

  static let shared = SharedDataManager()

  private let appGroupIdentifier = "group.com.finpessoal.shared"
  private let widgetDataKey = "widgetData"

  private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: appGroupIdentifier)
  }

  private init() {}

  // MARK: - Save Data

  func saveWidgetData(_ data: WidgetData) {
    guard let defaults = sharedDefaults else {
      print("SharedDataManager: Failed to access App Group")
      return
    }

    do {
      let encoded = try JSONEncoder().encode(data)
      defaults.set(encoded, forKey: widgetDataKey)
      defaults.synchronize()

      // Reload all widgets
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      print("SharedDataManager: Failed to encode data - \(error)")
    }
  }

  // MARK: - Load Data

  func loadWidgetData() -> WidgetData {
    guard let defaults = sharedDefaults,
          let data = defaults.data(forKey: widgetDataKey) else {
      return .empty
    }

    do {
      return try JSONDecoder().decode(WidgetData.self, from: data)
    } catch {
      print("SharedDataManager: Failed to decode data - \(error)")
      return .empty
    }
  }

  // MARK: - Clear Data

  func clearData() {
    sharedDefaults?.removeObject(forKey: widgetDataKey)
    sharedDefaults?.synchronize()
  }

  // MARK: - Last Update Time

  var lastUpdateTime: Date? {
    loadWidgetData().lastUpdated
  }
}
```

**Step 4: Add to both targets and run tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FinPessoalTests/SharedDataManagerTests`

Expected: All tests PASS

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add SharedDataManager for widget data sync"
```

---

### Task 2.2: Create WidgetDataProvider

**Files:**
- Create: `Shared/Services/WidgetDataProvider.swift`
- Test: `FinPessoalTests/Shared/WidgetDataProviderTests.swift`

**Step 1: Create test file**

Create file `FinPessoalTests/Shared/WidgetDataProviderTests.swift`:

```swift
import XCTest
@testable import FinPessoal

final class WidgetDataProviderTests: XCTestCase {

  func test_convertAccountToSummary() {
    // Given
    let account = Account(
      id: "123",
      name: "My Checking",
      type: .checking,
      balance: 1500.75,
      currency: "BRL",
      isActive: true
    )

    // When
    let summary = WidgetDataProvider.toSummary(account)

    // Then
    XCTAssertEqual(summary.id, "123")
    XCTAssertEqual(summary.name, "My Checking")
    XCTAssertEqual(summary.balance, 1500.75)
  }

  func test_convertBudgetToSummary() {
    // Given
    let budget = Budget(
      id: "456",
      name: "Food Budget",
      category: .food,
      budgetAmount: 1000,
      spent: 750,
      period: .monthly,
      startDate: Date(),
      endDate: Date(),
      alertThreshold: 80
    )

    // When
    let summary = WidgetDataProvider.toSummary(budget)

    // Then
    XCTAssertEqual(summary.id, "456")
    XCTAssertEqual(summary.spent, 750)
    XCTAssertEqual(summary.limit, 1000)
    XCTAssertEqual(summary.percentage, 75, accuracy: 0.1)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FinPessoalTests/WidgetDataProviderTests`

Expected: FAIL - WidgetDataProvider not found

**Step 3: Create WidgetDataProvider**

Create file `Shared/Services/WidgetDataProvider.swift`:

```swift
import Foundation

enum WidgetDataProvider {

  // MARK: - Account Conversion

  static func toSummary(_ account: Account) -> AccountSummary {
    AccountSummary(
      id: account.id,
      name: account.name,
      type: account.type.rawValue,
      balance: account.balance,
      currency: account.currency
    )
  }

  // MARK: - Budget Conversion

  static func toSummary(_ budget: Budget) -> BudgetSummary {
    BudgetSummary(
      id: budget.id,
      name: budget.name,
      category: budget.category.rawValue,
      categoryIcon: budget.category.icon,
      spent: budget.spent,
      limit: budget.budgetAmount
    )
  }

  // MARK: - Bill Conversion

  static func toSummary(_ bill: Bill) -> BillSummary {
    BillSummary(
      id: bill.id,
      name: bill.name,
      amount: bill.amount,
      dueDate: bill.nextDueDate,
      status: bill.status.rawValue,
      categoryIcon: bill.category?.icon ?? "dollarsign.circle"
    )
  }

  // MARK: - Goal Conversion

  static func toSummary(_ goal: Goal) -> GoalSummary {
    GoalSummary(
      id: goal.id,
      name: goal.name,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      targetDate: goal.targetDate,
      categoryIcon: goal.category.icon
    )
  }

  // MARK: - Credit Card Conversion

  static func toSummary(_ card: CreditCard) -> CardSummary {
    CardSummary(
      id: card.id,
      name: card.name,
      currentBalance: card.currentBalance,
      creditLimit: card.creditLimit,
      dueDate: card.dueDate,
      brand: card.brand.rawValue
    )
  }

  // MARK: - Transaction Conversion

  static func toSummary(_ transaction: Transaction) -> TransactionSummary {
    TransactionSummary(
      id: transaction.id,
      description: transaction.description,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type.rawValue,
      category: transaction.category.rawValue,
      categoryIcon: transaction.category.icon
    )
  }

  // MARK: - Build Complete Widget Data

  static func buildWidgetData(
    accounts: [Account],
    budgets: [Budget],
    bills: [Bill],
    goals: [Goal],
    creditCards: [CreditCard],
    transactions: [Transaction]
  ) -> WidgetData {

    let activeAccounts = accounts.filter { $0.isActive }
    let totalBalance = activeAccounts.reduce(Decimal(0)) { $0 + $1.balance }

    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

    let monthlyTransactions = transactions.filter { $0.date >= startOfMonth }
    let monthlyIncome = monthlyTransactions
      .filter { $0.type == .income }
      .reduce(Decimal(0)) { $0 + $1.amount }
    let monthlyExpenses = monthlyTransactions
      .filter { $0.type == .expense }
      .reduce(Decimal(0)) { $0 + $1.amount }

    let upcomingBills = bills
      .filter { $0.status != .paid }
      .sorted { $0.nextDueDate < $1.nextDueDate }
      .prefix(5)

    let recentTransactions = transactions
      .sorted { $0.date > $1.date }
      .prefix(10)

    return WidgetData(
      lastUpdated: Date(),
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      accounts: activeAccounts.map { toSummary($0) },
      budgets: budgets.map { toSummary($0) },
      upcomingBills: Array(upcomingBills).map { toSummary($0) },
      goals: goals.map { toSummary($0) },
      creditCards: creditCards.map { toSummary($0) },
      recentTransactions: Array(recentTransactions).map { toSummary($0) }
    )
  }
}
```

**Step 4: Run tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FinPessoalTests/WidgetDataProviderTests`

Expected: All tests PASS

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add WidgetDataProvider for model conversion"
```

---

### Task 2.3: Integrate Data Sync in Main App

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/ViewModel/DashboardViewModel.swift`
- Modify: `FinPessoal/FinPessoalApp.swift`

**Step 1: Add sync method to DashboardViewModel**

Add to `DashboardViewModel.swift`:

```swift
// MARK: - Widget Data Sync

func syncWidgetData() {
  let widgetData = WidgetDataProvider.buildWidgetData(
    accounts: accounts,
    budgets: budgets,
    bills: bills,
    goals: goals,
    creditCards: creditCards,
    transactions: transactions
  )
  SharedDataManager.shared.saveWidgetData(widgetData)
}
```

**Step 2: Call sync when data loads**

In `DashboardViewModel.swift`, add call to `syncWidgetData()` at end of `loadData()` method.

**Step 3: Add sync on app background**

In `FinPessoalApp.swift`, add scene phase observer:

```swift
@Environment(\.scenePhase) private var scenePhase

// In body, add:
.onChange(of: scenePhase) { oldPhase, newPhase in
  if newPhase == .background {
    // Sync widget data when app goes to background
    NotificationCenter.default.post(name: .syncWidgetData, object: nil)
  }
}

// Add extension:
extension Notification.Name {
  static let syncWidgetData = Notification.Name("syncWidgetData")
}
```

**Step 4: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' build`

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: integrate widget data sync in main app"
```

---

## Phase 3: Home Screen Widgets

### Task 3.1: Create Balance Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/BalanceWidget.swift`
- Create: `FinPessoalWidgets/Views/BalanceWidgetView.swift`

**Step 1: Create BalanceWidgetView**

Create file `FinPessoalWidgets/Views/BalanceWidgetView.swift`:

```swift
import SwiftUI
import WidgetKit

struct BalanceWidgetView: View {
  let data: WidgetData
  let family: WidgetFamily

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      smallView
    }
  }

  // MARK: - Small

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Saldo Total", systemImage: "banknote")
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(formattedBalance)
        .font(.title2)
        .fontWeight(.bold)
        .minimumScaleFactor(0.5)

      Spacer()

      HStack {
        trendIndicator
        Text(trendText)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Saldo total: \(formattedBalance). \(trendText)")
  }

  // MARK: - Medium

  private var mediumView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Label("Saldo Total", systemImage: "banknote")
          .font(.caption)
          .foregroundStyle(.secondary)

        Text(formattedBalance)
          .font(.title)
          .fontWeight(.bold)

        HStack {
          trendIndicator
          Text(trendText)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 8) {
        accountTypeRow(icon: "building.columns", label: "Corrente", value: checkingBalance)
        accountTypeRow(icon: "dollarsign.circle", label: "Poupança", value: savingsBalance)
        accountTypeRow(icon: "chart.line.uptrend.xyaxis", label: "Investimentos", value: investmentBalance)
      }
    }
    .padding()
  }

  // MARK: - Large

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Label("Saldo Total", systemImage: "banknote")
            .font(.caption)
            .foregroundStyle(.secondary)

          Text(formattedBalance)
            .font(.largeTitle)
            .fontWeight(.bold)
        }

        Spacer()

        trendIndicator
          .font(.title2)
      }

      Divider()

      // Account List
      Text("Contas")
        .font(.headline)

      ForEach(data.accounts.prefix(3)) { account in
        HStack {
          Image(systemName: iconForAccountType(account.type))
            .foregroundStyle(.blue)
          Text(account.name)
            .font(.subheadline)
          Spacer()
          Text(formatCurrency(account.balance))
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }

      Spacer()

      // Last updated
      Text("Atualizado: \(formattedLastUpdate)")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
    .padding()
  }

  // MARK: - Helpers

  private var formattedBalance: String {
    formatCurrency(data.totalBalance)
  }

  private var trendIndicator: some View {
    let isPositive = data.monthlyIncome >= data.monthlyExpenses
    return Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
      .foregroundStyle(isPositive ? .green : .red)
  }

  private var trendText: String {
    let net = data.monthlyIncome - data.monthlyExpenses
    let sign = net >= 0 ? "+" : ""
    return "\(sign)\(formatCurrency(net)) este mês"
  }

  private var checkingBalance: Decimal {
    data.accounts.filter { $0.type == "checking" }.reduce(0) { $0 + $1.balance }
  }

  private var savingsBalance: Decimal {
    data.accounts.filter { $0.type == "savings" }.reduce(0) { $0 + $1.balance }
  }

  private var investmentBalance: Decimal {
    data.accounts.filter { $0.type == "investment" }.reduce(0) { $0 + $1.balance }
  }

  private func accountTypeRow(icon: String, label: String, value: Decimal) -> some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(formatCurrency(value))
        .font(.caption)
        .fontWeight(.medium)
    }
  }

  private func iconForAccountType(_ type: String) -> String {
    switch type {
    case "checking": return "building.columns"
    case "savings": return "dollarsign.circle"
    case "investment": return "chart.line.uptrend.xyaxis"
    case "credit": return "creditcard"
    default: return "banknote"
    }
  }

  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
  }

  private var formattedLastUpdate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.localizedString(for: data.lastUpdated, relativeTo: Date())
  }
}
```

**Step 2: Create BalanceWidget**

Create file `FinPessoalWidgets/HomeScreen/BalanceWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct BalanceWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BalanceWidgetEntry {
    BalanceWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BalanceWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BalanceWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BalanceWidgetEntry(date: Date(), data: data)

    // Refresh every 30 minutes
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

struct BalanceWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

struct BalanceWidget: Widget {
  let kind: String = "BalanceWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BalanceWidgetProvider()) { entry in
      BalanceWidgetView(data: entry.data, family: .systemSmall)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Saldo")
    .description("Visualize seu saldo total rapidamente.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

#Preview(as: .systemSmall) {
  BalanceWidget()
} timeline: {
  BalanceWidgetEntry(date: Date(), data: .empty)
}
```

**Step 3: Update WidgetBundle**

Modify `FinPessoalWidgets/FinPessoalWidgetsBundle.swift`:

```swift
import WidgetKit
import SwiftUI

@main
struct FinPessoalWidgetsBundle: WidgetBundle {
  var body: some Widget {
    BalanceWidget()
  }
}
```

**Step 4: Build widget extension**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoalWidgets -destination 'platform=iOS Simulator,name=iPhone 15' build`

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add Balance widget (small/medium/large)"
```

---

### Task 3.2: Create Budget Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/BudgetWidget.swift`
- Create: `FinPessoalWidgets/Views/BudgetWidgetView.swift`

**Step 1: Create BudgetWidgetView**

Create file `FinPessoalWidgets/Views/BudgetWidgetView.swift`:

```swift
import SwiftUI
import WidgetKit

struct BudgetWidgetView: View {
  let data: WidgetData
  let family: WidgetFamily

  var body: some View {
    switch family {
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      mediumView
    }
  }

  // MARK: - Medium

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Orçamentos", systemImage: "chart.pie")
        .font(.caption)
        .foregroundStyle(.secondary)

      if data.budgets.isEmpty {
        emptyState
      } else {
        ForEach(data.budgets.prefix(3)) { budget in
          budgetRow(budget)
        }
      }
    }
    .padding()
  }

  // MARK: - Large

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Orçamentos", systemImage: "chart.pie")
        .font(.headline)

      if data.budgets.isEmpty {
        emptyState
      } else {
        ForEach(data.budgets) { budget in
          budgetRowLarge(budget)
        }
      }

      Spacer()
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Text("Nenhum orçamento")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  private func budgetRow(_ budget: BudgetSummary) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Image(systemName: budget.categoryIcon)
          .font(.caption)
        Text(budget.name)
          .font(.caption)
          .lineLimit(1)
        Spacer()
        Text("\(Int(budget.percentage))%")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundStyle(colorForPercentage(budget.percentage))
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 2)
            .fill(Color.gray.opacity(0.2))

          RoundedRectangle(cornerRadius: 2)
            .fill(colorForPercentage(budget.percentage))
            .frame(width: geometry.size.width * min(1, budget.percentage / 100))
        }
      }
      .frame(height: 4)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(budget.name): \(Int(budget.percentage))% utilizado")
  }

  private func budgetRowLarge(_ budget: BudgetSummary) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Image(systemName: budget.categoryIcon)
          .foregroundStyle(colorForPercentage(budget.percentage))
        Text(budget.name)
          .font(.subheadline)
          .fontWeight(.medium)
        Spacer()
        Text(formatCurrency(budget.spent))
          .font(.caption)
        Text("/")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(formatCurrency(budget.limit))
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.2))

          RoundedRectangle(cornerRadius: 3)
            .fill(colorForPercentage(budget.percentage))
            .frame(width: geometry.size.width * min(1, budget.percentage / 100))
        }
      }
      .frame(height: 6)
    }
    .padding(.vertical, 2)
  }

  // MARK: - Helpers

  private func colorForPercentage(_ percentage: Double) -> Color {
    switch percentage {
    case ..<75: return .green
    case 75..<90: return .yellow
    case 90..<100: return .orange
    default: return .red
    }
  }

  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.maximumFractionDigits = 0
    return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0"
  }
}
```

**Step 2: Create BudgetWidget**

Create file `FinPessoalWidgets/HomeScreen/BudgetWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct BudgetWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BudgetWidgetEntry {
    BudgetWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BudgetWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BudgetWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BudgetWidgetEntry(date: Date(), data: data)

    // Refresh every hour
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

struct BudgetWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

struct BudgetWidget: Widget {
  let kind: String = "BudgetWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BudgetWidgetProvider()) { entry in
      BudgetWidgetView(data: entry.data, family: .systemMedium)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Orçamentos")
    .description("Acompanhe seus orçamentos.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}
```

**Step 3: Add to WidgetBundle**

Update `FinPessoalWidgetsBundle.swift`:

```swift
@main
struct FinPessoalWidgetsBundle: WidgetBundle {
  var body: some Widget {
    BalanceWidget()
    BudgetWidget()
  }
}
```

**Step 4: Build and commit**

```bash
xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoalWidgets -destination 'platform=iOS Simulator,name=iPhone 15' build
git add -A
git commit -m "feat: add Budget widget (medium/large)"
```

---

### Task 3.3: Create Bills Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/BillsWidget.swift`
- Create: `FinPessoalWidgets/Views/BillsWidgetView.swift`

**Step 1: Create BillsWidgetView**

Create file `FinPessoalWidgets/Views/BillsWidgetView.swift`:

```swift
import SwiftUI
import WidgetKit

struct BillsWidgetView: View {
  let data: WidgetData
  let family: WidgetFamily

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    default:
      smallView
    }
  }

  // MARK: - Small

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Próximo", systemImage: "calendar.badge.clock")
        .font(.caption)
        .foregroundStyle(.secondary)

      if let nextBill = data.upcomingBills.first {
        Spacer()

        Text(nextBill.name)
          .font(.headline)
          .lineLimit(1)

        Text(formatCurrency(nextBill.amount))
          .font(.title3)
          .fontWeight(.bold)

        Spacer()

        HStack {
          if nextBill.isOverdue {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(.red)
            Text("Vencido")
              .font(.caption)
              .foregroundStyle(.red)
          } else {
            Image(systemName: "clock")
              .foregroundStyle(colorForDays(nextBill.daysUntilDue))
            Text(daysText(nextBill.daysUntilDue))
              .font(.caption)
              .foregroundStyle(colorForDays(nextBill.daysUntilDue))
          }
        }
      } else {
        Spacer()
        Text("Nenhuma conta")
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer()
      }
    }
    .padding()
  }

  // MARK: - Medium

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Contas a Pagar", systemImage: "calendar.badge.clock")
          .font(.caption)
          .foregroundStyle(.secondary)

        Spacer()

        if !data.upcomingBills.isEmpty {
          Text("\(data.upcomingBills.count) pendentes")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }

      if data.upcomingBills.isEmpty {
        emptyState
      } else {
        ForEach(data.upcomingBills.prefix(3)) { bill in
          billRow(bill)
        }
      }
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Image(systemName: "checkmark.circle")
        .font(.title)
        .foregroundStyle(.green)
      Text("Tudo em dia!")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  private func billRow(_ bill: BillSummary) -> some View {
    HStack {
      Image(systemName: bill.categoryIcon)
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 0) {
        Text(bill.name)
          .font(.caption)
          .lineLimit(1)
        Text(formatDate(bill.dueDate))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(formatCurrency(bill.amount))
          .font(.caption)
          .fontWeight(.medium)

        if bill.isOverdue {
          Text("Vencido")
            .font(.caption2)
            .foregroundStyle(.red)
        } else {
          Text(daysText(bill.daysUntilDue))
            .font(.caption2)
            .foregroundStyle(colorForDays(bill.daysUntilDue))
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(bill.name), \(formatCurrency(bill.amount)), \(bill.isOverdue ? "vencido" : "vence em \(bill.daysUntilDue) dias")")
  }

  // MARK: - Helpers

  private func daysText(_ days: Int) -> String {
    switch days {
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "em \(days) dias"
    }
  }

  private func colorForDays(_ days: Int) -> Color {
    switch days {
    case ..<0: return .red
    case 0...1: return .orange
    case 2...3: return .yellow
    default: return .secondary
    }
  }

  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
}
```

**Step 2: Create BillsWidget**

Create file `FinPessoalWidgets/HomeScreen/BillsWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct BillsWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BillsWidgetEntry {
    BillsWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BillsWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BillsWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BillsWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BillsWidgetEntry(date: Date(), data: data)

    // Refresh every hour
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

struct BillsWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

struct BillsWidget: Widget {
  let kind: String = "BillsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BillsWidgetProvider()) { entry in
      BillsWidgetView(data: entry.data, family: .systemSmall)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Contas a Pagar")
    .description("Veja suas próximas contas.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
```

**Step 3: Add to WidgetBundle and commit**

```bash
# Update bundle, build, and commit
git add -A
git commit -m "feat: add Bills widget (small/medium)"
```

---

### Task 3.4: Create Goals Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/GoalsWidget.swift`
- Create: `FinPessoalWidgets/Views/GoalsWidgetView.swift`

*(Similar pattern to previous widgets - creates small/medium/large views with goal progress rings)*

**Step 1-4: Create GoalsWidgetView and GoalsWidget** (similar structure)

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add Goals widget (small/medium/large)"
```

---

### Task 3.5: Create Credit Card Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/CreditCardWidget.swift`
- Create: `FinPessoalWidgets/Views/CreditCardWidgetView.swift`

*(Creates small gauge for utilization, medium for per-card breakdown)*

**Commit:**

```bash
git add -A
git commit -m "feat: add Credit Card widget (small/medium)"
```

---

### Task 3.6: Create Transactions Widget

**Files:**
- Create: `FinPessoalWidgets/HomeScreen/TransactionsWidget.swift`
- Create: `FinPessoalWidgets/Views/TransactionsWidgetView.swift`

*(Creates medium/large views showing recent transactions with category icons)*

**Commit:**

```bash
git add -A
git commit -m "feat: add Transactions widget (medium/large)"
```

---

## Phase 4: Lock Screen Widgets

### Task 4.1: Create Lock Screen Widget Views

**Files:**
- Create: `FinPessoalWidgets/LockScreen/BalanceLockWidget.swift`
- Create: `FinPessoalWidgets/LockScreen/BillsLockWidget.swift`
- Create: `FinPessoalWidgets/LockScreen/BudgetLockWidget.swift`
- Create: `FinPessoalWidgets/LockScreen/GoalsLockWidget.swift`
- Create: `FinPessoalWidgets/LockScreen/QuickExpenseLockWidget.swift`

**Step 1: Create BalanceLockWidget**

```swift
import WidgetKit
import SwiftUI

struct BalanceLockWidget: Widget {
  let kind: String = "BalanceLockWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BalanceWidgetProvider()) { entry in
      BalanceLockWidgetView(data: entry.data)
    }
    .configurationDisplayName("Saldo")
    .description("Saldo total na tela de bloqueio.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular])
  }
}

struct BalanceLockWidgetView: View {
  let data: WidgetData
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectangularView
    default:
      circularView
    }
  }

  private var circularView: some View {
    VStack(spacing: 0) {
      Image(systemName: "banknote")
        .font(.caption)
      Text(abbreviatedBalance)
        .font(.caption2)
        .fontWeight(.bold)
    }
    .accessibilityLabel("Saldo: \(formattedBalance)")
  }

  private var rectangularView: some View {
    HStack {
      Image(systemName: "banknote")
      VStack(alignment: .leading) {
        Text("Saldo")
          .font(.caption2)
        Text(formattedBalance)
          .font(.caption)
          .fontWeight(.bold)
      }
    }
  }

  private var abbreviatedBalance: String {
    let value = Double(truncating: data.totalBalance as NSDecimalNumber)
    if value >= 1000 {
      return String(format: "R$%.1fk", value / 1000)
    }
    return String(format: "R$%.0f", value)
  }

  private var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: data.totalBalance as NSDecimalNumber) ?? "R$ 0"
  }
}
```

**Step 2-5: Create remaining Lock Screen widgets** (similar pattern)

**Step 6: Update WidgetBundle with all Lock Screen widgets**

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: add Lock Screen widgets (Balance, Bills, Budget, Goals, Quick Expense)"
```

---

## Phase 5: Live Activities

### Task 5.1: Create Activity Attributes

**Files:**
- Create: `FinPessoalWidgets/LiveActivities/FinPessoalActivityAttributes.swift`

**Step 1: Create activity attributes**

```swift
import ActivityKit
import Foundation

struct BillReminderAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var daysRemaining: Int
    var isPaid: Bool
  }

  var billId: String
  var billName: String
  var amount: Decimal
  var dueDate: Date
}

struct BudgetAlertAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var currentSpent: Decimal
    var percentage: Double
  }

  var budgetId: String
  var budgetName: String
  var budgetLimit: Decimal
  var categoryIcon: String
}

struct GoalMilestoneAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var currentAmount: Decimal
    var milestone: Int // 25, 50, 75, 100
  }

  var goalId: String
  var goalName: String
  var targetAmount: Decimal
}

struct CreditCardReminderAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var daysRemaining: Int
    var isPaid: Bool
  }

  var cardId: String
  var cardName: String
  var statementBalance: Decimal
  var dueDate: Date
}
```

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: add Live Activity attributes"
```

---

### Task 5.2: Create Live Activity Views

**Files:**
- Create: `FinPessoalWidgets/LiveActivities/BillReminderActivity.swift`
- Create: `FinPessoalWidgets/LiveActivities/BudgetAlertActivity.swift`
- Create: `FinPessoalWidgets/LiveActivities/GoalMilestoneActivity.swift`
- Create: `FinPessoalWidgets/LiveActivities/CreditCardReminderActivity.swift`

**Step 1: Create BillReminderActivity**

```swift
import ActivityKit
import SwiftUI
import WidgetKit

struct BillReminderLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: BillReminderAttributes.self) { context in
      // Lock Screen view
      BillReminderLockScreenView(
        attributes: context.attributes,
        state: context.state
      )
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded view
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "calendar.badge.clock")
            .foregroundStyle(.orange)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(context.state.daysRemaining == 0 ? "Hoje" : "\(context.state.daysRemaining)d")
            .font(.title2)
            .fontWeight(.bold)
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.billName)
            .font(.headline)
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack {
            Text(formatCurrency(context.attributes.amount))
              .font(.title3)
              .fontWeight(.semibold)
            Spacer()
            Link(destination: URL(string: "finpessoal://pay-bill/\(context.attributes.billId)")!) {
              Text("Pagar")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
          }
        }
      } compactLeading: {
        Image(systemName: "calendar.badge.clock")
          .foregroundStyle(.orange)
      } compactTrailing: {
        Text("\(context.state.daysRemaining)d")
          .fontWeight(.bold)
      } minimal: {
        Image(systemName: "calendar.badge.clock")
          .foregroundStyle(.orange)
      }
    }
  }

  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0"
  }
}

struct BillReminderLockScreenView: View {
  let attributes: BillReminderAttributes
  let state: BillReminderAttributes.ContentState

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Label(attributes.billName, systemImage: "calendar.badge.clock")
          .font(.headline)
        Text(formatCurrency(attributes.amount))
          .font(.title2)
          .fontWeight(.bold)
      }

      Spacer()

      VStack(alignment: .trailing) {
        if state.isPaid {
          Label("Pago", systemImage: "checkmark.circle.fill")
            .foregroundStyle(.green)
        } else if state.daysRemaining == 0 {
          Text("Vence Hoje")
            .foregroundStyle(.orange)
            .fontWeight(.bold)
        } else if state.daysRemaining < 0 {
          Text("Vencido")
            .foregroundStyle(.red)
            .fontWeight(.bold)
        } else {
          Text("em \(state.daysRemaining) dias")
            .foregroundStyle(.secondary)
        }

        if !state.isPaid {
          Link(destination: URL(string: "finpessoal://pay-bill/\(attributes.billId)")!) {
            Text("Pagar Agora")
              .font(.caption)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(.blue)
              .foregroundStyle(.white)
              .clipShape(Capsule())
          }
        }
      }
    }
    .padding()
  }

  private func formatCurrency(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0"
  }
}
```

**Step 2-4: Create remaining Live Activity widgets** (similar pattern)

**Step 5: Update WidgetBundle**

```swift
@main
struct FinPessoalWidgetsBundle: WidgetBundle {
  var body: some Widget {
    // Home Screen
    BalanceWidget()
    BudgetWidget()
    BillsWidget()
    GoalsWidget()
    CreditCardWidget()
    TransactionsWidget()

    // Lock Screen
    BalanceLockWidget()
    BillsLockWidget()
    BudgetLockWidget()
    GoalsLockWidget()
    QuickExpenseLockWidget()

    // Live Activities
    BillReminderLiveActivity()
    BudgetAlertLiveActivity()
    GoalMilestoneLiveActivity()
    CreditCardReminderLiveActivity()
  }
}
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add Live Activities (Bill, Budget, Goal, Credit Card)"
```

---

### Task 5.3: Create LiveActivityManager

**Files:**
- Create: `FinPessoal/Code/Core/Services/LiveActivityManager.swift`

**Step 1: Create LiveActivityManager**

```swift
import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {

  static let shared = LiveActivityManager()

  private init() {}

  // MARK: - Bill Reminders

  func startBillReminder(bill: Bill) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    let attributes = BillReminderAttributes(
      billId: bill.id,
      billName: bill.name,
      amount: bill.amount,
      dueDate: bill.nextDueDate
    )

    let state = BillReminderAttributes.ContentState(
      daysRemaining: bill.daysUntilDue,
      isPaid: bill.status == .paid
    )

    do {
      _ = try Activity.request(
        attributes: attributes,
        content: .init(state: state, staleDate: nil)
      )
    } catch {
      print("Failed to start bill reminder activity: \(error)")
    }
  }

  func updateBillReminder(billId: String, daysRemaining: Int, isPaid: Bool) async {
    let state = BillReminderAttributes.ContentState(
      daysRemaining: daysRemaining,
      isPaid: isPaid
    )

    for activity in Activity<BillReminderAttributes>.activities {
      if activity.attributes.billId == billId {
        await activity.update(using: state)
      }
    }
  }

  func endBillReminder(billId: String) async {
    for activity in Activity<BillReminderAttributes>.activities {
      if activity.attributes.billId == billId {
        await activity.end(dismissalPolicy: .immediate)
      }
    }
  }

  // MARK: - Budget Alerts

  func startBudgetAlert(budget: Budget) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    let attributes = BudgetAlertAttributes(
      budgetId: budget.id,
      budgetName: budget.name,
      budgetLimit: budget.budgetAmount,
      categoryIcon: budget.category.icon
    )

    let percentage = Double(truncating: (budget.spent / budget.budgetAmount * 100) as NSDecimalNumber)
    let state = BudgetAlertAttributes.ContentState(
      currentSpent: budget.spent,
      percentage: percentage
    )

    do {
      _ = try Activity.request(
        attributes: attributes,
        content: .init(state: state, staleDate: nil)
      )
    } catch {
      print("Failed to start budget alert activity: \(error)")
    }
  }

  // MARK: - Goal Milestones

  func startGoalMilestone(goal: Goal, milestone: Int) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

    let attributes = GoalMilestoneAttributes(
      goalId: goal.id,
      goalName: goal.name,
      targetAmount: goal.targetAmount
    )

    let state = GoalMilestoneAttributes.ContentState(
      currentAmount: goal.currentAmount,
      milestone: milestone
    )

    do {
      _ = try Activity.request(
        attributes: attributes,
        content: .init(state: state, staleDate: nil)
      )
    } catch {
      print("Failed to start goal milestone activity: \(error)")
    }
  }
}
```

**Step 2: Commit**

```bash
git add -A
git commit -m "feat: add LiveActivityManager for managing Live Activities"
```

---

## Phase 6: Deep Links & Integration

### Task 6.1: Add Deep Link Handling

**Files:**
- Modify: `FinPessoal/FinPessoalApp.swift`
- Create: `FinPessoal/Code/Core/Navigation/DeepLinkHandler.swift`

**Step 1: Create DeepLinkHandler**

```swift
import Foundation

enum DeepLink {
  case addTransaction
  case payBill(String)
  case viewBudget(String)
  case viewGoal(String)
  case viewCard(String)

  init?(url: URL) {
    guard url.scheme == "finpessoal" else { return nil }

    switch url.host {
    case "add-transaction":
      self = .addTransaction
    case "pay-bill":
      guard let id = url.pathComponents.dropFirst().first else { return nil }
      self = .payBill(id)
    case "view-budget":
      guard let id = url.pathComponents.dropFirst().first else { return nil }
      self = .viewBudget(id)
    case "view-goal":
      guard let id = url.pathComponents.dropFirst().first else { return nil }
      self = .viewGoal(id)
    case "view-card":
      guard let id = url.pathComponents.dropFirst().first else { return nil }
      self = .viewCard(id)
    default:
      return nil
    }
  }
}

@MainActor
final class DeepLinkHandler: ObservableObject {
  @Published var pendingDeepLink: DeepLink?

  func handle(_ url: URL) {
    pendingDeepLink = DeepLink(url: url)
  }
}
```

**Step 2: Integrate in FinPessoalApp**

Add to `FinPessoalApp.swift`:

```swift
@StateObject private var deepLinkHandler = DeepLinkHandler()

// In body:
.onOpenURL { url in
  deepLinkHandler.handle(url)
}
.environmentObject(deepLinkHandler)
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add deep link handling for widgets"
```

---

### Task 6.2: Add Widget Previews and Tests

**Files:**
- Create: `FinPessoalWidgets/Previews/WidgetPreviews.swift`
- Create: `FinPessoalTests/Widgets/WidgetDataProviderTests.swift`

**Step 1: Create preview data**

```swift
import WidgetKit

extension WidgetData {
  static let preview = WidgetData(
    lastUpdated: Date(),
    totalBalance: 15750.50,
    monthlyIncome: 8500,
    monthlyExpenses: 5200,
    accounts: [
      AccountSummary(id: "1", name: "Nubank", type: "checking", balance: 5200, currency: "BRL"),
      AccountSummary(id: "2", name: "Poupança", type: "savings", balance: 8000, currency: "BRL"),
      AccountSummary(id: "3", name: "Investimentos", type: "investment", balance: 2550.50, currency: "BRL")
    ],
    budgets: [
      BudgetSummary(id: "1", name: "Alimentação", category: "food", categoryIcon: "fork.knife", spent: 850, limit: 1000),
      BudgetSummary(id: "2", name: "Transporte", category: "transport", categoryIcon: "car.fill", spent: 420, limit: 500),
      BudgetSummary(id: "3", name: "Lazer", category: "entertainment", categoryIcon: "gamecontroller.fill", spent: 380, limit: 300)
    ],
    upcomingBills: [
      BillSummary(id: "1", name: "Aluguel", amount: 1500, dueDate: Date().addingTimeInterval(86400 * 3), status: "upcoming", categoryIcon: "house.fill"),
      BillSummary(id: "2", name: "Internet", amount: 120, dueDate: Date().addingTimeInterval(86400 * 5), status: "upcoming", categoryIcon: "wifi"),
      BillSummary(id: "3", name: "Energia", amount: 180, dueDate: Date().addingTimeInterval(-86400), status: "overdue", categoryIcon: "bolt.fill")
    ],
    goals: [
      GoalSummary(id: "1", name: "Viagem", currentAmount: 3500, targetAmount: 5000, targetDate: Date().addingTimeInterval(86400 * 90), categoryIcon: "airplane"),
      GoalSummary(id: "2", name: "Emergência", currentAmount: 8000, targetAmount: 10000, targetDate: nil, categoryIcon: "shield.fill")
    ],
    creditCards: [
      CardSummary(id: "1", name: "Nubank", currentBalance: 1200, creditLimit: 5000, dueDate: Date().addingTimeInterval(86400 * 10), brand: "mastercard")
    ],
    recentTransactions: [
      TransactionSummary(id: "1", description: "Supermercado", amount: 250, date: Date(), type: "expense", category: "food", categoryIcon: "cart.fill"),
      TransactionSummary(id: "2", description: "Salário", amount: 5000, date: Date().addingTimeInterval(-86400), type: "income", category: "salary", categoryIcon: "banknote.fill")
    ]
  )
}
```

**Step 2: Add widget tests**

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: add widget previews and tests"
```

---

## Phase 7: Final Integration

### Task 7.1: Update Info.plist and Entitlements

**Files:**
- Modify: `FinPessoal/Info.plist`
- Modify: `FinPessoalWidgets/Info.plist`

**Step 1: Add URL scheme**

Add to main app Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>finpessoal</string>
    </array>
  </dict>
</array>
```

**Step 2: Add Supports Live Activities**

Add to widget extension Info.plist:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: configure Info.plist for widgets and deep links"
```

---

### Task 7.2: Update Changelog and Documentation

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `README.md`

**Step 1: Update CHANGELOG**

Add entry for widget implementation.

**Step 2: Update README**

Add widgets section to README.

**Step 3: Final commit**

```bash
git add -A
git commit -m "docs: update changelog and readme for widget suite"
```

---

## Summary

**Total Tasks:** 22 tasks across 7 phases
**Estimated Commits:** 22+ commits

**Phase Breakdown:**
1. Project Setup: 3 tasks
2. Shared Data Layer: 3 tasks
3. Home Screen Widgets: 6 tasks
4. Lock Screen Widgets: 1 task (batch)
5. Live Activities: 3 tasks
6. Deep Links & Integration: 2 tasks
7. Final Integration: 2 tasks

**Key Files Created:**
- `Shared/Models/` - 7 model files
- `Shared/Services/` - 2 service files
- `FinPessoalWidgets/HomeScreen/` - 6 widget files
- `FinPessoalWidgets/LockScreen/` - 5 widget files
- `FinPessoalWidgets/LiveActivities/` - 5 activity files
- `FinPessoalWidgets/Views/` - 6 view files
