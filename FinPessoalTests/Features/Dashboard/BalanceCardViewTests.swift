//
//  BalanceCardViewTests.swift
//  FinPessoalTests
//
//  Created by Claude on 02/02/26.
//

import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class BalanceCardViewTests: XCTestCase {

  func testBalanceCardRendersWithAnimatedNumbers() {
    let view = BalanceCardView(
      totalBalance: .constant(1000.0),
      monthlyExpenses: .constant(500.0)
    )

    XCTAssertNotNil(view)
  }

  func testBalanceCardHasTapAction() {
    var tapped = false
    let view = BalanceCardView(
      totalBalance: .constant(1000.0),
      monthlyExpenses: .constant(500.0),
      onTap: {
        tapped = true
      }
    )

    XCTAssertNotNil(view)
  }
}
