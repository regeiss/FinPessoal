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
