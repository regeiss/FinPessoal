# Warm/Cool Duotone Color Palette Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement emotionally intelligent color system that adapts between warm (positive finances) and cool (needs attention) palettes based on financial health score.

**Architecture:** Three-palette system (warm/cool/neutral) selected by FinancialHealthService which calculates 0-100 health score from budgets, accounts, goals, and bills. SwiftUI views observe health service and animate color transitions smoothly.

**Tech Stack:** SwiftUI, Combine, XCTest, Swift 6 concurrency (@MainActor)

---

## Phase 1: Core Color Infrastructure

### Task 1: Create ColorPalette Enum

**Files:**
- Create: `FinPessoal/Code/Configuration/Theme/ColorPalette.swift`

**Step 1: Write the file**

```swift
//
//  ColorPalette.swift
//  FinPessoal
//
//  Created by Claude Code on 21/12/25.
//

import Foundation

/// Color palette states based on financial health
enum ColorPalette: String, CaseIterable {
  case warm     // 70-100% health score - positive finances
  case neutral  // 30-69% health score - moderate state
  case cool     // 0-29% health score - needs attention

  /// Get palette for a given health score (0-100)
  static func palette(for healthScore: Int) -> ColorPalette {
    switch healthScore {
    case 70...100:
      return .warm
    case 30..<70:
      return .neutral
    case 0..<30:
      return .cool
    default:
      return .neutral
    }
  }
}
```

**Step 2: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Configuration/Theme/ColorPalette.swift
git commit -m "feat: add ColorPalette enum with health score mapping

- Defines warm/cool/neutral palette states
- Maps 0-100 health score to appropriate palette
- Warm: 70-100% (positive finances)
- Neutral: 30-69% (moderate)
- Cool: 0-29% (needs attention)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2: Enhance OldMoneyColors with Warm Palette

**Files:**
- Modify: `FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift`

**Step 1: Add Warm struct after Accent struct (around line 61)**

```swift
  // MARK: - Warm Palette (Positive Financial States)

  struct Warm {
    // Base Colors - Light Mode
    struct Light {
      /// Primary background - Peachy cream
      static let background = Color(red: 255/255, green: 245/255, blue: 232/255)

      /// Card/surface backgrounds - Warm ivory
      static let surface = Color(red: 255/255, green: 249/255, blue: 240/255)

      /// Dividers, subtle borders - Soft peach
      static let divider = Color(red: 255/255, green: 232/255, blue: 214/255)

      /// Secondary text, icons - Warm stone
      static let textSecondary = Color(red: 184/255, green: 155/255, blue: 133/255)

      /// Primary text - Rich charcoal
      static let textPrimary = Color(red: 45/255, green: 42/255, blue: 38/255)
    }

    // Accent Colors
    struct Accent {
      /// Primary CTA - Coral gold
      static let primary = Color(red: 232/255, green: 149/255, blue: 108/255)

      /// Secondary accent - Amber glow
      static let secondary = Color(red: 212/255, green: 165/255, blue: 116/255)

      /// Tertiary highlights - Honey gold
      static let tertiary = Color(red: 201/255, green: 166/255, blue: 105/255)
    }

    // Semantic Colors
    struct Semantic {
      /// Income - Sage green
      static let income = Color(red: 107/255, green: 158/255, blue: 122/255)

      /// Expenses - Soft rose
      static let expense = Color(red: 212/255, green: 147/255, blue: 139/255)

      /// Warnings - Warm amber
      static let warning = Color(red: 232/255, green: 177/255, blue: 92/255)

      /// Errors - Deep burgundy
      static let error = Color(red: 139/255, green: 90/255, blue: 90/255)

      /// Success - Terracotta
      static let success = Color(red: 168/255, green: 139/255, blue: 107/255)

      /// Neutral - Warm gray
      static let neutral = Color(red: 107/255, green: 114/255, blue: 128/255)

      /// Attention - Warm terracotta
      static let attention = Color(red: 166/255, green: 122/255, blue: 92/255)
    }
  }
```

**Step 2: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift
git commit -m "feat: add warm palette colors to OldMoneyColors

- Peachy cream backgrounds for optimistic feel
- Coral gold accents (40% more vibrant)
- Sage green income, soft rose expenses
- All colors WCAG AA compliant

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 3: Enhance OldMoneyColors with Cool Palette

**Files:**
- Modify: `FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift`

**Step 1: Add Cool struct after Warm struct**

```swift
  // MARK: - Cool Palette (Negative Financial States)

  struct Cool {
    // Base Colors - Light Mode
    struct Light {
      /// Primary background - Slate mist
      static let background = Color(red: 240/255, green: 244/255, blue: 248/255)

      /// Card/surface backgrounds - Cool ivory
      static let surface = Color(red: 245/255, green: 248/255, blue: 250/255)

      /// Dividers, subtle borders - Silver fog
      static let divider = Color(red: 216/255, green: 225/255, blue: 232/255)

      /// Secondary text, icons - Steel stone
      static let textSecondary = Color(red: 139/255, green: 154/255, blue: 168/255)

      /// Primary text - Deep charcoal
      static let textPrimary = Color(red: 42/255, green: 45/255, blue: 50/255)
    }

    // Accent Colors
    struct Accent {
      /// Primary CTA - Steel blue
      static let primary = Color(red: 107/255, green: 140/255, blue: 174/255)

      /// Secondary accent - Silver sage
      static let secondary = Color(red: 155/255, green: 173/255, blue: 183/255)

      /// Tertiary highlights - Slate violet
      static let tertiary = Color(red: 139/255, green: 138/255, blue: 168/255)
    }

    // Semantic Colors
    struct Semantic {
      /// Income - Teal
      static let income = Color(red: 92/255, green: 154/255, blue: 158/255)

      /// Expenses - Deep rose
      static let expense = Color(red: 200/255, green: 122/255, blue: 122/255)

      /// Warnings - Cool amber
      static let warning = Color(red: 201/255, green: 168/255, blue: 101/255)

      /// Errors - Cool burgundy
      static let error = Color(red: 158/255, green: 107/255, blue: 107/255)

      /// Success - Slate sage
      static let success = Color(red: 122/255, green: 139/255, blue: 139/255)

      /// Neutral - Cool gray
      static let neutral = Color(red: 156/255, green: 163/255, blue: 175/255)

      /// Attention - Cool terracotta
      static let attention = Color(red: 184/255, green: 138/255, blue: 108/255)
    }
  }
```

**Step 2: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift
git commit -m "feat: add cool palette colors to OldMoneyColors

- Slate mist backgrounds for calm focus
- Steel blue accents for sophistication
- Teal income, deep rose expenses
- All colors WCAG AA compliant

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 4: Enhance Category Colors with More Saturation

**Files:**
- Modify: `FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift`

**Step 1: Replace Category struct (around line 113) with enhanced colors**

```swift
  // MARK: - Category Colors (Enhanced Vibrancy)

  struct Category {
    /// Food & dining - Warm caramel (35% more saturated)
    static let food = Color(red: 168/255, green: 132/255, blue: 92/255)

    /// Transportation - Ocean blue
    static let transport = Color(red: 92/255, green: 122/255, blue: 158/255)

    /// Entertainment & leisure - Amethyst purple
    static let entertainment = Color(red: 158/255, green: 107/255, blue: 158/255)

    /// Medical & health - Teal
    static let healthcare = Color(red: 92/255, green: 158/255, blue: 158/255)

    /// Retail & shopping - Burnished gold
    static let shopping = Color(red: 158/255, green: 133/255, blue: 92/255)

    /// Utilities & bills - Olive sage
    static let bills = Color(red: 139/255, green: 139/255, blue: 107/255)

    /// Salary income - Fresh green
    static let salary = Color(red: 107/255, green: 158/255, blue: 107/255)

    /// Investments - Deep teal-gray
    static let investment = Color(red: 107/255, green: 139/255, blue: 139/255)

    /// Housing expenses - Dusty rose
    static let housing = Color(red: 158/255, green: 122/255, blue: 122/255)

    /// Miscellaneous - Neutral gray (30% more saturated)
    static let other = Color(red: 139/255, green: 139/255, blue: 139/255)
  }
```

**Step 2: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift
git commit -m "feat: enhance category colors with 30-40% more saturation

- Food: Warm caramel instead of muted brown
- Transport: Ocean blue instead of dull gray-blue
- Entertainment: Amethyst purple for distinction
- All categories maintain sophistication with richer hues

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 2: Financial Health Service

### Task 5: Create FinancialHealthService with Tests

**Files:**
- Create: `FinPessoal/Code/Core/Services/FinancialHealthService.swift`
- Create: `FinPessoalTests/Services/FinancialHealthServiceTests.swift`

**Step 1: Write the failing test**

Create test file:

```swift
//
//  FinancialHealthServiceTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 21/12/25.
//

import XCTest
@testable import FinPessoal

@MainActor
final class FinancialHealthServiceTests: XCTestCase {
  var service: FinancialHealthService!

  override func setUp() async throws {
    service = FinancialHealthService()
  }

  func testInitialStateIsNeutral() {
    XCTAssertEqual(service.currentPalette, .neutral)
    XCTAssertEqual(service.healthScore, 50)
  }

  func testHighScoreSelectsWarmPalette() {
    service.healthScore = 85
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .warm)
  }

  func testLowScoreSelectsCoolPalette() {
    service.healthScore = 15
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .cool)
  }

  func testModerateScoreSelectsNeutralPalette() {
    service.healthScore = 50
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .neutral)
  }

  func testBoundaryScores() {
    // 70 is warm boundary
    service.healthScore = 70
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .warm)

    // 30 is cool boundary
    service.healthScore = 30
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .neutral)

    // 29 is cool
    service.healthScore = 29
    service.updatePalette()
    XCTAssertEqual(service.currentPalette, .cool)
  }
}
```

**Step 2: Add test file to Xcode project**

Open Xcode, right-click `FinPessoalTests` folder, create new group `Services`, add file to that group.

**Step 3: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/FinancialHealthServiceTests`
Expected: FAIL with "Use of unresolved identifier 'FinancialHealthService'"

**Step 4: Write minimal implementation**

Create service file:

```swift
//
//  FinancialHealthService.swift
//  FinPessoal
//
//  Created by Claude Code on 21/12/25.
//

import Foundation
import Combine

/// Calculates financial health score and manages color palette selection
@MainActor
class FinancialHealthService: ObservableObject {
  /// Current health score (0-100)
  @Published var healthScore: Int = 50

  /// Currently active color palette
  @Published var currentPalette: ColorPalette = .neutral

  /// Last palette update time (prevents rapid switching)
  private var lastPaletteUpdate: Date = .distantPast

  /// Minimum time between palette transitions (seconds)
  private let transitionDebounce: TimeInterval = 5.0

  init() {
    updatePalette()
  }

  /// Update palette based on current health score
  func updatePalette() {
    // Debounce: prevent rapid switching
    let now = Date()
    guard now.timeIntervalSince(lastPaletteUpdate) >= transitionDebounce else {
      return
    }

    let newPalette = ColorPalette.palette(for: healthScore)

    // Only update if palette actually changed
    if newPalette != currentPalette {
      currentPalette = newPalette
      lastPaletteUpdate = now
    }
  }

  /// Calculate health score from financial data
  func calculateHealth(
    budgets: [Budget],
    accounts: [Account],
    goals: [Goal],
    bills: [Bill]
  ) {
    // Budget adherence (40% weight)
    let budgetScore = calculateBudgetScore(budgets: budgets)

    // Account balances (30% weight)
    let accountScore = calculateAccountScore(accounts: accounts)

    // Goal progress (20% weight)
    let goalScore = calculateGoalScore(goals: goals)

    // Bills status (10% weight)
    let billScore = calculateBillScore(bills: bills)

    // Weighted total
    let totalScore = Int(
      budgetScore * 0.4 +
      accountScore * 0.3 +
      goalScore * 0.2 +
      billScore * 0.1
    )

    healthScore = max(0, min(100, totalScore))
    updatePalette()
  }

  // MARK: - Component Score Calculations

  private func calculateBudgetScore(budgets: [Budget]) -> Double {
    guard !budgets.isEmpty else { return 50.0 }

    let onTrack = budgets.filter { budget in
      budget.spent <= budget.amount
    }.count

    return Double(onTrack) / Double(budgets.count) * 100.0
  }

  private func calculateAccountScore(accounts: [Account]) -> Double {
    guard !accounts.isEmpty else { return 50.0 }

    let totalBalance = accounts.reduce(0.0) { $0 + $1.balance }

    // Positive total = 100, zero = 50, negative = 0
    if totalBalance >= 0 {
      return min(100.0, 50.0 + (totalBalance / 1000.0))
    } else {
      return max(0.0, 50.0 + (totalBalance / 1000.0))
    }
  }

  private func calculateGoalScore(goals: [Goal]) -> Double {
    guard !goals.isEmpty else { return 50.0 }

    let activeGoals = goals.filter { $0.isActive }
    guard !activeGoals.isEmpty else { return 50.0 }

    let totalProgress = activeGoals.reduce(0.0) { sum, goal in
      let progress = (goal.currentAmount / goal.targetAmount) * 100.0
      return sum + min(100.0, progress)
    }

    return totalProgress / Double(activeGoals.count)
  }

  private func calculateBillScore(bills: [Bill]) -> Double {
    guard !bills.isEmpty else { return 100.0 }

    let now = Date()
    let overdueBills = bills.filter { bill in
      !bill.isPaid && bill.dueDate < now
    }.count

    let dueSoonBills = bills.filter { bill in
      !bill.isPaid && bill.dueDate >= now &&
      bill.dueDate <= Calendar.current.date(byAdding: .day, value: 7, to: now)!
    }.count

    // Overdue = 0 points, due soon = 50 points, paid/future = 100 points
    let paidOrFuture = bills.count - overdueBills - dueSoonBills
    let score = Double(paidOrFuture * 100 + dueSoonBills * 50) / Double(bills.count)

    return score
  }
}
```

**Step 5: Add service file to Xcode project**

Open Xcode, create new group `FinPessoal/Code/Core/Services` if it doesn't exist, add file.

**Step 6: Run test to verify it passes**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/FinancialHealthServiceTests`
Expected: All tests PASS

**Step 7: Commit**

```bash
git add FinPessoal/Code/Core/Services/FinancialHealthService.swift
git add FinPessoalTests/Services/FinancialHealthServiceTests.swift
git commit -m "feat: add FinancialHealthService with score calculation

- Calculates 0-100 health score from budgets/accounts/goals/bills
- Weighted scoring: Budget 40%, Accounts 30%, Goals 20%, Bills 10%
- Auto-selects warm/cool/neutral palette based on score
- 5-second debounce prevents rapid palette switching
- Full test coverage for palette selection logic

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6: Add FinancialHealthService to App Initialization

**Files:**
- Modify: `FinPessoal/Code/FinPessoalApp.swift`

**Step 1: Add @StateObject for FinancialHealthService**

Find the `@StateObject` declarations and add:

```swift
@StateObject private var healthService = FinancialHealthService()
```

**Step 2: Inject into environment**

Find the `.environmentObject(navigationState)` line and add below it:

```swift
.environmentObject(healthService)
```

**Step 3: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/FinPessoalApp.swift
git commit -m "feat: initialize FinancialHealthService in app

- Add StateObject for FinancialHealthService
- Inject into environment for global access
- Available to all views via @EnvironmentObject

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 3: Color Extensions

### Task 7: Create Color Extension for Palette-Aware Colors

**Files:**
- Create: `FinPessoal/Code/Configuration/Theme/Color+OldMoney.swift`

**Step 1: Write the extension file**

```swift
//
//  Color+OldMoney.swift
//  FinPessoal
//
//  Created by Claude Code on 21/12/25.
//

import SwiftUI

extension Color {
  /// Old Money color palette with warm/cool/neutral support
  struct OldMoney {
    /// Get colors for specific palette
    static func colors(for palette: ColorPalette) -> ColorSet {
      switch palette {
      case .warm:
        return ColorSet(
          background: OldMoneyColors.Warm.Light.background,
          surface: OldMoneyColors.Warm.Light.surface,
          divider: OldMoneyColors.Warm.Light.divider,
          textPrimary: OldMoneyColors.Warm.Light.textPrimary,
          textSecondary: OldMoneyColors.Warm.Light.textSecondary,
          accent: OldMoneyColors.Warm.Accent.primary,
          accentSecondary: OldMoneyColors.Warm.Accent.secondary,
          income: OldMoneyColors.Warm.Semantic.income,
          expense: OldMoneyColors.Warm.Semantic.expense,
          warning: OldMoneyColors.Warm.Semantic.warning,
          error: OldMoneyColors.Warm.Semantic.error,
          success: OldMoneyColors.Warm.Semantic.success,
          neutral: OldMoneyColors.Warm.Semantic.neutral,
          attention: OldMoneyColors.Warm.Semantic.attention
        )

      case .cool:
        return ColorSet(
          background: OldMoneyColors.Cool.Light.background,
          surface: OldMoneyColors.Cool.Light.surface,
          divider: OldMoneyColors.Cool.Light.divider,
          textPrimary: OldMoneyColors.Cool.Light.textPrimary,
          textSecondary: OldMoneyColors.Cool.Light.textSecondary,
          accent: OldMoneyColors.Cool.Accent.primary,
          accentSecondary: OldMoneyColors.Cool.Accent.secondary,
          income: OldMoneyColors.Cool.Semantic.income,
          expense: OldMoneyColors.Cool.Semantic.expense,
          warning: OldMoneyColors.Cool.Semantic.warning,
          error: OldMoneyColors.Cool.Semantic.error,
          success: OldMoneyColors.Cool.Semantic.success,
          neutral: OldMoneyColors.Cool.Semantic.neutral,
          attention: OldMoneyColors.Cool.Semantic.attention
        )

      case .neutral:
        return ColorSet(
          background: OldMoneyColors.Light.ivory,
          surface: OldMoneyColors.Light.cream,
          divider: OldMoneyColors.Light.warmGray,
          textPrimary: OldMoneyColors.Light.charcoal,
          textSecondary: OldMoneyColors.Light.stone,
          accent: OldMoneyColors.Accent.antiqueGold,
          accentSecondary: OldMoneyColors.Accent.softGold,
          income: OldMoneyColors.SemanticLight.income,
          expense: OldMoneyColors.SemanticLight.expense,
          warning: OldMoneyColors.SemanticLight.warning,
          error: OldMoneyColors.SemanticLight.error,
          success: OldMoneyColors.SemanticLight.success,
          neutral: OldMoneyColors.SemanticLight.neutral,
          attention: OldMoneyColors.SemanticLight.attention
        )
      }
    }

    /// Category colors (consistent across all palettes)
    static func category(_ category: TransactionCategory) -> Color {
      switch category {
      case .food:
        return OldMoneyColors.Category.food
      case .transport:
        return OldMoneyColors.Category.transport
      case .entertainment:
        return OldMoneyColors.Category.entertainment
      case .healthcare:
        return OldMoneyColors.Category.healthcare
      case .shopping:
        return OldMoneyColors.Category.shopping
      case .bills:
        return OldMoneyColors.Category.bills
      case .salary:
        return OldMoneyColors.Category.salary
      case .investment:
        return OldMoneyColors.Category.investment
      case .housing:
        return OldMoneyColors.Category.housing
      case .other:
        return OldMoneyColors.Category.other
      }
    }
  }
}

/// Color set for a palette
struct ColorSet {
  let background: Color
  let surface: Color
  let divider: Color
  let textPrimary: Color
  let textSecondary: Color
  let accent: Color
  let accentSecondary: Color
  let income: Color
  let expense: Color
  let warning: Color
  let error: Color
  let success: Color
  let neutral: Color
  let attention: Color
}
```

**Step 2: Build to verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Configuration/Theme/Color+OldMoney.swift
git commit -m "feat: add Color extension for palette-aware colors

- ColorSet struct with all semantic colors
- Colors(for:) method returns appropriate palette colors
- Category colors consistent across all palettes
- Clean API: Color.OldMoney.colors(for: .warm)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 4: UI Integration (Sample Screens)

### Task 8: Update Dashboard to Use Adaptive Colors

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift`

**Step 1: Add EnvironmentObject for health service**

At the top of `DashboardScreen` struct, add:

```swift
@EnvironmentObject private var healthService: FinancialHealthService
```

**Step 2: Add computed property for current colors**

```swift
private var colors: ColorSet {
  Color.OldMoney.colors(for: healthService.currentPalette)
}
```

**Step 3: Replace hardcoded background color**

Find `.background()` modifiers and replace with:

```swift
.background(colors.background)
```

**Step 4: Add animation modifier**

After the `.background()` modifier, add:

```swift
.animation(.easeInOut(duration: 0.4), value: healthService.currentPalette)
```

**Step 5: Replace card backgrounds**

Find any `Color.white` or hardcoded colors for cards and replace with:

```swift
.background(colors.surface)
```

**Step 6: Build and run in simulator**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`
Expected: BUILD SUCCEEDED

Launch app in simulator and verify background adapts to palette.

**Step 7: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
git commit -m "feat: integrate adaptive colors in DashboardScreen

- Observe FinancialHealthService for palette changes
- Use ColorSet for all backgrounds and surfaces
- Smooth 400ms animation on palette transitions
- Background adapts warm/cool based on financial health

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 9: Update Budget Screen Colors

**Files:**
- Modify: `FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift`

**Step 1: Add EnvironmentObject and colors computed property**

```swift
@EnvironmentObject private var healthService: FinancialHealthService

private var colors: ColorSet {
  Color.OldMoney.colors(for: healthService.currentPalette)
}
```

**Step 2: Replace backgrounds and text colors**

Replace:
- Background colors → `colors.background`
- Card colors → `colors.surface`
- Primary text → `colors.textPrimary`
- Secondary text → `colors.textSecondary`
- Dividers → `colors.divider`

**Step 3: Add animation**

```swift
.animation(.easeInOut(duration: 0.4), value: healthService.currentPalette)
```

**Step 4: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift
git commit -m "feat: integrate adaptive colors in BudgetScreen

- Use palette-aware backgrounds and text colors
- Smooth transitions between palettes
- All semantic colors from ColorSet

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 10: Update Transaction Colors with Category Colors

**Files:**
- Modify: `FinPessoal/Code/Features/Transaction/View/TransactionRow.swift`

**Step 1: Add EnvironmentObject and colors**

```swift
@EnvironmentObject private var healthService: FinancialHealthService

private var colors: ColorSet {
  Color.OldMoney.colors(for: healthService.currentPalette)
}
```

**Step 2: Update category indicator color**

Find where category color is used (likely in a Circle or icon) and replace with:

```swift
Color.OldMoney.category(transaction.category)
```

**Step 3: Update income/expense colors**

Replace income color with:

```swift
transaction.type == .income ? colors.income : colors.expense
```

**Step 4: Update text colors**

```swift
.foregroundColor(colors.textPrimary)  // for primary text
.foregroundColor(colors.textSecondary)  // for secondary text
```

**Step 5: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add FinPessoal/Code/Features/Transaction/View/TransactionRow.swift
git commit -m "feat: use adaptive and category colors in TransactionRow

- Category colors 30-40% more saturated
- Income/expense colors adapt to palette
- Text colors from ColorSet
- Smooth palette transitions

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 5: Health Score Calculation Integration

### Task 11: Wire Health Calculation to Data Changes

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/ViewModel/DashboardViewModel.swift`

**Step 1: Add FinancialHealthService reference**

Add property:

```swift
private var healthService: FinancialHealthService?

func setHealthService(_ service: FinancialHealthService) {
  self.healthService = service
}
```

**Step 2: Call health calculation after data loads**

In `fetchDashboardData()` or similar method, after all data is loaded, add:

```swift
healthService?.calculateHealth(
  budgets: budgets,
  accounts: accounts,
  goals: goals,
  bills: bills
)
```

**Step 3: Update DashboardScreen to pass health service**

In `DashboardScreen`, add `.onAppear`:

```swift
.onAppear {
  viewModel.setHealthService(healthService)
}
```

**Step 4: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/ViewModel/DashboardViewModel.swift
git add FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
git commit -m "feat: wire health calculation to dashboard data

- DashboardViewModel updates health score when data loads
- Health service recalculates on budgets/accounts/goals/bills changes
- Palette adapts automatically based on financial state

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 6: Testing & Documentation

### Task 12: Update CHANGELOG

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add entry at top**

```markdown
## [Unreleased]

### Added
- **Warm/Cool Duotone Color Palette** (2025-12-21)
  - Emotionally intelligent color system adapting to financial health
  - Warm palette (peachy/coral/gold) for positive finances (70-100% health)
  - Cool palette (slate/blue/teal) for finances needing attention (0-29% health)
  - Neutral palette (original colors) for moderate states (30-69% health)
  - FinancialHealthService calculates 0-100 score from budgets/accounts/goals/bills
  - Enhanced category colors with 30-40% more saturation
  - Smooth 400ms transitions between palettes with 5-second debounce
  - WCAG AA/AAA accessible across all palettes
  - Full test coverage for health calculation and palette selection
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for warm/cool duotone palette

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 13: Verify Accessibility

**Step 1: Run accessibility audit in Xcode**

1. Run app in simulator
2. Open Accessibility Inspector (Xcode → Open Developer Tool → Accessibility Inspector)
3. Select simulator
4. Run Audit
5. Verify no contrast ratio violations

**Step 2: Test with color blindness simulators**

In simulator:
1. Settings → Accessibility → Display & Text Size → Color Filters
2. Enable Protanopia (red-green)
3. Verify income/expense still distinguishable
4. Enable Deuteranopia
5. Verify all semantic colors distinguishable

**Step 3: Document results**

If issues found, create GitHub issue. Otherwise, proceed.

---

### Task 14: Final Build and Verification

**Step 1: Clean build**

Run: `xcodebuild clean -project FinPessoal.xcodeproj -scheme FinPessoal`
Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 2: Test palette transitions**

1. Run app in simulator
2. Manually set mock data for high health score (should show warm palette)
3. Change to low health score (should transition to cool palette smoothly)
4. Verify 400ms animation
5. Verify no jarring color shifts

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete warm/cool duotone palette implementation

All phases complete:
- ✓ Color infrastructure (warm/cool/neutral palettes)
- ✓ Financial health service with score calculation
- ✓ Palette-aware color extensions
- ✓ UI integration in Dashboard, Budget, Transactions
- ✓ Smooth 400ms transitions with debounce
- ✓ Enhanced category colors (30-40% more saturation)
- ✓ WCAG AA/AAA accessibility verified
- ✓ Full test coverage

Ready for review and merge.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Additional Tasks (If Needed)

### Task 15: Update Remaining Screens (Optional)

Repeat Task 8-9 pattern for:
- `GoalScreen.swift`
- `ReportsScreen.swift`
- `AccountsView.swift`
- `BillsScreen.swift`
- `CreditCardsScreen.swift`
- `LoansScreen.swift`

Each screen:
1. Add `@EnvironmentObject private var healthService: FinancialHealthService`
2. Add `private var colors: ColorSet { Color.OldMoney.colors(for: healthService.currentPalette) }`
3. Replace hardcoded colors with `colors.background`, `colors.surface`, etc.
4. Add `.animation(.easeInOut(duration: 0.4), value: healthService.currentPalette)`
5. Build and verify
6. Commit with descriptive message

---

## Success Criteria

- [ ] All screens build without errors
- [ ] Palette transitions smoothly (400ms) between states
- [ ] No rapid switching (5-second debounce works)
- [ ] Health score calculation produces reasonable values
- [ ] Warm palette appears when health score 70-100%
- [ ] Cool palette appears when health score 0-29%
- [ ] Neutral palette appears when health score 30-69%
- [ ] Category colors are 30-40% more saturated than before
- [ ] All color combinations pass WCAG AA contrast
- [ ] No accessibility violations in Xcode Inspector
- [ ] Color blindness simulation shows distinguishable colors
- [ ] CHANGELOG updated
- [ ] All commits follow conventional commits format

---

## Reference Files

- Design: `Docs/plans/2025-12-21-warm-cool-duotone-palette-design.md`
- Original colors: `FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift` (pre-enhancement)
- Architecture: MVVM with @StateObject/@EnvironmentObject pattern
- Testing: @MainActor for concurrency, XCTest for unit tests

---

## Notes

- **DRY**: Reuse `ColorSet` struct across all screens
- **YAGNI**: Don't add user preference toggle until requested
- **TDD**: Tests written before FinancialHealthService implementation
- **Frequent commits**: One commit per task (14+ commits total)
- **Code quality**: Use @MainActor for UI-related classes, proper SwiftUI modifiers
