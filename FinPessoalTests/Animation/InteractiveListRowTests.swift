//
//  InteractiveListRowTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 07/02/26.
//

import SwiftUI
import XCTest
@testable import FinPessoal

@MainActor
final class InteractiveListRowTests: XCTestCase {

  func testRowActionPresets() {
    // Test delete preset
    let deleteAction = RowAction.delete { }
    XCTAssertEqual(deleteAction.title, "Delete")
    XCTAssertEqual(deleteAction.icon, "trash")
    XCTAssertEqual(deleteAction.role, .destructive)

    // Test edit preset
    let editAction = RowAction.edit { }
    XCTAssertEqual(editAction.title, "Edit")
    XCTAssertEqual(editAction.icon, "pencil")
    XCTAssertNil(editAction.role)

    // Test complete preset
    let completeAction = RowAction.complete { }
    XCTAssertEqual(completeAction.title, "Complete")
    XCTAssertEqual(completeAction.icon, "checkmark.circle.fill")
  }

  func testRowActionExecution() async {
    var executed = false
    let action = RowAction.delete {
      executed = true
    }

    await action.action()
    XCTAssertTrue(executed, "Action should execute")
  }
}
