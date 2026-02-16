# Phase 5B: Card Interactions Design

**Date:** 2026-02-15
**Status:** Approved
**Author:** Claude Code (Brainstorming Session)
**Target:** iOS 15+, iPhone & iPad
**Duration:** 2 weeks
**Prerequisites:** Phase 5A Complete ✅

---

## Overview

Phase 5B introduces advanced card interactions to FinPessoal, building on the animation and gesture foundation from Phase 5A. This phase delivers three reusable components: custom swipe-to-reveal actions, 3D flip card transitions, and single-expansion accordions. All components maintain the refined Old Money aesthetic with comprehensive accessibility support.

### Key Deliverables
- ✅ **SwipeableRow** - Physics-based swipe gestures with action reveal
- ✅ **FlipCard** - 3D rotation transitions between front/back views
- ✅ **ExpandableSection** - Single-expansion accordion with smooth animations
- ✅ **Full Accessibility** - VoiceOver, Dynamic Type, Reduce Motion, High Contrast
- ✅ **Performance** - 60fps sustained across all interactions

---

## Design Decisions

### Architecture: Component-Based

**Why component-based over modifiers?**
- ✅ Proven pattern from Phase 5A (`PieDonutChart`, `BarChart`, `ChartCalloutView`)
- ✅ Clean separation of concerns - each component has one job
- ✅ Maximum reusability - works anywhere (lists, cards, standalone)
- ✅ Easier testing - isolated components with clear boundaries
- ✅ Future-proof - easy to extend and maintain

### Interaction Model

**SwipeableRow: Custom Gesture (not native)**
- Fine-grained control over animation and physics
- Resistance curve for natural feel
- Partial swipe preview with bounce-back
- Matches refined Old Money aesthetic
- Integrates with existing `HapticEngine` and `AnimationEngine`

**FlipCard: Tap-to-Flip**
- Single tap triggers 3D rotation
- 400ms spring animation with perspective
- Front/back are generic views (maximum flexibility)
- Optional auto-flip back for temporary reveals

**ExpandableSection: Single Expansion**
- Only one section expanded at a time
- Clean, focused UI
- 300ms height animation with chevron rotation
- Coordinator manages expansion state

### Animation Philosophy

**Consistency with Phase 5A:**
- **Timing**: 300ms base, 400ms for dramatic effects (flip)
- **Curves**: Gentle springs (dampingFraction: 0.75-0.8)
- **Stagger**: None needed (single-element interactions)
- **Respect AnimationSettings**: Full/Reduced/Minimal modes

**Physics-Based Feel:**
- Swipe resistance increases with distance
- Spring animations with natural bounce
- Haptic feedback at key moments (threshold, commit)

---

## Architecture

### Component Hierarchy

```
AnimationEngine (Phase 5A)
├── AnimationEngine+CardInteractions (new extensions)
│
HapticEngine (Phase 5A)
│
SwipeGestureHandler (new)
├── Drag tracking
├── Resistance curve
├── Threshold detection
└── Haptic coordination
│
Components:
├── SwipeableRow<Content>
│   ├── Uses: SwipeGestureHandler
│   ├── Uses: SwipeAction model
│   └── Reveals actions on swipe
│
├── FlipCard<Front, Back>
│   ├── 3D rotation transform
│   ├── Perspective effect
│   └── Front/back visibility logic
│
└── ExpandableSection<Header, Content>
    ├── Uses: ExpansionCoordinator
    ├── Height animation
    └── Chevron rotation
```

### Integration Points

**With Phase 5A:**
- Uses `AnimationEngine` for all animations
- Uses `HapticEngine.shared` for feedback
- Respects `AnimationSettings.effectiveMode`
- Uses Old Money color palette
- Follows same accessibility patterns

**With Existing Components:**
- `SwipeableRow` can replace/enhance `InteractiveListRow`
- `FlipCard` wraps existing card views (Budget, Goal, Transaction)
- `ExpandableSection` used in Filters, Settings, Category details

---

## Component Specifications

### 1. SwipeableRow<Content>

**Purpose:** Horizontal swipe gesture revealing action buttons

**API:**
```swift
struct SwipeableRow<Content: View>: View {
  init(
    leadingActions: [SwipeAction] = [],
    trailingActions: [SwipeAction] = [],
    threshold: CGFloat = 0.5,
    maxSwipeDistance: CGFloat = 120,
    @ViewBuilder content: () -> Content
  )
}
```

**SwipeAction Model:**
```swift
struct SwipeAction: Identifiable {
  let title: String
  let icon: String
  let tint: Color
  let role: ButtonRole?
  let action: () async -> Void

  // Presets
  static func delete(_ action: @escaping () async -> Void) -> SwipeAction
  static func edit(_ action: @escaping () async -> Void) -> SwipeAction
  static func archive(_ action: @escaping () async -> Void) -> SwipeAction
  static func complete(_ action: @escaping () async -> Void) -> SwipeAction
}
```

**Gesture Behavior:**

| Swipe Distance | Behavior |
|----------------|----------|
| 0-30px | Resistance starts, subtle haptic (light) |
| 30-60px | Actions fade in, labels visible |
| 60px (threshold) | Medium haptic, action highlighted |
| Release < 60px | Bounce back with spring |
| Release > 60px | Execute action, selection haptic, reset |

**Visual Design:**
- Actions revealed behind content (depth effect)
- Each action: 60px wide, icon + label stacked vertically
- Background: `.ultraThinMaterial` (frosted glass from Phase 4)
- Content slides with shadow increase (depth cue)
- Animations: 300ms spring for resistance, 350ms for reset

**Accessibility:**
- Swipe actions exposed as VoiceOver custom actions
- No physical swipe needed with VoiceOver
- Actions announced: "Edit, Delete" in hint
- Respects Reduce Motion (instant reveal/hide)

---

### 2. FlipCard<Front, Back>

**Purpose:** 3D rotation transition between two views

**API:**
```swift
struct FlipCard<Front: View, Back: View>: View {
  init(
    axis: FlipAxis = .vertical,
    duration: TimeInterval = 0.4,
    autoFlipBack: TimeInterval? = nil,
    @ViewBuilder front: () -> Front,
    @ViewBuilder back: () -> Back
  )
}

enum FlipAxis {
  case vertical    // Y-axis rotation (default)
  case horizontal  // X-axis rotation
}
```

**Animation Mechanics:**

| Angle | Front Visibility | Back Visibility | Notes |
|-------|------------------|-----------------|-------|
| 0° | ✅ Visible | ❌ Hidden | Initial state |
| 0-90° | ✅ Fading | ❌ Hidden | Front rotating away |
| 90° | ❌ Hidden | ❌ Hidden | Transition point |
| 90-180° | ❌ Hidden | ✅ Fading in | Back rotating in |
| 180° | ❌ Hidden | ✅ Visible | Flipped state |

**3D Transform:**
```swift
.rotation3DEffect(
  .degrees(rotationAngle),
  axis: (x: 0, y: 1, z: 0),  // Y-axis for vertical flip
  perspective: 0.5            // Depth illusion
)
```

**Timing:**
- **Duration**: 400ms (slightly slower than Phase 5A for dramatic effect)
- **Curve**: Spring (response: 0.4, damping: 0.75)
- **Haptic**: Light impact on flip start

**Use Cases:**
- Transaction cards: Summary → Full details
- Budget cards: Current status → Category breakdown
- Goal cards: Progress → Contribution history

**Accessibility:**
- Current side announced to VoiceOver
- "Double tap to flip card" hint
- Flip action accessible via double-tap
- Reduce Motion: Crossfade instead of 3D rotation

---

### 3. ExpandableSection<Header, Content>

**Purpose:** Accordion-style expandable section with single-expansion

**API:**
```swift
struct ExpandableSection<Header: View, Content: View>: View {
  init(
    initiallyExpanded: Bool = false,
    showChevron: Bool = true,
    onExpand: (() -> Void)? = nil,
    onCollapse: (() -> Void)? = nil,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content
  )
}
```

**ExpansionCoordinator:**
```swift
@Observable
class ExpansionCoordinator {
  var expandedSectionID: String? = nil

  func expand(_ id: String) {
    expandedSectionID = id
  }

  func isExpanded(_ id: String) -> Bool {
    expandedSectionID == id
  }
}
```

**Behavior:**
- **Single Expansion**: Expanding section B auto-collapses section A
- **Header**: Always visible, entire row tappable
- **Chevron**: Rotates 0° → 90° (right → down) over 250ms
- **Content**: Height animates 0 → auto over 300ms with easeInOut
- **Clipping**: Content clipped during animation, no overflow

**Visual Design:**
- Header: HStack with title + Spacer + chevron
- Divider: Subtle line between header and content (Old Money style)
- Content: VStack with padding, revealed smoothly
- Background: Maintains card surface color

**Use Cases:**
- Category spending breakdowns
- Budget filter panels
- Settings sections
- FAQ-style content

**Accessibility:**
- Header is interactive button element
- State announced: "Expanded" or "Collapsed"
- Hint: "Double tap to expand/collapse"
- Content children navigable when expanded

---

## Animation System Integration

### AnimationEngine+CardInteractions

**New animation curves:**
```swift
extension AnimationEngine {
  // Swipe animations
  static let swipeReveal = Animation.spring(response: 0.3, dampingFraction: 0.8)
  static let swipeBounce = Animation.spring(response: 0.25, dampingFraction: 0.6)
  static let swipeReset = Animation.spring(response: 0.35, dampingFraction: 0.75)

  // Flip animations
  static let cardFlip = Animation.spring(response: 0.4, dampingFraction: 0.75)

  // Expand/collapse
  static let sectionExpand = Animation.easeInOut(duration: 0.3)
  static let chevronRotate = Animation.easeInOut(duration: 0.25)

  // Adaptive versions (respect AnimationSettings)
  static func adaptiveSwipe() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full: return swipeReveal
    case .reduced: return .linear(duration: 0.2)
    case .minimal: return nil
    }
  }

  static func adaptiveFlip() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full: return cardFlip
    case .reduced: return .linear(duration: 0.25)
    case .minimal: return nil
    }
  }

  static func adaptiveExpand() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full: return sectionExpand
    case .reduced: return .linear(duration: 0.15)
    case .minimal: return nil
    }
  }
}
```

### SwipeGestureHandler

**State Management:**
```swift
@MainActor
class SwipeGestureHandler: ObservableObject {
  @Published var offset: CGFloat = 0
  @Published var isDragging: Bool = false
  @Published var revealedSide: SwipeSide? = nil

  private var hasTriggeredHaptic = false

  enum SwipeSide {
    case leading
    case trailing
  }

  func handleDragChanged(_ value: DragGesture.Value, maxDistance: CGFloat) {
    isDragging = true

    // Apply resistance curve (rubber band effect)
    let translation = value.translation.width
    let resistance = abs(translation) / maxDistance
    let dampedOffset = translation * (1 - resistance * 0.3)

    offset = min(maxDistance, max(-maxDistance, dampedOffset))

    // Haptic at threshold (only once per swipe)
    if abs(offset) > maxDistance * 0.5 && !hasTriggeredHaptic {
      HapticEngine.shared.medium()
      hasTriggeredHaptic = true
    }
  }

  func handleDragEnded(threshold: CGFloat, maxDistance: CGFloat) {
    isDragging = false

    if abs(offset) > threshold {
      // Commit swipe - reveal actions
      revealedSide = offset > 0 ? .leading : .trailing
      HapticEngine.shared.selection()
    } else {
      // Bounce back
      offset = 0
      hasTriggeredHaptic = false
    }
  }

  func reset() {
    offset = 0
    revealedSide = nil
    hasTriggeredHaptic = false
  }
}
```

### Animation Mode Adaptations

**Full Mode:**
- All springs and physics-based animations
- Resistance curve for swipe
- 3D perspective flip with rotation
- Smooth height animation with easing

**Reduced Mode:**
- Simplified linear animations (no springs)
- Basic swipe (reduced resistance)
- 2D flip (scale + fade instead of rotation)
- Faster durations (150-200ms)

**Minimal Mode:**
- Instant state changes (no animation)
- Swipe: Actions appear/disappear instantly
- Flip: Instant swap with crossfade
- Expand: Content shows/hides instantly
- Haptics disabled via `HapticEngine.shouldSuppressHaptics`

---

## Accessibility

### VoiceOver Support

**SwipeableRow:**
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("Transaction row")
.accessibilityHint("Swipe left for actions: Edit, Delete")
.accessibilityActions {
  ForEach(trailingActions) { action in
    Button(action.title) {
      Task { await action.action() }
    }
  }
}
```

**FlipCard:**
```swift
.accessibilityElement(children: .ignore)
.accessibilityLabel(isFlipped ? backAccessibilityLabel : frontAccessibilityLabel)
.accessibilityHint("Double tap to flip card")
.accessibilityAddTraits(.isButton)
.accessibilityAction {
  isFlipped.toggle()
  HapticEngine.shared.light()
}
```

**ExpandableSection:**
```swift
.accessibilityElement(children: .contain)
.accessibilityLabel(headerLabel)
.accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
.accessibilityAddTraits(.isButton)
.accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
```

### Dynamic Type

**Text Scaling:**
- All action labels scale from Small to xxxLarge
- Section headers respect user text size
- `.minimumScaleFactor(0.8)` prevents extreme scaling
- Layout adjusts: Swipe actions may stack vertically at xxxLarge

**Fixed Elements:**
- Swipe distances don't scale
- Animation speeds consistent
- Chevron size capped for visual consistency

### Reduce Motion Integration

**Mode Detection:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion
// OR use existing AnimationSettings.effectiveMode
```

**Adaptations:**

| Mode | Swipe | Flip | Expand |
|------|-------|------|--------|
| Full | Spring with resistance | 3D rotation | Height animation |
| Reduced | Linear 200ms | 2D scale/fade | Linear 150ms |
| Minimal | Instant reveal | Instant swap | Instant show/hide |

### High Contrast Mode

**Detection:**
```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
```

**Adaptations:**
- Thicker borders (3px instead of 1px)
- Stronger color saturation for actions
- Higher contrast dividers
- Icons + text labels (not just icons)

### WCAG AA Compliance

**Requirements Met:**
- ✅ Color Contrast: 4.5:1 minimum for all text
- ✅ Touch Targets: 44x44pt minimum for all interactive elements
- ✅ Focus Indicators: Clear visual feedback on all interactions
- ✅ Keyboard Navigation: All actions accessible via VoiceOver
- ✅ Motion Control: Animations respect Reduce Motion
- ✅ Alternative Input: All gestures have non-gesture alternatives

---

## Testing Strategy

### Unit Tests

**SwipeGestureHandlerTests.swift:**
- Threshold detection (above/below)
- Bounce-back behavior
- Resistance curve calculation
- Haptic trigger timing
- Reset functionality

**FlipCardTests.swift:**
- State toggle (front/back)
- Rotation angle calculation
- Visibility logic (0-90° vs 90-180°)
- Animation timing
- Accessibility label switching

**ExpandableSectionTests.swift:**
- Expansion toggle
- Single-expansion coordinator
- Height calculation
- Chevron rotation
- Callback execution

### Accessibility Tests

**CardInteractionsAccessibilityTests.swift:**
- VoiceOver actions exposed
- Accessibility labels correct
- Reduce Motion disables animations
- Haptics respect Reduce Motion
- Dynamic Type doesn't break layouts
- High Contrast increases visibility

### Integration Tests

**Real-world usage:**
- SwipeableRow in TransactionsList
- FlipCard in BudgetCards
- ExpandableSection in CategoryFilters
- Multiple components on same screen
- Memory usage during rapid interactions

### Manual QA Checklist

**Per Component:**

**SwipeableRow:**
- [ ] Swipe reveals actions smoothly
- [ ] Resistance curve feels natural
- [ ] Haptic at threshold (60px)
- [ ] Bounce back below threshold
- [ ] Actions execute correctly
- [ ] VoiceOver exposes actions
- [ ] Reduce Motion instant reveal
- [ ] High Contrast stronger colors
- [ ] Works in Dark Mode

**FlipCard:**
- [ ] Flip animation smooth (400ms)
- [ ] 3D perspective visible
- [ ] Front/back content correct
- [ ] Tap gesture responsive
- [ ] VoiceOver announces both sides
- [ ] Reduce Motion uses crossfade
- [ ] Works in all orientations
- [ ] Auto-flip back (if enabled)

**ExpandableSection:**
- [ ] Expands smoothly (300ms)
- [ ] Single-expansion enforced
- [ ] Chevron rotates (0° → 90°)
- [ ] Content clips during animation
- [ ] Header always tappable
- [ ] VoiceOver navigation works
- [ ] Dynamic Type scales correctly
- [ ] Callbacks fire correctly

### Performance Testing

**Targets (match Phase 5A):**
- **60fps** sustained during all animations
- **<16ms** per frame during gesture tracking
- **<8ms** haptic trigger delay
- **No memory leaks** during repeated interactions
- **Smooth on iPhone SE 2020**

**Tools:**
- Instruments Time Profiler
- Instruments Core Animation
- Memory Graph Debugger
- Manual testing on low-end devices

---

## Implementation Plan

### Week 1: Swipe & Gesture Foundation

**Day 1-2: SwipeGestureHandler & Core**
- Create `SwipeGestureHandler.swift`
- Implement drag tracking with resistance curve
- Add threshold detection
- Integrate haptics at key moments
- Unit tests for gesture logic
- **Deliverable:** Working gesture handler (isolated component)

**Day 3-4: SwipeableRow Component**
- Build `SwipeableRow.swift`
- Integrate `SwipeGestureHandler`
- Create `SwipeAction` model with presets
- Action reveal animations (fade + slide)
- Background blur with frosted glass
- **Deliverable:** Complete swipeable row component

**Day 5: SwipeableRow Integration & Testing**
- Integrate into TransactionsList
- Replace or complement `InteractiveListRow`
- VoiceOver testing (custom actions)
- Reduce Motion testing
- Unit + integration tests
- **Deliverable:** Swipe working in production

---

### Week 2: Flip & Expand Components

**Day 1-2: FlipCard Component**
- Create `FlipCard.swift`
- Implement 3D rotation with perspective
- Front/back visibility switching logic
- Tap gesture integration
- Auto-flip back timer (optional)
- Unit tests
- **Deliverable:** Working flip card component

**Day 3: FlipCard Integrations**
- Wrap Transaction detail cards
- Wrap Budget summary cards
- Wrap Goal progress cards
- Accessibility testing (VoiceOver, Reduce Motion)
- Dark Mode verification
- **Deliverable:** Flip in 3+ locations

**Day 4: ExpandableSection Component**
- Create `ExpandableSection.swift`
- Build `ExpansionCoordinator` for single-expansion
- Height animation with clipping
- Chevron rotation
- Callbacks (onExpand, onCollapse)
- Unit tests
- **Deliverable:** Working expandable sections

**Day 5: Polish, Testing & Documentation**
- Integrate ExpandableSection (Filters, Settings, Category details)
- Full performance testing (60fps verification)
- Complete accessibility audit
- Fix any edge cases
- Update CHANGELOG.md
- Write Phase 5B completion report
- **Deliverable:** Phase 5B complete & documented

---

## File Structure

### Files to Create (10 files)

**Core Components:**
```
FinPessoal/Code/Animation/Components/CardInteractions/
├── SwipeableRow.swift           (~200 lines)
├── FlipCard.swift                (~180 lines)
├── ExpandableSection.swift       (~150 lines)
├── SwipeGestureHandler.swift    (~120 lines)
├── SwipeAction.swift             (~80 lines)
└── ExpansionCoordinator.swift    (~60 lines)
```

**Animation Extensions:**
```
FinPessoal/Code/Animation/Engine/
└── AnimationEngine+CardInteractions.swift  (~100 lines)
```

**Tests:**
```
FinPessoalTests/Animation/CardInteractions/
├── SwipeGestureHandlerTests.swift  (~150 lines)
├── FlipCardTests.swift              (~120 lines)
└── ExpandableSectionTests.swift     (~100 lines)
```

**Total: 10 new files, ~1,260 lines**

### Files to Modify (5 files)

**Integration Points:**
- `TransactionsList.swift` - Add SwipeableRow
- `BudgetCard.swift` - Wrap with FlipCard
- `GoalCard.swift` - Wrap with FlipCard
- `CategorySpendingView.swift` - Add ExpandableSection
- `CHANGELOG.md` - Document Phase 5B

---

## Success Criteria

Phase 5B complete when:

1. ✅ **SwipeableRow** working with custom gestures
2. ✅ **FlipCard** integrated in 3+ locations (Transaction, Budget, Goal)
3. ✅ **ExpandableSection** with single-expansion coordinator
4. ✅ All components respect `AnimationSettings.effectiveMode`
5. ✅ Full accessibility compliance:
   - VoiceOver navigation
   - Dynamic Type support
   - Reduce Motion integration
   - High Contrast mode
6. ✅ Performance targets met:
   - 60fps sustained
   - <16ms gesture tracking
   - No memory leaks
7. ✅ Testing complete:
   - Unit tests passing (10+ test cases)
   - Accessibility tests passing (5+ test cases)
   - Manual QA checklist 100%
8. ✅ Build succeeds with zero errors
9. ✅ CHANGELOG.md updated
10. ✅ Completion report written

---

## Design Philosophy

### Consistency with Phase 5A

**Animation Timing:**
- Same base: 300ms easeInOut
- Same springs: gentle (damping 0.75-0.8)
- Slightly slower for flip: 400ms (more dramatic)

**Component Architecture:**
- Reusable components (not one-off implementations)
- Protocol-based where beneficial
- StateObject for state management
- Generic views for flexibility

**Accessibility Standards:**
- WCAG AA compliance (4.5:1 contrast)
- VoiceOver first-class support
- Reduce Motion respected
- Dynamic Type support
- High Contrast adaptations

**Testing Rigor:**
- Unit tests for all logic
- Accessibility tests comprehensive
- Integration tests in real views
- Performance benchmarks
- Manual QA checklists

### Key Principles

**Physics-Based:**
- Natural spring animations
- Resistance curves for gestures
- Momentum and bounce effects

**Accessible-First:**
- VoiceOver designed in from start
- All gestures have non-gesture alternatives
- Reduce Motion support from day 1

**Performance:**
- 60fps non-negotiable
- Optimize rendering for smooth animations
- Cancel tasks on disappear

**Reusable:**
- Components work anywhere
- Not tied to specific views
- Generic and composable

**Tested:**
- No component ships without tests
- Accessibility verified
- Performance measured

---

## Edge Cases & Considerations

### SwipeableRow

**Edge Cases:**
- Multiple rapid swipes: Cancel previous, start new
- Swipe during scroll: Prioritize scroll, threshold higher
- Simultaneous swipes: Only one row active at a time
- Action execution error: Reset with error haptic

**Accessibility:**
- VoiceOver: Actions as custom actions (no swipe needed)
- Switch Control: Actions accessible via interface
- Voice Control: Action buttons have clear labels

### FlipCard

**Edge Cases:**
- Rapid taps during flip: Debounce, queue next flip
- Orientation change mid-flip: Complete current animation
- Content height mismatch: Use max height of both sides
- Auto-flip back timer: Cancel if user manually flips

**Accessibility:**
- VoiceOver: Announce current side, offer flip action
- Reduce Motion: Crossfade instead of 3D rotation
- Dynamic Type: Both sides scale consistently

### ExpandableSection

**Edge Cases:**
- Content taller than screen: Enable scrolling
- Rapid expand/collapse: Debounce, complete current animation
- Dynamic content height: Recalculate on content change
- All sections collapsed: Valid state

**Accessibility:**
- VoiceOver: Navigate header, then content when expanded
- Keyboard: Space/Enter expands/collapses
- Content focus: Move to first item when expanded

---

## Next Steps After Phase 5B

### Phase 5C: Advanced Polish (2 weeks)
- Hero transitions between screens
- Parallax scrolling effects
- Celebration animations for milestones
- Gradient animations
- Subtle 3D transforms

### Prerequisites for Phase 5C
- Phase 5B components stable ✅
- Animation system extended ✅
- Gesture patterns proven ✅

---

## Appendix

### Comparison with Phase 5A

| Aspect | Phase 5A | Phase 5B |
|--------|----------|----------|
| **Focus** | Data visualization | Card interactions |
| **Components** | 2 charts | 3 interaction types |
| **Gestures** | Tap, Drag, Long press | Swipe, Tap, Tap (header) |
| **Duration** | 4 weeks | 2 weeks |
| **Timing** | 300ms base | 300-400ms |
| **Accessibility** | WCAG AA | WCAG AA |
| **Performance** | 60fps | 60fps |
| **Tests** | 20+ tests | 15+ tests |

### References

- Phase 5A Completion Report
- Phase 4 Frosted Glass Design
- Phase 3 Interactive List Rows Design
- AnimationEngine documentation
- HapticEngine documentation
- WCAG 2.1 Level AA Guidelines

---

**End of Phase 5B Design Document**
