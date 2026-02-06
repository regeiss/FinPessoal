# Surface Effects Implementation Design

**Date**: 2026-02-05
**Status**: Approved
**Approach**: Bold & Comprehensive

## Overview

Comprehensive enhancement of FinPessoal's visual design by applying depth surface effects (frosted glass, inner shadows, layered backgrounds, pressed depth) throughout the entire application. This design implements a fully animated, mode-aware system that integrates seamlessly with existing animation infrastructure.

## Design Philosophy

- **Bold & Comprehensive**: Maximum visual impact with modern iOS aesthetic
- **Fully Animated**: All effects respect AnimationSettings.effectiveMode
- **Unified Architecture**: Enhanced AnimatedCard as single card system
- **Consistent Inputs**: Custom StyledTextField components for uniform styling
- **Component-Type Rollout**: Four phases, one effect type at a time

## Architecture Overview

### Core Components

#### 1. AnimatedCard Enhancement

Enhanced version of existing AnimatedCard with style variants:

```swift
struct AnimatedCard<Content: View>: View {
  let style: CardStyle
  let cornerRadius: CGFloat
  let onTap: (() -> Void)?
  let content: Content

  init(
    style: CardStyle = .standard,
    cornerRadius: CGFloat = 16,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  )
}

enum CardStyle {
  case standard    // Layered background + elevated depth (default)
  case premium     // Layered background + floating depth + accent glow
  case frosted     // Frosted glass + moderate depth
  case recessed    // Inner shadow + subtle depth
}
```

**Features**:
- Backward compatible (`.standard` is default)
- Layered backgrounds on all styles
- Animated appearance (fade-in 200ms)
- Press states with haptic feedback
- Respects AnimationSettings.effectiveMode

#### 2. StyledTextField Component

New text input wrapper replacing bare TextField/SecureField:

```swift
struct StyledTextField: View {
  let title: String
  @Binding var text: String
  let placeholder: String
  let keyboardType: UIKeyboardType
  let error: String?

  @FocusState private var isFocused: Bool
  @Environment(\.animationMode) private var animationMode
}
```

**Features**:
- Inner shadow (recessed appearance)
- Focus state with animated border glow (accent color, 2pt, 300ms spring)
- Layered background adapts to light/dark mode
- Error state with red tint + message
- Label above field with proper spacing
- Respects accessibility settings

#### 3. Enhanced Surface Modifiers

```swift
extension View {
  // Fades in on appearance (200ms)
  func layeredBackground(
    cornerRadius: CGFloat = 16,
    animated: Bool = true
  ) -> some View

  // Animates blur on sheet presentation (300ms)
  func frostedSheet() -> some View

  // For list items (press + haptic + scale)
  func interactiveRow() -> some View
}
```

#### 4. SheetModifier

Automatic frosted glass for sheet presentations:
- Blur animates with presentation/dismissal
- Works with all `.sheet()` presentations
- Uses `.ultraThinMaterial` on iOS 15+

## Four-Phase Rollout Plan

### Phase 1: Layered Backgrounds on All Cards (Week 1)

**Target Components**:
- Dashboard: `BalanceCardView`, `StatCard`
- Budget: `BudgetCard`, `BudgetAlertCard`
- Goals: `GoalCard`
- Accounts: `AccountsCard`
- Reports: `ReportSummaryCard`
- All other card-like components (8+ total)

**Changes**:
- Enhance `AnimatedCard` with `CardStyle` enum
- Default style is `.standard` (layered background)
- Existing cards automatically get enhancement
- Add fade-in animation on appearance
- Migration: No code changes needed (automatic)

**Success Criteria**:
- ✅ All 8+ card components render with layered backgrounds
- ✅ Fade-in animation works in Full mode
- ✅ No animation in Minimal mode
- ✅ No visual regressions

### Phase 2: Inner Shadows on All Inputs (Week 2)

**Target Components**:
- All `TextField` instances (15+ files)
- All `SecureField` instances (login, auth)
- All `TextEditor` instances (notes fields)
- Search bars (BillsScreen, TransactionsScreen, etc.)

**Changes**:
- Create `StyledTextField` component
- Create `StyledSecureField` component
- Create `StyledTextEditor` component
- Add `@FocusState` tracking
- Focus animation: border glow (300ms spring)
- Migration: TextField → StyledTextField (search & replace)

**Success Criteria**:
- ✅ All 15+ input screens use StyledTextField
- ✅ Focus states animate correctly
- ✅ Error states display properly
- ✅ VoiceOver reads labels and errors

### Phase 3: Pressed Depth on Interactive Elements (Week 3)

**Target Elements**:
- All card tap gestures (AnimatedCard handles)
- List row items (TransactionRow, BillRow, etc.)
- Custom buttons (QuickActionButton)
- Goal contribution buttons
- Category chips

**Changes**:
- AnimatedCard already has press states, enhance depth levels
- Create `.interactiveRow()` modifier for list items
- Add press gestures to buttons not using AnimatedCard
- Ensure haptic feedback on all interactions

**Success Criteria**:
- ✅ All tappable elements have press feedback
- ✅ Haptic feedback works on physical device
- ✅ 300ms spring animation timing verified
- ✅ No dropped frames during press

### Phase 4: Frosted Glass on Sheets & Navigation (Week 4)

**Target UI**:
- All `.sheet()` presentations (10+ screens)
- Navigation bars (MainTabView, navigation stacks)
- Detail sheets (BudgetDetailSheet, GoalProgressSheet, BillDetailView)
- Confirmation alerts and action sheets

**Changes**:
- Create `.frostedSheet()` modifier
- Apply to all sheet presentations
- Add navigation bar blur: `.toolbarBackground(.ultraThinMaterial)`
- Animate blur intensity on presentation/dismissal

**Success Criteria**:
- ✅ All 10+ sheets have frosted background
- ✅ Blur animates on presentation (300ms)
- ✅ Navigation bars blur correctly
- ✅ Sheet stacking works (sheet over sheet)

## Animation Integration

All animations respect `AnimationSettings.effectiveMode`:

### Full Mode
- All animations enabled
- Fade-in: 200ms ease-in-out
- Focus glow: 300ms spring
- Blur transitions: 300ms ease-in-out
- Press depth: 300ms spring

### Reduced Mode
- Simplified animations only
- Quick fades: 100ms linear
- No springs (use easeInOut)
- Reduced blur intensity

### Minimal Mode
- No animations (instant transitions)
- All effects appear immediately
- Press states use opacity change only

## Migration Strategy

### Phase 1: Cards (Automatic)

Before (no change needed):
```swift
AnimatedCard {
  VStack {
    Text("Balance")
    Text("$1,234")
  }
}
```

After (automatic enhancement):
- Gets layered background by default
- Optional: Specify premium style

```swift
AnimatedCard(style: .premium) {
  VStack {
    Text("Balance")
    Text("$1,234")
  }
}
```

### Phase 2: Text Fields

Before:
```swift
TextField("Amount", text: $amount)
  .textFieldStyle(.roundedBorder)
  .keyboardType(.decimalPad)
```

After:
```swift
StyledTextField(
  title: "Amount",
  text: $amount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)
```

### Phase 3: Interactive Elements

Before:
```swift
TransactionRow(transaction: transaction)
  .onTapGesture { selectTransaction(transaction) }
```

After:
```swift
TransactionRow(transaction: transaction)
  .interactiveRow()
  .onTapGesture { selectTransaction(transaction) }
```

### Phase 4: Sheets

Before:
```swift
.sheet(isPresented: $showingAddTransaction) {
  AddTransactionView()
}
```

After:
```swift
.sheet(isPresented: $showingAddTransaction) {
  AddTransactionView()
    .frostedSheet()
}
```

Navigation bars:
```swift
.navigationBarTitleDisplayMode(.large)
.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
```

## Error Handling & Edge Cases

### Animation Mode Handling

**Reduce Motion enabled**:
- Layered backgrounds appear instantly (no fade)
- Frosted glass blur is static (no transition)
- Press depth uses quick fade instead of spring
- Focus glow appears instantly

**Low Power Mode** (future):
- Can detect via `ProcessInfo.processInfo.isLowPowerModeEnabled`
- Automatically switches to Minimal mode
- Effects remain visible, no animations

### Input Field Error States

```swift
StyledTextField(
  title: "Amount",
  text: $amount,
  placeholder: "0.00",
  keyboardType: .decimalPad,
  error: viewModel.amountError  // Optional String
)
```

When error is present:
- Border color: `.oldMoney.error` (red tint)
- Error message below field
- Inner shadow intensity increases
- Accessibility: "Error: [message]"

### Color Scheme Adaptation

All effects adapt to light/dark mode:
- Layered backgrounds: Lighter gradients in dark mode
- Inner shadows: More visible in light, subtle in dark
- Frosted glass: Material automatically adapts
- Focus glow: Accent color works in both modes

### Accessibility

- **VoiceOver**: All decorative effects hidden
- **Dynamic Type**: Text scales properly in StyledTextField
- **Contrast**: Inner shadows maintain WCAG AA standards
- **High Contrast**: Effects become more pronounced
- **Haptic**: Respects "Reduce Motion" setting

### Edge Cases

1. **Sheet over sheet**: Frosted glass stacks properly (each layer blurs)
2. **Card in card**: Only outer card gets layered background
3. **Disabled inputs**: Recessed style with reduced opacity
4. **Empty states**: Cards without content still get backgrounds
5. **iPad split view**: Effects scale for larger screens

## Testing Strategy

### Phase 1 Testing (Cards)
- Visual regression: Screenshot comparison
- Animation timing: Verify fade-in in all modes
- Manual QA: All card screens
- Accessibility: VoiceOver navigation
- **Success**: All 8+ cards render correctly

### Phase 2 Testing (Inputs)
- Unit tests: Focus states, error states
- Integration tests: Form validation
- Manual QA: Keyboard types, focus flow
- Accessibility: VoiceOver reads labels/errors
- **Success**: All 15+ input screens migrated

### Phase 3 Testing (Interactive)
- Haptic verification on device
- Press timing: 300ms spring
- Manual QA: All tappable elements
- Performance: No dropped frames
- **Success**: All elements have feedback

### Phase 4 Testing (Frosted Glass)
- Sheet blur animation: 300ms
- Navigation bar blur on scroll
- Stacking: Sheet over sheet
- GPU usage monitoring
- **Success**: All 10+ sheets have blur

### Performance Benchmarks

- Card render: < 16ms (60fps)
- Input focus animation: < 300ms
- Sheet presentation: < 400ms total
- Memory: No leaks from animation states
- Battery: < 1% impact over baseline

## Success Criteria

Implementation complete when:
1. ✅ All cards use AnimatedCard with layered backgrounds
2. ✅ All inputs use StyledTextField with inner shadows
3. ✅ All interactive elements have press depth
4. ✅ All sheets have frosted glass backgrounds
5. ✅ Animations respect accessibility settings
6. ✅ No visual regressions
7. ✅ Build succeeds with zero warnings
8. ✅ All accessibility labels maintained

## Rollback Plan

If issues arise:
- Each phase is separate git branch
- Individual phase rollback possible
- Feature flag: `enableSurfaceEffects`
- Previous styles preserved as fallback

## Next Steps

1. Create implementation plan with detailed tasks
2. Set up git worktree for isolated development
3. Begin Phase 1: Card enhancements
4. Validate and test each phase before proceeding
5. Update CHANGELOG.md after each phase
