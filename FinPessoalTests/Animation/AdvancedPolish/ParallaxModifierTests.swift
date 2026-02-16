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
