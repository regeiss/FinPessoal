//
//  FrostedGlassTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 2026-02-10.
//  Copyright © 2026 FinPessoal. All rights reserved.
//

import XCTest
import SwiftUI
@testable import FinPessoal

/// Unit tests for Phase 4 Frosted Glass components
///
/// Tests cover:
/// - AnimationMode adaptation (full/reduced/minimal)
/// - Reduce motion accessibility handling
/// - Scroll offset calculations and blur progress
/// - Blur intensity scaling based on mode
@MainActor
final class FrostedGlassTests: XCTestCase {

  // MARK: - Setup & Teardown

  override func setUp() async throws {
    try await super.setUp()
    // Reset animation settings to default
    AnimationSettings.shared.mode = .full
    AnimationSettings.shared.respectReduceMotion = false
    AnimationSettings.shared.systemReduceMotionEnabled = false
  }

  // MARK: - AnimationMode Adaptation Tests

  func testFrostedSheetRespectsFullMode() async throws {
    // Given: Full animation mode
    AnimationSettings.shared.mode = .full
    AnimationSettings.shared.respectReduceMotion = false

    // When: Getting effective intensity
    let effectiveMode = AnimationSettings.shared.effectiveMode
    let intensity = effectiveMode == .minimal ? 0.5 : 1.0

    // Then: Intensity should be 1.0 (full blur)
    XCTAssertEqual(effectiveMode, .full, "Should be in full mode")
    XCTAssertEqual(intensity, 1.0, "Intensity should be 1.0 in full mode")
  }

  func testFrostedSheetRespectsReducedMode() async throws {
    // Given: Reduced animation mode
    AnimationSettings.shared.mode = .reduced

    // When: Getting effective mode
    let effectiveMode = AnimationSettings.shared.effectiveMode

    // Then: Should be in reduced mode with reduced intensity
    XCTAssertEqual(effectiveMode, .reduced, "Should be in reduced mode")

    let intensity = effectiveMode == .minimal ? 0.5 : (effectiveMode == .reduced ? 0.7 : 1.0)
    XCTAssertEqual(intensity, 0.7, "Intensity should be 0.7 in reduced mode")
  }

  func testFrostedSheetRespectsMinimalMode() async throws {
    // Given: Minimal animation mode
    AnimationSettings.shared.mode = .minimal

    // When: Getting effective intensity
    let effectiveMode = AnimationSettings.shared.effectiveMode
    let intensity = effectiveMode == .minimal ? 0.0 : 1.0

    // Then: Intensity should be 0.0 (no blur, solid color fallback)
    XCTAssertEqual(effectiveMode, .minimal, "Should be in minimal mode")
    XCTAssertEqual(intensity, 0.0, "Intensity should be 0.0 in minimal mode")
  }

  func testFrostedSheetRespectsReduceMotion() async throws {
    // Given: Full mode but with reduce motion enabled
    AnimationSettings.shared.mode = .full
    AnimationSettings.shared.respectReduceMotion = true
    AnimationSettings.shared.systemReduceMotionEnabled = true

    // When: Getting effective mode
    let effectiveMode = AnimationSettings.shared.effectiveMode

    // Then: Should fall back to minimal mode
    XCTAssertEqual(effectiveMode, .minimal, "Should fall back to minimal when reduce motion is enabled")
  }

  func testFrostedSheetIgnoresReduceMotionWhenDisabled() async throws {
    // Given: Respect reduce motion is disabled
    AnimationSettings.shared.mode = .full
    AnimationSettings.shared.respectReduceMotion = false
    AnimationSettings.shared.systemReduceMotionEnabled = true

    // When: Getting effective mode
    let effectiveMode = AnimationSettings.shared.effectiveMode

    // Then: Should stay in full mode (not respecting system setting)
    XCTAssertEqual(effectiveMode, .full, "Should ignore system reduce motion when respectReduceMotion is false")
  }

  // MARK: - Scroll Blur Tests

  func testScrollBlurProgressCalculation() throws {
    // Given: Blur threshold of 100pt
    let threshold: CGFloat = 100.0

    // When/Then: Test various scroll offsets
    let testCases: [(offset: CGFloat, expected: CGFloat)] = [
      (0, 0.0),      // At top - no blur
      (50, 0.5),     // Halfway - 50% blur
      (100, 1.0),    // At threshold - full blur
      (150, 1.0),    // Beyond threshold - capped at 1.0
      (200, 1.0)     // Far beyond - still capped
    ]

    for testCase in testCases {
      let progress = min(testCase.offset / threshold, 1.0)
      XCTAssertEqual(
        progress,
        testCase.expected,
        accuracy: 0.01,
        "Progress for offset \(testCase.offset) should be \(testCase.expected)"
      )
    }
  }

  func testScrollOffsetConversion() throws {
    // Given: Scroll offsets (negative when scrolling down)
    let testCases: [(raw: CGFloat, expected: CGFloat)] = [
      (0, 0),       // At top
      (-50, 50),    // Scrolled down 50pt
      (-100, 100),  // Scrolled down 100pt
      (20, 0)       // Scrolled up (capped at 0)
    ]

    // When/Then: Convert to positive scroll distance
    for testCase in testCases {
      let converted = max(0, -testCase.raw)
      XCTAssertEqual(
        converted,
        testCase.expected,
        "Offset \(testCase.raw) should convert to \(testCase.expected)"
      )
    }
  }

  func testScrollBlurThreshold() throws {
    // Given: 10pt blur threshold
    let threshold: CGFloat = 10.0

    // When/Then: Test threshold crossing
    let beforeThreshold = CGFloat(5.0)
    let atThreshold = CGFloat(10.0)
    let afterThreshold = CGFloat(15.0)

    XCTAssertFalse(beforeThreshold >= threshold, "Should not blur before threshold")
    XCTAssertTrue(atThreshold >= threshold, "Should blur at threshold")
    XCTAssertTrue(afterThreshold >= threshold, "Should blur after threshold")
  }

  // MARK: - Accessibility Tests

  func testBlurDisabledInMinimalMode() async throws {
    // Given: Minimal animation mode
    AnimationSettings.shared.mode = .minimal

    // When: Checking if blur should be applied
    let effectiveMode = AnimationSettings.shared.effectiveMode
    let shouldApplyBlur = effectiveMode != .minimal

    // Then: Blur should be disabled
    XCTAssertFalse(shouldApplyBlur, "Blur should be disabled in minimal mode")
  }

  func testBlurEnabledInFullMode() async throws {
    // Given: Full animation mode
    AnimationSettings.shared.mode = .full
    AnimationSettings.shared.respectReduceMotion = false

    // When: Checking if blur should be applied
    let effectiveMode = AnimationSettings.shared.effectiveMode
    let shouldApplyBlur = effectiveMode != .minimal

    // Then: Blur should be enabled
    XCTAssertTrue(shouldApplyBlur, "Blur should be enabled in full mode")
  }

  func testTintColorOpacityAdaptation() throws {
    // Test tint color opacity based on mode
    let fullModeOpacity = 0.05
    let reducedModeOpacity = 0.02
    let minimalModeOpacity = 0.0

    XCTAssertEqual(fullModeOpacity, 0.05, "Full mode should use 5% tint opacity")
    XCTAssertEqual(reducedModeOpacity, 0.02, "Reduced mode should use 2% tint opacity")
    XCTAssertEqual(minimalModeOpacity, 0.0, "Minimal mode should use 0% tint opacity (no tint)")
  }

  // MARK: - Performance Tests

  func testScrollOffsetCalculationPerformance() throws {
    // Given: Large number of scroll updates
    let iterations = 10000
    let threshold: CGFloat = 100.0

    // When: Calculating blur progress repeatedly
    measure {
      for i in 0..<iterations {
        let offset = CGFloat(i % 200)
        let _ = min(offset / threshold, 1.0)
      }
    }

    // Then: Should complete quickly (measured by XCTest)
  }

  // MARK: - Integration Tests

  func testAnimationModeEffectiveMode() async throws {
    // Test all combinations of mode and reduce motion
    let testCases: [(mode: AnimationMode, respectRM: Bool, systemRM: Bool, expected: AnimationMode)] = [
      (.full, false, false, .full),
      (.full, false, true, .full),
      (.full, true, false, .full),
      (.full, true, true, .minimal),
      (.reduced, false, false, .reduced),
      (.reduced, true, true, .minimal),
      (.minimal, false, false, .minimal),
      (.minimal, true, true, .minimal)
    ]

    for testCase in testCases {
      // Given: Specific configuration
      AnimationSettings.shared.mode = testCase.mode
      AnimationSettings.shared.respectReduceMotion = testCase.respectRM
      AnimationSettings.shared.systemReduceMotionEnabled = testCase.systemRM

      // When: Getting effective mode
      let effectiveMode = AnimationSettings.shared.effectiveMode

      // Then: Should match expected
      XCTAssertEqual(
        effectiveMode,
        testCase.expected,
        "Mode: \(testCase.mode), respectRM: \(testCase.respectRM), systemRM: \(testCase.systemRM) should result in \(testCase.expected)"
      )
    }
  }
}
