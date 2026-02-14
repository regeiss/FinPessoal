// FinPessoalTests/Animation/PieDonutChartTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

final class PieDonutChartTests: XCTestCase {

  // MARK: - Angle Calculation Tests

  func testCalculateAngles_TwoSegmentsEqual() {
    // Given: Two segments with 50% each
    let segments = [
      ChartSegment(
        id: "segment1",
        value: 100,
        percentage: 50,
        label: "Segment 1",
        color: .blue,
        category: nil
      ),
      ChartSegment(
        id: "segment2",
        value: 100,
        percentage: 50,
        label: "Segment 2",
        color: .red,
        category: nil
      )
    ]

    // When: Calculate angles
    let angles = PieDonutChart.calculateAngles(for: segments)

    // Then: Should start at -90° (top) and calculate correct sweep
    XCTAssertEqual(angles.count, 2, "Should have 2 angle pairs")

    // First segment: -90° to 90° (180° sweep)
    XCTAssertEqual(angles[0].start, -90, accuracy: 0.01)
    XCTAssertEqual(angles[0].end, 90, accuracy: 0.01)

    // Second segment: 90° to 270° (180° sweep)
    XCTAssertEqual(angles[1].start, 90, accuracy: 0.01)
    XCTAssertEqual(angles[1].end, 270, accuracy: 0.01)
  }

  func testCalculateAngles_FourSegmentsUnequal() {
    // Given: Four segments with different percentages
    let segments = [
      ChartSegment(id: "1", value: 100, percentage: 40, label: "A", color: .blue, category: nil),
      ChartSegment(id: "2", value: 75, percentage: 30, label: "B", color: .red, category: nil),
      ChartSegment(id: "3", value: 50, percentage: 20, label: "C", color: .green, category: nil),
      ChartSegment(id: "4", value: 25, percentage: 10, label: "D", color: .yellow, category: nil)
    ]

    // When: Calculate angles
    let angles = PieDonutChart.calculateAngles(for: segments)

    // Then: Should calculate correct angles
    XCTAssertEqual(angles.count, 4, "Should have 4 angle pairs")

    // First segment: 40% = 144° sweep
    XCTAssertEqual(angles[0].start, -90, accuracy: 0.01)
    XCTAssertEqual(angles[0].end, 54, accuracy: 0.01) // -90 + 144

    // Second segment: 30% = 108° sweep
    XCTAssertEqual(angles[1].start, 54, accuracy: 0.01)
    XCTAssertEqual(angles[1].end, 162, accuracy: 0.01) // 54 + 108

    // Third segment: 20% = 72° sweep
    XCTAssertEqual(angles[2].start, 162, accuracy: 0.01)
    XCTAssertEqual(angles[2].end, 234, accuracy: 0.01) // 162 + 72

    // Fourth segment: 10% = 36° sweep
    XCTAssertEqual(angles[3].start, 234, accuracy: 0.01)
    XCTAssertEqual(angles[3].end, 270, accuracy: 0.01) // 234 + 36
  }

  func testCalculateAngles_EmptySegments() {
    // Given: Empty segments array
    let segments: [ChartSegment] = []

    // When: Calculate angles
    let angles = PieDonutChart.calculateAngles(for: segments)

    // Then: Should return empty array
    XCTAssertEqual(angles.count, 0, "Should have no angles for empty segments")
  }

  func testCalculateAngles_SingleSegment() {
    // Given: Single segment with 100%
    let segments = [
      ChartSegment(
        id: "only",
        value: 200,
        percentage: 100,
        label: "Only",
        color: .blue,
        category: nil
      )
    ]

    // When: Calculate angles
    let angles = PieDonutChart.calculateAngles(for: segments)

    // Then: Should cover full circle
    XCTAssertEqual(angles.count, 1, "Should have 1 angle pair")
    XCTAssertEqual(angles[0].start, -90, accuracy: 0.01)
    XCTAssertEqual(angles[0].end, 270, accuracy: 0.01) // -90 + 360
  }
}
