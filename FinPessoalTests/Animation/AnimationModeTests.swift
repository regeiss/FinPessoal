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
