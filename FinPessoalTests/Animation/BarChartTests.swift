// FinPessoalTests/Animation/BarChartTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class BarChartTests: XCTestCase {

  func testCalculateHeight() {
    // Given: bar with value=1500, maxValue=2000, maxHeight=200
    let bar = ChartBar(
      id: "test",
      value: 1500,
      maxValue: 2000,
      label: "Test",
      color: .blue,
      date: nil
    )

    // When: calculating height
    let height = BarChart.calculateHeight(for: bar, maxHeight: 200)

    // Then: should return 150 (1500/2000 * 200)
    XCTAssertEqual(height, 150, accuracy: 0.01)
  }

  func testCalculateHeightWithZeroMaxValue() {
    // Given: bar with zero maxValue
    let bar = ChartBar(
      id: "test",
      value: 100,
      maxValue: 0,
      label: "Test",
      color: .blue,
      date: nil
    )

    // When: calculating height
    let height = BarChart.calculateHeight(for: bar, maxHeight: 200)

    // Then: should return 0 to avoid division by zero
    XCTAssertEqual(height, 0)
  }

  func testCalculateHeightWithZeroValue() {
    // Given: bar with zero value
    let bar = ChartBar(
      id: "test",
      value: 0,
      maxValue: 2000,
      label: "Test",
      color: .blue,
      date: nil
    )

    // When: calculating height
    let height = BarChart.calculateHeight(for: bar, maxHeight: 200)

    // Then: should return 0
    XCTAssertEqual(height, 0)
  }

  func testCalculateHeightWithMaxValue() {
    // Given: bar with value equal to maxValue
    let bar = ChartBar(
      id: "test",
      value: 2000,
      maxValue: 2000,
      label: "Test",
      color: .blue,
      date: nil
    )

    // When: calculating height
    let height = BarChart.calculateHeight(for: bar, maxHeight: 200)

    // Then: should return maxHeight
    XCTAssertEqual(height, 200)
  }

  func testEmptyBarsArray() {
    // Given: empty bars array
    let bars: [ChartBar] = []

    // When: creating BarChart
    let chart = BarChart(bars: bars)

    // Then: should not crash and have empty bars
    XCTAssertTrue(chart.bars.isEmpty)
  }

  func testAnimationStateInitialization() {
    // Given: bars with default animation state
    let bars = [
      ChartBar(
        id: "1",
        value: 1000,
        maxValue: 2000,
        label: "Bar 1",
        color: .blue,
        date: nil
      )
    ]

    // When: creating BarChart
    let chart = BarChart(bars: bars)

    // Then: bars should maintain their default animation state
    XCTAssertEqual(chart.bars[0].height, 0)
    XCTAssertEqual(chart.bars[0].opacity, 0)
  }
}
