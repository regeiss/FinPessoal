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
