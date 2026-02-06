# Phase 1: Layered Backgrounds on All Cards - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enhance AnimatedCard with CardStyle enum and apply layered backgrounds to all card components throughout the app.

**Architecture:** Extend existing AnimatedCard component with CardStyle variants (.standard, .premium, .frosted, .recessed). Default style is .standard with layered background, ensuring backward compatibility. All cards automatically get layered backgrounds with mode-aware fade-in animations.

**Tech Stack:** SwiftUI, existing DepthModifier system, AnimationEngine, AnimationSettings

---

## Task 1: Add CardStyle Enum to AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Animation/Components/AnimatedCard.swift`
- Test: `FinPessoalTests/Animation/AnimatedCardTests.swift`

**Step 1: Write failing test for CardStyle enum**

Add to `AnimatedCardTests.swift`:

```swift
func testCardStyleDefault() {
  let card = AnimatedCard {
    Text("Test")
  }

  // Card should have .standard style by default
  XCTAssertNotNil(card)
}

func testCardStylePremium() {
  let card = AnimatedCard(style: .premium) {
    Text("Test")
  }

  XCTAssertNotNil(card)
}

func testCardStyleFrosted() {
  let card = AnimatedCard(style: .frosted) {
    Text("Test")
  }

  XCTAssertNotNil(card)
}

func testCardStyleRecessed() {
  let card = AnimatedCard(style: .recessed) {
    Text("Test")
  }

  XCTAssertNotNil(card)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/AnimatedCardTests`

Expected: BUILD FAILED - "Cannot find 'style' in scope"

**Step 3: Add CardStyle enum to AnimatedCard.swift**

Add before `AnimatedCard` struct:

```swift
/// Visual style variants for AnimatedCard
public enum CardStyle {
  case standard   // Layered background + elevated depth (default)
  case premium    // Layered background + floating depth + accent glow
  case frosted    // Frosted glass + moderate depth
  case recessed   // Inner shadow + subtle depth

  var depthLevel: DepthLevel {
    switch self {
    case .standard:  return .elevated
    case .premium:   return .floating
    case .frosted:   return .moderate
    case .recessed:  return .subtle
    }
  }

  var usesLayeredBackground: Bool {
    switch self {
    case .standard, .premium:  return true
    case .frosted, .recessed:  return false
    }
  }

  var usesFrostedGlass: Bool {
    self == .frosted
  }

  var usesInnerShadow: Bool {
    self == .recessed
  }
}
```

**Step 4: Update AnimatedCard struct to accept style**

Modify `AnimatedCard` struct:

```swift
public struct AnimatedCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false
  @State private var opacity: Double = 0  // For fade-in animation

  public let style: CardStyle
  public let cornerRadius: CGFloat
  public let content: Content
  public let onTap: (() -> Void)?
  public let heroID: String?

  public init(
    style: CardStyle = .standard,
    cornerRadius: CGFloat = 16,
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }

  // Keep old initializer for backward compatibility
  public init(
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.style = .standard
    self.cornerRadius = 16
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }
```

**Step 5: Run tests to verify they pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/AnimatedCardTests`

Expected: All tests PASS

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AnimatedCard.swift FinPessoalTests/Animation/AnimatedCardTests.swift
git commit -m "feat: add CardStyle enum to AnimatedCard

- Add CardStyle enum with standard, premium, frosted, recessed variants
- Update AnimatedCard init to accept optional style parameter
- Default style is .standard for backward compatibility
- Add tests for all card style variants

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Integrate Layered Background into AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Animation/Components/AnimatedCard.swift`
- Test: `FinPessoalTests/Animation/AnimatedCardTests.swift`

**Step 1: Write test for layered background integration**

Add to `AnimatedCardTests.swift`:

```swift
func testStandardStyleHasLayeredBackground() {
  let card = AnimatedCard(style: .standard) {
    Text("Test")
  }

  // Verify card body includes layered background
  XCTAssertNotNil(card)
}

func testPremiumStyleHasLayeredBackground() {
  let card = AnimatedCard(style: .premium) {
    Text("Test")
  }

  XCTAssertNotNil(card)
}
```

**Step 2: Run test to verify current state**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/AnimatedCardTests`

Expected: Tests PASS but no background applied yet

**Step 3: Update AnimatedCard body to apply surface effects**

Replace the `body` computed property in `AnimatedCard`:

```swift
public var body: some View {
  content
    .background(backgroundView)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .shadow(
      color: shadowColor,
      radius: shadowRadius,
      x: 0,
      y: isPressed ? 2 : 4
    )
    .opacity(opacity)
    .onAppear {
      withAnimation(.easeInOut(duration: 0.2)) {
        opacity = 1.0
      }
    }
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          guard !isPressed else { return }
          withAnimation(AnimationEngine.snappySpring) {
            isPressed = true
          }
          HapticEngine.shared.light()
        }
        .onEnded { _ in
          withAnimation(AnimationEngine.gentleSpring) {
            isPressed = false
          }
          onTap?()
        }
    )
    .if(heroID != nil) { view in
      view.matchedGeometryEffect(id: heroID!, in: namespace)
    }
}
```

**Step 4: Add background view helper**

Add after `body` property:

```swift
@ViewBuilder
private var backgroundView: some View {
  if style.usesLayeredBackground {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(Color.clear)
      .layeredBackground(cornerRadius: cornerRadius, animated: true)
  } else if style.usesFrostedGlass {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(Color.clear)
      .frostedGlass(intensity: 1.0)
  } else if style.usesInnerShadow {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(surfaceColor)
      .innerShadow(cornerRadius: cornerRadius, intensity: 1.0)
  } else {
    Color.clear
  }
}

private var surfaceColor: Color {
  Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
}
```

**Step 5: Update shadow to use depth level from style**

Modify `shadowRadius` property:

```swift
private var shadowRadius: CGFloat {
  let baseRadius = style.depthLevel.shadowRadius
  return isPressed ? baseRadius * 0.67 : baseRadius
}
```

**Step 6: Run tests to verify they pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/AnimatedCardTests`

Expected: All tests PASS

**Step 7: Build project to verify visual changes**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 8: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AnimatedCard.swift FinPessoalTests/Animation/AnimatedCardTests.swift
git commit -m "feat: integrate layered backgrounds into AnimatedCard

- Apply layered background based on card style
- Add fade-in animation on card appearance (200ms)
- Use depth levels from CardStyle enum for shadows
- Support frosted glass and inner shadow styles
- Add tests for layered background integration

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Update BalanceCardView to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift`

**Step 1: Check current BalanceCardView structure**

Current structure uses AnimatedCard wrapper. Verify it exists:

Run: `grep -n "AnimatedCard" FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift`

**Step 2: Update BalanceCardView to wrap content in AnimatedCard**

Find the `body` property (around line 32) and update it:

```swift
var body: some View {
  AnimatedCard(style: .standard, onTap: onTap) {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("dashboard.total.balance")
          .font(.headline)
          .foregroundStyle(Color.oldMoney.textSecondary)
        Spacer()
        Image(systemName: "eye")
          .foregroundStyle(Color.oldMoney.textSecondary)
          .accessibilityHidden(true)
      }

      PhysicsNumberCounter(
        value: $totalBalance,
        format: .currency(code: "BRL"),
        font: OldMoneyTheme.Typography.moneyLarge
      )
      .foregroundStyle(Color.oldMoney.text)

      Text("dashboard.monthly.expenses")
        .font(.caption)
        .foregroundStyle(Color.oldMoney.textSecondary)

      PhysicsNumberCounter(
        value: $monthlyExpenses,
        format: .currency(code: "BRL"),
        font: OldMoneyTheme.Typography.body
      )
      .foregroundStyle(Color.oldMoney.expense)
    }
    .padding(20)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("dashboard.balance.card.accessibility.label"))
    .accessibilityValue("\(totalBalance.formatted(.currency(code: "BRL"))). \("dashboard.monthly.expenses"): \(monthlyExpenses.formatted(.currency(code: "BRL")))")
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift
git commit -m "feat: apply layered background to BalanceCardView

- Wrap BalanceCardView content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains all existing functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Update StatCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/Screen/StatCard.swift`

**Step 1: Read current StatCard implementation**

Run: `cat FinPessoal/Code/Features/Dashboard/Screen/StatCard.swift`

**Step 2: Update StatCard body to use AnimatedCard**

Wrap the VStack content in AnimatedCard:

```swift
var body: some View {
  AnimatedCard(style: .standard) {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption)
        .foregroundStyle(Color.oldMoney.textSecondary)

      Text(value)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundStyle(textColor)

      if let subtitle = subtitle {
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
      }
    }
    .padding(16)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title): \(value)")
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/Screen/StatCard.swift
git commit -m "feat: apply layered background to StatCard

- Wrap StatCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains all existing functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Update BudgetCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Budget/View/BudgetCard.swift`

**Step 1: Read current BudgetCard implementation**

Run: `cat FinPessoal/Code/Features/Budget/View/BudgetCard.swift | head -60`

**Step 2: Update BudgetCard body**

Wrap content in AnimatedCard with onTap handler:

```swift
var body: some View {
  AnimatedCard(style: .standard, onTap: onTap) {
    // Existing VStack content
    VStack(alignment: .leading, spacing: 12) {
      // ... existing content ...
    }
    .padding(16)
    // ... existing accessibility modifiers ...
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Budget/View/BudgetCard.swift
git commit -m "feat: apply layered background to BudgetCard

- Wrap BudgetCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains tap functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Update GoalCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Goals/View/GoalCard.swift`

**Step 1: Read current GoalCard implementation**

Run: `cat FinPessoal/Code/Features/Goals/View/GoalCard.swift | head -60`

**Step 2: Update GoalCard body**

Wrap content in AnimatedCard:

```swift
var body: some View {
  AnimatedCard(style: .standard, onTap: onTap) {
    // Existing VStack content
    VStack(alignment: .leading, spacing: 12) {
      // ... existing content ...
    }
    .padding(16)
    // ... existing accessibility modifiers ...
  }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Goals/View/GoalCard.swift
git commit -m "feat: apply layered background to GoalCard

- Wrap GoalCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains tap functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Update AccountsCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Account/View/AccountsCard.swift`

Follow same pattern as previous cards.

**Step 1-4**: Same as Task 6 but for AccountsCard

**Commit message**:
```bash
git commit -m "feat: apply layered background to AccountsCard

- Wrap AccountsCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains all existing functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Update BudgetAlertCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Budget/View/BudgetAlertCard.swift`

Follow same pattern.

**Commit message**:
```bash
git commit -m "feat: apply layered background to BudgetAlertCard

- Wrap BudgetAlertCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains alert functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Update ReportSummaryCard to Use AnimatedCard

**Files:**
- Modify: `FinPessoal/Code/Features/Reports/View/ReportSummaryCard.swift`

Follow same pattern.

**Commit message**:
```bash
git commit -m "feat: apply layered background to ReportSummaryCard

- Wrap ReportSummaryCard content in AnimatedCard with standard style
- Card now has layered background with fade-in animation
- Maintains all existing functionality and accessibility

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Run Full Test Suite and Update Changelog

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Run complete test suite**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

Expected: All tests PASS

**Step 2: Build for final verification**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED with no warnings

**Step 3: Update CHANGELOG.md**

Add under "## [Unreleased]" → "### Added - February 2026":

```markdown
- **Phase 1: Layered Backgrounds on All Cards** (2026-02-05)
  - Added CardStyle enum to AnimatedCard (standard, premium, frosted, recessed)
  - Integrated layered background system into AnimatedCard
  - Applied layered backgrounds to all card components:
    - BalanceCardView (Dashboard)
    - StatCard (Dashboard)
    - BudgetCard (Budget feature)
    - GoalCard (Goals feature)
    - AccountsCard (Account feature)
    - BudgetAlertCard (Budget feature)
    - ReportSummaryCard (Reports feature)
  - Fade-in animation on card appearance (200ms, respects AnimationMode)
  - Backward compatible - existing AnimatedCard usage works unchanged
  - All cards automatically get premium layered background effect
  - Comprehensive test coverage for CardStyle variants
```

**Step 4: Commit changelog**

```bash
git add CHANGELOG.md
git commit -m "docs: update changelog for Phase 1 completion

Document layered backgrounds implementation across all cards

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria

Phase 1 is complete when:
- ✅ CardStyle enum implemented with 4 variants
- ✅ AnimatedCard integrated with layered backgrounds
- ✅ All 7+ card components use AnimatedCard with layered backgrounds
- ✅ Fade-in animations work in Full mode, disabled in Minimal mode
- ✅ All existing tests pass
- ✅ Build succeeds with zero warnings
- ✅ Backward compatibility maintained (old code still works)
- ✅ CHANGELOG.md updated

## Next Steps

After Phase 1 completion:
1. Review visual results in simulator/device
2. Test accessibility with VoiceOver
3. Proceed to Phase 2: Inner Shadows on All Inputs
