# Phase 1 Week 2: Dashboard Completion Design
**Date:** 2026-02-02
**Status:** Approved
**Dependencies:** Phase 1 Week 1 (Animation Foundation)

## Overview

Complete Phase 1 Dashboard animations with interactive charts, loading states, and custom pull-to-refresh. Builds on Week 1's animation infrastructure (AnimationEngine, HapticEngine, PhysicsNumberCounter, AnimatedCard, ParticleEmitter).

## Implementation Order

1. **Chart Animations** - Spending Trends Chart widget (Priority #1)
2. **Loading States** - Skeleton shimmer placeholders
3. **Pull-to-Refresh** - Custom spring-based refresh animation

## 1. Chart Animation Architecture

### Core Components

**AnimatedChart Protocol**
- Base protocol for all chart types
- Defines animation lifecycle (draw, update, transition)
- Integrates with AnimationSettings for mode-aware rendering
- Supports gesture recognition for interactions

**SpendingTrendsChart**
- Line chart showing 7-day or 30-day spending history
- Data points with animated drawing using path animation
- Gradient fill beneath the line (animated reveal)
- Interactive data points (tap for details, haptic feedback)
- Smooth transitions when data updates

**ChartAnimationCoordinator**
- Manages chart animation timing and sequencing
- Coordinates with DashboardAnimationCoordinator
- Handles gesture-driven interactions (pan to scrub through time)
- Provides haptic feedback for data point interactions

### Technical Approach

- **Drawing**: SwiftUI Canvas for custom rendering
- **Animation**: Shape.trim() for line drawing (0.0 → 1.0)
- **Performance**: TimelineView for 120 FPS updates
- **Gestures**: DragGesture for scrubbing through data
- **Integration**: AnimatedCard wrapper, PhysicsNumberCounter for labels

## 2. Spending Trends Chart Animations

### Animation Sequence (Staggered Entry)

**Initial Reveal (0-800ms)**
1. Chart container fades in with AnimatedCard scale
2. Axes draw first (X-axis left-to-right, Y-axis bottom-to-top) - 200ms stagger
3. Grid lines fade in sequentially - 50ms stagger each
4. Axis labels appear with spring physics

**Data Line Drawing (300-900ms)**
1. Path draws from left to right using trim animation
2. Uses AnimationEngine.gentleSpring for smooth motion
3. Gradient fill reveals as line progresses (mask animation)
4. Data points appear sequentially as line reaches them (100ms after line)

### Interactive States

**Touch & Hold**
- Scrubber line appears at touch point (vertical indicator)
- Data point nearest to touch highlights (scale 1.2x + glow)
- Callout appears above point showing date & amount
- Light haptic feedback on data point snap
- PhysicsNumberCounter for animated value display

**Pan Gesture**
- Scrubber follows finger horizontally
- Snaps to nearest data point (with selection haptic)
- Callout updates smoothly as you pan
- Line segment behind scrubber dims slightly for focus

**Tap Data Point**
- Point scales with bouncy spring
- Medium haptic impact
- Brief particle burst (gold shimmer in full mode)
- Optional: expand to detailed transaction list for that day

## 3. Data Structure & Performance

### Chart Data Model

```swift
struct ChartDataPoint {
  let date: Date
  let value: Double
  let transactions: [Transaction]  // Drill-down data

  var position: CGPoint  // Calculated layout position
  var isHighlighted: Bool = false
}

struct SpendingTrendsData {
  let points: [ChartDataPoint]
  let maxValue: Double
  let minValue: Double
  let dateRange: ClosedRange<Date>

  // For smooth updates
  var previousPoints: [ChartDataPoint]?
}
```

### Performance Optimizations

**Drawing**
- Use `.drawingGroup()` for Canvas to enable Metal acceleration
- Cache path calculations when data doesn't change
- Limit redraws to 120 FPS max (ProMotion)
- Lazy calculation of data point positions

**Data Updates**
- Diff old vs new data to animate only changes
- Smooth value transitions using @State animations
- Background thread for data aggregation (7-day rollup)
- Debounce gesture updates to avoid over-rendering

**Memory**
- Keep max 30 days of chart data in memory
- Aggregate older data into weekly summaries
- Release gesture state immediately after interaction

**Accessibility**
- VoiceOver: "Spending chart, 7 days, trending down"
- Data points readable: "Monday, January 27, $234.50"
- Reduced motion: Show static chart with fade transitions only
- Haptic-only mode for vision-impaired users

## 4. Loading States with Skeleton Shimmer

### SkeletonView Component

**Reusable placeholder for any content**
- Animated gradient shimmer effect (light → accent → light)
- Respects color scheme (dark mode uses muted shimmer)
- Mode-aware: Full mode = shimmer, Reduced = pulse, Minimal = static

### Shimmer Animation

- Linear gradient moves across view (-1.0 → 1.0 x-position)
- Uses TimelineView for 120 FPS smooth movement
- 1.5 second animation duration with easeInOut
- Colors: `.oldMoney.surface` → `.oldMoney.divider` → `.oldMoney.surface`

### Dashboard Skeleton States

**BalanceCardView Skeleton**
- Rounded rectangles matching text layout
- Large rect for balance amount
- Smaller rect for monthly expenses
- Shimmer sweeps across all elements

**SpendingTrendsChart Skeleton**
- Outline of chart axes (static)
- Placeholder bars or line segments
- Shimmer on data area only
- Maintains chart shape for visual continuity

**Recent Transactions Skeleton**
- 3-5 transaction row placeholders
- Icon circle + text rectangles
- Staggered shimmer start (50ms delay each row)

### Transition: Loading → Data

When data loads:
1. Fade out skeleton (200ms)
2. Staggered reveal of real content (100ms delay per card)
3. Cards slide in from below with spring physics
4. Numbers count up using PhysicsNumberCounter

## 5. Pull-to-Refresh Animation

### Custom Pull-to-Refresh System

Replace standard iOS `.refreshable` with custom implementation:
- Custom ScrollView offset tracking
- Custom refresh indicator with physics
- Elastic resistance feel

### Pull States & Animations

**Idle State**
- Indicator hidden above scroll view
- Monitoring scroll offset

**Pulling (0-60pt offset)**
- Refresh icon rotates proportionally (0° → 180°)
- Icon scales (0.5x → 1.0x) based on pull distance
- Elastic resistance feel (pulls slower as you go further)
- Light haptic at 50% threshold

**Ready to Refresh (60pt+)**
- Medium haptic impact (threshold crossed)
- Icon completes rotation to 180°
- Icon pulses gently (scale 1.0x → 1.1x → 1.0x)
- Color shifts to accent color

**Releasing (trigger refresh)**
- Icon springs back to center position
- Starts spinning animation (continuous rotation)
- Smooth spring bounce (overdamped)
- Success haptic pattern when data loads

**Loading**
- Spinner rotates smoothly (360° loop with easeInOut)
- Optional: particle shimmer around spinner (full mode only)
- PhysicsNumberCounter shows "Updating..." text

**Complete**
- Icon checkmark appears with scale animation
- Gentle success haptic
- Indicator fades out over 300ms
- Content reveals with staggered animation (from Loading States)

### Technical Details

- Use PreferenceKey to track ScrollView offset
- DragGesture for pull detection
- Custom refresh coordinator managing state machine
- Integrates with DashboardViewModel.loadDashboardData()

## Implementation Files

### New Files to Create

**Charts:**
- `FinPessoal/Code/Animation/Components/Charts/AnimatedChart.swift` - Protocol
- `FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift` - Line chart
- `FinPessoal/Code/Animation/Components/Charts/ChartDataPoint.swift` - Data model
- `FinPessoal/Code/Animation/Coordinators/ChartAnimationCoordinator.swift` - Coordinator

**Loading:**
- `FinPessoal/Code/Animation/Components/SkeletonView.swift` - Shimmer component
- `FinPessoal/Code/Animation/Components/SkeletonModifier.swift` - View modifier

**Refresh:**
- `FinPessoal/Code/Animation/Components/PullToRefreshView.swift` - Custom refresh
- `FinPessoal/Code/Animation/Components/RefreshIndicator.swift` - Refresh icon
- `FinPessoal/Code/Animation/Coordinators/RefreshCoordinator.swift` - State management

### Files to Modify

- `FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift` - Add chart, skeleton, refresh
- `FinPessoal/Code/Features/Dashboard/ViewModel/DashboardViewModel.swift` - Add chart data

### Tests to Create

- `FinPessoalTests/Animation/Charts/SpendingTrendsChartTests.swift`
- `FinPessoalTests/Animation/SkeletonViewTests.swift`
- `FinPessoalTests/Animation/PullToRefreshTests.swift`

## Success Criteria

**Chart Animations**
- ✅ Line draws smoothly at 120 FPS
- ✅ Interactive scrubbing feels responsive
- ✅ Haptics enhance data point selection
- ✅ Graceful degradation in reduced motion mode

**Loading States**
- ✅ Skeleton shimmer is smooth and subtle
- ✅ Loading → data transition is seamless
- ✅ Staggered reveal feels premium

**Pull-to-Refresh**
- ✅ Pull gesture feels elastic and natural
- ✅ Threshold feedback is clear
- ✅ Refresh animation is satisfying
- ✅ Integrates cleanly with data loading

## Timeline

**Week 2 Breakdown:**
- Days 1-3: Chart animations (SpendingTrendsChart)
- Days 4-5: Loading states (SkeletonView)
- Days 6-7: Pull-to-refresh + integration testing

**Dependencies:**
- Must complete charts before loading states (skeleton needs chart shape)
- Must complete loading states before refresh (refresh triggers loading)

## Notes

- All animations respect AnimationSettings.effectiveMode
- All components use existing animation infrastructure (AnimationEngine, HapticEngine)
- Chart data aggregation happens in background thread
- Performance profiling after each component
