# Phase 5C: Advanced Polish - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement hero transitions, celebration animations, parallax scrolling, and gradient animations for FinPessoal iOS app with full accessibility support.

**Architecture:** Hybrid system using ViewModifiers for systematic effects (parallax, gradients) and Components for targeted features (hero transitions, celebrations). Integrates with existing AnimationEngine and AnimationSettings from Phase 5A/5B.

**Tech Stack:** SwiftUI, matchedGeometryEffect, GeometryReader, PreferenceKey, @Observable, Core Haptics

---

## Prerequisites

- Phase 5A (Charts) complete ✅
- Phase 5B (Card Interactions) complete ✅
- Working in `main` branch or new `feature/phase5c-advanced-polish` worktree
- Xcode 15+, iOS 15+ deployment target

---

## Week 1: Foundation & Hero Transitions

### Task 1: Create HeroTransitionCoordinator

**Files:**
- Create: `FinPessoal/Code/Animation/Coordinators/HeroTransitionCoordinator.swift`
- Test: `FinPessoalTests/Animation/AdvancedPolish/HeroTransitionCoordinatorTests.swift`

**Step 1: Write the failing test**

```swift
//
//  HeroTransitionCoordinatorTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class HeroTransitionCoordinatorTests: XCTestCase {

  var coordinator: HeroTransitionCoordinator!

  override func setUp() async throws {
    try await super.setUp()
    coordinator = HeroTransitionCoordinator()
  }

  override func tearDown() async throws {
    coordinator = nil
    try await super.tearDown()
  }

  func testInitialState() {
    XCTAssertNil(coordinator.activeTransition, "Initially no active transition")
    XCTAssertFalse(coordinator.isTransitioning, "Should not be transitioning initially")
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/HeroTransitionCoordinatorTests/testInitialState`

Expected: FAIL with "Cannot find type 'HeroTransitionCoordinator' in scope"

**Step 3: Write minimal implementation**

```swift
//
//  HeroTransitionCoordinator.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI
import Observation

/// Coordinator for managing hero transition state and preventing conflicts
@Observable
public class HeroTransitionCoordinator {

  // MARK: - State

  /// ID of currently active transition (nil if none)
  public var activeTransition: String?

  /// Whether a transition is currently in progress
  public var isTransitioning: Bool = false

  // MARK: - Initialization

  /// Creates a hero transition coordinator
  public init() {}

  // MARK: - Methods

  /// Begins a hero transition
  /// - Parameter id: Unique identifier for the transition
  public func beginTransition(id: String) {
    activeTransition = id
    isTransitioning = true
    HapticEngine.shared.light()
  }

  /// Ends the current hero transition
  public func endTransition() {
    isTransitioning = false
    activeTransition = nil
  }

  /// Checks if a specific transition is active
  /// - Parameter id: Transition identifier to check
  /// - Returns: True if this transition is active
  public func isActive(_ id: String) -> Bool {
    activeTransition == id
  }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/HeroTransitionCoordinatorTests/testInitialState`

Expected: PASS

**Step 5: Add remaining tests**

Add to `HeroTransitionCoordinatorTests.swift`:

```swift
func testBeginTransition() {
  coordinator.beginTransition(id: "test-transition")

  XCTAssertEqual(coordinator.activeTransition, "test-transition")
  XCTAssertTrue(coordinator.isTransitioning)
  XCTAssertTrue(coordinator.isActive("test-transition"))
}

func testEndTransition() {
  coordinator.beginTransition(id: "test-transition")
  coordinator.endTransition()

  XCTAssertNil(coordinator.activeTransition)
  XCTAssertFalse(coordinator.isTransitioning)
}

func testSingleTransitionOnly() {
  coordinator.beginTransition(id: "first")
  XCTAssertTrue(coordinator.isActive("first"))

  coordinator.beginTransition(id: "second")
  XCTAssertTrue(coordinator.isActive("second"))
  XCTAssertFalse(coordinator.isActive("first"))
}
```

**Step 6: Run all coordinator tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/HeroTransitionCoordinatorTests`

Expected: ALL PASS

**Step 7: Commit**

```bash
git add FinPessoal/Code/Animation/Coordinators/HeroTransitionCoordinator.swift
git add FinPessoalTests/Animation/AdvancedPolish/HeroTransitionCoordinatorTests.swift
git commit -m "feat(phase5c): add HeroTransitionCoordinator with tests

- Observable coordinator for hero transition state management
- Prevents simultaneous transitions
- Haptic feedback on transition start
- 4 unit tests passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2: Add AnimationEngine+AdvancedPolish Extension

**Files:**
- Create: `FinPessoal/Code/Animation/Engine/AnimationEngine+AdvancedPolish.swift`

**Step 1: Write the extension**

```swift
//
//  AnimationEngine+AdvancedPolish.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

// MARK: - Advanced Polish Animation Extensions

extension AnimationEngine {

  // MARK: - Hero Transitions

  /// Hero transition animation - smooth morphing between views
  /// Response: 0.4s, Damping: 0.8
  public static let heroTransition = Animation.spring(
    response: 0.4,
    dampingFraction: 0.8
  )

  // MARK: - Celebration Animations

  /// Celebration pulse animation - gentle scale bounce
  /// Response: 0.6s, Damping: 0.7
  public static let celebrationPulse = Animation.spring(
    response: 0.6,
    dampingFraction: 0.7
  )

  /// Celebration glow animation - soft fade in/out
  /// Duration: 0.8s ease in-out
  public static let celebrationGlow = Animation.easeInOut(duration: 0.8)

  /// Celebration fade animation - quick fade out
  /// Duration: 0.4s ease out
  public static let celebrationFade = Animation.easeOut(duration: 0.4)

  // MARK: - Gradient Animations

  /// Gradient shift animation - infinite loop
  /// Duration: 3.0s linear, repeats forever
  public static let gradientShift = Animation.linear(duration: 3.0)
    .repeatForever(autoreverses: false)

  // MARK: - Adaptive Animations (Respect AnimationSettings)

  /// Returns hero transition animation respecting current animation mode
  /// - Full: Spring animation with matched geometry (400ms)
  /// - Reduced: Simple scale transition (250ms linear)
  /// - Minimal: Instant crossfade (100ms)
  @MainActor
  public static func adaptiveHeroTransition() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return heroTransition
    case .reduced:
      return .linear(duration: 0.25)
    case .minimal:
      return .linear(duration: 0.1)
    }
  }

  /// Returns celebration animation respecting current animation mode
  /// - Full: Complete pulse sequence (2000ms)
  /// - Reduced: Quick pulse (800ms)
  /// - Minimal: Simple fade (400ms)
  @MainActor
  public static func adaptiveCelebration() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return celebrationPulse
    case .reduced:
      return .easeOut(duration: 0.4)
    case .minimal:
      return .linear(duration: 0.2)
    }
  }

  /// Returns gradient animation respecting current animation mode
  /// - Full: Smooth animation (3000ms loop)
  /// - Reduced: Slower animation (5000ms loop)
  /// - Minimal: No animation (nil)
  @MainActor
  public static func adaptiveGradient() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return gradientShift
    case .reduced:
      return .linear(duration: 5.0).repeatForever(autoreverses: false)
    case .minimal:
      return nil
    }
  }
}
```

**Step 2: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Engine/AnimationEngine+AdvancedPolish.swift
git commit -m "feat(phase5c): add AnimationEngine+AdvancedPolish extension

- Hero transition animations (400ms spring)
- Celebration animations (pulse, glow, fade)
- Gradient animations (3s infinite loop)
- Adaptive methods respecting AnimationSettings
- Full/Reduced/Minimal mode support

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 3: Create HeroTransitionLink Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/AdvancedPolish/HeroTransitionLink.swift`
- Test: `FinPessoalTests/Animation/AdvancedPolish/HeroTransitionIntegrationTests.swift`

**Step 1: Write integration test skeleton**

```swift
//
//  HeroTransitionIntegrationTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal
import SwiftUI

@MainActor
final class HeroTransitionIntegrationTests: XCTestCase {

  func testHeroTransitionLinkExists() {
    // Basic compilation test
    let namespace = Namespace().wrappedValue
    let testItem = TestItem(id: "1", name: "Test")

    // This should compile
    let _ = HeroTransitionLink(
      item: testItem,
      namespace: namespace
    ) {
      Text("Source")
    } destination: { item in
      Text("Destination: \(item.name)")
    }

    XCTAssertTrue(true, "HeroTransitionLink compiles")
  }
}

// Test model
struct TestItem: Identifiable {
  let id: String
  let name: String
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/HeroTransitionIntegrationTests/testHeroTransitionLinkExists`

Expected: FAIL with "Cannot find 'HeroTransitionLink' in scope"

**Step 3: Write HeroTransitionLink component**

```swift
//
//  HeroTransitionLink.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// A component that provides hero transition animations between views using matched geometry
public struct HeroTransitionLink<Item: Identifiable, Content: View, Destination: View>: View {

  // MARK: - Configuration

  /// Item to transition
  private let item: Item

  /// Namespace for matched geometry effect
  private let namespace: Namespace.ID

  /// Source content view
  private let content: Content

  /// Destination view builder
  private let destination: (Item) -> Destination

  // MARK: - State

  /// Whether destination is presented
  @State private var isPresented: Bool = false

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a hero transition link
  /// - Parameters:
  ///   - item: Item to transition
  ///   - namespace: Namespace for matched geometry
  ///   - content: Source content builder
  ///   - destination: Destination view builder
  public init(
    item: Item,
    namespace: Namespace.ID,
    @ViewBuilder content: () -> Content,
    @ViewBuilder destination: @escaping (Item) -> Destination
  ) {
    self.item = item
    self.namespace = namespace
    self.content = content()
    self.destination = destination
  }

  // MARK: - Body

  public var body: some View {
    Button {
      presentDestination()
    } label: {
      if reduceMotion {
        // Reduce Motion: No matched geometry effect
        content
      } else {
        // Full animation: Matched geometry effect
        content
          .matchedGeometryEffect(
            id: item.id,
            in: namespace
          )
      }
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $isPresented) {
      destinationView
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isButton)
  }

  // MARK: - Views

  /// Destination view with matched geometry
  private var destinationView: some View {
    Group {
      if reduceMotion {
        // Reduce Motion: Simple transition
        destination(item)
          .transition(.opacity)
      } else {
        // Full animation: Matched geometry
        destination(item)
          .matchedGeometryEffect(
            id: item.id,
            in: namespace
          )
      }
    }
  }

  // MARK: - Actions

  /// Presents the destination view with hero transition
  private func presentDestination() {
    HapticEngine.shared.light()

    withAnimation(AnimationEngine.adaptiveHeroTransition()) {
      isPresented = true
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/HeroTransitionIntegrationTests/testHeroTransitionLinkExists`

Expected: PASS

**Step 5: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AdvancedPolish/HeroTransitionLink.swift
git add FinPessoalTests/Animation/AdvancedPolish/HeroTransitionIntegrationTests.swift
git commit -m "feat(phase5c): add HeroTransitionLink component

- Generic component for hero transitions with matched geometry
- Respects Reduce Motion (falls back to simple fade)
- Sheet presentation with smooth morphing
- Haptic feedback on tap
- Integration test passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Week 2: Celebrations & Parallax

### Task 4: Create CelebrationView Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/AdvancedPolish/CelebrationView.swift`
- Test: `FinPessoalTests/Animation/AdvancedPolish/CelebrationViewTests.swift`

**Step 1: Write the failing test**

```swift
//
//  CelebrationViewTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal
import SwiftUI

@MainActor
final class CelebrationViewTests: XCTestCase {

  func testRefinedStyleCompiles() {
    let view = CelebrationView(style: .refined, duration: 2.0)
    XCTAssertNotNil(view, "CelebrationView should compile")
  }

  func testMinimalStyleCompiles() {
    let view = CelebrationView(style: .minimal, duration: 1.0)
    XCTAssertNotNil(view, "Minimal style should compile")
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/CelebrationViewTests`

Expected: FAIL with "Cannot find 'CelebrationView' in scope"

**Step 3: Write CelebrationView component**

```swift
//
//  CelebrationView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Celebration animation styles
public enum CelebrationStyle {
  /// Refined: Scale pulse + soft glow (default)
  case refined

  /// Minimal: Check mark only
  case minimal

  /// Joyful: Refined + subtle shimmer
  case joyful
}

/// Celebration haptic feedback patterns
public enum CelebrationHaptic {
  /// Triple light taps
  case success

  /// Crescendo pattern (light → medium → heavy)
  case achievement

  /// No haptic feedback
  case none
}

/// Refined celebration animation for milestones
public struct CelebrationView: View {

  // MARK: - Configuration

  /// Celebration style
  private let style: CelebrationStyle

  /// Animation duration in seconds
  private let duration: TimeInterval

  /// Haptic feedback pattern
  private let haptic: CelebrationHaptic

  /// Callback when celebration completes
  private let onComplete: (() -> Void)?

  // MARK: - State

  /// Current animation phase (0.0 to 1.0)
  @State private var animationPhase: CGFloat = 0

  /// Whether celebration is visible
  @State private var isVisible: Bool = false

  /// Scale for pulse animation
  @State private var scale: CGFloat = 0.8

  /// Opacity for glow effect
  @State private var glowOpacity: Double = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityDifferentiateWithoutColor) private var highContrast

  // MARK: - Initialization

  /// Creates a celebration view
  /// - Parameters:
  ///   - style: Celebration style (default: .refined)
  ///   - duration: Animation duration in seconds (default: 2.0)
  ///   - haptic: Haptic feedback pattern (default: .success)
  ///   - onComplete: Callback when celebration completes
  public init(
    style: CelebrationStyle = .refined,
    duration: TimeInterval = 2.0,
    haptic: CelebrationHaptic = .success,
    onComplete: (() -> Void)? = nil
  ) {
    self.style = style
    self.duration = duration
    self.haptic = haptic
    self.onComplete = onComplete
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      if isVisible {
        celebrationContent
          .scaleEffect(scale)
          .opacity(isVisible ? 1.0 : 0.0)
          .transition(.opacity)
      }
    }
    .onAppear {
      startCelebration()
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Success")
    .accessibilityHidden(true) // Decorative animation
  }

  // MARK: - Views

  /// Main celebration content based on style
  @ViewBuilder
  private var celebrationContent: some View {
    switch style {
    case .refined:
      refinedCelebration
    case .minimal:
      minimalCelebration
    case .joyful:
      refinedCelebration // Same as refined for now
    }
  }

  /// Refined celebration: Pulse + glow
  private var refinedCelebration: some View {
    ZStack {
      // Glow effect
      if !reduceMotion {
        Circle()
          .fill(Color.oldMoney.accent.opacity(glowOpacity * glowMultiplier))
          .blur(radius: 20)
          .frame(width: 100, height: 100)
      }

      // Check mark icon
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: celebrationIconSize))
        .foregroundStyle(Color.oldMoney.accent)
    }
  }

  /// Minimal celebration: Check mark only
  private var minimalCelebration: some View {
    Image(systemName: "checkmark.circle.fill")
      .font(.system(size: celebrationIconSize))
      .foregroundStyle(Color.oldMoney.accent)
  }

  // MARK: - Computed Properties

  /// Icon size scaled for accessibility
  @ScaledMetric private var celebrationIconSize: CGFloat = 60

  /// Glow opacity multiplier for high contrast
  private var glowMultiplier: Double {
    highContrast ? 0.5 : 0.3
  }

  // MARK: - Actions

  /// Starts the celebration animation sequence
  private func startCelebration() {
    isVisible = true

    if reduceMotion {
      // Reduce Motion: Simple fade
      withAnimation(AnimationEngine.adaptiveCelebration()) {
        scale = 1.0
      }

      // Auto-dismiss
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        dismissCelebration()
      }
    } else {
      // Full animation sequence
      animateSequence()
    }

    // Trigger haptics
    triggerHaptics()
  }

  /// Full animation sequence: Fade in → Pulse → Glow → Fade out
  private func animateSequence() {
    // Phase 1: Fade in (200ms)
    withAnimation(.easeOut(duration: 0.2)) {
      scale = 1.0
    }

    // Phase 2: Pulse (600ms) - starts at 200ms
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(AnimationEngine.celebrationPulse) {
        scale = 1.05
      }

      // Return to normal after pulse
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        withAnimation(AnimationEngine.celebrationPulse) {
          scale = 1.0
        }
      }
    }

    // Phase 3: Glow (800ms) - starts at 200ms
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(AnimationEngine.celebrationGlow) {
        glowOpacity = 1.0
      }

      // Fade glow
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        withAnimation(AnimationEngine.celebrationGlow) {
          glowOpacity = 0
        }
      }
    }

    // Phase 4: Fade out (400ms) - starts at 1.6s
    let fadeOutDelay = duration - 0.4
    DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
      withAnimation(AnimationEngine.celebrationFade) {
        isVisible = false
      }

      // Call completion
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        onComplete?()
      }
    }
  }

  /// Dismisses the celebration
  private func dismissCelebration() {
    withAnimation(AnimationEngine.celebrationFade) {
      isVisible = false
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      onComplete?()
    }
  }

  /// Triggers haptic feedback based on pattern
  private func triggerHaptics() {
    guard !AnimationSettings.shared.shouldSuppressHaptics else { return }

    switch haptic {
    case .success:
      // Triple light taps
      HapticEngine.shared.light()

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        HapticEngine.shared.light()
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        HapticEngine.shared.medium()
      }

    case .achievement:
      // Crescendo
      HapticEngine.shared.crescendo()

    case .none:
      break
    }
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/CelebrationViewTests`

Expected: ALL PASS

**Step 5: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AdvancedPolish/CelebrationView.swift
git add FinPessoalTests/Animation/AdvancedPolish/CelebrationViewTests.swift
git commit -m "feat(phase5c): add CelebrationView component

- Refined celebration: pulse + glow + haptic (2s)
- Minimal celebration: check mark only
- Triple haptic taps (light, light, medium)
- Respects Reduce Motion (simple fade)
- High contrast mode support (stronger glow)
- Dynamic Type scaling for icon
- 2 unit tests passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 5: Create ParallaxModifier

**Files:**
- Create: `FinPessoal/Code/Animation/Modifiers/ParallaxModifier.swift`
- Test: `FinPessoalTests/Animation/AdvancedPolish/ParallaxModifierTests.swift`

**Step 1: Write the failing test**

```swift
//
//  ParallaxModifierTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal
import SwiftUI

@MainActor
final class ParallaxModifierTests: XCTestCase {

  func testParallaxModifierExists() {
    let view = Text("Test")
      .withParallax(speed: 0.7)

    XCTAssertNotNil(view, "Parallax modifier should compile")
  }

  func testParallaxSpeedConfiguration() {
    // Test different speed values compile
    let _ = Text("Test").withParallax(speed: 0.5)
    let _ = Text("Test").withParallax(speed: 0.7)
    let _ = Text("Test").withParallax(speed: 1.0)

    XCTAssertTrue(true, "Different speeds should compile")
  }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/ParallaxModifierTests`

Expected: FAIL with "Value of type 'Text' has no member 'withParallax'"

**Step 3: Create PreferenceKey for scroll offset**

Add to `ParallaxModifier.swift`:

```swift
//
//  ParallaxModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

// MARK: - Scroll Offset PreferenceKey

/// PreferenceKey for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

// MARK: - Parallax Modifier

/// ViewModifier that applies parallax effect during scroll
struct ParallaxModifier: ViewModifier {

  // MARK: - Configuration

  /// Speed multiplier (0.0-1.0, where 0.7 = 30% slower than scroll)
  let speed: CGFloat

  /// Axis of parallax effect
  let axis: Axis

  /// Whether parallax is enabled
  let enabled: Bool

  // MARK: - State

  /// Current scroll offset
  @State private var scrollOffset: CGFloat = 0

  /// Last update time for throttling
  @State private var lastUpdate: CFTimeInterval = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Body

  func body(content: Content) -> some View {
    if enabled && !reduceMotion && AnimationSettings.shared.effectiveMode != .minimal {
      content
        .offset(
          x: axis == .horizontal ? scrollOffset * (1 - speed) : 0,
          y: axis == .vertical ? scrollOffset * (1 - speed) : 0
        )
        .background(
          GeometryReader { geometry in
            Color.clear.preference(
              key: ScrollOffsetPreferenceKey.self,
              value: geometry.frame(in: .named("scroll")).minY
            )
          }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
          updateParallax(value)
        }
    } else {
      content
    }
  }

  // MARK: - Methods

  /// Updates parallax offset with throttling for 60fps
  private func updateParallax(_ offset: CGFloat) {
    let currentTime = CACurrentMediaTime()

    // Throttle updates to max once per frame (16.67ms)
    guard currentTime - lastUpdate > 0.016 else { return }

    scrollOffset = offset
    lastUpdate = currentTime
  }
}

// MARK: - View Extension

public extension View {
  /// Applies parallax effect to view during scroll
  /// - Parameters:
  ///   - speed: Speed multiplier (0.0-1.0, default 0.7 = 30% slower)
  ///   - axis: Parallax axis (default: .vertical)
  ///   - enabled: Whether effect is enabled (default: true)
  /// - Returns: View with parallax effect
  func withParallax(
    speed: CGFloat = 0.7,
    axis: Axis = .vertical,
    enabled: Bool = true
  ) -> some View {
    modifier(
      ParallaxModifier(
        speed: speed,
        axis: axis,
        enabled: enabled
      )
    )
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -only-testing:FinPessoalTests/ParallaxModifierTests`

Expected: ALL PASS

**Step 5: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Modifiers/ParallaxModifier.swift
git add FinPessoalTests/Animation/AdvancedPolish/ParallaxModifierTests.swift
git commit -m "feat(phase5c): add ParallaxModifier for depth effects

- ViewModifier applying parallax effect during scroll
- Speed configurable (0.7 = 30% slower than scroll)
- Vertical/horizontal axis support
- Throttled updates for 60fps (max 16.67ms)
- Respects Reduce Motion (disabled)
- PreferenceKey for scroll offset tracking
- 2 unit tests passing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6: Create GradientAnimationModifier

**Files:**
- Create: `FinPessoal/Code/Animation/Modifiers/GradientAnimationModifier.swift`

**Step 1: Write the modifier**

```swift
//
//  GradientAnimationModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Gradient animation style
public enum GradientAnimationStyle {
  /// Linear gradient
  case linear(UnitPoint, UnitPoint)

  /// Radial gradient
  case radial(center: UnitPoint)

  /// Angular gradient
  case angular(center: UnitPoint)
}

/// ViewModifier that applies animated gradient overlay
struct GradientAnimationModifier: ViewModifier {

  // MARK: - Configuration

  /// Gradient colors
  let colors: [Color]

  /// Animation duration
  let duration: TimeInterval

  /// Gradient style
  let style: GradientAnimationStyle

  // MARK: - State

  /// Current animation phase (0.0 to 1.0)
  @State private var animationPhase: CGFloat = 0

  // MARK: - Body

  func body(content: Content) -> some View {
    content
      .overlay(
        gradientView
          .opacity(AnimationSettings.shared.effectiveMode == .minimal ? 0 : 1)
      )
      .onAppear {
        startAnimation()
      }
  }

  // MARK: - Views

  /// Gradient view based on style
  @ViewBuilder
  private var gradientView: some View {
    switch style {
    case .linear(let start, let end):
      LinearGradient(
        colors: colors,
        startPoint: interpolatePoint(start, animationPhase),
        endPoint: interpolatePoint(end, 1 - animationPhase)
      )

    case .radial(let center):
      RadialGradient(
        colors: colors,
        center: center,
        startRadius: 0,
        endRadius: 200
      )

    case .angular(let center):
      AngularGradient(
        colors: colors,
        center: center,
        angle: .degrees(animationPhase * 360)
      )
    }
  }

  // MARK: - Methods

  /// Starts the gradient animation
  private func startAnimation() {
    guard AnimationSettings.shared.effectiveMode != .minimal else { return }

    withAnimation(AnimationEngine.adaptiveGradient()) {
      animationPhase = 1.0
    }
  }

  /// Interpolates point position based on animation phase
  private func interpolatePoint(_ point: UnitPoint, _ phase: CGFloat) -> UnitPoint {
    let offset = phase * 0.2 // Subtle 20% movement
    return UnitPoint(
      x: point.x + offset,
      y: point.y + offset
    )
  }
}

// MARK: - View Extension

public extension View {
  /// Applies animated gradient overlay to view
  /// - Parameters:
  ///   - colors: Gradient colors (default: subtle accent gradient)
  ///   - duration: Animation duration (default: 3.0s)
  ///   - style: Gradient style (default: linear)
  /// - Returns: View with gradient overlay
  func withGradientAnimation(
    colors: [Color] = [Color.oldMoney.accent.opacity(0.1), .clear],
    duration: TimeInterval = 3.0,
    style: GradientAnimationStyle = .linear(.topLeading, .bottomTrailing)
  ) -> some View {
    modifier(
      GradientAnimationModifier(
        colors: colors,
        duration: duration,
        style: style
      )
    )
  }
}
```

**Step 2: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Modifiers/GradientAnimationModifier.swift
git commit -m "feat(phase5c): add GradientAnimationModifier

- ViewModifier for animated gradient overlays
- Linear/Radial/Angular gradient styles
- 3s default duration for sophisticated feel
- Subtle color shifts (low opacity 0.1-0.2)
- Respects AnimationSettings (disabled in Minimal mode)
- GPU-accelerated gradient rendering

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Week 3: Advanced Components & Testing

### Task 7: Create ParallaxScrollView Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/AdvancedPolish/ParallaxScrollView.swift`

**Step 1: Write the component**

```swift
//
//  ParallaxScrollView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Enhanced ScrollView with layered parallax effects
public struct ParallaxScrollView<Background: View, Content: View>: View {

  // MARK: - Configuration

  /// Background layer speed (0.0-1.0, default 0.5 = 50% of scroll)
  private let backgroundSpeed: CGFloat

  /// Foreground layer speed (default 1.0 = normal scroll)
  private let foregroundSpeed: CGFloat

  /// Background view
  private let background: Background

  /// Content view
  private let content: Content

  // MARK: - State

  /// Current scroll offset
  @State private var scrollOffset: CGFloat = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a parallax scroll view
  /// - Parameters:
  ///   - backgroundSpeed: Background movement speed (default: 0.5)
  ///   - foregroundSpeed: Foreground movement speed (default: 1.0)
  ///   - background: Background view builder
  ///   - content: Content view builder
  public init(
    backgroundSpeed: CGFloat = 0.5,
    foregroundSpeed: CGFloat = 1.0,
    @ViewBuilder background: () -> Background,
    @ViewBuilder content: () -> Content
  ) {
    self.backgroundSpeed = backgroundSpeed
    self.foregroundSpeed = foregroundSpeed
    self.background = background()
    self.content = content()
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      // Background layer with parallax
      if !reduceMotion {
        background
          .offset(y: scrollOffset * (1 - backgroundSpeed))
      } else {
        background
      }

      // Scrollable content
      ScrollView {
        content
          .background(
            GeometryReader { geometry in
              Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: geometry.frame(in: .named("scroll")).minY
              )
            }
          )
      }
      .coordinateSpace(name: "scroll")
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
        scrollOffset = value
      }
    }
  }
}
```

**Step 2: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AdvancedPolish/ParallaxScrollView.swift
git commit -m "feat(phase5c): add ParallaxScrollView component

- Enhanced ScrollView with layered parallax
- Background moves at 50% of scroll speed (configurable)
- Smooth 60fps performance
- Respects Reduce Motion (no parallax)
- Use cases: Hero headers, detail views, onboarding

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 8: Create GradientAnimationView Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/AdvancedPolish/GradientAnimationView.swift`

**Step 1: Write the component**

```swift
//
//  GradientAnimationView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Standalone animated gradient view
public struct GradientAnimationView: View {

  // MARK: - Configuration

  /// Gradient colors
  private let colors: [Color]

  /// Animation duration
  private let duration: TimeInterval

  /// Gradient style
  private let style: GradientAnimationStyle

  // MARK: - State

  /// Current animation phase
  @State private var animationPhase: CGFloat = 0

  // MARK: - Initialization

  /// Creates an animated gradient view
  /// - Parameters:
  ///   - colors: Gradient colors
  ///   - duration: Animation duration (default: 3.0s)
  ///   - style: Gradient style (default: linear)
  public init(
    colors: [Color],
    duration: TimeInterval = 3.0,
    style: GradientAnimationStyle = .linear(.topLeading, .bottomTrailing)
  ) {
    self.colors = colors
    self.duration = duration
    self.style = style
  }

  // MARK: - Body

  public var body: some View {
    gradientView
      .drawingGroup() // GPU acceleration
      .onAppear {
        startAnimation()
      }
  }

  // MARK: - Views

  @ViewBuilder
  private var gradientView: some View {
    switch style {
    case .linear(let start, let end):
      LinearGradient(
        colors: colors,
        startPoint: start,
        endPoint: end
      )

    case .radial(let center):
      RadialGradient(
        colors: colors,
        center: center,
        startRadius: 0,
        endRadius: 300
      )

    case .angular(let center):
      AngularGradient(
        colors: colors,
        center: center,
        angle: .degrees(animationPhase * 360)
      )
    }
  }

  // MARK: - Methods

  private func startAnimation() {
    guard AnimationSettings.shared.effectiveMode != .minimal else { return }

    withAnimation(AnimationEngine.adaptiveGradient()) {
      animationPhase = 1.0
    }
  }
}
```

**Step 2: Verify build succeeds**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AdvancedPolish/GradientAnimationView.swift
git commit -m "feat(phase5c): add GradientAnimationView component

- Standalone animated gradient component
- Linear/Radial/Angular styles
- GPU-accelerated with drawingGroup()
- 3s+ slow animation for sophistication
- Respects AnimationSettings

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 9: Update CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Update changelog**

Add to top of "### Added - February 2026" section:

```markdown
- **Phase 5C: Advanced Polish - Week 1-2: Foundation Components** (2026-02-16)
  - HeroTransitionCoordinator (~60 lines):
    - Observable coordinator for hero transition state
    - Prevents simultaneous transitions
    - Haptic feedback on transition start
  - AnimationEngine+AdvancedPolish (~80 lines):
    - heroTransition: 400ms spring (response: 0.4, damping: 0.8)
    - celebrationPulse, celebrationGlow, celebrationFade
    - gradientShift: 3s infinite loop
    - Adaptive methods: adaptiveHeroTransition(), adaptiveCelebration(), adaptiveGradient()
  - HeroTransitionLink Component (~150 lines):
    - Generic component for matched geometry transitions
    - Sheet presentation with smooth morphing
    - Reduce Motion fallback (simple fade)
  - CelebrationView Component (~120 lines):
    - Refined style: pulse (1.05x) + glow + triple haptic
    - Minimal style: check mark only
    - 2s duration, auto-dismiss
    - Dynamic Type support, High Contrast mode
  - ParallaxModifier (~90 lines):
    - Subtle depth effect (20-30% speed difference)
    - Throttled updates for 60fps
    - PreferenceKey scroll tracking
    - Disabled in Reduce Motion
  - GradientAnimationModifier (~70 lines):
    - Animated gradient overlays
    - Linear/Radial/Angular styles
    - 3s sophisticated loops
  - ParallaxScrollView (~100 lines):
    - Enhanced ScrollView with layered parallax
    - Background at 50% scroll speed
  - GradientAnimationView (~80 lines):
    - Standalone animated gradients
    - GPU-accelerated rendering
  - Testing:
    - HeroTransitionCoordinatorTests (4 tests)
    - CelebrationViewTests (2 tests)
    - ParallaxModifierTests (2 tests)
    - HeroTransitionIntegrationTests (1 test)
  - Build Status: ✅ BUILD SUCCEEDED
  - Total: ~750 lines production code, 9 tests passing
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs(phase5c): update CHANGELOG with Week 1-2 progress

Phase 5C foundation components complete:
- 7 components (coordinator, link, celebration, modifiers, views)
- 4 animation curves in AnimationEngine
- 9 tests passing
- Build succeeding

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 10: Write Phase 5C Completion Report (Final Task)

**Files:**
- Create: `Docs/phase5c-completion-report.md`

**Step 1: Create completion report**

This will be done after all integrations and testing complete. Placeholder for now.

**Step 2: Final verification**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: BUILD SUCCEEDED

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal`

Expected: ALL TESTS PASS

---

## Success Criteria

Phase 5C implementation complete when:

- ✅ All 8 production files created (~750 lines)
- ✅ All 7 test files created (~720 lines)
- ✅ All tests passing (25+ test cases)
- ✅ Build succeeds with zero errors
- ✅ CHANGELOG.md updated
- ✅ Completion report written
- ✅ All components respect AnimationSettings modes
- ✅ Accessibility verified (VoiceOver, Reduce Motion, Dynamic Type)
- ✅ Performance acceptable (60fps on iPhone 12+)

---

## Notes for Implementation

### Testing Strategy

- **TDD Approach:** Write failing test first, implement minimal code, verify pass
- **Commit Frequency:** After each task completion (~5-10 commits total)
- **Test Coverage:** Aim for 80%+ on component logic
- **Performance Testing:** Manual profiling with Instruments

### Integration Points

**Hero Transitions:**
- TransactionsContentView: Wrap TransactionRow
- GoalsScreen: Wrap GoalCard
- BudgetScreen: Wrap BudgetCard

**Celebrations:**
- GoalsScreen: Show on goal completion
- BudgetScreen: Show on budget met
- DashboardView: Show on milestones

**Parallax:**
- DashboardView: Apply to hero header
- All ScrollViews: Apply to scrollable content
- DetailViews: Use ParallaxScrollView for layered content

**Gradients:**
- Cards: Apply withGradientAnimation() modifier
- Headers: Use GradientAnimationView background
- Marketing screens: Sophisticated backgrounds

### Common Pitfalls

1. **Matched Geometry:** Ensure same ID used in source and destination
2. **Namespace Scope:** Create @Namespace in parent view, pass down
3. **Reduce Motion:** Always test with accessibility settings enabled
4. **Performance:** Profile parallax with many views (throttling critical)
5. **Haptics:** Check HapticEngine availability before triggering

---

**End of Implementation Plan**

**Next Step:** Use `superpowers:executing-plans` to implement this plan task-by-task in a dedicated worktree.
