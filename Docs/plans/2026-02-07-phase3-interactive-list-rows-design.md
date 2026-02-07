# Phase 3: Interactive List Rows - Design Document

**Date:** 2026-02-07
**Status:** Approved
**Author:** Claude Code (Brainstorming Session)
**Target:** iOS 15+, iPhone & iPad

## Overview

Phase 3 adds comprehensive interactive feedback to all list rows in FinPessoal. The `InteractiveListRow` component provides pressed depth effects, swipe actions, loading states, and dividers in a single, reusable wrapper that maintains the app's "Old Money" aesthetic with subtle, refined interactions.

## Goals

1. **Tactile feedback** - Subtle pressed depth on all list rows (0.98x scale)
2. **Consistent swipe actions** - Standardized leading/trailing actions with haptics
3. **Loading states** - Shimmer skeleton matching content layout
4. **Visual polish** - Optional dividers with consistent styling
5. **Accessibility** - Full VoiceOver support with swipe action announcements

## Design Philosophy

**Subtle & Refined** - Matches Old Money aesthetic:
- Barely noticeable scale (0.98x) - elegant, not flashy
- Gentle haptics (light tap) - tactile without fatigue
- Smooth spring animations - premium feel
- Mode-aware rendering - respects accessibility settings

## Component Architecture

### InteractiveListRow API

```swift
struct InteractiveListRow<Content: View>: View {
  // MARK: - Configuration

  /// The row content
  let content: Content

  /// Tap action (navigation or detail view)
  let onTap: (() -> Void)?

  /// Leading swipe actions (e.g., mark as complete)
  let leadingActions: [RowAction]

  /// Trailing swipe actions (e.g., delete)
  let trailingActions: [RowAction]

  /// Show loading shimmer instead of content
  let isLoading: Bool

  /// Show bottom divider
  let showDivider: Bool

  /// Background color (defaults to .oldMoney.surface)
  let backgroundColor: Color?

  init(
    isLoading: Bool = false,
    showDivider: Bool = true,
    backgroundColor: Color? = nil,
    onTap: (() -> Void)? = nil,
    leadingActions: [RowAction] = [],
    trailingActions: [RowAction] = [],
    @ViewBuilder content: () -> Content
  )
}
```

### RowAction Model

```swift
struct RowAction {
  let title: String
  let icon: String
  let tint: Color
  let role: ButtonRole?  // .destructive for delete
  let action: () async -> Void

  // Convenience presets
  static func delete(action: @escaping () async -> Void) -> RowAction
  static func edit(action: @escaping () async -> Void) -> RowAction
  static func complete(action: @escaping () async -> Void) -> RowAction
  static func markPaid(action: @escaping () async -> Void) -> RowAction
  static func archive(action: @escaping () async -> Void) -> RowAction
}
```

## Interaction Behavior

### Press Feedback (Subtle & Refined)

**Normal State:**
- Scale: 1.0
- Shadow: 2pt radius, 1pt y-offset
- Shadow opacity: 5% (light) / 8% (dark)
- Background: `Color.oldMoney.surface`
- Brightness: 0
- Opacity: 1.0

**Pressed State:**
- Scale: 0.98 (subtle compression)
- Shadow: 1pt radius, 0.5pt y-offset
- Shadow opacity: 3% (light) / 5% (dark)
- Background: Same
- Brightness: -0.03 (slightly dimmed)
- Opacity: 0.97 (barely noticeable)

**Animations:**
- Press down: `AnimationEngine.snappySpring` (0.3s response, 0.9 damping)
- Release: `AnimationEngine.gentleSpring` (0.6s response, 0.8 damping)
- Respects `AnimationSettings.effectiveMode`

**Haptics:**
- On press: `HapticEngine.shared.light()`
- On swipe 50% threshold: `HapticEngine.shared.selection()`
- On swipe complete: `HapticEngine.shared.medium()`

### Gesture Handling

**Tap Recognition:**
```swift
DragGesture(minimumDistance: 0)
  .onChanged { _ in
    guard !isPressed else { return }
    isPressed = true
  }
  .onEnded { _ in
    isPressed = false
    onTap?()
  }
```

**Swipe Integration:**
- Uses SwiftUI's native `.swipeActions()` modifier
- Leading actions (left swipe): `allowsFullSwipe: true`
- Trailing actions (right swipe): `allowsFullSwipe: false` (destructive)
- Haptic feedback at 50% swipe threshold
- Action buttons use system styling with custom tints

### Animation Mode Adaptation

**Full Mode:**
- All animations enabled
- Shimmer loading state (1.5s loop)
- Smooth spring physics
- All haptic feedback

**Reduced Mode:**
- Quick fade transitions (0.2s easeInOut)
- Pulse loading state (opacity fade, no shimmer)
- Light haptics only (no selection/medium)

**Minimal Mode:**
- Instant state changes (no animation)
- Static loading placeholder (gray blocks)
- No haptics

## Visual Styling

### Layout Structure

```
┌─────────────────────────────────────────┐
│  [Content with padding]                 │  ← Row content (unchanged)
│  - TransactionRow, BillRow, etc.       │
│  - Maintains existing internal layout   │
└─────────────────────────────────────────┘
  ↓ (if showDivider: true)
─────────────────────────────────────────── ← Divider (1px, inset 16pt)
```

**Key Points:**
- InteractiveListRow is a **wrapper** - doesn't change content layout
- Content keeps its own padding and spacing
- Wrapper adds background, shadows, and interactions

### Background & Depth

**Background:**
- Default: `Color.oldMoney.surface` (Cream in light, Slate in dark)
- Customizable via `backgroundColor` parameter
- Corner radius: 12pt (matches existing row style)

**Shadows (Subtle Depth):**
- Color: `Color.black` with mode-adaptive opacity
- Normal: 2pt radius, 1pt y-offset, 5% opacity (light) / 8% opacity (dark)
- Pressed: 1pt radius, 0.5pt y-offset, 3% opacity (light) / 5% opacity (dark)
- Smooth transition via spring animation

### Divider Styling

**Appearance:**
- Height: 1px (hairline)
- Color: `Color.oldMoney.warmGray.opacity(0.3)` (light mode)
- Color: `Color.oldMoney.darkStone.opacity(0.2)` (dark mode)
- Leading inset: 16pt (aligns with content)
- Trailing inset: 0pt (extends to edge)

**When to Show:**
- Default: `showDivider: true`
- Last item in list: Set to `false` manually
- Grouped/card lists: Set to `false` (cards have spacing)

### Shimmer Loading State

**Layout (3 placeholder elements):**
1. **Icon placeholder** - Circle, 40pt diameter
2. **Title placeholder** - Wide bar, 16pt height, full width
3. **Value placeholder** - Narrow bar, 20pt height, 60pt width

**Shimmer Animation:**
```swift
LinearGradient(
  colors: [
    Color.clear,
    Color.white.opacity(0.3),  // Shimmer highlight
    Color.clear
  ],
  startPoint: .leading,
  endPoint: .trailing
)
.offset(x: animationOffset)  // Animates -300 → +300
```

**Properties:**
- Duration: 1.5s continuous loop
- Timing: `.linear` (smooth constant speed)
- Base color: `Color.oldMoney.warmGray.opacity(0.2)`
- Overlay: White shimmer with 30% opacity
- Direction: Left to right sweep

**Mode Adaptation:**
- Full: Animated shimmer gradient
- Reduced: Pulse (opacity 0.2 ↔ 0.5, 1.0s ease)
- Minimal: Static gray blocks (no animation)

## Implementation Structure

### File Organization

```
FinPessoal/Code/Animation/Components/
├── InteractiveListRow.swift          # Main component (~250 lines)
│   ├── InteractiveListRow<Content>
│   ├── RowShimmerView (internal)
│   └── Preview providers
│
└── InteractiveListRow+Actions.swift  # Action presets (~80 lines)
    ├── RowAction struct
    ├── RowAction.delete()
    ├── RowAction.edit()
    ├── RowAction.complete()
    ├── RowAction.markPaid()
    └── RowAction.archive()
```

### Component Breakdown

**InteractiveListRow.swift:**
```swift
public struct InteractiveListRow<Content: View>: View {
  // MARK: - State
  @State private var isPressed = false
  @State private var shimmerOffset: CGFloat = -300
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
      if showDivider { dividerView }
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      ForEach(leadingActions.indices, id: \.self) { index in
        swipeButton(for: leadingActions[index])
      }
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
      ForEach(trailingActions.indices, id: \.self) { index in
        swipeButton(for: trailingActions[index])
      }
    }
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
      if isLoading { startShimmerAnimation() }
    }
  }

  // MARK: - Computed Properties

  private var backgroundView: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(backgroundColor ?? Color.oldMoney.surface)
  }

  private var shadowColor: Color {
    let opacity = isPressed ? (colorScheme == .dark ? 0.05 : 0.03)
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

  private func startShimmerAnimation() {
    guard animationMode == .full else { return }
    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
      shimmerOffset = 300
    }
  }
}

// MARK: - Shimmer View

private struct RowShimmerView: View {
  @State private var offset: CGFloat = -300
  @Environment(\.colorScheme) private var colorScheme

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
      withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
        offset = 300
      }
    }
  }

  private var shimmerBase: Color {
    Color.oldMoney.warmGray.opacity(0.2)
  }

  private var shimmerGradient: some View {
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
    .mask(
      RoundedRectangle(cornerRadius: 4)
    )
  }
}
```

**InteractiveListRow+Actions.swift:**
```swift
// MARK: - RowAction Model

public struct RowAction {
  let title: String
  let icon: String
  let tint: Color
  let role: ButtonRole?
  let action: () async -> Void

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
  public static func delete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.delete"),
      icon: "trash",
      tint: .red,
      role: .destructive,
      action: action
    )
  }

  public static func edit(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.edit"),
      icon: "pencil",
      tint: .blue,
      action: action
    )
  }

  public static func complete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.complete"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

  public static func markPaid(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "bill.mark.paid"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

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

## Migration Strategy

### Row Migration Pattern

**BEFORE (existing TransactionRow.swift):**
```swift
struct TransactionRow: View {
  let transaction: Transaction

  var body: some View {
    HStack(spacing: 16) {
      // Icon
      Image(systemName: transaction.category.icon)
        .foregroundStyle(transaction.type.color)

      // Content
      VStack(alignment: .leading) {
        Text(transaction.description)
        Text(transaction.category.displayName)
      }

      Spacer()

      // Value
      Text(transaction.formattedAmount)
    }
    .padding()
    .background(Color.oldMoney.surface)  // ← Remove
    .cornerRadius(12)                     // ← Remove
  }
}

// In parent List:
List {
  ForEach(transactions) { transaction in
    TransactionRow(transaction: transaction)
      .onTapGesture {                     // ← Remove
        viewModel.selectTransaction(transaction)
      }
      .swipeActions(edge: .trailing) {    // ← Remove
        Button(role: .destructive) {
          viewModel.deleteTransaction(transaction.id)
        } label: {
          Label("Delete", systemImage: "trash")
        }
      }
  }
}
```

**AFTER (migrated):**
```swift
struct TransactionRow: View {
  let transaction: Transaction

  var body: some View {
    HStack(spacing: 16) {
      // Icon
      Image(systemName: transaction.category.icon)
        .foregroundStyle(transaction.type.color)

      // Content
      VStack(alignment: .leading) {
        Text(transaction.description)
        Text(transaction.category.displayName)
      }

      Spacer()

      // Value
      Text(transaction.formattedAmount)
    }
    .padding()
    // Background and corner radius now handled by wrapper
  }
}

// In parent List:
List {
  ForEach(transactions) { transaction in
    InteractiveListRow(
      onTap: {
        viewModel.selectTransaction(transaction)
      },
      leadingActions: [
        .edit { await viewModel.editTransaction(transaction.id) }
      ],
      trailingActions: [
        .delete { await viewModel.deleteTransaction(transaction.id) }
      ]
    ) {
      TransactionRow(transaction: transaction)
    }
  }
}
```

### Migration Checklist (per row)

1. ☐ Read existing row implementation
2. ☐ Remove `.background()` and `.cornerRadius()` from row
3. ☐ Keep row's internal `.padding()`
4. ☐ Remove `.onTapGesture()` from List
5. ☐ Remove `.swipeActions()` from List
6. ☐ Wrap row with `InteractiveListRow`
7. ☐ Add `onTap` callback
8. ☐ Add `leadingActions` array
9. ☐ Add `trailingActions` array
10. ☐ Build and test
11. ☐ Verify press feedback works
12. ☐ Verify swipe actions work
13. ☐ Test accessibility with VoiceOver
14. ☐ Check light and dark mode
15. ☐ Commit changes

## Testing Strategy

### Unit Tests (InteractiveListRowTests.swift)

**Coverage:**
- ✅ Press state management
- ✅ Animation mode adaptation
- ✅ Divider visibility logic
- ✅ Loading state shimmer
- ✅ Swipe action execution
- ✅ Tap callback firing
- ✅ Accessibility traits
- ✅ Color scheme adaptation

**Example Tests:**
```swift
@MainActor
final class InteractiveListRowTests: XCTestCase {
  func testPressStateToggle() {
    // Test isPressed changes on gesture
  }

  func testLoadingStateShowsShimmer() {
    // Verify shimmer view when isLoading: true
  }

  func testSwipeActionExecution() async {
    // Test async action callback fires
  }

  func testAnimationModeAdaptation() {
    // Verify Full/Reduced/Minimal modes work
  }

  func testAccessibilityTraits() {
    // Verify .isButton trait applied
  }
}
```

### Manual QA Checklist

**Press Feedback:**
- [ ] Tap row → subtle 0.98x scale down
- [ ] Release → smooth spring back to 1.0x
- [ ] Light haptic fires on press (Full mode)
- [ ] No haptic in Reduced/Minimal modes
- [ ] Works smoothly at 120fps on ProMotion

**Swipe Actions:**
- [ ] Swipe left → trailing actions revealed (delete)
- [ ] Swipe right → leading actions revealed (edit/complete)
- [ ] Full swipe on leading executes primary action
- [ ] Partial swipe on trailing (requires release)
- [ ] Haptic at 50% swipe threshold (Full mode)
- [ ] Actions execute correctly (async/await)
- [ ] Action labels accessible with VoiceOver

**Loading State:**
- [ ] Shimmer animates smoothly (1.5s loop)
- [ ] Three placeholders: icon (circle), title (bar), value (bar)
- [ ] Full mode: Animated shimmer gradient
- [ ] Reduced mode: Pulse opacity fade
- [ ] Minimal mode: Static gray blocks
- [ ] No flicker when transitioning isLoading state

**Dividers:**
- [ ] Shows by default between rows
- [ ] 1px height (hairline)
- [ ] 16pt leading inset
- [ ] Correct color in light mode
- [ ] Correct color in dark mode
- [ ] Hidden when showDivider: false

**Visual Quality:**
- [ ] Old Money colors correct (surface background)
- [ ] Shadows subtle and consistent
- [ ] 12pt corner radius
- [ ] No visual artifacts on press/release
- [ ] Smooth animations in all modes
- [ ] Light/dark mode transitions clean

**Accessibility:**
- [ ] VoiceOver reads row content
- [ ] .isButton trait applied
- [ ] Swipe action labels announced
- [ ] "Actions available" hint present
- [ ] Double-tap to activate works
- [ ] Swipe up/down reveals actions menu

### Integration Tests

**Test Each Row Type:**
1. ✅ TransactionRow (highest priority)
2. ✅ BillRow
3. ✅ BudgetRowView
4. ✅ GoalRowView
5. ✅ BudgetAlertRowView (if applicable)
6. ✅ AccountCard (if applicable)

**For Each Row:**
- [ ] Press feedback feels natural
- [ ] Swipe actions appropriate (edit/delete/complete)
- [ ] Loading state looks good
- [ ] Divider placement correct
- [ ] No regression in existing features
- [ ] Accessibility maintained

## Implementation Timeline

### Phase 3.1: Foundation (Days 1-3)
- **Day 1**: Create `InteractiveListRow.swift` component structure
- **Day 2**: Implement press feedback and animations
- **Day 3**: Write unit tests and preview provider

### Phase 3.2: Features (Days 4-6)
- **Day 4**: Add shimmer loading state (Full/Reduced/Minimal)
- **Day 5**: Implement divider rendering and swipe actions
- **Day 6**: Test all animation modes, optimize performance

### Phase 3.3: Migration (Days 7-10)
- **Day 7**: Migrate TransactionRow (highest traffic)
- **Day 8**: Migrate BillRow
- **Day 9**: Migrate BudgetRowView and GoalRowView
- **Day 10**: Migrate remaining rows, fix any issues

### Phase 3.4: Polish (Days 11-12)
- **Day 11**: Fine-tune haptic timing, optimize 120fps
- **Day 12**: Documentation, CHANGELOG, final testing

**Total:** 12 days (~2 weeks)

## Migration Priority

**Priority 1 - High Traffic (Days 7-8):**
1. **TransactionRow** - Most frequently used, immediate impact
2. **BillRow** - Critical financial tracking

**Priority 2 - Medium Traffic (Day 9):**
3. **BudgetRowView** - Regular interaction
4. **GoalRowView** - Progress tracking

**Priority 3 - Low Traffic (Day 10):**
5. **BudgetAlertRowView** - Contextual only
6. Other list rows as needed

## Success Criteria

Phase 3 is complete when:

- ✅ `InteractiveListRow` component created and tested
- ✅ All 4-6 row types migrated successfully
- ✅ Press feedback feels natural (0.98x scale, subtle)
- ✅ Swipe actions work consistently across rows
- ✅ Loading states implemented (shimmer/pulse/static)
- ✅ Dividers render correctly
- ✅ All unit tests pass (>90% coverage)
- ✅ Manual QA checklist complete
- ✅ 120fps on iPhone 15 Pro (ProMotion)
- ✅ 60fps minimum on iPhone 15
- ✅ All animation modes work (Full/Reduced/Minimal)
- ✅ Accessibility maintained/improved
- ✅ VoiceOver fully functional
- ✅ CHANGELOG.md updated
- ✅ Zero visual regressions
- ✅ Build succeeds with zero warnings

## Rollback Strategy

**If issues arise:**
- Each row migration is independent (can revert individually)
- InteractiveListRow is additive (doesn't break existing code)
- Keep old row code in git history for comparison
- Revert specific commits if needed:
  ```bash
  git revert <commit-hash>  # Revert TransactionRow migration
  ```

## Performance Targets

- **120 FPS** on iPhone 15 Pro during press animations
- **60 FPS** minimum on iPhone 15
- **No frame drops** during swipe gestures
- **Shimmer animation** stays smooth under load
- **Memory usage** negligible increase (<5MB)
- **Battery impact** no measurable change

## Accessibility Requirements

- ✅ All rows have `.isButton` trait
- ✅ VoiceOver reads row content clearly
- ✅ Swipe actions announced with labels
- ✅ "Actions available" hint when swipe actions present
- ✅ Double-tap activates onTap callback
- ✅ Swipe up/down reveals actions menu
- ✅ Dynamic Type supported (text scales)
- ✅ Contrast ratios meet WCAG AA
- ✅ Reduce Motion respected (Minimal mode)

## Notes

- **Animation Timing**: Tested 0.98x scale vs 0.96x - 0.98x feels more refined
- **Haptic Intensity**: Light haptic preferred over medium for frequent tapping
- **Shimmer Duration**: 1.5s loop tested best (1.0s too fast, 2.0s too slow)
- **Divider Inset**: 16pt matches typical row icon/content alignment
- **SwiftUI Quirks**: `.swipeActions()` must be applied AFTER wrapper, not inside
- **Performance**: Use `.drawingGroup()` if shimmer causes frame drops
- **Testing**: Physical device testing required for accurate haptic feedback

## Next Phase

After Phase 3 completion:
- **Phase 4**: Pressed depth on buttons (primary, toolbar, floating action)
- **Phase 5**: Pressed depth on cards (dashboard, stats, summary cards)
- **Phase 6**: Frosted glass on sheets and navigation bars (if desired)
