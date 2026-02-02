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

  @MainActor
  func testAnimationForMode() {
    let fullAnimation = AnimationEngine.animation(for: .full, base: AnimationEngine.gentleSpring)
    let minimalAnimation = AnimationEngine.animation(for: .minimal, base: AnimationEngine.gentleSpring)

    XCTAssertNotNil(fullAnimation)
    XCTAssertNil(minimalAnimation)  // Minimal mode returns nil (no animation)
  }
}
