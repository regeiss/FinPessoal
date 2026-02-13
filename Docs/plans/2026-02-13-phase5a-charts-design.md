# Phase 5A: Charts & Data Visualization Design

**Date:** 2026-02-13
**Status:** Approved
**Author:** Claude Code (Brainstorming Session)
**Target:** iOS 15+, iPhone & iPad
**Duration:** 4 weeks

## Overview

Phase 5A introduces animated, interactive charts with comprehensive gesture support to FinPessoal's Reports feature. This phase replaces basic progress circles with sophisticated Pie/Donut and Bar charts featuring smooth animations, advanced interactions (tap, drag/scrub, long press), haptic feedback, and full accessibility support.

This is the first of three Phase 5 sub-phases focusing on visual polish and advanced interactions. Phase 5A specifically targets data visualization, establishing the foundation for future card interactions (5B) and advanced polish (5C).

## Design Decisions

### Chart Types

**Phase 5A focuses on two chart types:**
1. **Pie/Donut Charts** - Category spending breakdowns
2. **Bar Charts** - Monthly trends, budget performance

These cover 80% of FinPessoal's data visualization needs while keeping scope manageable.

### Interaction Model

**Advanced gesture support:**
- **Tap** - Select/deselect single element
- **Drag/Scrub** - Highlight elements while dragging across chart
- **Long Press** - Open detailed breakdown sheet
- **Double Tap** - Reset zoom/selection (future)
- **Pinch Zoom** - Scale chart (future, bar charts only)

All gestures include haptic feedback and have VoiceOver equivalents.

### Animation Philosophy

**Refined & Subtle** (Old Money aesthetic):
- 300ms base timing with 50ms stagger for cascading reveals
- `easeInOut` curves for smoothness
- Gentle springs for selections (no bouncy effects)
- 5% scale increase on selection (subtle, not dramatic)
- Smooth morphing transitions when data changes

All animations respect `AnimationSettings.effectiveMode`:
- **Full**: All effects enabled
- **Reduced**: Simplified animations (150ms linear, no springs)
- **Minimal**: Instant transitions, opacity-based selection

### Data Update Strategy

**Smooth Morphing** when period changes:
1. Fade out old values (150ms)
2. Morph shapes to new proportions (300ms spring)
3. Fade in new labels (150ms, delayed)

No jarring replacements - everything transitions smoothly.

### Accessibility

**Comprehensive support:**
- VoiceOver navigation via `accessibilityRepresentation`
- Dynamic Type scaling for all text
- WCAG AA color contrast (4.5:1 minimum)
- Haptic feedback for all interactions
- Reduce Motion integration via existing `AnimationSettings`
- High Contrast mode support

### Loading States

**Skeleton Shimmer** (reusing Phase 1 infrastructure):
- Animated shimmer gradient in Full mode
- Static gradient in Reduced mode
- Solid placeholder in Minimal mode
- Smooth crossfade when data loads

### Error Handling

**Unified empty/error states:**
- Clear error messaging
- Retry button
- Accessible descriptions
- No animations (instant appearance to avoid frustration)

## Architecture

### Core Components

#### 1. AnimatedChart Protocol (Extension)

Extends existing protocol with chart-specific requirements:

```swift
protocol AnimatedChart: View {
  associatedtype Data
  associatedtype GestureHandler: ObservableObject

  var data: [Data] { get }
  var gestureHandler: GestureHandler { get }
  var isAnimating: Bool { get set }

  func animate()
  func reset()
}
```

All charts conform to this protocol for consistency.

#### 2. PieDonutChart Component

Canvas-based pie/donut chart with animated slices:

```swift
struct PieDonutChart: View, AnimatedChart {
  let segments: [ChartSegment]
  let style: PieChartStyle
  @StateObject var gestureHandler = ChartGestureHandler()

  @State private var animatedSegments: [ChartSegment] = []
  @Environment(\.animationMode) private var animationMode

  enum PieChartStyle {
    case pie                    // Solid circle
    case donut(innerRadius: CGFloat)  // Ring (0.0-1.0)
  }

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      let radius = min(size.width, size.height) / 2

      var startAngle = Angle.degrees(-90)

      for segment in animatedSegments {
        let endAngle = startAngle + .degrees(segment.percentage * 3.6)

        var path = Path()
        path.addArc(
          center: center,
          radius: radius * (gestureHandler.selectedID == segment.id ? 1.05 : 1.0),
          startAngle: startAngle,
          endAngle: startAngle + .degrees(segment.percentage * 3.6 * segment.trimEnd),
          clockwise: false
        )

        if case .donut(let innerRadius) = style {
          path.addArc(
            center: center,
            radius: radius * innerRadius,
            startAngle: startAngle + .degrees(segment.percentage * 3.6 * segment.trimEnd),
            endAngle: startAngle,
            clockwise: true
          )
          path.closeSubpath()
        } else {
          path.addLine(to: center)
          path.closeSubpath()
        }

        context.fill(path, with: .color(segment.color.opacity(segment.opacity)))

        startAngle = endAngle
      }
    }
    .gesture(tapGesture)
    .gesture(dragGesture)
    .gesture(longPressGesture)
    .overlay {
      if let selectedID = gestureHandler.selectedID,
         let selected = segments.first(where: { $0.id == selectedID }) {
        ChartCalloutView(segment: selected)
      }
    }
    .onAppear(perform: animate)
  }
}
```

#### 3. BarChart Component

VStack-based bar chart with animated heights:

```swift
struct BarChart: View, AnimatedChart {
  let bars: [ChartBar]
  @StateObject var gestureHandler = ChartGestureHandler()

  @State private var animatedBars: [ChartBar] = []
  @Environment(\.animationMode) private var animationMode

  var body: some View {
    HStack(alignment: .bottom, spacing: 12) {
      ForEach(Array(animatedBars.enumerated()), id: \.element.id) { index, bar in
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 8)
            .fill(bar.color)
            .frame(width: 40, height: bar.height)
            .opacity(bar.opacity)
            .scaleEffect(
              gestureHandler.selectedID == bar.id ? 1.05 : 1.0,
              anchor: .bottom
            )
            .animation(AnimationEngine.snappySpring, value: gestureHandler.selectedID)

          Text(bar.label)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .onTapGesture {
          gestureHandler.handleTap(barID: bar.id)
        }
      }
    }
    .overlay {
      if let selectedID = gestureHandler.selectedID,
         let selected = bars.first(where: { $0.id == selectedID }) {
        ChartCalloutView(bar: selected)
      }
    }
    .onAppear(perform: animate)
  }
}
```

#### 4. ChartGestureHandler

Centralized gesture coordination:

```swift
class ChartGestureHandler: ObservableObject {
  @Published var selectedID: String?
  @Published var isDragging: Bool = false
  @Published var zoomScale: CGFloat = 1.0

  func handleTap(at location: CGPoint, in segments: [ChartSegment]) {
    if let tapped = segment(at: location, in: segments) {
      HapticEngine.selection()
      selectedID = (selectedID == tapped.id) ? nil : tapped.id
    }
  }

  func handleTap(barID: String) {
    HapticEngine.selection()
    selectedID = (selectedID == barID) ? nil : barID
  }

  func handleDrag(value: DragGesture.Value, in segments: [ChartSegment]) {
    isDragging = true
    if let hovered = segment(at: value.location, in: segments) {
      if selectedID != hovered.id {
        HapticEngine.selection()
        selectedID = hovered.id
      }
    }
  }

  func handleLongPress(at location: CGPoint) {
    HapticEngine.impact(.medium)
    // Trigger detail sheet presentation
  }

  private func segment(at point: CGPoint, in segments: [ChartSegment]) -> ChartSegment? {
    // Hit test implementation
    // Returns segment at point or nil
  }
}
```

#### 5. ChartCalloutView

Floating callout for selected elements:

```swift
struct ChartCalloutView: View {
  let segment: ChartSegment?
  let bar: ChartBar?

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let segment = segment {
        Text(segment.label)
          .font(.caption)
          .fontWeight(.semibold)

        HStack(spacing: 8) {
          Text("\(segment.percentage.formatted(.number.precision(.fractionLength(1))))%")
            .font(.caption2)

          Text(segment.value.formatted(.currency(code: "USD")))
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      } else if let bar = bar {
        Text(bar.label)
          .font(.caption)
          .fontWeight(.semibold)

        Text(bar.value.formatted(.currency(code: "USD")))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.oldMoney.accent, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8)
    )
    .transition(.asymmetric(
      insertion: .opacity.combined(with: .offset(y: -10)),
      removal: .opacity
    ))
    .animation(AnimationEngine.quickFade, value: segment != nil || bar != nil)
  }
}
```

## Data Flow & Models

### Chart Data Models

**ChartSegment** (for Pie/Donut charts):
```swift
struct ChartSegment: Identifiable {
  let id: String
  let value: Double
  let percentage: Double
  let label: String
  let color: Color
  let category: Category?

  // Animation state
  var trimEnd: Double = 0
  var scale: CGFloat = 1.0
  var opacity: Double = 1.0
}
```

**ChartBar** (for Bar charts):
```swift
struct ChartBar: Identifiable {
  let id: String
  let value: Double
  let maxValue: Double
  let label: String
  let color: Color
  let date: Date?

  // Animation state
  var height: CGFloat = 0
  var opacity: Double = 0
}
```

### Data Transformation Pipeline

**CategorySpending → ChartSegment**:
```swift
extension CategorySpending {
  func toChartSegment(totalSpent: Double) -> ChartSegment {
    ChartSegment(
      id: category.id,
      value: amount,
      percentage: (amount / totalSpent) * 100,
      label: category.name,
      color: Color(category.color),
      category: category
    )
  }
}
```

**MonthlyTrend → ChartBar**:
```swift
extension MonthlyTrend {
  func toChartBar(maxAmount: Double) -> ChartBar {
    ChartBar(
      id: month,
      value: amount,
      maxValue: maxAmount,
      label: monthLabel,
      color: .oldMoney.accent,
      date: Date.from(month: month)
    )
  }
}
```

### State Management

Charts manage their own animation state through `@State` properties:
- **Selected element**: `@State private var selectedID: String?`
- **Interaction state**: `@State private var isDragging: Bool = false`
- **Animation progress**: `@State private var animationPhase: AnimationPhase = .initial`

ViewModels provide source data only. Charts handle all presentation logic internally, keeping ViewModels lean and testable.

## Gesture Interactions

### Gesture Recognition System

**ChartGestureHandler** centralizes all gesture logic:

```swift
class ChartGestureHandler: ObservableObject {
  @Published var selectedID: String?
  @Published var isDragging: Bool = false
  @Published var zoomScale: CGFloat = 1.0

  func handleTap(at location: CGPoint, in segments: [ChartSegment]) {
    // Hit test: find tapped segment
    if let tapped = segment(at: location, in: segments) {
      HapticEngine.selection()
      selectedID = (selectedID == tapped.id) ? nil : tapped.id
    }
  }

  func handleDrag(value: DragGesture.Value, in segments: [ChartSegment]) {
    isDragging = true
    // Continuous hit test while dragging
    if let hovered = segment(at: value.location, in: segments) {
      if selectedID != hovered.id {
        HapticEngine.selection()
        selectedID = hovered.id
      }
    }
  }

  func handleLongPress(at location: CGPoint) {
    HapticEngine.impact(.medium)
    // Show detailed breakdown sheet
  }
}
```

### Gesture Priority & Conflict Resolution

**Priority order** (highest to lowest):
1. **Long Press** (500ms delay) → Opens detail sheet, cancels other gestures
2. **Drag/Scrub** → Highlights on hover, updates continuously
3. **Double Tap** → Resets zoom/selection
4. **Tap** → Selects single element

**Conflict handling**:
- Long press delay prevents accidental triggers during tap
- Drag gesture threshold (10pt) prevents tap false positives
- Double tap cancels single tap with 300ms window
- Pinch zoom disables drag during scaling

### Accessibility Alternative Inputs

For VoiceOver users (gestures unavailable):
- **Swipe right/left**: Navigate between chart elements
- **Double tap**: Select/deselect element (same as visual tap)
- **Magic Tap**: Announce summary statistics
- **Rotor**: Jump to "Chart Values" category

All gesture-driven interactions have keyboard/VoiceOver equivalents.

## Animation System

### Animation Phases

Charts animate through distinct phases:

```swift
enum AnimationPhase {
  case initial      // Data loaded, no animation yet
  case appearing    // Initial reveal (300ms)
  case idle         // Fully visible, awaiting interaction
  case transitioning // Data changing (300ms morph)
  case interacting  // User gesture in progress
}
```

### Initial Reveal Animation

**Pie/Donut Chart** (300ms with 50ms stagger):
```swift
ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
  PieSlice(segment: segment)
    .trim(from: 0, to: segment.trimEnd)
    .animation(
      AnimationEngine.easeInOut
        .delay(Double(index) * AnimationEngine.standardStagger),
      value: segment.trimEnd
    )
}
.onAppear {
  for i in segments.indices {
    segments[i].trimEnd = segments[i].percentage / 100
  }
}
```

**Bar Chart** (300ms with 50ms stagger):
```swift
ForEach(Array(bars.enumerated()), id: \.element.id) { index, bar in
  BarView(bar: bar)
    .frame(height: bar.height)
    .opacity(bar.opacity)
    .animation(
      AnimationEngine.easeInOut
        .delay(Double(index) * AnimationEngine.standardStagger),
      value: bar.height
    )
}
.onAppear {
  for i in bars.indices {
    bars[i].height = bars[i].value / bars[i].maxValue * maxHeight
    bars[i].opacity = 1.0
  }
}
```

### Data Morphing Transitions

When data updates (e.g., period changes):

1. **Fade out** old values (150ms)
2. **Morph** shapes to new proportions (300ms with spring)
3. **Fade in** new labels (150ms, delayed 200ms)

```swift
.onChange(of: viewModel.categorySpending) { oldData, newData in
  withAnimation(.easeOut(duration: 0.15)) {
    // Fade out
    segments.indices.forEach { segments[$0].opacity = 0 }
  }

  DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
    // Update data
    segments = newData.map { $0.toChartSegment(totalSpent: total) }

    withAnimation(AnimationEngine.gentleSpring) {
      // Morph & fade in
      segments.indices.forEach {
        segments[$0].trimEnd = segments[$0].percentage / 100
        segments[$0].opacity = 1.0
      }
    }
  }
}
```

### Selection Animation (Refined & Subtle)

Selected element scales to **1.05x** (5% larger):
```swift
.scaleEffect(segment.id == selectedID ? 1.05 : 1.0)
.animation(AnimationEngine.snappySpring, value: selectedID)
```

Callout appears with **200ms fade + slide**:
```swift
ChartCalloutView(segment: selectedSegment)
  .transition(.asymmetric(
    insertion: .opacity.combined(with: .offset(y: -10)),
    removal: .opacity
  ))
  .animation(AnimationEngine.quickFade, value: selectedID)
```

All animations respect `AnimationSettings.effectiveMode`:
- **Full**: All animations enabled as described
- **Reduced**: 150ms linear, no springs, scale reduced to 1.02x
- **Minimal**: Instant transitions, no morphing, selection uses opacity only

## Accessibility

### VoiceOver Integration

Charts are fully navigable with VoiceOver using **accessibilityRepresentation**:

```swift
PieDonutChart(segments: segments)
  .accessibilityRepresentation {
    VStack(alignment: .leading, spacing: 8) {
      Text("Category Spending Chart")
        .accessibilityAddTraits(.isHeader)

      Text("Total: \(totalSpent.formatted(.currency(code: "USD")))")

      ForEach(segments) { segment in
        Button {
          selectedID = segment.id
          HapticEngine.selection()
        } label: {
          HStack {
            Text(segment.label)
            Spacer()
            Text("\(segment.percentage.formatted(.number.precision(.fractionLength(1))))%")
            Text("•")
            Text(segment.value.formatted(.currency(code: "USD")))
          }
        }
        .accessibilityLabel("\(segment.label), \(segment.percentage.formatted())percent, \(segment.value.formatted(.currency(code: "USD")))")
        .accessibilityHint("Double tap to view details")
      }
    }
  }
```

**VoiceOver announces**:
- Chart title as header
- Total amount summary
- Each segment as navigable button (swipe right/left)
- Selection changes with haptic feedback
- Custom hints for interactions

### Dynamic Type Support

All text scales with user's preferred text size:

```swift
Text(segment.label)
  .font(.subheadline)  // Scales automatically
  .minimumScaleFactor(0.8)  // Prevents extreme scaling in small spaces

ChartCalloutView(segment: selectedSegment)
  .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Cap at xxxLarge to prevent layout breakage
```

Chart sizes remain fixed (don't scale with text), but all labels/callouts/legends scale appropriately.

### Color Contrast (WCAG AA)

All chart colors meet **4.5:1 contrast ratio** against backgrounds:

```swift
extension Color.oldMoney {
  static let chartColors: [Color] = [
    .accent,      // 7.2:1 contrast
    .success,     // 5.8:1 contrast
    .warning,     // 6.1:1 contrast
    .error,       // 7.5:1 contrast
    .secondary,   // 4.9:1 contrast
  ]
}
```

**High Contrast mode**: Increase contrast automatically:
```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

var strokeWidth: CGFloat {
  differentiateWithoutColor ? 3 : 1.5  // Thicker borders in high contrast
}
```

### Reduce Motion Integration

Already handled by `AnimationSettings.effectiveMode`:
- **Minimal mode** removes all animations, morphing, springs
- Charts appear instantly, selections change via opacity only
- Skeleton shimmer becomes static placeholder

### Haptic Feedback

All interactions include appropriate haptics:
- **Selection** (light tap): Element selection
- **Impact (medium)**: Long press trigger
- **Notification (success)**: Data refresh complete
- **Notification (warning)**: Error state

Haptics respect **Reduce Motion** setting (disabled in Minimal mode).

## Loading States

### Skeleton Shimmer (Reusing Phase 1 Infrastructure)

Charts use existing `SkeletonView` component during data loading:

```swift
struct CategorySpendingView: View {
  @StateObject private var viewModel = ReportsViewModel()

  var body: some View {
    VStack {
      if viewModel.isLoading {
        SkeletonView()
          .frame(width: 250, height: 250)
          .clipShape(Circle())
          .accessibilityLabel("Loading category spending chart")
      } else if let segments = viewModel.categorySegments {
        PieDonutChart(segments: segments)
          .transition(.opacity.combined(with: .scale(scale: 0.95)))
          .animation(AnimationEngine.easeInOut, value: viewModel.isLoading)
      }
    }
  }
}
```

**Bar chart skeleton**:
```swift
if viewModel.isLoading {
  HStack(alignment: .bottom, spacing: 12) {
    ForEach(0..<6, id: \.self) { _ in
      SkeletonView()
        .frame(width: 40, height: CGFloat.random(in: 60...200))
        .cornerRadius(8)
    }
  }
  .accessibilityLabel("Loading monthly trends chart")
}
```

### Shimmer Animation Modes

**Full mode**: Animated shimmer gradient (existing Phase 1 implementation)
```swift
SkeletonView()  // 1.5s repeating linear gradient animation
```

**Reduced mode**: Static gradient (no animation)
```swift
SkeletonView(animated: false)  // Gradient visible but static
```

**Minimal mode**: Solid color placeholder
```swift
Color.oldMoney.surface
  .opacity(0.3)
```

### Loading → Data Transition

Smooth crossfade when data arrives:

```swift
.onChange(of: viewModel.isLoading) { wasLoading, isLoading in
  if wasLoading && !isLoading {
    // Data just loaded
    HapticEngine.notification(.success)

    withAnimation(AnimationEngine.easeInOut) {
      // Fade out skeleton, fade in chart
      showChart = true
    }

    // Delay chart reveal animation by 100ms
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      triggerChartAnimation()
    }
  }
}
```

### Error States

When data fails to load, show unified error view:

```swift
else if let error = viewModel.errorMessage {
  VStack(spacing: 16) {
    Image(systemName: "exclamationmark.triangle.fill")
      .font(.system(size: 48))
      .foregroundStyle(Color.oldMoney.error)
      .accessibilityHidden(true)

    Text("Unable to load chart")
      .font(.headline)

    Text(error)
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)

    Button("Retry") {
      viewModel.refreshData()
    }
    .buttonStyle(.bordered)
    .accessibilityLabel("Retry loading chart data")
  }
  .frame(width: 250, height: 250)
}
```

Error states are **non-animated** (appear instantly) to avoid frustrating users during failures.

## Testing Strategy

### Unit Tests (ChartsTests.swift)

```swift
@MainActor
final class ChartsTests: XCTestCase {

  func testChartSegmentCreation() {
    let spending = CategorySpending(category: .food, amount: 500, percentage: 25)
    let segment = spending.toChartSegment(totalSpent: 2000)

    XCTAssertEqual(segment.value, 500)
    XCTAssertEqual(segment.percentage, 25)
    XCTAssertEqual(segment.label, "Food")
  }

  func testChartBarCalculation() {
    let trend = MonthlyTrend(month: "2026-01", amount: 1500)
    let bar = trend.toChartBar(maxAmount: 2000)

    XCTAssertEqual(bar.value, 1500)
    XCTAssertEqual(bar.maxValue, 2000)
  }

  func testGestureHandlerTapSelection() {
    let handler = ChartGestureHandler()
    let segments = [
      ChartSegment(id: "1", value: 100, percentage: 50, label: "A", color: .blue, category: nil),
      ChartSegment(id: "2", value: 100, percentage: 50, label: "B", color: .red, category: nil)
    ]

    handler.handleTap(at: CGPoint(x: 50, y: 50), in: segments)
    XCTAssertNotNil(handler.selectedID)

    // Tap again to deselect
    handler.handleTap(at: CGPoint(x: 50, y: 50), in: segments)
    XCTAssertNil(handler.selectedID)
  }

  func testAnimationModeAdaptation() {
    AnimationSettings.shared.mode = .minimal

    let animation = AnimationEngine.adaptiveAnimation(
      full: .spring(response: 0.3),
      reduced: .linear(duration: 0.15),
      minimal: nil
    )

    XCTAssertNil(animation) // Minimal mode returns nil
  }

  func testDataMorphTransition() async {
    let viewModel = ReportsViewModel()

    viewModel.selectedPeriod = .thisMonth
    await viewModel.refreshData()
    let initialSegments = viewModel.categorySegments

    viewModel.selectedPeriod = .lastMonth
    await viewModel.refreshData()
    let newSegments = viewModel.categorySegments

    XCTAssertNotEqual(initialSegments, newSegments)
  }
}
```

### Snapshot Tests (ChartsSnapshotTests.swift)

```swift
@MainActor
final class ChartsSnapshotTests: XCTestCase {

  func testPieChartAppearance() {
    let segments = mockCategorySegments()
    let chart = PieDonutChart(segments: segments)
      .frame(width: 250, height: 250)

    assertSnapshot(matching: chart, as: .image)
  }

  func testBarChartAppearance() {
    let bars = mockMonthlyBars()
    let chart = BarChart(bars: bars)
      .frame(width: 350, height: 200)

    assertSnapshot(matching: chart, as: .image)
  }

  func testChartWithSelectionState() {
    let handler = ChartGestureHandler()
    handler.selectedID = "food"

    let chart = PieDonutChart(segments: mockCategorySegments(), gestureHandler: handler)
      .frame(width: 250, height: 250)

    assertSnapshot(matching: chart, as: .image)
  }

  func testSkeletonLoadingState() {
    let skeleton = SkeletonView()
      .frame(width: 250, height: 250)
      .clipShape(Circle())

    assertSnapshot(matching: skeleton, as: .image)
  }
}
```

### Manual QA Checklist

**Per Chart Type:**
- [ ] Initial reveal animation smooth (300ms + 50ms stagger)
- [ ] Tap selects element, second tap deselects
- [ ] Drag/scrub highlights elements continuously
- [ ] Long press triggers detail view
- [ ] Callout appears at correct position
- [ ] Haptic feedback on all interactions
- [ ] VoiceOver navigates all elements
- [ ] Dynamic Type scales labels correctly
- [ ] Works in light & dark mode
- [ ] Color contrast meets WCAG AA

**Data Transitions:**
- [ ] Period change morphs smoothly (300ms)
- [ ] No flicker during data updates
- [ ] Skeleton shimmer appears during loading
- [ ] Error state displays on failure
- [ ] Retry button reloads data

**Accessibility:**
- [ ] VoiceOver announces chart title
- [ ] Each segment navigable with swipe
- [ ] Selection confirmed with haptic
- [ ] Reduce Motion disables animations
- [ ] High Contrast increases borders
- [ ] Reduce Transparency works (if applicable)

**Performance:**
- [ ] 60fps minimum during animations
- [ ] No lag on gesture recognition
- [ ] Smooth on iPhone SE 2020
- [ ] Memory stable during data updates

## Implementation Strategy

### Files to Create

**Core Chart Components:**
1. `FinPessoal/Code/Animation/Components/Charts/AnimatedChart.swift` (protocol extension)
2. `FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift`
3. `FinPessoal/Code/Animation/Components/Charts/BarChart.swift`
4. `FinPessoal/Code/Animation/Components/Charts/ChartGestureHandler.swift`
5. `FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift`

**Data Models:**
6. `FinPessoal/Code/Animation/Components/Charts/Models/ChartSegment.swift`
7. `FinPessoal/Code/Animation/Components/Charts/Models/ChartBar.swift`

**Animation Helpers:**
8. `FinPessoal/Code/Animation/Engine/AnimationEngine+Charts.swift` (chart-specific animations)

**Tests:**
9. `FinPessoalTests/Animation/ChartsTests.swift`
10. `FinPessoalTests/Animation/ChartsSnapshotTests.swift`

### Files to Modify

**Reports Feature:**
- `FinPessoal/Code/Features/Reports/View/CategorySpendingView.swift` - Replace progress circles with PieDonutChart
- `FinPessoal/Code/Features/Reports/View/MonthlyTrendsView.swift` - Replace with BarChart
- `FinPessoal/Code/Features/Reports/View/BudgetPerformanceView.swift` - Replace with BarChart
- `FinPessoal/Code/Features/Reports/Screen/ReportsScreen.swift` - Update layout for new charts

**Budget Feature:**
- `FinPessoal/Code/Features/Budget/View/BudgetCard.swift` - Add mini bar chart
- `FinPessoal/Code/Features/Budget/Screen/BudgetScreen.swift` - Update integration

**Dashboard Feature:**
- `FinPessoal/Code/Features/Dashboard/View/StatCard.swift` - Add sparkline variant (future)

**ViewModels (Data Transformation):**
- `FinPessoal/Code/Features/Reports/ViewModel/ReportsViewModel.swift` - Add segment/bar conversion methods

### Migration Pattern

**Before (CategorySpendingView.swift:30-45):**
```swift
Circle()
  .trim(from: 0.0, to: min(spending.percentage / 100.0, 1.0))
  .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
  .rotationEffect(.degrees(-90))
```

**After:**
```swift
PieDonutChart(
  segments: viewModel.categorySegments,
  style: .donut(innerRadius: 0.6)
)
.frame(width: 250, height: 250)
```

### Rollout Phases (Within Phase 5A)

**Week 1: Core Infrastructure**
- Day 1-2: Create AnimatedChart protocol, ChartSegment/ChartBar models
- Day 3-4: Implement ChartGestureHandler
- Day 5: Implement ChartCalloutView

**Week 2: Chart Components**
- Day 1-3: Build PieDonutChart with animations
- Day 4-5: Build BarChart with animations

**Week 3: Integration**
- Day 1: Integrate PieDonutChart into CategorySpendingView
- Day 2: Integrate BarChart into MonthlyTrendsView
- Day 3: Integrate BarChart into BudgetPerformanceView
- Day 4: Update BudgetCard with mini chart
- Day 5: Polish & refinement

**Week 4: Testing & QA**
- Day 1-2: Write unit tests + snapshot tests
- Day 3: Manual QA checklist
- Day 4: Accessibility verification
- Day 5: Performance testing, bug fixes

### Success Criteria

Phase 5A complete when:
1. ✅ PieDonutChart replaces all progress circles
2. ✅ BarChart used in MonthlyTrendsView & BudgetPerformanceView
3. ✅ All gestures work (tap, drag, long press)
4. ✅ Unit tests passing (8+ test cases)
5. ✅ Snapshot tests passing (6+ snapshots)
6. ✅ Manual QA checklist 100% complete
7. ✅ VoiceOver navigation verified
8. ✅ Build succeeds with zero warnings
9. ✅ Performance targets met (60fps)
10. ✅ CHANGELOG.md updated with Phase 5A entry

## Edge Cases & Completion

### Edge Cases

**Empty Data**:
```swift
if segments.isEmpty {
  VStack(spacing: 16) {
    Image(systemName: "chart.pie")
      .font(.system(size: 48))
      .foregroundStyle(.secondary)
    Text("No spending data")
      .font(.headline)
    Text("Start tracking expenses to see your spending breakdown")
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
  }
  .frame(width: 250, height: 250)
}
```

**Single Data Point**:
- Pie chart shows single 100% segment
- Bar chart shows single bar
- No stagger animation (only one element)
- Selection still works

**Extreme Values**:
- Very small percentages (<1%): Label outside segment with leader line
- Very large values: Number formatting with K/M suffixes
- Zero values: Filtered out before chart rendering

**iPad Split View**:
- Charts scale proportionally to available space
- Callout positioning adapts to narrow splits
- Gestures work in all split configurations

**Landscape Orientation**:
- Charts remain circular/proportional
- Bar charts adjust spacing for wider screens
- Callout positions recalculated for new bounds

**Dark Mode**:
- All colors adapt automatically via `.oldMoney` palette
- Chart backgrounds use `.background` (system adaptive)
- Callout shadows lighter in dark mode

**Multiple Rapid Selections**:
- Debounce haptic feedback (max 1 per 100ms)
- Cancel in-flight animations before starting new ones
- Prevent gesture conflicts with state machine

### Performance Optimization

**Canvas Rendering**:
- Draw calls batched per frame
- Path calculations cached when data unchanged
- Only redraw affected segments on selection change

**Animation Optimization**:
```swift
.drawingGroup() // Flatten layer hierarchy for smoother animation
```

**Memory Management**:
- Gesture handlers weak reference to parent
- Animation timers invalidated on disappear
- Large chart data paginated if >100 segments

### Rollback Plan

**If issues arise:**
- Each chart component independent (can disable individually)
- Feature flag: `enableAnimatedCharts` in AnimationSettings
- Fallback to existing progress circles in CategorySpendingView
- Original implementations preserved in git history

**Emergency disable:**
```swift
extension AnimationSettings {
  var useAnimatedCharts: Bool {
    #if DEBUG
    if UserDefaults.standard.bool(forKey: "disableAnimatedCharts") {
      return false
    }
    #endif
    return true
  }
}
```

### Next Steps After Phase 5A

1. **Phase 5B: Card Interactions** (2 weeks)
   - Swipe-to-reveal actions
   - Card flip animations
   - Expandable sections
   - Stack/carousel layouts

2. **Phase 5C: Advanced Polish** (2 weeks)
   - Hero transitions between screens
   - Parallax effects
   - Celebration animations
   - Gradient animations
   - 3D transforms (subtle)

### Documentation Updates

After Phase 5A completion:
1. Update `CHANGELOG.md` with Phase 5A entry
2. Add chart usage examples to `Docs/animation-guide.md`
3. Document gesture interactions in `Docs/accessibility.md`
4. Update `README.md` with new feature highlights

### Final Approval Checklist

Before marking Phase 5A complete:
- [ ] All 10 success criteria met
- [ ] Zero compiler warnings
- [ ] Zero accessibility warnings
- [ ] All tests passing (unit + snapshot)
- [ ] Manual QA 100% complete
- [ ] Code review approved
- [ ] CHANGELOG.md updated
- [ ] Design document archived
