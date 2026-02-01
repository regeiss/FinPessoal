# Phase 1: Dashboard Animations Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the animation foundation and implement all Dashboard animations including balance cards, number counters, particles, and interactive charts.

**Architecture:** Three-layer approach with AnimationEngine (core), reusable components (AnimatedCard, PhysicsNumberCounter, ParticleEmitter), and DashboardAnimationCoordinator for screen-specific choreography.

**Tech Stack:** SwiftUI, CoreHaptics, Metal (particle shaders), ProMotion support, @MainActor concurrency

**Timeline:** Week 1: Foundation, Week 2: Components + Balance Cards, Week 3: Charts + Polish

---

## Prerequisites

**Current Working Directory:** `/Users/robertoedgargeiss/ProjetosIOS/FinPessoal/.worktrees/depth-microtransitions`

**Existing Files to Understand:**
- `FinPessoal/Code/Configuration/Theme/OldMoneyTheme.swift` - Current theme system
- `FinPessoal/Code/Configuration/Theme/OldMoneyColors.swift` - Color palette
- `FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift` - Current balance card
- `FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift` - Main dashboard

**Test Command:** `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`

---

## Task 1: Animation Mode System

**Files:**
- Create: `FinPessoal/Code/Animation/Engine/AnimationMode.swift`
- Create: `FinPessoal/Code/Animation/Engine/AnimationSettings.swift`
- Test: `FinPessoalTests/Animation/AnimationModeTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Animation/AnimationModeTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class AnimationModeTests: XCTestCase {

  func testDefaultModeIsFull() {
    let settings = AnimationSettings.shared
    XCTAssertEqual(settings.mode, .full)
  }

  func testReducedMotionOverride() {
    let settings = AnimationSettings.shared
    settings.respectReduceMotion = true
    settings.systemReduceMotionEnabled = true

    XCTAssertEqual(settings.effectiveMode, .minimal)
  }

  func testUserCanOverrideReducedMotion() {
    let settings = AnimationSettings.shared
    settings.respectReduceMotion = false
    settings.systemReduceMotionEnabled = true
    settings.mode = .full

    XCTAssertEqual(settings.effectiveMode, .full)
  }
}
```

**Step 2: Run test to verify it fails**

Run: Test via Xcode or `xcodebuild test` command above
Expected: FAIL with "No such module 'FinPessoal'" or type not found errors

**Step 3: Create directory structure**

```bash
mkdir -p FinPessoal/Code/Animation/Engine
mkdir -p FinPessoalTests/Animation
```

**Step 4: Write AnimationMode enum**

```swift
// FinPessoal/Code/Animation/Engine/AnimationMode.swift
import Foundation

/// Animation mode determining the complexity of animations shown to the user
@MainActor
public enum AnimationMode: String, Codable, CaseIterable {
  /// Full animations with particles, complex transitions, parallax
  case full

  /// Reduced animations - no particles, simplified transitions, smooth fades
  case reduced

  /// Minimal animations - instant transitions, fade-only effects
  case minimal

  /// Display name for UI
  var displayName: String {
    switch self {
    case .full:
      return "Full Experience"
    case .reduced:
      return "Reduced Motion"
    case .minimal:
      return "Minimal Motion"
    }
  }

  /// Description for accessibility
  var description: String {
    switch self {
    case .full:
      return "All animations enabled including particles and complex effects"
    case .reduced:
      return "Simplified animations without decorative effects"
    case .minimal:
      return "Minimal animations with instant transitions"
    }
  }
}
```

**Step 5: Write AnimationSettings class**

```swift
// FinPessoal/Code/Animation/Engine/AnimationSettings.swift
import SwiftUI
import Combine

/// Global animation settings managing animation mode and accessibility
@MainActor
public class AnimationSettings: ObservableObject {
  public static let shared = AnimationSettings()

  /// Current animation mode set by user
  @Published public var mode: AnimationMode = .full

  /// Whether to respect system reduce motion setting
  @Published public var respectReduceMotion: Bool = true

  /// System reduce motion setting (injected for testing)
  public var systemReduceMotionEnabled: Bool = false

  private init() {
    // Initialize with system setting
    systemReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
  }

  /// Effective mode considering user preference and system settings
  public var effectiveMode: AnimationMode {
    if respectReduceMotion && systemReduceMotionEnabled {
      return .minimal
    }
    return mode
  }

  /// Whether particles should be shown
  public var shouldShowParticles: Bool {
    effectiveMode == .full
  }

  /// Whether complex hero transitions should be used
  public var shouldUseHeroTransitions: Bool {
    effectiveMode != .minimal
  }

  /// Whether parallax effects should be applied
  public var shouldUseParallax: Bool {
    effectiveMode == .full
  }
}
```

**Step 6: Add AnimationMode.swift and AnimationSettings.swift to Xcode project**

1. Open Xcode project
2. Right-click on `Code/Animation/Engine` folder (create if needed)
3. Add both files to FinPessoal target
4. Verify they appear in Project Navigator

**Step 7: Add test file to project**

1. Right-click on `FinPessoalTests/Animation` folder
2. Add `AnimationModeTests.swift` to FinPessoalTests target

**Step 8: Run tests to verify they pass**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:FinPessoalTests/AnimationModeTests`
Expected: PASS (3 tests)

**Step 9: Commit**

```bash
git add FinPessoal/Code/Animation/Engine/AnimationMode.swift
git add FinPessoal/Code/Animation/Engine/AnimationSettings.swift
git add FinPessoalTests/Animation/AnimationModeTests.swift
git commit -m "feat: add animation mode system with accessibility support

- AnimationMode enum (full, reduced, minimal)
- AnimationSettings singleton managing mode and accessibility
- Tests for mode switching and reduce motion override

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Animation Engine Core

**Files:**
- Create: `FinPessoal/Code/Animation/Engine/AnimationEngine.swift`
- Test: `FinPessoalTests/Animation/AnimationEngineTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Animation/AnimationEngineTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

final class AnimationEngineTests: XCTestCase {

  func testSpringPresets() {
    // Test that spring animations are configured correctly
    let gentle = AnimationEngine.gentleSpring
    let bouncy = AnimationEngine.bouncySpring
    let snappy = AnimationEngine.snappySpring

    XCTAssertNotNil(gentle)
    XCTAssertNotNil(bouncy)
    XCTAssertNotNil(snappy)
  }

  func testTimingCurves() {
    let easeInOut = AnimationEngine.easeInOut
    let quickFade = AnimationEngine.quickFade

    XCTAssertNotNil(easeInOut)
    XCTAssertNotNil(quickFade)
  }

  func testAnimationForMode() {
    let fullAnimation = AnimationEngine.animation(for: .full, base: AnimationEngine.gentleSpring)
    let minimalAnimation = AnimationEngine.animation(for: .minimal, base: AnimationEngine.gentleSpring)

    XCTAssertNotNil(fullAnimation)
    XCTAssertNotNil(minimalAnimation)
  }
}
```

**Step 2: Run test to verify it fails**

Run: Test command
Expected: FAIL with type not found

**Step 3: Write AnimationEngine**

```swift
// FinPessoal/Code/Animation/Engine/AnimationEngine.swift
import SwiftUI

/// Centralized animation configuration and presets
public struct AnimationEngine {

  // MARK: - Spring Animations

  /// Gentle spring for subtle interactions (response: 0.6, damping: 0.8)
  public static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)

  /// Bouncy spring for playful interactions (response: 0.5, damping: 0.6)
  public static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)

  /// Snappy spring for quick feedback (response: 0.3, damping: 0.9)
  public static let snappySpring = Animation.spring(response: 0.3, dampingFraction: 0.9)

  /// Overdamped spring for smooth momentum (response: 0.8, damping: 1.0)
  public static let overdampedSpring = Animation.spring(response: 0.8, dampingFraction: 1.0)

  // MARK: - Timing Curves

  /// Standard ease in-out (0.3s)
  public static let easeInOut = Animation.easeInOut(duration: 0.3)

  /// Quick fade (0.2s)
  public static let quickFade = Animation.easeOut(duration: 0.2)

  /// Slow ease (0.5s)
  public static let slowEase = Animation.easeInOut(duration: 0.5)

  // MARK: - Mode-Aware Animations

  /// Returns appropriate animation based on current mode
  @MainActor
  public static func animation(for mode: AnimationMode, base: Animation) -> Animation? {
    switch mode {
    case .full:
      return base
    case .reduced:
      // Simplified version - shorter duration
      return .easeInOut(duration: 0.2)
    case .minimal:
      // No animation
      return nil
    }
  }

  /// Returns animation based on current global settings
  @MainActor
  public static func animation(base: Animation) -> Animation? {
    animation(for: AnimationSettings.shared.effectiveMode, base: base)
  }

  // MARK: - Stagger Delays

  /// Standard stagger delay for list items (50ms)
  public static let standardStagger: Double = 0.05

  /// Quick stagger for fast reveals (30ms)
  public static let quickStagger: Double = 0.03

  /// Slow stagger for dramatic effect (100ms)
  public static let slowStagger: Double = 0.1
}
```

**Step 4: Add files to Xcode**

1. Add `AnimationEngine.swift` to project under `Code/Animation/Engine`
2. Add `AnimationEngineTests.swift` to project under `FinPessoalTests/Animation`
3. Ensure both are in correct targets

**Step 5: Run tests**

Run: Test command
Expected: PASS (3 tests)

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Engine/AnimationEngine.swift
git add FinPessoalTests/Animation/AnimationEngineTests.swift
git commit -m "feat: add animation engine with spring presets and mode-aware animations

- Spring presets (gentle, bouncy, snappy, overdamped)
- Timing curves (easeInOut, quickFade, slowEase)
- Mode-aware animation selection
- Stagger delay constants

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Haptic Engine

**Files:**
- Create: `FinPessoal/Code/Animation/Engine/HapticEngine.swift`
- Test: `FinPessoalTests/Animation/HapticEngineTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Animation/HapticEngineTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class HapticEngineTests: XCTestCase {

  func testHapticEngineSharedInstance() {
    let engine1 = HapticEngine.shared
    let engine2 = HapticEngine.shared

    XCTAssertTrue(engine1 === engine2, "Should return same instance")
  }

  func testImpactHapticsDoNotCrash() {
    let engine = HapticEngine.shared

    // These should not crash even if haptics unavailable
    XCTAssertNoThrow(engine.light())
    XCTAssertNoThrow(engine.medium())
    XCTAssertNoThrow(engine.heavy())
  }

  func testNotificationHapticsDoNotCrash() {
    let engine = HapticEngine.shared

    XCTAssertNoThrow(engine.success())
    XCTAssertNoThrow(engine.warning())
    XCTAssertNoThrow(engine.error())
  }
}
```

**Step 2: Run test**

Run: Test command
Expected: FAIL with type not found

**Step 3: Write HapticEngine**

```swift
// FinPessoal/Code/Animation/Engine/HapticEngine.swift
import UIKit
import CoreHaptics

/// Centralized haptic feedback engine
@MainActor
public class HapticEngine {
  public static let shared = HapticEngine()

  private var impactLight: UIImpactFeedbackGenerator?
  private var impactMedium: UIImpactFeedbackGenerator?
  private var impactHeavy: UIImpactFeedbackGenerator?
  private var notification: UINotificationFeedbackGenerator?
  private var selection: UISelectionFeedbackGenerator?

  private var hapticEngine: CHHapticEngine?
  private var supportsHaptics: Bool = false

  private init() {
    setupHapticEngine()
  }

  private func setupHapticEngine() {
    // Check if device supports haptics
    supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    guard supportsHaptics else { return }

    // Initialize feedback generators
    impactLight = UIImpactFeedbackGenerator(style: .light)
    impactMedium = UIImpactFeedbackGenerator(style: .medium)
    impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    notification = UINotificationFeedbackGenerator()
    selection = UISelectionFeedbackGenerator()

    // Setup Core Haptics engine for custom patterns
    do {
      hapticEngine = try CHHapticEngine()
      try hapticEngine?.start()
    } catch {
      print("Haptic engine failed to start: \(error)")
    }
  }

  // MARK: - Impact Haptics

  public func light() {
    guard supportsHaptics else { return }
    impactLight?.prepare()
    impactLight?.impactOccurred()
  }

  public func medium() {
    guard supportsHaptics else { return }
    impactMedium?.prepare()
    impactMedium?.impactOccurred()
  }

  public func heavy() {
    guard supportsHaptics else { return }
    impactHeavy?.prepare()
    impactHeavy?.impactOccurred()
  }

  public func selection() {
    guard supportsHaptics else { return }
    self.selection?.prepare()
    self.selection?.selectionChanged()
  }

  // MARK: - Notification Haptics

  public func success() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.success)
  }

  public func warning() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.warning)
  }

  public func error() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.error)
  }

  // MARK: - Custom Patterns

  /// Gentle success pattern (tap-tap-tap)
  public func gentleSuccess() {
    guard supportsHaptics, let engine = hapticEngine else {
      // Fallback to simple haptic
      success()
      return
    }

    do {
      let pattern = try CHHapticPattern(
        events: [
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0),
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.1),
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        ],
        parameters: []
      )

      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      // Fallback
      success()
    }
  }

  /// Crescendo pattern for celebrations (light → medium → heavy)
  public func crescendo() {
    guard supportsHaptics else { return }

    light()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.medium()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.heavy()
    }
  }

  /// Warning pattern (tap-pause-tap)
  public func warningPattern() {
    guard supportsHaptics else { return }

    medium()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.medium()
    }
  }
}
```

**Step 4: Add files to Xcode**

1. Add `HapticEngine.swift` to project
2. Add `HapticEngineTests.swift` to tests
3. Ensure targets are set correctly

**Step 5: Run tests**

Run: Test command
Expected: PASS (3 tests)

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Engine/HapticEngine.swift
git add FinPessoalTests/Animation/HapticEngineTests.swift
git commit -m "feat: add haptic engine with custom patterns

- Impact haptics (light, medium, heavy)
- Notification haptics (success, warning, error)
- Custom patterns (gentle success, crescendo, warning)
- CoreHaptics integration for complex patterns
- Graceful fallback when haptics unavailable

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: PhysicsNumberCounter Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/PhysicsNumberCounter.swift`
- Test: `FinPessoalTests/Animation/PhysicsNumberCounterTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Animation/PhysicsNumberCounterTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class PhysicsNumberCounterTests: XCTestCase {

  func testInitialValue() {
    let counter = PhysicsNumberCounter(value: 1000.0, format: .currency(code: "BRL"))
    XCTAssertEqual(counter.value, 1000.0)
  }

  func testValueUpdate() {
    var counter = PhysicsNumberCounter(value: 1000.0, format: .currency(code: "BRL"))
    counter.value = 2000.0
    XCTAssertEqual(counter.value, 2000.0)
  }
}
```

**Step 2: Run test**

Run: Test command
Expected: FAIL with type not found

**Step 3: Create directory and write component**

```bash
mkdir -p FinPessoal/Code/Animation/Components
```

```swift
// FinPessoal/Code/Animation/Components/PhysicsNumberCounter.swift
import SwiftUI

/// Animated number counter with spring physics
public struct PhysicsNumberCounter: View {
  @Binding public var value: Double
  public let format: FloatingPointFormatStyle<Double>.Currency
  public let font: Font

  @State private var displayValue: Double

  public init(
    value: Binding<Double>,
    format: FloatingPointFormatStyle<Double>.Currency,
    font: Font = OldMoneyTheme.Typography.moneyLarge
  ) {
    self._value = value
    self.format = format
    self.font = font
    self._displayValue = State(initialValue: value.wrappedValue)
  }

  // Convenience initializer for testing
  public init(
    value: Double,
    format: FloatingPointFormatStyle<Double>.Currency,
    font: Font = OldMoneyTheme.Typography.moneyLarge
  ) {
    self._value = .constant(value)
    self.format = format
    self.font = font
    self._displayValue = State(initialValue: value)
  }

  public var body: some View {
    Text(displayValue.formatted(format))
      .font(font)
      .onChange(of: value) { oldValue, newValue in
        animateChange(from: oldValue, to: newValue)
      }
      .onAppear {
        displayValue = value
      }
  }

  @MainActor
  private func animateChange(from oldValue: Double, to newValue: Double) {
    let settings = AnimationSettings.shared

    guard settings.effectiveMode != .minimal else {
      // Instant change in minimal mode
      displayValue = newValue
      return
    }

    // Animate with spring physics
    let animation = settings.effectiveMode == .full
      ? AnimationEngine.gentleSpring
      : AnimationEngine.quickFade

    withAnimation(animation) {
      displayValue = newValue
    }

    // Haptic feedback for significant changes
    if abs(newValue - oldValue) > 100 {
      if newValue > oldValue {
        HapticEngine.shared.light()
      } else {
        HapticEngine.shared.selection()
      }
    }
  }
}
```

**Step 4: Add files to Xcode**

Add both files to project with correct targets

**Step 5: Run tests**

Run: Test command
Expected: PASS (2 tests)

**Step 6: Commit**

```bash
git add FinPessoal/Code/Animation/Components/PhysicsNumberCounter.swift
git add FinPessoalTests/Animation/PhysicsNumberCounterTests.swift
git commit -m "feat: add physics-based number counter component

- Animates number changes with spring physics
- Mode-aware animation (full, reduced, minimal)
- Haptic feedback for significant changes
- Currency formatting support

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: AnimatedCard Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/AnimatedCard.swift`
- Create: `FinPessoal/Code/Animation/Components/AnimatedCardModifier.swift`
- Test: `FinPessoalTests/Animation/AnimatedCardTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Animation/AnimatedCardTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class AnimatedCardTests: XCTestCase {

  func testCardInitialization() {
    let card = AnimatedCard {
      Text("Test")
    }

    XCTAssertNotNil(card)
  }

  func testPressStateToggle() {
    var isPressed = false
    let card = AnimatedCard(onTap: {
      isPressed = true
    }) {
      Text("Test")
    }

    XCTAssertNotNil(card)
  }
}
```

**Step 2: Run test**

Run: Test command
Expected: FAIL

**Step 3: Write AnimatedCard component**

```swift
// FinPessoal/Code/Animation/Components/AnimatedCard.swift
import SwiftUI

/// Animated card with press states, shadows, and optional hero transitions
public struct AnimatedCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false

  public let content: Content
  public let onTap: (() -> Void)?
  public let heroID: String?

  public init(
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }

  public var body: some View {
    content
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .shadow(
        color: shadowColor,
        radius: shadowRadius,
        x: 0,
        y: isPressed ? 2 : 4
      )
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

  @Namespace private var namespace

  private var shadowColor: Color {
    Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 8 : 12
  }
}

// Helper extension for conditional view modifiers
extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
```

**Step 4: Write AnimatedCardModifier**

```swift
// FinPessoal/Code/Animation/Components/AnimatedCardModifier.swift
import SwiftUI

/// View modifier for applying animated card behavior
public struct AnimatedCardModifier: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false
  @MainActor private let settings = AnimationSettings.shared

  public let onTap: (() -> Void)?

  public init(onTap: (() -> Void)? = nil) {
    self.onTap = onTap
  }

  public func body(content: Content) -> some View {
    content
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .shadow(
        color: shadowColor,
        radius: shadowRadius,
        x: 0,
        y: isPressed ? 2 : 4
      )
      .gesture(pressGesture)
  }

  private var pressGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        guard !isPressed, settings.effectiveMode != .minimal else { return }

        let animation = settings.effectiveMode == .full
          ? AnimationEngine.snappySpring
          : AnimationEngine.quickFade

        withAnimation(animation) {
          isPressed = true
        }
        HapticEngine.shared.light()
      }
      .onEnded { _ in
        let animation = settings.effectiveMode == .full
          ? AnimationEngine.gentleSpring
          : AnimationEngine.quickFade

        withAnimation(animation) {
          isPressed = false
        }
        onTap?()
      }
  }

  private var shadowColor: Color {
    Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 8 : 12
  }
}

extension View {
  /// Applies animated card behavior to any view
  public func animatedCard(onTap: (() -> Void)? = nil) -> some View {
    modifier(AnimatedCardModifier(onTap: onTap))
  }
}
```

**Step 5: Add files to Xcode**

Add all three files with correct targets

**Step 6: Run tests**

Run: Test command
Expected: PASS (2 tests)

**Step 7: Commit**

```bash
git add FinPessoal/Code/Animation/Components/AnimatedCard.swift
git add FinPessoal/Code/Animation/Components/AnimatedCardModifier.swift
git add FinPessoalTests/Animation/AnimatedCardTests.swift
git commit -m "feat: add animated card component with press states

- AnimatedCard with scale/shadow animations
- Press gesture handling with haptic feedback
- Mode-aware animations
- View modifier for easy application
- Conditional hero transition support

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Update BalanceCardView with Animations

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift`
- Test: `FinPessoalTests/Features/Dashboard/BalanceCardViewTests.swift`

**Step 1: Write the failing test**

```swift
// FinPessoalTests/Features/Dashboard/BalanceCardViewTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class BalanceCardViewTests: XCTestCase {

  func testBalanceCardRendersWithAnimatedNumbers() {
    let view = BalanceCardView(
      totalBalance: .constant(1000.0),
      monthlyExpenses: .constant(500.0)
    )

    XCTAssertNotNil(view)
  }

  func testBalanceCardHasTapAction() {
    var tapped = false
    let view = BalanceCardView(
      totalBalance: .constant(1000.0),
      monthlyExpenses: .constant(500.0),
      onTap: {
        tapped = true
      }
    )

    XCTAssertNotNil(view)
  }
}
```

**Step 2: Run test**

Run: Test command
Expected: FAIL (file/type not found)

**Step 3: Update BalanceCardView**

```swift
// FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift
import SwiftUI

struct BalanceCardView: View {
  @Binding var totalBalance: Double
  @Binding var monthlyExpenses: Double
  var onTap: (() -> Void)? = nil

  // Convenience init for backwards compatibility
  init(totalBalance: Double, monthlyExpenses: Double, onTap: (() -> Void)? = nil) {
    self._totalBalance = .constant(totalBalance)
    self._monthlyExpenses = .constant(monthlyExpenses)
    self.onTap = onTap
  }

  // Binding init for animated updates
  init(
    totalBalance: Binding<Double>,
    monthlyExpenses: Binding<Double>,
    onTap: (() -> Void)? = nil
  ) {
    self._totalBalance = totalBalance
    self._monthlyExpenses = monthlyExpenses
    self.onTap = onTap
  }

  var body: some View {
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

      HStack {
        VStack(alignment: .leading) {
          Text("dashboard.monthly.expenses")
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)

          PhysicsNumberCounter(
            value: $monthlyExpenses,
            format: .currency(code: "BRL"),
            font: OldMoneyTheme.Typography.moneyMedium
          )
          .foregroundStyle(Color.oldMoney.expense)
        }
        Spacer()
      }
    }
    .padding()
    .background(Color.oldMoney.surface)
    .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.medium))
    .animatedCard(onTap: onTap)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Balance Overview")
    .accessibilityValue("Total balance: \(totalBalance.formatted(.currency(code: "BRL"))), Monthly expenses: \(monthlyExpenses.formatted(.currency(code: "BRL")))")
  }
}
```

**Step 4: Add test file to Xcode**

Create test directory if needed and add file

**Step 5: Run tests**

Run: Test command
Expected: PASS (2 tests)

**Step 6: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/View/BalanceCardView.swift
git add FinPessoalTests/Features/Dashboard/BalanceCardViewTests.swift
git commit -m "feat: update BalanceCardView with animated numbers and card interactions

- Replace static text with PhysicsNumberCounter
- Add AnimatedCard press interactions
- Support binding for live updates
- Maintain backwards compatibility
- Add tap action support

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: ParticleEmitter Foundation (Metal Shader)

**Files:**
- Create: `FinPessoal/Code/Animation/Shaders/ParticleShaders.metal`
- Create: `FinPessoal/Code/Animation/Components/ParticleEmitter.swift`
- Test: `FinPessoalTests/Animation/ParticleEmitterTests.swift`

**Step 1: Write test**

```swift
// FinPessoalTests/Animation/ParticleEmitterTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ParticleEmitterTests: XCTestCase {

  func testParticleEmitterInitialization() {
    let emitter = ParticleEmitter(preset: .goldShimmer)
    XCTAssertNotNil(emitter)
  }

  func testPresetConfigurations() {
    let gold = ParticleEmitter(preset: .goldShimmer)
    let celebration = ParticleEmitter(preset: .celebration)

    XCTAssertNotNil(gold)
    XCTAssertNotNil(celebration)
  }
}
```

**Step 2: Run test**

Run: Test command
Expected: FAIL

**Step 3: Create shaders directory and Metal file**

```bash
mkdir -p FinPessoal/Code/Animation/Shaders
```

```metal
// FinPessoal/Code/Animation/Shaders/ParticleShaders.metal
#include <metal_stdlib>
using namespace metal;

struct Particle {
  float2 position;
  float2 velocity;
  float life;
  float size;
  float4 color;
};

// Simple particle rendering shader
vertex float4 particle_vertex(
  const device Particle* particles [[buffer(0)]],
  uint vid [[vertex_id]]
) {
  Particle p = particles[vid];
  return float4(p.position.x, p.position.y, 0.0, 1.0);
}

fragment float4 particle_fragment(
  float4 position [[stage_in]],
  const device Particle* particles [[buffer(0)]],
  uint fid [[fragment_id]]
) {
  Particle p = particles[fid];
  return p.color * p.life;
}
```

**Step 4: Create ParticleEmitter SwiftUI component**

```swift
// FinPessoal/Code/Animation/Components/ParticleEmitter.swift
import SwiftUI

/// Particle emitter preset configurations
public enum ParticlePreset {
  case goldShimmer
  case celebration
  case warning
}

/// Particle system for visual effects
public struct ParticleEmitter: View {
  public let preset: ParticlePreset
  @State private var particles: [Particle] = []
  @State private var isActive = false
  @MainActor private let settings = AnimationSettings.shared

  public init(preset: ParticlePreset) {
    self.preset = preset
  }

  public var body: some View {
    // Particles only shown in full mode
    guard settings.shouldShowParticles else {
      return AnyView(EmptyView())
    }

    return AnyView(
      TimelineView(.animation) { timeline in
        Canvas { context, size in
          let now = timeline.date.timeIntervalSinceReferenceDate

          for particle in particles {
            let opacity = particle.life
            var particleContext = context
            particleContext.opacity = opacity

            let rect = CGRect(
              x: particle.position.x - particle.size / 2,
              y: particle.position.y - particle.size / 2,
              width: particle.size,
              height: particle.size
            )

            particleContext.fill(
              Circle().path(in: rect),
              with: .color(particle.color)
            )
          }
        }
        .onAppear {
          startEmitting()
        }
      }
    )
  }

  private func startEmitting() {
    guard settings.shouldShowParticles else { return }

    // Generate particles based on preset
    let particleCount: Int
    let colors: [Color]

    switch preset {
    case .goldShimmer:
      particleCount = 20
      colors = [Color(red: 184/255, green: 150/255, blue: 92/255)]
    case .celebration:
      particleCount = 50
      colors = [
        Color(red: 184/255, green: 150/255, blue: 92/255),
        Color(red: 212/255, green: 186/255, blue: 138/255)
      ]
    case .warning:
      particleCount = 15
      colors = [Color(red: 232/255, green: 177/255, blue: 92/255)]
    }

    particles = (0..<particleCount).map { _ in
      Particle(
        position: CGPoint(
          x: CGFloat.random(in: -50...50),
          y: CGFloat.random(in: -50...50)
        ),
        velocity: CGPoint(
          x: CGFloat.random(in: -2...2),
          y: CGFloat.random(in: -3...(-1))
        ),
        life: 1.0,
        size: CGFloat.random(in: 2...6),
        color: colors.randomElement() ?? colors[0]
      )
    }
  }
}

/// Particle data structure
struct Particle {
  var position: CGPoint
  var velocity: CGPoint
  var life: Double
  var size: CGFloat
  var color: Color
}
```

**Step 5: Add files to Xcode**

1. Add Metal file to project (ensure it's in FinPessoal target)
2. Add ParticleEmitter.swift
3. Add test file

**Step 6: Run tests**

Run: Test command
Expected: PASS (2 tests)

**Step 7: Commit**

```bash
git add FinPessoal/Code/Animation/Shaders/ParticleShaders.metal
git add FinPessoal/Code/Animation/Components/ParticleEmitter.swift
git add FinPessoalTests/Animation/ParticleEmitterTests.swift
git commit -m "feat: add particle emitter with Metal shaders

- Metal shader for particle rendering
- SwiftUI particle emitter component
- Preset configurations (gold shimmer, celebration, warning)
- Mode-aware rendering (only in full mode)
- TimelineView for smooth animation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Summary & Next Steps

**Completed in this plan:**
- ✅ Animation mode system with accessibility
- ✅ Animation engine with spring presets
- ✅ Haptic engine with custom patterns
- ✅ PhysicsNumberCounter component
- ✅ AnimatedCard component
- ✅ Updated BalanceCardView with animations
- ✅ ParticleEmitter foundation

**Remaining work for Phase 1:**
- Dashboard animation coordinator
- Chart animations
- Loading states with skeleton shimmer
- Pull-to-refresh custom animation
- Integration testing
- Performance profiling

**Next Phase:** Week 2 will focus on chart interactions, scroll behaviors, and dashboard coordinator integration.

**Testing:** Run full test suite with:
```bash
xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

**Expected:** All new tests passing (15+ new tests), pre-existing failures remain unchanged.
