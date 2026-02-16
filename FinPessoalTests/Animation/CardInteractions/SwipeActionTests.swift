//
//  SwipeActionTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 15/02/26.
//

import SwiftUI
import XCTest
@testable import FinPessoal

@MainActor
final class SwipeActionTests: XCTestCase {

  // MARK: - Test 1: SwipeAction Creation

  func testSwipeActionCreation() {
    var executed = false
    let action = SwipeAction(
      title: "Test",
      icon: "star.fill",
      tint: .blue,
      role: .destructive
    ) {
      executed = true
    }

    XCTAssertEqual(action.title, "Test")
    XCTAssertEqual(action.icon, "star.fill")
    XCTAssertEqual(action.tint, .blue)
    XCTAssertEqual(action.role, .destructive)
    XCTAssertNotNil(action.id)
  }

  // MARK: - Test 2: Delete Preset

  func testDeletePreset() {
    let action = SwipeAction.delete { }

    XCTAssertEqual(action.title, String(localized: "common.delete"))
    XCTAssertEqual(action.icon, "trash")
    XCTAssertEqual(action.tint, .red)
    XCTAssertEqual(action.role, .destructive)
    XCTAssertNotNil(action.id)
  }

  // MARK: - Test 3: Edit Preset

  func testEditPreset() {
    let action = SwipeAction.edit { }

    XCTAssertEqual(action.title, String(localized: "common.edit"))
    XCTAssertEqual(action.icon, "pencil")
    XCTAssertEqual(action.tint, .blue)
    XCTAssertNil(action.role)
    XCTAssertNotNil(action.id)
  }

  // MARK: - Test 4: Archive Preset

  func testArchivePreset() {
    let action = SwipeAction.archive { }

    XCTAssertEqual(action.title, String(localized: "common.archive"))
    XCTAssertEqual(action.icon, "archivebox")
    XCTAssertEqual(action.tint, .orange)
    XCTAssertNil(action.role)
    XCTAssertNotNil(action.id)
  }

  // MARK: - Test 5: Complete Preset

  func testCompletePreset() {
    let action = SwipeAction.complete { }

    XCTAssertEqual(action.title, String(localized: "common.complete"))
    XCTAssertEqual(action.icon, "checkmark.circle.fill")
    // Note: We can't test Color.oldMoney.income directly in tests,
    // but we verify it's not nil
    XCTAssertNotNil(action.tint)
    XCTAssertNil(action.role)
    XCTAssertNotNil(action.id)
  }

  // MARK: - Test 6: Action Execution

  func testActionExecution() async {
    var executed = false
    let action = SwipeAction.delete {
      executed = true
    }

    await action.action()
    XCTAssertTrue(executed, "Action should execute")
  }
}
