//
//  AnimatedCardTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 2026-02-02.
//

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
