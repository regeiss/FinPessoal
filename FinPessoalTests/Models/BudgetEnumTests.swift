//
//  BudgetEnumTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 26/10/25.
//

import XCTest
@testable import FinPessoal

final class BudgetEnumTests: XCTestCase {

  // MARK: - BudgetPeriod Tests

  func testBudgetPeriodRawValues() throws {
    XCTAssertEqual(BudgetPeriod.weekly.rawValue, "Semanal")
    XCTAssertEqual(BudgetPeriod.monthly.rawValue, "Mensal")
    XCTAssertEqual(BudgetPeriod.quarterly.rawValue, "Trimestral")
    XCTAssertEqual(BudgetPeriod.yearly.rawValue, "Anual")
  }

  func testBudgetPeriodIcons() throws {
    XCTAssertEqual(BudgetPeriod.weekly.icon, "calendar.badge.clock")
    XCTAssertEqual(BudgetPeriod.monthly.icon, "calendar")
    XCTAssertEqual(BudgetPeriod.quarterly.icon, "calendar.badge.plus")
    XCTAssertEqual(BudgetPeriod.yearly.icon, "calendar.circle")
  }

  func testBudgetPeriodDisplayNames() throws {
    XCTAssertFalse(BudgetPeriod.weekly.displayName.isEmpty)
    XCTAssertFalse(BudgetPeriod.monthly.displayName.isEmpty)
    XCTAssertFalse(BudgetPeriod.quarterly.displayName.isEmpty)
    XCTAssertFalse(BudgetPeriod.yearly.displayName.isEmpty)
  }

  func testBudgetPeriodCodable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for period in BudgetPeriod.allCases {
      let encoded = try encoder.encode(period)
      let decoded = try decoder.decode(BudgetPeriod.self, from: encoded)
      XCTAssertEqual(period, decoded)
    }
  }

  // MARK: - Next Period Start Tests

  func testWeeklyNextPeriodStart() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 10, day: 26).date!

    let nextPeriodStart = BudgetPeriod.weekly.nextPeriodStart(from: startDate)

    let expectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
    XCTAssertEqual(calendar.component(.day, from: nextPeriodStart), calendar.component(.day, from: expectedDate))
    XCTAssertEqual(calendar.component(.month, from: nextPeriodStart), calendar.component(.month, from: expectedDate))
  }

  func testMonthlyNextPeriodStart() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 10, day: 15).date!

    let nextPeriodStart = BudgetPeriod.monthly.nextPeriodStart(from: startDate)

    let expectedDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
    XCTAssertEqual(calendar.component(.day, from: nextPeriodStart), calendar.component(.day, from: expectedDate))
    XCTAssertEqual(calendar.component(.month, from: nextPeriodStart), calendar.component(.month, from: expectedDate))
  }

  func testQuarterlyNextPeriodStart() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 1).date!

    let nextPeriodStart = BudgetPeriod.quarterly.nextPeriodStart(from: startDate)

    let expectedDate = calendar.date(byAdding: .month, value: 3, to: startDate)!
    XCTAssertEqual(calendar.component(.day, from: nextPeriodStart), calendar.component(.day, from: expectedDate))
    XCTAssertEqual(calendar.component(.month, from: nextPeriodStart), 4) // April
  }

  func testYearlyNextPeriodStart() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 1).date!

    let nextPeriodStart = BudgetPeriod.yearly.nextPeriodStart(from: startDate)

    let expectedDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
    XCTAssertEqual(calendar.component(.year, from: nextPeriodStart), calendar.component(.year, from: expectedDate))
    XCTAssertEqual(calendar.component(.year, from: nextPeriodStart), 2026)
  }

  func testNextPeriodStartWithLeapYear() throws {
    let calendar = Calendar.current
    // February 29, 2024 (leap year)
    let leapDate = DateComponents(calendar: calendar, year: 2024, month: 2, day: 29).date!

    let nextYear = BudgetPeriod.yearly.nextPeriodStart(from: leapDate)

    // Should handle the non-leap year correctly
    XCTAssertEqual(calendar.component(.year, from: nextYear), 2025)
    // February 28 or 29 depending on calendar handling
    XCTAssertTrue([28, 29].contains(calendar.component(.day, from: nextYear)))
  }

  func testNextPeriodStartAcrossMonthBoundary() throws {
    let calendar = Calendar.current
    let endOfMonth = DateComponents(calendar: calendar, year: 2025, month: 1, day: 31).date!

    let nextMonth = BudgetPeriod.monthly.nextPeriodStart(from: endOfMonth)

    // Should be end of February (28 or 29 days)
    XCTAssertEqual(calendar.component(.month, from: nextMonth), 2)
    XCTAssertTrue([28, 29].contains(calendar.component(.day, from: nextMonth)))
  }

  // MARK: - Edge Cases

  func testAllPeriodsHaveValidIcons() throws {
    for period in BudgetPeriod.allCases {
      XCTAssertFalse(period.icon.isEmpty, "Period \(period) should have a non-empty icon")
    }
  }

  func testAllPeriodsHaveValidDisplayNames() throws {
    for period in BudgetPeriod.allCases {
      XCTAssertFalse(period.displayName.isEmpty, "Period \(period) should have a non-empty display name")
    }
  }

  func testNextPeriodStartIsAlwaysInFuture() throws {
    let now = Date()

    for period in BudgetPeriod.allCases {
      let nextPeriodStart = period.nextPeriodStart(from: now)
      XCTAssertTrue(nextPeriodStart > now, "Next period start for \(period) should be in the future")
    }
  }
}
