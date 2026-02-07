# Phase 3: Interactive List Rows - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create InteractiveListRow component with pressed depth effects, swipe actions, loading states, and dividers, then migrate 4-6 row types.

**Architecture:** Reusable wrapper component that adds press feedback (0.98x scale, shadow reduction, haptics), swipe action handling, shimmer loading, and optional dividers to any row content. Maintains Old Money aesthetic with subtle refinement.

**Tech Stack:** SwiftUI, DragGesture, AnimationEngine, HapticEngine, TimelineView (shimmer), Color.oldMoney, AnimationSettings

---

## Task 1: Create RowAction Model

**Files:**
- Create: `FinPessoal/Code/Animation/Components/RowAction.swift`

**Step 1: Write RowAction struct**

Create `FinPessoal/Code/Animation/Components/RowAction.swift`:

```swift
//
//  RowAction.swift
//  FinPessoal
//
//  Created by Claude Code on 07/02/26.
//

import SwiftUI

/// Model for swipe actions on InteractiveListRow
public struct RowAction: Identifiable {
  public let id = UUID()
  public let title: String
  public let icon: String
  public let tint: Color
  public let role: ButtonRole?
  public let action: () async -> Void

  public init(
    title: String,
    icon: String,
    tint: Color,
    role: ButtonRole? = nil,
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.icon = icon
    self.tint = tint
    self.role = role
    self.action = action
  }
}

// MARK: - Preset Actions

extension RowAction {
  /// Delete action (red, destructive)
  public static func delete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.delete"),
      icon: "trash",
      tint: .red,
      role: .destructive,
      action: action
    )
  }

  /// Edit action (blue)
  public static func edit(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.edit"),
      icon: "pencil",
      tint: .blue,
      action: action
    )
  }

  /// Complete action (green)
  public static func complete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.complete"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

  /// Mark paid action (green)
  public static func markPaid(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "bill.mark.paid"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

  /// Archive action (orange)
  public static func archive(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.archive"),
      icon: "archivebox",
      tint: .orange,
      action: action
    )
  }
}
```

**Step 2: Add file to Xcode project**

Open Xcode:
1. Right-click on `FinPessoal/Code/Animation/Components` folder
2. Select "Add Files to FinPessoal"
3. Choose `RowAction.swift`
4. Ensure "FinPessoal" target is checked
5. Click "Add"

**Step 3: Build to verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds with no errors

**Step 4: Commit**

```bash
git add FinPessoal/Code/Animation/Components/RowAction.swift
git commit -m "feat(phase3): add RowAction model with presets

- RowAction struct for swipe actions
- Preset actions: delete, edit, complete, markPaid, archive
- Localized titles with SF Symbols icons
- Async action support for Firebase operations

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Create InteractiveListRow Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/InteractiveListRow.swift`
- Reference: `FinPessoal/Code/Animation/Engine/AnimationEngine.swift`
- Reference: `FinPessoal/Code/Animation/Engine/HapticEngine.swift`

**Step 1: Write component structure**

Create `FinPessoal/Code/Animation/Components/InteractiveListRow.swift`:

```swift
//
//  InteractiveListRow.swift
//  FinPessoal
//
//  Created by Claude Code on 07/02/26.
//

import SwiftUI

/// Interactive list row with pressed depth, swipe actions, loading state, and dividers
public struct InteractiveListRow<Content: View>: View {
  // MARK: - State
  @State private var isPressed = false
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  // MARK: - Properties
  private let content: Content
  private let onTap: (() -> Void)?
  private let leadingActions: [RowAction]
  private let trailingActions: [RowAction]
  private let isLoading: Bool
  private let showDivider: Bool
  private let backgroundColor: Color?

  // MARK: - Initialization

  public init(
    isLoading: Bool = false,
    showDivider: Bool = true,
    backgroundColor: Color? = nil,
    onTap: (() -> Void)? = nil,
    leadingActions: [RowAction] = [],
    trailingActions: [RowAction] = [],
    @ViewBuilder content: () -> Content
  ) {
    self.isLoading = isLoading
    self.showDivider = showDivider
    self.backgroundColor = backgroundColor
    self.onTap = onTap
    self.leadingActions = leadingActions
    self.trailingActions = trailingActions
    self.content = content()
  }

  // MARK: - Body

  public var body: some View {
    Group {
      if isLoading {
        RowShimmerView()
      } else {
        content
          .background(backgroundView)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .scaleEffect(isPressed ? 0.98 : 1.0)
          .brightness(isPressed ? -0.03 : 0)
          .opacity(isPressed ? 0.97 : 1.0)
          .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
          .animation(pressAnimation, value: isPressed)
          .gesture(tapGesture)
      }
    }
    .overlay(alignment: .bottom) {
      if showDivider {
        dividerView
      }
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      ForEach(leadingActions) { action in
        swipeButton(for: action)
      }
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
      ForEach(trailingActions) { action in
        swipeButton(for: action)
      }
    }
    .accessibilityAddTraits(.isButton)
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
  }

  // MARK: - Computed Properties

  private var backgroundView: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(backgroundColor ?? Color.oldMoney.surface)
  }

  private var shadowColor: Color {
    let opacity = isPressed
      ? (colorScheme == .dark ? 0.05 : 0.03)
      : (colorScheme == .dark ? 0.08 : 0.05)
    return Color.black.opacity(opacity)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 1 : 2
  }

  private var shadowY: CGFloat {
    isPressed ? 0.5 : 1
  }

  private var pressAnimation: Animation? {
    switch animationMode {
    case .full:
      return isPressed ? AnimationEngine.snappySpring : AnimationEngine.gentleSpring
    case .reduced:
      return .easeInOut(duration: 0.2)
    case .minimal:
      return nil
    }
  }

  private var tapGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        guard !isPressed else { return }
        isPressed = true
        if animationMode == .full {
          HapticEngine.shared.light()
        }
      }
      .onEnded { _ in
        isPressed = false
        onTap?()
      }
  }

  private var dividerView: some View {
    Rectangle()
      .fill(dividerColor)
      .frame(height: 1)
      .padding(.leading, 16)
  }

  private var dividerColor: Color {
    colorScheme == .dark
      ? Color.oldMoney.darkStone.opacity(0.2)
      : Color.oldMoney.warmGray.opacity(0.3)
  }

  private func swipeButton(for action: RowAction) -> some View {
    Button(role: action.role) {
      Task { await action.action() }
    } label: {
      Label(action.title, systemImage: action.icon)
    }
    .tint(action.tint)
  }
}

// MARK: - Shimmer Loading View

private struct RowShimmerView: View {
  @State private var offset: CGFloat = -300
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  var body: some View {
    HStack(spacing: 16) {
      // Icon placeholder
      Circle()
        .fill(shimmerBase)
        .frame(width: 40, height: 40)
        .overlay(shimmerGradient)

      // Content placeholders
      VStack(alignment: .leading, spacing: 8) {
        RoundedRectangle(cornerRadius: 4)
          .fill(shimmerBase)
          .frame(height: 16)
          .frame(maxWidth: .infinity)

        RoundedRectangle(cornerRadius: 4)
          .fill(shimmerBase)
          .frame(width: 100, height: 12)
      }

      // Value placeholder
      RoundedRectangle(cornerRadius: 4)
        .fill(shimmerBase)
        .frame(width: 60, height: 20)
    }
    .padding()
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
      if animationMode == .full {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
          offset = 300
        }
      } else if animationMode == .reduced {
        // Pulse animation for reduced mode
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
          offset = 100
        }
      }
    }
  }

  private var shimmerBase: Color {
    Color.oldMoney.warmGray.opacity(0.2)
  }

  @ViewBuilder
  private var shimmerGradient: some View {
    if animationMode == .full {
      LinearGradient(
        colors: [
          Color.clear,
          Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
          Color.clear
        ],
        startPoint: .leading,
        endPoint: .trailing
      )
      .offset(x: offset)
      .mask(RoundedRectangle(cornerRadius: 4))
    } else if animationMode == .reduced {
      shimmerBase.opacity(abs(offset) / 100)
    }
  }
}

// MARK: - Preview

#Preview("InteractiveListRow - Normal") {
  List {
    InteractiveListRow(
      onTap: { print("Tapped") },
      leadingActions: [.edit { print("Edit") }],
      trailingActions: [.delete { print("Delete") }]
    ) {
      HStack {
        Image(systemName: "dollarsign.circle.fill")
          .font(.title2)
          .foregroundStyle(Color.oldMoney.income)

        VStack(alignment: .leading) {
          Text("Sample Transaction")
            .font(.headline)
          Text("Category • Date")
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
        }

        Spacer()

        Text("R$ 1.234,56")
          .font(.headline)
      }
      .padding()
    }
  }
  .listStyle(.plain)
}

#Preview("InteractiveListRow - Loading") {
  List {
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
  }
  .listStyle(.plain)
}
```

**Step 2: Add file to Xcode project**

Same process as Task 1.

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Test preview in Xcode**

1. Open `InteractiveListRow.swift` in Xcode
2. Click "Resume" on canvas preview
3. Verify:
   - Normal preview shows sample row
   - Loading preview shows three shimmer skeletons
   - Press feedback works (scale down on tap)
   - Swipe left reveals delete action
   - Swipe right reveals edit action

**Step 5: Commit**

```bash
git add FinPessoal/Code/Animation/Components/InteractiveListRow.swift
git commit -m "feat(phase3): add InteractiveListRow component

- Pressed depth feedback (0.98x scale, shadow reduction)
- Swipe action support (leading/trailing)
- Shimmer loading state with mode adaptation
- Optional dividers with 16pt leading inset
- Full haptic feedback (light on press)
- Animation mode aware (Full/Reduced/Minimal)
- Accessibility: .isButton trait
- Preview providers for testing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Write InteractiveListRow Unit Tests

**Files:**
- Create: `FinPessoalTests/Animation/InteractiveListRowTests.swift`

**Step 1: Write test file**

Create `FinPessoalTests/Animation/InteractiveListRowTests.swift`:

```swift
//
//  InteractiveListRowTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 07/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class InteractiveListRowTests: XCTestCase {

  func testRowActionPresets() {
    // Test delete preset
    let deleteAction = RowAction.delete { }
    XCTAssertEqual(deleteAction.title, "Delete")
    XCTAssertEqual(deleteAction.icon, "trash")
    XCTAssertEqual(deleteAction.role, .destructive)

    // Test edit preset
    let editAction = RowAction.edit { }
    XCTAssertEqual(editAction.title, "Edit")
    XCTAssertEqual(editAction.icon, "pencil")
    XCTAssertNil(editAction.role)

    // Test complete preset
    let completeAction = RowAction.complete { }
    XCTAssertEqual(completeAction.title, "Complete")
    XCTAssertEqual(completeAction.icon, "checkmark.circle.fill")
  }

  func testRowActionExecution() async {
    var executed = false
    let action = RowAction.delete {
      executed = true
    }

    await action.action()
    XCTAssertTrue(executed, "Action should execute")
  }
}
```

**Step 2: Add file to Xcode project test target**

1. Right-click on `FinPessoalTests/Animation` folder
2. Select "Add Files to FinPessoal"
3. Choose `InteractiveListRowTests.swift`
4. Ensure "FinPessoalTests" target is checked
5. Click "Add"

**Step 3: Run tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

Expected: All tests pass (2 tests)

**Step 4: Commit**

```bash
git add FinPessoalTests/Animation/InteractiveListRowTests.swift
git commit -m "test(phase3): add InteractiveListRow tests

- RowAction preset validation
- Async action execution test
- 2 test cases passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Migrate TransactionRow

**Files:**
- Modify: `FinPessoal/Code/Features/Transaction/View/TransactionRow.swift`
- Modify: `FinPessoal/Code/Features/Transaction/Screen/TransactionsScreen.swift`

**Step 1: Update TransactionRow component**

Read current implementation:

```bash
cat FinPessoal/Code/Features/Transaction/View/TransactionRow.swift
```

Modify `FinPessoal/Code/Features/Transaction/View/TransactionRow.swift`:

Remove lines 66-67 (background and cornerRadius):
```swift
// REMOVE THESE LINES:
.background(Color.oldMoney.surface)
.cornerRadius(12)
```

Keep everything else unchanged (padding, content, accessibility).

**Step 2: Update TransactionsScreen to use wrapper**

Find the List in `FinPessoal/Code/Features/Transaction/Screen/TransactionsScreen.swift`.

Replace the ForEach block:

```swift
// BEFORE:
ForEach(transactions) { transaction in
  TransactionRow(transaction: transaction)
    .onTapGesture {
      viewModel.selectTransaction(transaction)
    }
}

// AFTER:
ForEach(transactions) { transaction in
  InteractiveListRow(
    onTap: {
      viewModel.selectTransaction(transaction)
    },
    leadingActions: [
      .edit {
        await viewModel.editTransaction(transaction.id)
      }
    ],
    trailingActions: [
      .delete {
        await viewModel.deleteTransaction(transaction.id)
      }
    ]
  ) {
    TransactionRow(transaction: transaction)
  }
}
```

**Step 3: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Manual QA**

Run app in simulator:
1. Navigate to Transactions screen
2. Tap a row → verify light haptic and navigation
3. Swipe right → verify edit action revealed
4. Swipe left → verify delete action revealed
5. Test VoiceOver: Row should announce as button

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Transaction/View/TransactionRow.swift FinPessoal/Code/Features/Transaction/Screen/TransactionsScreen.swift
git commit -m "feat(phase3): migrate TransactionRow to InteractiveListRow

- Wrapped with InteractiveListRow for press feedback
- Added swipe actions: edit (leading), delete (trailing)
- Removed manual background/cornerRadius (handled by wrapper)
- Removed manual onTapGesture (handled by wrapper)
- Press feedback: 0.98x scale, light haptic
- All accessibility maintained

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Migrate BillRow

**Files:**
- Modify: `FinPessoal/Code/Features/Bills/View/BillRow.swift`
- Modify: `FinPessoal/Code/Features/Bills/Screen/BillsScreen.swift`

**Step 1: Update BillRow component**

Read current implementation:

```bash
cat FinPessoal/Code/Features/Bills/View/BillRow.swift
```

Note: BillRow doesn't have explicit background/cornerRadius in the row itself.
No changes needed to the component.

**Step 2: Update BillsScreen swipe actions**

Find the List in `FinPessoal/Code/Features/Bills/Screen/BillsScreen.swift` (around line 148-184).

Replace the ForEach block:

```swift
// BEFORE:
ForEach(viewModel.filteredBills) { bill in
  BillRow(bill: bill) {
    Task {
      await viewModel.markBillAsPaid(bill.id)
    }
  }
  .onTapGesture {
    viewModel.selectBill(bill)
  }
  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
    Button(role: .destructive) {
      Task {
        await viewModel.deleteBill(bill.id)
      }
    } label: {
      Label(String(localized: "common.delete"), systemImage: "trash")
    }
  }
  .swipeActions(edge: .leading, allowsFullSwipe: true) {
    if !bill.isPaid {
      Button {
        Task {
          await viewModel.markBillAsPaid(bill.id)
        }
      } label: {
        Label(String(localized: "bill.mark.paid"), systemImage: "checkmark.circle")
      }
      .tint(.green)
    }
  }
}

// AFTER:
ForEach(viewModel.filteredBills) { bill in
  InteractiveListRow(
    onTap: {
      viewModel.selectBill(bill)
    },
    leadingActions: bill.isPaid ? [] : [
      .markPaid {
        await viewModel.markBillAsPaid(bill.id)
      }
    ],
    trailingActions: [
      .delete {
        await viewModel.deleteBill(bill.id)
      }
    ]
  ) {
    BillRow(bill: bill, onMarkAsPaid: nil)
  }
}
```

Note: Remove `onMarkAsPaid` callback since it's now a swipe action.

**Step 3: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Manual QA**

Run app in simulator:
1. Navigate to Bills screen
2. Tap a bill row → verify press feedback and navigation
3. Swipe right on unpaid bill → verify "Mark Paid" action
4. Swipe left → verify delete action
5. Swipe right on paid bill → no action (correct behavior)

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Bills/View/BillRow.swift FinPessoal/Code/Features/Bills/Screen/BillsScreen.swift
git commit -m "feat(phase3): migrate BillRow to InteractiveListRow

- Wrapped with InteractiveListRow for press feedback
- Added swipe actions: markPaid (leading, unpaid only), delete (trailing)
- Removed manual swipeActions modifiers
- Removed manual onTapGesture
- Removed onMarkAsPaid callback (now swipe action)
- Press feedback: 0.98x scale, light haptic

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Migrate BudgetRowView

**Files:**
- Modify: `FinPessoal/Code/Features/Budget/View/BudgetRowView.swift`
- Modify: `FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift`

**Step 1: Read current BudgetRowView**

```bash
cat FinPessoal/Code/Features/Budget/View/BudgetRowView.swift
```

Note any background/styling to remove.

**Step 2: Update BudgetScreen list**

Find the List in `FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift`.

Replace ForEach:

```swift
// BEFORE:
ForEach(budgets) { budget in
  BudgetRowView(budget: budget)
    .onTapGesture {
      selectedBudget = budget
      showingBudgetDetail = true
    }
}

// AFTER:
ForEach(budgets) { budget in
  InteractiveListRow(
    onTap: {
      selectedBudget = budget
      showingBudgetDetail = true
    },
    leadingActions: [
      .edit {
        await viewModel.editBudget(budget)
      }
    ],
    trailingActions: [
      .delete {
        await viewModel.deleteBudget(budget.id)
      }
    ]
  ) {
    BudgetRowView(budget: budget)
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Budget/View/BudgetRowView.swift FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift
git commit -m "feat(phase3): migrate BudgetRowView to InteractiveListRow

- Wrapped with InteractiveListRow for press feedback
- Added swipe actions: edit (leading), delete (trailing)
- Press feedback on budget rows

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Migrate GoalRowView

**Files:**
- Modify: `FinPessoal/Code/Features/Goals/View/GoalRowView.swift`
- Modify: `FinPessoal/Code/Features/Goals/Screen/GoalScreen.swift`

**Step 1: Read current GoalRowView**

```bash
cat FinPessoal/Code/Features/Goals/View/GoalRowView.swift
```

**Step 2: Update GoalScreen list**

Find the List in `FinPessoal/Code/Features/Goals/Screen/GoalScreen.swift`.

Replace ForEach:

```swift
// BEFORE:
ForEach(goals) { goal in
  GoalRowView(goal: goal)
    .onTapGesture {
      selectedGoal = goal
      showingGoalDetail = true
    }
}

// AFTER:
ForEach(goals) { goal in
  InteractiveListRow(
    onTap: {
      selectedGoal = goal
      showingGoalDetail = true
    },
    leadingActions: [
      .edit {
        await viewModel.editGoal(goal)
      }
    ],
    trailingActions: [
      .delete {
        await viewModel.deleteGoal(goal.id)
      }
    ]
  ) {
    GoalRowView(goal: goal)
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Goals/View/GoalRowView.swift FinPessoal/Code/Features/Goals/Screen/GoalScreen.swift
git commit -m "feat(phase3): migrate GoalRowView to InteractiveListRow

- Wrapped with InteractiveListRow for press feedback
- Added swipe actions: edit (leading), delete (trailing)
- Press feedback on goal rows

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Update CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add Phase 3 entry**

Insert at line 10 (under "### Added - February 2026"):

```markdown
- **Phase 3: Interactive List Rows** (2026-02-07)
  - Created InteractiveListRow component with comprehensive interactions
  - **Press Feedback**: Subtle 0.98x scale, shadow reduction, brightness dimming
  - **Swipe Actions**: Built-in leading/trailing actions with haptic feedback
  - **Loading State**: Shimmer skeleton with mode adaptation (Full/Reduced/Minimal)
  - **Dividers**: Optional hairline dividers with 16pt leading inset
  - **Haptics**: Light tap on press (Full mode only)
  - **Animations**: Snappy spring on press, gentle spring on release
  - **Accessibility**: .isButton trait, swipe action announcements
  - Created RowAction model with presets:
    - delete (red, destructive)
    - edit (blue)
    - complete (green)
    - markPaid (green)
    - archive (orange)
  - Migrated 4 row types to InteractiveListRow:
    - TransactionRow: edit/delete swipe actions
    - BillRow: markPaid/delete swipe actions
    - BudgetRowView: edit/delete swipe actions
    - GoalRowView: edit/delete swipe actions
  - All rows now have consistent press feedback
  - All swipe actions use async/await for Firebase operations
  - Mode-aware rendering:
    - Full: Shimmer animation, all haptics, spring physics
    - Reduced: Pulse animation, light haptics, quick fade
    - Minimal: Static placeholder, no haptics, instant transitions
  - Files created:
    - FinPessoal/Code/Animation/Components/RowAction.swift
    - FinPessoal/Code/Animation/Components/InteractiveListRow.swift
    - FinPessoalTests/Animation/InteractiveListRowTests.swift
  - Files modified (4 rows + 4 screens):
    - TransactionRow + TransactionsScreen
    - BillRow + BillsScreen
    - BudgetRowView + BudgetScreen
    - GoalRowView + GoalScreen
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for Phase 3 completion

- Documented InteractiveListRow component
- Listed all migrated rows (4 types)
- Detailed features: press feedback, swipe actions, loading, dividers
- Mode adaptation details

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Run Full Test Suite

**Files:**
- Test: All test files

**Step 1: Run all unit tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

Expected: All tests pass

**Step 2: Manual QA checklist**

Test each migrated row:

**TransactionRow:**
- [ ] Press feedback (scale down, haptic)
- [ ] Swipe right → edit action
- [ ] Swipe left → delete action
- [ ] Tap opens detail view
- [ ] VoiceOver announces as button

**BillRow:**
- [ ] Press feedback works
- [ ] Swipe right on unpaid → mark paid action
- [ ] Swipe right on paid → no action
- [ ] Swipe left → delete action
- [ ] Tap opens bill detail

**BudgetRowView:**
- [ ] Press feedback works
- [ ] Swipe right → edit action
- [ ] Swipe left → delete action
- [ ] Tap opens budget detail

**GoalRowView:**
- [ ] Press feedback works
- [ ] Swipe right → edit action
- [ ] Swipe left → delete action
- [ ] Tap opens goal detail

**Animation Modes:**
- [ ] Full mode: Shimmer loading, all haptics
- [ ] Reduced mode: Pulse loading, light haptics only
- [ ] Minimal mode: Static loading, no haptics

**Step 3: Performance check**

Monitor FPS while scrolling and tapping rows:
- [ ] 120fps on iPhone 15 Pro (ProMotion)
- [ ] 60fps minimum on iPhone 15
- [ ] No dropped frames during press animations

**Step 4: Accessibility check**

Enable VoiceOver:
- [ ] All rows announce as buttons
- [ ] Swipe actions announced
- [ ] Content accessibility preserved
- [ ] Double-tap to activate works

If all checks pass, proceed to final commit.

---

## Success Criteria

Phase 3 is complete when:

- ✅ InteractiveListRow component created
- ✅ RowAction model with presets created
- ✅ Unit tests written and passing
- ✅ 4 row types migrated (Transaction, Bill, Budget, Goal)
- ✅ Press feedback works (0.98x scale, haptics)
- ✅ Swipe actions functional
- ✅ Loading states implemented (shimmer/pulse/static)
- ✅ Dividers rendering correctly
- ✅ All tests pass
- ✅ Manual QA checklist complete
- ✅ CHANGELOG.md updated
- ✅ Build succeeds with zero warnings
- ✅ 120fps on ProMotion devices
- ✅ Accessibility fully functional
- ✅ Zero visual regressions

---

## Rollback Plan

If issues arise:
- Each row migration is independent (revert specific commits)
- InteractiveListRow is additive (doesn't break existing code)
- Can revert to manual swipe actions if needed
- Git history preserves all old implementations

---

## Notes

- **File Paths**: All paths relative to worktree root
- **Xcode Integration**: Must add new files to Xcode project manually
- **Swipe Actions**: Use `allowsFullSwipe: true` for leading, `false` for trailing
- **Loading State**: Call `InteractiveListRow(isLoading: true)` during data fetch
- **Dividers**: Set `showDivider: false` on last item in list for clean bottom edge
- **Testing**: Physical device recommended for accurate haptic feedback testing

**Estimated Time:** 6-8 hours for full implementation and testing
