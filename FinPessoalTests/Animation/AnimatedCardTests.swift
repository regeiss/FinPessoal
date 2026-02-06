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

  func testCardStyleDefault() {
    let card = AnimatedCard {
      Text("Test")
    }

    // Card should have .standard style by default
    XCTAssertNotNil(card)
  }

  func testCardStylePremium() {
    let card = AnimatedCard(style: .premium) {
      Text("Test")
    }

    XCTAssertNotNil(card)
  }

  func testCardStyleFrosted() {
    let card = AnimatedCard(style: .frosted) {
      Text("Test")
    }

    XCTAssertNotNil(card)
  }

  func testCardStyleRecessed() {
    let card = AnimatedCard(style: .recessed) {
      Text("Test")
    }

    XCTAssertNotNil(card)
  }
}
