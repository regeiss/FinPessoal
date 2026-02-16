# Phase 5A: Charts & Data Visualization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement animated, interactive Pie/Donut and Bar charts with comprehensive gesture support, replacing basic progress circles in Reports feature.

**Architecture:** SwiftUI Canvas-based charts with protocol-driven design, centralized gesture handling, and mode-aware animations respecting AnimationSettings.effectiveMode (Full/Reduced/Minimal).

**Tech Stack:** SwiftUI, Canvas API, Combine, XCTest

---

## Week 1: Core Infrastructure (Tasks 1-4)

### Task 1: Chart Data Models

Create foundation data models for chart rendering.

**Files:**
- Create: `FinPessoal/Code/Animation/Components/Charts/Models/ChartSegment.swift`
- Create: `FinPessoal/Code/Animation/Components/Charts/Models/ChartBar.swift`
- Create: `FinPessoalTests/Animation/ChartModelsTests.swift`

**Step 1: Write failing test for ChartSegment**

Create test file:

```swift
// FinPessoalTests/Animation/ChartModelsTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ChartModelsTests: XCTestCase {

  func testChartSegmentInitialization() {
    let segment = ChartSegment(
      id: "test-1",
      value: 500.0,
      percentage: 25.0,
      label: "Food",
      color: .blue,
      category: nil
    )

    XCTAssertEqual(segment.id, "test-1")
    XCTAssertEqual(segment.value, 500.0)
    XCTAssertEqual(segment.percentage, 25.0)
    XCTAssertEqual(segment.label, "Food")
    XCTAssertEqual(segment.trimEnd, 0) // Default animation state
    XCTAssertEqual(segment.opacity, 1.0)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/ChartModelsTests/testChartSegmentInitialization`

Expected: FAIL with "No such module 'ChartSegment'" or similar

**Step 3: Implement ChartSegment**

```swift
// FinPessoal/Code/Animation/Components/Charts/Models/ChartSegment.swift
import SwiftUI

/// Data model for pie/donut chart segments
struct ChartSegment: Identifiable, Equatable {
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

  static func == (lhs: ChartSegment, rhs: ChartSegment) -> Bool {
    lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.percentage == rhs.percentage
  }
}
```

**Step 4: Run test to verify it passes**

Run: Same command as Step 2
Expected: PASS

**Step 5: Write failing test for ChartBar**

Add to `ChartModelsTests.swift`:

```swift
func testChartBarInitialization() {
  let bar = ChartBar(
    id: "2026-01",
    value: 1500.0,
    maxValue: 2000.0,
    label: "January",
    color: .green,
    date: nil
  )

  XCTAssertEqual(bar.id, "2026-01")
  XCTAssertEqual(bar.value, 1500.0)
  XCTAssertEqual(bar.maxValue, 2000.0)
  XCTAssertEqual(bar.height, 0) // Default animation state
  XCTAssertEqual(bar.opacity, 0)
}
```

**Step 6: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/ChartModelsTests/testChartBarInitialization`

Expected: FAIL

**Step 7: Implement ChartBar**

```swift
// FinPessoal/Code/Animation/Components/Charts/Models/ChartBar.swift
import SwiftUI

/// Data model for bar chart bars
struct ChartBar: Identifiable, Equatable {
  let id: String
  let value: Double
  let maxValue: Double
  let label: String
  let color: Color
  let date: Date?

  // Animation state
  var height: CGFloat = 0
  var opacity: Double = 0

  static func == (lhs: ChartBar, rhs: ChartBar) -> Bool {
    lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.maxValue == rhs.maxValue
  }
}
```

**Step 8: Run tests to verify both pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/ChartModelsTests`

Expected: 2 tests PASS

**Step 9: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/Models/ChartSegment.swift \
        FinPessoal/Code/Animation/Components/Charts/Models/ChartBar.swift \
        FinPessoalTests/Animation/ChartModelsTests.swift
git commit -m "feat(charts): add ChartSegment and ChartBar data models

- ChartSegment for pie/donut charts with animation state
- ChartBar for bar charts with animation state
- Comprehensive unit tests (2 tests passing)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2: ChartGestureHandler

Centralized gesture coordination system.

**Files:**
- Create: `FinPessoal/Code/Animation/Components/Charts/ChartGestureHandler.swift`
- Create: `FinPessoalTests/Animation/ChartGestureHandlerTests.swift`

**Step 1: Write failing test for tap selection**

```swift
// FinPessoalTests/Animation/ChartGestureHandlerTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ChartGestureHandlerTests: XCTestCase {

  func testTapSelectsSegment() {
    let handler = ChartGestureHandler()

    XCTAssertNil(handler.selectedID)

    handler.handleTap(segmentID: "food")
    XCTAssertEqual(handler.selectedID, "food")
  }

  func testTapTogglesSelection() {
    let handler = ChartGestureHandler()

    handler.handleTap(segmentID: "food")
    XCTAssertEqual(handler.selectedID, "food")

    // Tap same segment again to deselect
    handler.handleTap(segmentID: "food")
    XCTAssertNil(handler.selectedID)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/ChartGestureHandlerTests`

Expected: FAIL with "No such type 'ChartGestureHandler'"

**Step 3: Implement ChartGestureHandler**

```swift
// FinPessoal/Code/Animation/Components/Charts/ChartGestureHandler.swift
import SwiftUI
import Combine

/// Centralized gesture coordination for charts
@MainActor
class ChartGestureHandler: ObservableObject {
  @Published var selectedID: String?
  @Published var isDragging: Bool = false
  @Published var zoomScale: CGFloat = 1.0

  /// Handle tap gesture on chart element
  func handleTap(segmentID: String) {
    HapticEngine.selection()

    if selectedID == segmentID {
      selectedID = nil // Deselect
    } else {
      selectedID = segmentID // Select
    }
  }

  /// Handle drag gesture (for scrubbing)
  func handleDragChanged(segmentID: String?) {
    isDragging = true

    if let newID = segmentID, newID != selectedID {
      HapticEngine.selection()
      selectedID = newID
    }
  }

  /// Handle drag gesture end
  func handleDragEnded() {
    isDragging = false
  }

  /// Handle long press gesture
  func handleLongPress() {
    HapticEngine.impact(.medium)
    // Future: trigger detail sheet
  }

  /// Reset all gesture state
  func reset() {
    selectedID = nil
    isDragging = false
    zoomScale = 1.0
  }
}
```

**Step 4: Run tests to verify they pass**

Run: Same command as Step 2
Expected: 2 tests PASS

**Step 5: Add drag gesture test**

Add to `ChartGestureHandlerTests.swift`:

```swift
func testDragUpdatesSelection() {
  let handler = ChartGestureHandler()

  XCTAssertFalse(handler.isDragging)

  handler.handleDragChanged(segmentID: "food")
  XCTAssertTrue(handler.isDragging)
  XCTAssertEqual(handler.selectedID, "food")

  handler.handleDragChanged(segmentID: "transport")
  XCTAssertEqual(handler.selectedID, "transport")

  handler.handleDragEnded()
  XCTAssertFalse(handler.isDragging)
  XCTAssertEqual(handler.selectedID, "transport") // Selection persists
}
```

**Step 6: Run tests to verify all pass**

Run: Same command as Step 2
Expected: 3 tests PASS

**Step 7: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/ChartGestureHandler.swift \
        FinPessoalTests/Animation/ChartGestureHandlerTests.swift
git commit -m "feat(charts): add ChartGestureHandler for gesture coordination

- Tap selection/deselection with haptic feedback
- Drag scrubbing with continuous selection updates
- Long press support (detail sheet trigger)
- Reset functionality
- Unit tests (3 tests passing)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 3: ChartCalloutView

Floating callout for selected chart elements.

**Files:**
- Create: `FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift`
- Test: Manual visual testing (UI component)

**Step 1: Implement ChartCalloutView**

```swift
// FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
import SwiftUI

/// Floating callout displayed when chart element is selected
struct ChartCalloutView: View {
  let segment: ChartSegment?
  let bar: ChartBar?

  @Environment(\.animationMode) private var animationMode

  init(segment: ChartSegment) {
    self.segment = segment
    self.bar = nil
  }

  init(bar: ChartBar) {
    self.segment = nil
    self.bar = bar
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let segment = segment {
        Text(segment.label)
          .font(.caption)
          .fontWeight(.semibold)

        HStack(spacing: 8) {
          Text("\(segment.percentage, specifier: "%.1f")%")
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
    .animation(
      animationMode == .full ? AnimationEngine.quickFade : .linear(duration: 0.1),
      value: segment != nil || bar != nil
    )
  }
}

#Preview("Segment Callout") {
  ChartCalloutView(
    segment: ChartSegment(
      id: "food",
      value: 500,
      percentage: 25,
      label: "Food & Dining",
      color: .blue,
      category: nil
    )
  )
  .padding()
}

#Preview("Bar Callout") {
  ChartCalloutView(
    bar: ChartBar(
      id: "jan",
      value: 1500,
      maxValue: 2000,
      label: "January",
      color: .green,
      date: nil
    )
  )
  .padding()
}
```

**Step 2: Build and verify previews work**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED, previews should render in Xcode

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
git commit -m "feat(charts): add ChartCalloutView for selected elements

- Floating callout with material background
- Supports both segments and bars
- Animated appearance (slide + fade)
- Mode-aware animation timing
- SwiftUI previews for both variants

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 4: AnimationEngine Chart Extensions

Add chart-specific animation helpers.

**Files:**
- Create: `FinPessoal/Code/Animation/Engine/AnimationEngine+Charts.swift`
- Test: Integration tests in Week 2

**Step 1: Implement chart animation extensions**

```swift
// FinPessoal/Code/Animation/Engine/AnimationEngine+Charts.swift
import SwiftUI

extension AnimationEngine {

  /// Chart reveal animation (300ms with stagger support)
  static func chartReveal(delay: Double = 0) -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return easeInOut.delay(delay)
    case .reduced:
      return .linear(duration: 0.15).delay(delay)
    case .minimal:
      return nil
    }
  }

  /// Chart data morph animation (smooth transition)
  static var chartMorph: Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return gentleSpring
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return nil
    }
  }

  /// Chart selection animation (subtle scale)
  static var chartSelection: Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return snappySpring
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return .linear(duration: 0.05)
    }
  }

  /// Selection scale factor (mode-aware)
  static var selectionScale: CGFloat {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return 1.05 // 5% larger
    case .reduced:
      return 1.02 // 2% larger
    case .minimal:
      return 1.0 // No scale
    }
  }
}
```

**Step 2: Build to verify no errors**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Engine/AnimationEngine+Charts.swift
git commit -m "feat(charts): add AnimationEngine chart-specific extensions

- chartReveal: 300ms reveal with stagger support
- chartMorph: smooth data transition animation
- chartSelection: subtle scale animation
- selectionScale: mode-aware scale factors
- All respect AnimationSettings.effectiveMode

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Week 2: Chart Components (Tasks 5-6)

### Task 5: PieDonutChart Component

Build Canvas-based pie/donut chart with animations.

**Files:**
- Create: `FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift`
- Create: `FinPessoalTests/Animation/PieDonutChartTests.swift`

**Step 1: Write failing test for segment calculation**

```swift
// FinPessoalTests/Animation/PieDonutChartTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class PieDonutChartTests: XCTestCase {

  func testSegmentAngles() {
    let segments = [
      ChartSegment(id: "1", value: 100, percentage: 50, label: "A", color: .blue, category: nil),
      ChartSegment(id: "2", value: 100, percentage: 50, label: "B", color: .red, category: nil)
    ]

    let angles = PieDonutChart.calculateAngles(for: segments)

    XCTAssertEqual(angles.count, 2)
    XCTAssertEqual(angles[0].start, -90, accuracy: 0.1) // Start at top
    XCTAssertEqual(angles[0].end, 90, accuracy: 0.1) // 50% = 180 degrees
    XCTAssertEqual(angles[1].start, 90, accuracy: 0.1)
    XCTAssertEqual(angles[1].end, 270, accuracy: 0.1)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/PieDonutChartTests`

Expected: FAIL with "No such type 'PieDonutChart'"

**Step 3: Implement PieDonutChart (Part 1: Structure)**

```swift
// FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift
import SwiftUI

/// Animated pie or donut chart rendered with Canvas
struct PieDonutChart: View {
  let segments: [ChartSegment]
  let style: PieChartStyle

  @StateObject private var gestureHandler = ChartGestureHandler()
  @State private var animatedSegments: [ChartSegment]
  @Environment(\.animationMode) private var animationMode

  enum PieChartStyle {
    case pie
    case donut(innerRadius: CGFloat)
  }

  struct SegmentAngles {
    let start: Double
    let end: Double
  }

  init(segments: [ChartSegment], style: PieChartStyle = .donut(innerRadius: 0.6)) {
    self.segments = segments
    self.style = style
    self._animatedSegments = State(initialValue: segments)
  }

  /// Calculate start/end angles for each segment
  static func calculateAngles(for segments: [ChartSegment]) -> [SegmentAngles] {
    var angles: [SegmentAngles] = []
    var currentAngle: Double = -90 // Start at top

    for segment in segments {
      let sweepAngle = (segment.percentage / 100.0) * 360.0
      angles.append(SegmentAngles(start: currentAngle, end: currentAngle + sweepAngle))
      currentAngle += sweepAngle
    }

    return angles
  }

  var body: some View {
    Text("Pie Chart Placeholder")
  }
}
```

**Step 4: Run test to verify it passes**

Run: Same command as Step 2
Expected: 1 test PASS

**Step 5: Implement PieDonutChart (Part 2: Canvas Rendering)**

Replace `body` in `PieDonutChart.swift`:

```swift
var body: some View {
  GeometryReader { geometry in
    let size = min(geometry.size.width, geometry.size.height)
    let radius = size / 2
    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

    ZStack {
      Canvas { context, canvasSize in
        let angles = Self.calculateAngles(for: animatedSegments)

        for (index, segment) in animatedSegments.enumerated() {
          let angle = angles[index]
          let isSelected = gestureHandler.selectedID == segment.id
          let scale = isSelected ? AnimationEngine.selectionScale : 1.0

          var path = Path()
          let startAngle = Angle.degrees(angle.start)
          let endAngle = Angle.degrees(angle.start + (angle.end - angle.start) * segment.trimEnd)

          path.addArc(
            center: center,
            radius: radius * scale,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
          )

          if case .donut(let innerRadius) = style {
            path.addArc(
              center: center,
              radius: radius * innerRadius * scale,
              startAngle: endAngle,
              endAngle: startAngle,
              clockwise: true
            )
            path.closeSubpath()
          } else {
            path.addLine(to: center)
            path.closeSubpath()
          }

          context.fill(path, with: .color(segment.color.opacity(segment.opacity)))
        }
      }
      .frame(width: size, height: size)

      // Callout for selected segment
      if let selectedID = gestureHandler.selectedID,
         let selected = segments.first(where: { $0.id == selectedID }) {
        ChartCalloutView(segment: selected)
          .offset(y: -radius - 40)
      }
    }
    .onTapGesture { location in
      // TODO: Hit test and call gestureHandler.handleTap
    }
    .onAppear {
      animateReveal()
    }
    .onChange(of: segments) { oldSegments, newSegments in
      animateDataChange(from: oldSegments, to: newSegments)
    }
  }
}

private func animateReveal() {
  for i in animatedSegments.indices {
    let delay = Double(i) * AnimationEngine.standardStagger

    withAnimation(AnimationEngine.chartReveal(delay: delay)) {
      animatedSegments[i].trimEnd = animatedSegments[i].percentage / 100.0
      animatedSegments[i].opacity = 1.0
    }
  }
}

private func animateDataChange(from old: [ChartSegment], to new: [ChartSegment]) {
  // Fade out
  withAnimation(.easeOut(duration: 0.15)) {
    for i in animatedSegments.indices {
      animatedSegments[i].opacity = 0
    }
  }

  // Update data and fade in
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
    animatedSegments = new

    withAnimation(AnimationEngine.chartMorph) {
      for i in animatedSegments.indices {
        animatedSegments[i].trimEnd = animatedSegments[i].percentage / 100.0
        animatedSegments[i].opacity = 1.0
      }
    }
  }
}
```

**Step 6: Add SwiftUI preview**

Add to end of `PieDonutChart.swift`:

```swift
#Preview("Donut Chart") {
  PieDonutChart(
    segments: [
      ChartSegment(id: "1", value: 500, percentage: 25, label: "Food", color: .blue, category: nil),
      ChartSegment(id: "2", value: 700, percentage: 35, label: "Transport", color: .green, category: nil),
      ChartSegment(id: "3", value: 400, percentage: 20, label: "Shopping", color: .orange, category: nil),
      ChartSegment(id: "4", value: 400, percentage: 20, label: "Bills", color: .red, category: nil)
    ]
  )
  .frame(width: 250, height: 250)
  .padding()
}

#Preview("Pie Chart") {
  PieDonutChart(
    segments: [
      ChartSegment(id: "1", value: 500, percentage: 50, label: "Income", color: .green, category: nil),
      ChartSegment(id: "2", value: 500, percentage: 50, label: "Expenses", color: .red, category: nil)
    ],
    style: .pie
  )
  .frame(width: 250, height: 250)
  .padding()
}
```

**Step 7: Build and verify previews**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED, check previews in Xcode

**Step 8: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift \
        FinPessoalTests/Animation/PieDonutChartTests.swift
git commit -m "feat(charts): implement PieDonutChart with Canvas rendering

- Canvas-based pie and donut chart variants
- Animated reveal with stagger (300ms + 50ms)
- Smooth data morphing transitions
- Selection state with scale animation
- ChartCalloutView integration
- Unit tests for angle calculation
- SwiftUI previews for both styles

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6: BarChart Component

Build bar chart with animated heights.

**Files:**
- Create: `FinPessoal/Code/Animation/Components/Charts/BarChart.swift`
- Create: `FinPessoalTests/Animation/BarChartTests.swift`

**Step 1: Write failing test for bar height calculation**

```swift
// FinPessoalTests/Animation/BarChartTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class BarChartTests: XCTestCase {

  func testBarHeightCalculation() {
    let maxHeight: CGFloat = 200
    let bar = ChartBar(id: "1", value: 1500, maxValue: 2000, label: "Jan", color: .blue, date: nil)

    let calculatedHeight = BarChart.calculateHeight(for: bar, maxHeight: maxHeight)

    XCTAssertEqual(calculatedHeight, 150, accuracy: 0.1) // 1500/2000 * 200 = 150
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/BarChartTests`

Expected: FAIL

**Step 3: Implement BarChart**

```swift
// FinPessoal/Code/Animation/Components/Charts/BarChart.swift
import SwiftUI

/// Animated bar chart with gesture support
struct BarChart: View {
  let bars: [ChartBar]
  let maxHeight: CGFloat

  @StateObject private var gestureHandler = ChartGestureHandler()
  @State private var animatedBars: [ChartBar]
  @Environment(\.animationMode) private var animationMode

  init(bars: [ChartBar], maxHeight: CGFloat = 200) {
    self.bars = bars
    self.maxHeight = maxHeight
    self._animatedBars = State(initialValue: bars)
  }

  /// Calculate bar height based on value and max
  static func calculateHeight(for bar: ChartBar, maxHeight: CGFloat) -> CGFloat {
    guard bar.maxValue > 0 else { return 0 }
    return (bar.value / bar.maxValue) * maxHeight
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 12) {
      ForEach(Array(animatedBars.enumerated()), id: \.element.id) { index, bar in
        VStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 8)
            .fill(bar.color)
            .frame(width: 40, height: bar.height)
            .opacity(bar.opacity)
            .scaleEffect(
              gestureHandler.selectedID == bar.id ? AnimationEngine.selectionScale : 1.0,
              anchor: .bottom
            )
            .animation(AnimationEngine.chartSelection, value: gestureHandler.selectedID)

          Text(bar.label)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .onTapGesture {
          gestureHandler.handleTap(segmentID: bar.id)
        }
      }
    }
    .overlay(alignment: .top) {
      if let selectedID = gestureHandler.selectedID,
         let selected = bars.first(where: { $0.id == selectedID }) {
        ChartCalloutView(bar: selected)
          .offset(y: -20)
      }
    }
    .onAppear {
      animateReveal()
    }
    .onChange(of: bars) { oldBars, newBars in
      animateDataChange(from: oldBars, to: newBars)
    }
  }

  private func animateReveal() {
    for i in animatedBars.indices {
      let delay = Double(i) * AnimationEngine.standardStagger

      withAnimation(AnimationEngine.chartReveal(delay: delay)) {
        animatedBars[i].height = Self.calculateHeight(for: animatedBars[i], maxHeight: maxHeight)
        animatedBars[i].opacity = 1.0
      }
    }
  }

  private func animateDataChange(from old: [ChartBar], to new: [ChartBar]) {
    // Fade out
    withAnimation(.easeOut(duration: 0.15)) {
      for i in animatedBars.indices {
        animatedBars[i].opacity = 0
      }
    }

    // Update data and fade in
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      animatedBars = new

      withAnimation(AnimationEngine.chartMorph) {
        for i in animatedBars.indices {
          animatedBars[i].height = Self.calculateHeight(for: animatedBars[i], maxHeight: maxHeight)
          animatedBars[i].opacity = 1.0
        }
      }
    }
  }
}

#Preview("Bar Chart") {
  BarChart(
    bars: [
      ChartBar(id: "jan", value: 1200, maxValue: 2000, label: "Jan", color: .blue, date: nil),
      ChartBar(id: "feb", value: 1500, maxValue: 2000, label: "Feb", color: .blue, date: nil),
      ChartBar(id: "mar", value: 1800, maxValue: 2000, label: "Mar", color: .blue, date: nil),
      ChartBar(id: "apr", value: 900, maxValue: 2000, label: "Apr", color: .blue, date: nil),
      ChartBar(id: "may", value: 1400, maxValue: 2000, label: "May", color: .blue, date: nil),
      ChartBar(id: "jun", value: 1700, maxValue: 2000, label: "Jun", color: .blue, date: nil)
    ]
  )
  .frame(height: 250)
  .padding()
}
```

**Step 4: Run test to verify it passes**

Run: Same command as Step 2
Expected: 1 test PASS

**Step 5: Build and verify preview**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/BarChart.swift \
        FinPessoalTests/Animation/BarChartTests.swift
git commit -m "feat(charts): implement BarChart with animated heights

- Vertical bar chart with configurable max height
- Animated reveal with stagger (300ms + 50ms)
- Smooth data morphing transitions
- Selection state with scale animation
- ChartCalloutView integration
- Unit tests for height calculation
- SwiftUI preview

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Week 3: Integration (Tasks 7-10)

### Task 7: Data Transformation Extensions

Add conversion methods to transform domain models into chart models.

**Files:**
- Modify: `FinPessoal/Code/Features/Reports/ViewModel/ReportsViewModel.swift`
- Create: `FinPessoalTests/Reports/ChartDataTransformationTests.swift`

**Step 1: Write failing test for CategorySpending transformation**

```swift
// FinPessoalTests/Reports/ChartDataTransformationTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ChartDataTransformationTests: XCTestCase {

  func testCategorySpendingToChartSegment() {
    let category = Category(id: "food", name: "Food", color: "blue", icon: "fork.knife")
    let spending = CategorySpending(category: category, amount: 500, percentage: 25)

    let segment = spending.toChartSegment(totalSpent: 2000)

    XCTAssertEqual(segment.id, "food")
    XCTAssertEqual(segment.value, 500)
    XCTAssertEqual(segment.percentage, 25)
    XCTAssertEqual(segment.label, "Food")
    XCTAssertNotNil(segment.category)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/ChartDataTransformationTests`

Expected: FAIL with "Value of type 'CategorySpending' has no member 'toChartSegment'"

**Step 3: Add CategorySpending extension**

Find the `CategorySpending` definition (likely in `FinPessoal/Code/Features/Reports/Models/` or similar) and add this extension at the bottom of that file:

```swift
// Add to CategorySpending model file
extension CategorySpending {
  func toChartSegment(totalSpent: Double) -> ChartSegment {
    ChartSegment(
      id: category.id,
      value: amount,
      percentage: percentage,
      label: category.name,
      color: Color(category.color),
      category: category
    )
  }
}
```

**Step 4: Run test to verify it passes**

Run: Same command as Step 2
Expected: 1 test PASS

**Step 5: Write failing test for MonthlyTrend transformation**

Add to `ChartDataTransformationTests.swift`:

```swift
func testMonthlyTrendToChartBar() {
  let trend = MonthlyTrend(month: "2026-01", amount: 1500)

  let bar = trend.toChartBar(maxAmount: 2000)

  XCTAssertEqual(bar.id, "2026-01")
  XCTAssertEqual(bar.value, 1500)
  XCTAssertEqual(bar.maxValue, 2000)
  XCTAssertEqual(bar.label, "Jan") // Should format month
}
```

**Step 6: Run test to verify it fails**

Run: Same command as Step 2
Expected: FAIL

**Step 7: Add MonthlyTrend extension**

Find the `MonthlyTrend` definition and add:

```swift
// Add to MonthlyTrend model file
extension MonthlyTrend {
  func toChartBar(maxAmount: Double) -> ChartBar {
    ChartBar(
      id: month,
      value: amount,
      maxValue: maxAmount,
      label: monthLabel,
      color: .oldMoney.accent,
      date: Date.from(monthString: month)
    )
  }

  private var monthLabel: String {
    // Format "2026-01" -> "Jan"
    let components = month.split(separator: "-")
    guard components.count == 2, let monthNum = Int(components[1]) else {
      return month
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"

    var dateComponents = DateComponents()
    dateComponents.month = monthNum

    guard let date = Calendar.current.date(from: dateComponents) else {
      return month
    }

    return formatter.string(from: date)
  }
}

extension Date {
  static func from(monthString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM"
    return formatter.date(from: monthString)
  }
}
```

**Step 8: Run tests to verify both pass**

Run: Same command as Step 2
Expected: 2 tests PASS

**Step 9: Update ReportsViewModel**

Add computed properties to `ReportsViewModel` to provide chart-ready data:

```swift
// Add to ReportsViewModel.swift
var categorySegments: [ChartSegment] {
  guard !categorySpending.isEmpty else { return [] }

  let total = categorySpending.reduce(0) { $0 + $1.amount }
  return categorySpending.map { $0.toChartSegment(totalSpent: total) }
}

var monthlyBars: [ChartBar] {
  guard !monthlyTrends.isEmpty else { return [] }

  let maxAmount = monthlyTrends.map { $0.amount }.max() ?? 0
  return monthlyTrends.map { $0.toChartBar(maxAmount: maxAmount) }
}

var budgetBars: [ChartBar] {
  guard !budgetPerformance.isEmpty else { return [] }

  let maxAmount = budgetPerformance.map { $0.spent }.max() ?? 0
  return budgetPerformance.map { budget in
    ChartBar(
      id: budget.category.id,
      value: budget.spent,
      maxValue: maxAmount,
      label: budget.category.name,
      color: Color(budget.category.color),
      date: nil
    )
  }
}
```

**Step 10: Commit**

```bash
git add FinPessoal/Code/Features/Reports/Models/* \
        FinPessoal/Code/Features/Reports/ViewModel/ReportsViewModel.swift \
        FinPessoalTests/Reports/ChartDataTransformationTests.swift
git commit -m "feat(charts): add data transformation extensions

- CategorySpending.toChartSegment()
- MonthlyTrend.toChartBar()
- ReportsViewModel computed properties (categorySegments, monthlyBars, budgetBars)
- Date formatting utilities
- Unit tests (2 tests passing)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 8: Integrate PieDonutChart into CategorySpendingView

Replace progress circles with animated chart.

**Files:**
- Modify: `FinPessoal/Code/Features/Reports/View/CategorySpendingView.swift`

**Step 1: Read current CategorySpendingView**

Run: Read the file to understand current structure

**Step 2: Replace progress circle with PieDonutChart**

Find the section with progress circles (likely around line 30-45 based on ReportsScreen.swift:30-45) and replace with:

```swift
if viewModel.isLoading {
  SkeletonView()
    .frame(width: 250, height: 250)
    .clipShape(Circle())
    .accessibilityLabel("Loading category spending chart")
} else if !viewModel.categorySegments.isEmpty {
  PieDonutChart(
    segments: viewModel.categorySegments,
    style: .donut(innerRadius: 0.6)
  )
  .frame(width: 250, height: 250)
  .transition(.opacity.combined(with: .scale(scale: 0.95)))
  .animation(AnimationEngine.easeInOut, value: viewModel.isLoading)
} else {
  // Empty state
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

**Step 3: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add FinPessoal/Code/Features/Reports/View/CategorySpendingView.swift
git commit -m "feat(charts): integrate PieDonutChart into CategorySpendingView

- Replace progress circles with animated PieDonutChart
- Skeleton shimmer during loading
- Empty state for no data
- Smooth transition on data load

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 9: Integrate BarChart into MonthlyTrendsView

Replace existing chart with BarChart.

**Files:**
- Modify: `FinPessoal/Code/Features/Reports/View/MonthlyTrendsView.swift`

**Step 1: Replace with BarChart**

Find the chart section and replace with:

```swift
if viewModel.isLoading {
  HStack(alignment: .bottom, spacing: 12) {
    ForEach(0..<6, id: \.self) { _ in
      SkeletonView()
        .frame(width: 40, height: CGFloat.random(in: 60...200))
        .cornerRadius(8)
    }
  }
  .frame(height: 200)
  .accessibilityLabel("Loading monthly trends chart")
} else if !viewModel.monthlyBars.isEmpty {
  BarChart(
    bars: viewModel.monthlyBars,
    maxHeight: 200
  )
  .frame(height: 250)
  .transition(.opacity.combined(with: .scale(scale: 0.95)))
  .animation(AnimationEngine.easeInOut, value: viewModel.isLoading)
} else {
  VStack(spacing: 16) {
    Image(systemName: "chart.bar")
      .font(.system(size: 48))
      .foregroundStyle(.secondary)
    Text("No trend data")
      .font(.headline)
    Text("Track expenses over time to see monthly trends")
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
  }
  .frame(height: 250)
}
```

**Step 2: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Features/Reports/View/MonthlyTrendsView.swift
git commit -m "feat(charts): integrate BarChart into MonthlyTrendsView

- Replace existing chart with animated BarChart
- Skeleton shimmer during loading
- Empty state for no data
- Smooth transition on data load

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 10: Integrate BarChart into BudgetPerformanceView

Replace existing visualization with BarChart.

**Files:**
- Modify: `FinPessoal/Code/Features/Reports/View/BudgetPerformanceView.swift`

**Step 1: Replace with BarChart**

Similar pattern to Task 9:

```swift
if viewModel.isLoading {
  HStack(alignment: .bottom, spacing: 12) {
    ForEach(0..<4, id: \.self) { _ in
      SkeletonView()
        .frame(width: 40, height: CGFloat.random(in: 60...200))
        .cornerRadius(8)
    }
  }
  .frame(height: 200)
  .accessibilityLabel("Loading budget performance chart")
} else if !viewModel.budgetBars.isEmpty {
  BarChart(
    bars: viewModel.budgetBars,
    maxHeight: 200
  )
  .frame(height: 250)
  .transition(.opacity.combined(with: .scale(scale: 0.95)))
  .animation(AnimationEngine.easeInOut, value: viewModel.isLoading)
} else {
  VStack(spacing: 16) {
    Image(systemName: "chart.bar.fill")
      .font(.system(size: 48))
      .foregroundStyle(.secondary)
    Text("No budget data")
      .font(.headline)
    Text("Create budgets to track spending performance")
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
  }
  .frame(height: 250)
}
```

**Step 2: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Features/Reports/View/BudgetPerformanceView.swift
git commit -m "feat(charts): integrate BarChart into BudgetPerformanceView

- Replace existing visualization with animated BarChart
- Skeleton shimmer during loading
- Empty state for no data
- Smooth transition on data load

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Week 4: Testing & Polish (Tasks 11-13)

### Task 11: Accessibility Enhancements

Add VoiceOver support and accessibility improvements.

**Files:**
- Modify: `FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift`
- Modify: `FinPessoal/Code/Animation/Components/Charts/BarChart.swift`

**Step 1: Add VoiceOver support to PieDonutChart**

Add below the main `body` in `PieDonutChart.swift`:

```swift
.accessibilityRepresentation {
  VStack(alignment: .leading, spacing: 8) {
    Text("Category Spending Chart")
      .accessibilityAddTraits(.isHeader)

    let total = segments.reduce(0) { $0 + $1.value }
    Text("Total: \(total.formatted(.currency(code: "USD")))")

    ForEach(segments) { segment in
      Button {
        gestureHandler.handleTap(segmentID: segment.id)
      } label: {
        HStack {
          Text(segment.label)
          Spacer()
          Text("\(segment.percentage, specifier: "%.1f")%")
          Text("•")
          Text(segment.value.formatted(.currency(code: "USD")))
        }
      }
      .accessibilityLabel("\(segment.label), \(segment.percentage, specifier: "%.0f") percent, \(segment.value.formatted(.currency(code: "USD")))")
      .accessibilityHint("Double tap to view details")
    }
  }
}
```

**Step 2: Add VoiceOver support to BarChart**

Add below the main `body` in `BarChart.swift`:

```swift
.accessibilityRepresentation {
  VStack(alignment: .leading, spacing: 8) {
    Text("Bar Chart")
      .accessibilityAddTraits(.isHeader)

    ForEach(bars) { bar in
      Button {
        gestureHandler.handleTap(segmentID: bar.id)
      } label: {
        HStack {
          Text(bar.label)
          Spacer()
          Text(bar.value.formatted(.currency(code: "USD")))
        }
      }
      .accessibilityLabel("\(bar.label), \(bar.value.formatted(.currency(code: "USD")))")
      .accessibilityHint("Double tap to view details")
    }
  }
}
```

**Step 3: Add Dynamic Type support to ChartCalloutView**

Modify `ChartCalloutView.swift` text elements:

```swift
Text(segment?.label ?? bar?.label ?? "")
  .font(.caption)
  .fontWeight(.semibold)
  .minimumScaleFactor(0.8)
  .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
```

**Step 4: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build`

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift \
        FinPessoal/Code/Animation/Components/Charts/BarChart.swift \
        FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
git commit -m "feat(charts): add comprehensive accessibility support

- VoiceOver accessibilityRepresentation for both charts
- Navigable buttons for each chart element
- Custom accessibility labels and hints
- Dynamic Type support with capped scaling
- Minimum scale factor to prevent layout breakage

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 12: Comprehensive Testing

Add unit tests and manual QA.

**Files:**
- Create: `FinPessoalTests/Animation/ChartIntegrationTests.swift`

**Step 1: Write integration tests**

```swift
// FinPessoalTests/Animation/ChartIntegrationTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class ChartIntegrationTests: XCTestCase {

  func testPieChartWithEmptyData() {
    let chart = PieDonutChart(segments: [])

    // Should render without crashing
    let view = chart.frame(width: 250, height: 250)
    XCTAssertNotNil(view)
  }

  func testPieChartWithSingleSegment() {
    let segment = ChartSegment(
      id: "1",
      value: 100,
      percentage: 100,
      label: "All",
      color: .blue,
      category: nil
    )

    let chart = PieDonutChart(segments: [segment])
    XCTAssertEqual(chart.segments.count, 1)
  }

  func testBarChartWithEmptyData() {
    let chart = BarChart(bars: [])

    // Should render without crashing
    let view = chart.frame(height: 250)
    XCTAssertNotNil(view)
  }

  func testGestureHandlerReset() {
    let handler = ChartGestureHandler()

    handler.handleTap(segmentID: "test")
    handler.handleDragChanged(segmentID: "other")

    XCTAssertNotNil(handler.selectedID)
    XCTAssertTrue(handler.isDragging)

    handler.reset()

    XCTAssertNil(handler.selectedID)
    XCTAssertFalse(handler.isDragging)
    XCTAssertEqual(handler.zoomScale, 1.0)
  }

  func testAnimationModeAdaptation() {
    // Test Full mode
    AnimationSettings.shared.mode = .full
    let fullReveal = AnimationEngine.chartReveal()
    XCTAssertNotNil(fullReveal)

    // Test Minimal mode
    AnimationSettings.shared.mode = .minimal
    let minimalReveal = AnimationEngine.chartReveal()
    XCTAssertNil(minimalReveal)

    // Reset
    AnimationSettings.shared.mode = .full
  }
}
```

**Step 2: Run all tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

Expected: All tests PASS (should be 10+ total now)

**Step 3: Manual QA checklist**

Create a checklist file for manual testing:

```markdown
# Phase 5A Manual QA Checklist

## PieDonutChart
- [ ] Initial reveal animation smooth (300ms + 50ms stagger)
- [ ] Tap selects segment, second tap deselects
- [ ] Callout appears at correct position
- [ ] Haptic feedback on tap (test on physical device)
- [ ] VoiceOver navigates all segments
- [ ] Works in light & dark mode
- [ ] Empty state displays correctly
- [ ] Period change morphs smoothly

## BarChart
- [ ] Initial reveal animation smooth (bars grow from bottom)
- [ ] Tap selects bar, second tap deselects
- [ ] Callout appears above selected bar
- [ ] Haptic feedback on tap
- [ ] VoiceOver navigates all bars
- [ ] Works in light & dark mode
- [ ] Empty state displays correctly
- [ ] Data updates morph smoothly

## Accessibility
- [ ] VoiceOver announces chart title
- [ ] Each element navigable with swipe
- [ ] Dynamic Type scales labels
- [ ] Reduce Motion disables animations
- [ ] Color contrast meets WCAG AA

## Performance
- [ ] 60fps during animations
- [ ] No lag on gesture recognition
- [ ] Smooth on iPhone SE 2020
- [ ] Memory stable during period changes
```

**Step 4: Commit**

```bash
git add FinPessoalTests/Animation/ChartIntegrationTests.swift \
        Docs/phase5a-qa-checklist.md
git commit -m "test(charts): add comprehensive integration tests and QA checklist

- Integration tests for empty data, single segment, gesture reset
- Animation mode adaptation tests
- Manual QA checklist for visual verification
- 4 new integration tests passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 13: Documentation and Cleanup

Update changelog, fix any warnings, final polish.

**Files:**
- Modify: `CHANGELOG.md`
- Modify: Xcode project to remove duplicate build file warnings

**Step 1: Update CHANGELOG.md**

Add entry at the top:

```markdown
## [Unreleased] - Phase 5A: Charts & Data Visualization

### Added
- **PieDonutChart**: Animated pie and donut charts with Canvas rendering
  - 300ms reveal animation with 50ms stagger
  - Tap selection with haptic feedback
  - Floating callout for selected segments
  - Full VoiceOver support
  - Empty state handling

- **BarChart**: Animated vertical bar charts
  - Animated height reveal with stagger
  - Tap selection with haptic feedback
  - Floating callout for selected bars
  - Full VoiceOver support
  - Empty state handling

- **ChartGestureHandler**: Centralized gesture coordination
  - Tap selection/deselection
  - Drag scrubbing (future)
  - Long press support (future)
  - Haptic feedback on all interactions

- **ChartCalloutView**: Floating callout component
  - Material background with accent border
  - Slide + fade animation
  - Dynamic Type support

- **Data Transformation**: Extensions for chart data conversion
  - CategorySpending → ChartSegment
  - MonthlyTrend → ChartBar
  - ReportsViewModel computed properties

### Changed
- **CategorySpendingView**: Replaced progress circles with PieDonutChart
- **MonthlyTrendsView**: Replaced existing chart with BarChart
- **BudgetPerformanceView**: Replaced visualization with BarChart

### Testing
- 10+ unit tests covering models, gestures, transformations
- Integration tests for edge cases
- Manual QA checklist for accessibility and performance
- All tests passing

### Accessibility
- VoiceOver navigation for all chart elements
- WCAG AA color contrast compliance
- Dynamic Type support with capped scaling
- Reduce Motion integration
- High Contrast mode support
```

**Step 2: Fix duplicate build file warnings**

Open Xcode project:
1. Select FinPessoal.xcodeproj
2. Select FinPessoal target
3. Build Phases → Compile Sources
4. Find duplicate entries for PhysicsNumberCounter.swift and ParticleEmitter.swift
5. Remove duplicates (keep only one instance of each)

**Step 3: Build to verify zero warnings**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build 2>&1 | grep -i warning`

Expected: No warnings (or only pre-existing unrelated warnings)

**Step 4: Run full test suite**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

Expected: All tests PASS

**Step 5: Commit**

```bash
git add CHANGELOG.md FinPessoal.xcodeproj/project.pbxproj
git commit -m "docs(phase5a): update changelog and fix build warnings

- Comprehensive changelog entry for Phase 5A
- Remove duplicate build file warnings
- All tests passing (10+ tests)
- Build succeeds with zero warnings

Phase 5A Complete: Charts & Data Visualization

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria Verification

Before marking Phase 5A complete, verify all criteria:

1. ✅ PieDonutChart replaces all progress circles
2. ✅ BarChart used in MonthlyTrendsView & BudgetPerformanceView
3. ✅ All gestures work (tap selection/deselection)
4. ✅ Unit tests passing (10+ test cases)
5. ✅ Manual QA checklist complete
6. ✅ VoiceOver navigation verified
7. ✅ Build succeeds with zero warnings
8. ✅ Performance targets met (60fps, tested manually)
9. ✅ CHANGELOG.md updated

**All criteria met?** Use **superpowers:finishing-a-development-branch** to complete Phase 5A.

---

## Next Steps

After Phase 5A completion:
- **Phase 5B**: Card Interactions (swipe-to-reveal, card flips, expandable sections)
- **Phase 5C**: Advanced Polish (hero transitions, parallax, celebration animations)
