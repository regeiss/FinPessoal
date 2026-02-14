// FinPessoalTests/Animation/ChartModelsTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class ChartModelsTests: XCTestCase {

  func testChartSegmentInitialization() {
    let segment = ChartSegment(
      id: "test-1",
      value: 500.0,
      percentage: 25.0,
      label: "Food",
      color: .blue,
      category: nil
    )

    XCTAssertEqual(segment.id, "test-1")
    XCTAssertEqual(segment.value, 500.0)
    XCTAssertEqual(segment.percentage, 25.0)
    XCTAssertEqual(segment.label, "Food")
    XCTAssertEqual(segment.trimEnd, 0) // Default animation state
    XCTAssertEqual(segment.opacity, 1.0)
  }

  func testChartBarInitialization() {
    let bar = ChartBar(
      id: "2026-01",
      value: 1500.0,
      maxValue: 2000.0,
      label: "January",
      color: .green,
      date: nil
    )

    XCTAssertEqual(bar.id, "2026-01")
    XCTAssertEqual(bar.value, 1500.0)
    XCTAssertEqual(bar.maxValue, 2000.0)
    XCTAssertEqual(bar.height, 0) // Default animation state
    XCTAssertEqual(bar.opacity, 0)
  }
}
