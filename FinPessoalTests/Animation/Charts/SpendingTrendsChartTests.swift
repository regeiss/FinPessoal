import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor

final class SpendingTrendsChartTests: XCTestCase {
  // MARK: - ChartDataPoint Tests

  func testChartDataPointInitialization() {
    let date = Date()
    let transactions: [FinPessoal.Transaction] = [] // Empty array for testing

    let point = ChartDataPoint(
      date: date,
      value: 150.0,
      transactions: transactions,
      position: CGPoint(x: 10, y: 20),
      isHighlighted: true
    )

    XCTAssertEqual(point.date, date)
    XCTAssertEqual(point.value, 150.0)
    XCTAssertEqual(point.transactions.count, 0)
    XCTAssertEqual(point.position, CGPoint(x: 10, y: 20))
    XCTAssertTrue(point.isHighlighted)
  }

  func testChartDataPointEquality() {
    let date = Date()
    let id = UUID()

    let point1 = ChartDataPoint(
      id: id,
      date: date,
      value: 100.0,
      position: CGPoint(x: 5, y: 5)
    )

    let point2 = ChartDataPoint(
      id: id,
      date: date,
      value: 100.0,
      position: CGPoint(x: 5, y: 5)
    )

    XCTAssertEqual(point1, point2)
  }

  func testChartDataPointInequality() {
    let point1 = ChartDataPoint(date: Date(), value: 100.0)
    let point2 = ChartDataPoint(date: Date(), value: 200.0)

    XCTAssertNotEqual(point1, point2)
  }

  // MARK: - SpendingTrendsData Tests

  func testSpendingTrendsDataInitialization() {
    let points = createMockDataPoints(count: 7)
    let dateRange = Date()...Date().addingTimeInterval(86400 * 6)

    let data = SpendingTrendsData(
      points: points,
      maxValue: 300.0,
      minValue: 50.0,
      dateRange: dateRange
    )

    XCTAssertEqual(data.points.count, 7)
    XCTAssertEqual(data.maxValue, 300.0)
    XCTAssertEqual(data.minValue, 50.0)
    XCTAssertNil(data.previousPoints)
  }

  func testSpendingTrendsDataWithPreviousPoints() {
    let currentPoints = createMockDataPoints(count: 7)
    let previousPoints = createMockDataPoints(count: 7)
    let dateRange = Date()...Date().addingTimeInterval(86400 * 6)

    let data = SpendingTrendsData(
      points: currentPoints,
      maxValue: 300.0,
      minValue: 50.0,
      dateRange: dateRange,
      previousPoints: previousPoints
    )

    XCTAssertNotNil(data.previousPoints)
    XCTAssertEqual(data.previousPoints?.count, 7)
  }

  func testSpendingTrendsDataEquality() {
    let points = createMockDataPoints(count: 5)
    let dateRange = Date()...Date().addingTimeInterval(86400 * 4)

    let data1 = SpendingTrendsData(
      points: points,
      maxValue: 200.0,
      minValue: 50.0,
      dateRange: dateRange
    )

    let data2 = SpendingTrendsData(
      points: points,
      maxValue: 200.0,
      minValue: 50.0,
      dateRange: dateRange
    )

    XCTAssertEqual(data1, data2)
  }

  // MARK: - ChartAnimationCoordinator Tests

  func testCoordinatorInitialization() {
    let coordinator = ChartAnimationCoordinator()

    XCTAssertEqual(coordinator.animationProgress, 0.0)
    XCTAssertFalse(coordinator.isAnimating)
    XCTAssertFalse(coordinator.isInteracting)
    XCTAssertNil(coordinator.currentDataPoint)
  }

  func testCoordinatorEntryAnimation() {
    let coordinator = ChartAnimationCoordinator()
    let expectation = expectation(description: "Animation completes")

    coordinator.startEntryAnimation()

    // Check that animation starts
    XCTAssertTrue(coordinator.isAnimating)

    // Wait for animation to complete
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      XCTAssertEqual(coordinator.animationProgress, 1.0)
      XCTAssertFalse(coordinator.isAnimating)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
  }

  func testCoordinatorMinimalModeSkipsAnimation() {
    // Set minimal animation mode
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .minimal

    let coordinator = ChartAnimationCoordinator()
    coordinator.startEntryAnimation()

    // In minimal mode, should complete immediately
    XCTAssertEqual(coordinator.animationProgress, 1.0)
    XCTAssertFalse(coordinator.isAnimating)

    // Restore previous mode
    AnimationSettings.shared.mode = previousMode
  }

  func testCoordinatorGestureInteraction() {
    let coordinator = ChartAnimationCoordinator()
    let point = ChartDataPoint(date: Date(), value: 100.0)

    coordinator.beginInteraction(at: point)

    XCTAssertTrue(coordinator.isInteracting)
    XCTAssertEqual(coordinator.currentDataPoint?.value, 100.0)

    coordinator.endInteraction()

    XCTAssertFalse(coordinator.isInteracting)
    XCTAssertNil(coordinator.currentDataPoint)
  }

  func testCoordinatorDataPointTap() {
    let coordinator = ChartAnimationCoordinator()
    let point = ChartDataPoint(date: Date(), value: 150.0)
    let expectation = expectation(description: "Tap completes")

    coordinator.tapDataPoint(point)

    // Should be in tapped state initially
    XCTAssertTrue(coordinator.isInteracting)

    // Wait for auto-reset
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      XCTAssertFalse(coordinator.isInteracting)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0)
  }

  func testCoordinatorSequencedAnimations() {
    let coordinator = ChartAnimationCoordinator()
    var executedIndices: [Int] = []
    let expectation = expectation(description: "Sequence completes")

    coordinator.sequenceAnimations(elements: 3, delay: 0.05) { index in
      executedIndices.append(index)

      if executedIndices.count == 3 {
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 1.0)

    XCTAssertEqual(executedIndices, [0, 1, 2])
  }

  // MARK: - Chart Interaction State Tests

  func testInteractionStateIdle() {
    let state: ChartInteractionState = .idle

    switch state {
    case .idle:
      XCTAssertTrue(true)
    default:
      XCTFail("Expected idle state")
    }
  }

  func testInteractionStateHovering() {
    let point = ChartDataPoint(date: Date(), value: 100.0)
    let state: ChartInteractionState = .hovering(point: point)

    switch state {
    case .hovering(let hoveredPoint):
      XCTAssertEqual(hoveredPoint.value, 100.0)
    default:
      XCTFail("Expected hovering state")
    }
  }

  func testInteractionStateDragging() {
    let point = ChartDataPoint(date: Date(), value: 150.0)
    let state: ChartInteractionState = .dragging(point: point)

    switch state {
    case .dragging(let draggedPoint):
      XCTAssertEqual(draggedPoint.value, 150.0)
    default:
      XCTFail("Expected dragging state")
    }
  }

  func testInteractionStateTapped() {
    let point = ChartDataPoint(date: Date(), value: 200.0)
    let state: ChartInteractionState = .tapped(point: point)

    switch state {
    case .tapped(let tappedPoint):
      XCTAssertEqual(tappedPoint.value, 200.0)
    default:
      XCTFail("Expected tapped state")
    }
  }

  // MARK: - Animation Mode Awareness Tests

  func testChartRespectsFullAnimationMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .full

    let data = createMockSpendingTrendsData()
    let chart = SpendingTrendsChart(data: data)

    XCTAssertTrue(chart.shouldAnimate)
    XCTAssertEqual(chart.animationDuration, 0.8)

    AnimationSettings.shared.mode = previousMode
  }

  func testChartRespectsReducedAnimationMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .reduced

    let data = createMockSpendingTrendsData()
    let chart = SpendingTrendsChart(data: data)

    XCTAssertTrue(chart.shouldAnimate)
    XCTAssertEqual(chart.animationDuration, 0.4)

    AnimationSettings.shared.mode = previousMode
  }

  func testChartRespectsMinimalAnimationMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .minimal

    let data = createMockSpendingTrendsData()
    let chart = SpendingTrendsChart(data: data)

    XCTAssertFalse(chart.shouldAnimate)
    XCTAssertEqual(chart.animationDuration, 0.0)

    AnimationSettings.shared.mode = previousMode
  }

  // MARK: - Accessibility Tests

  func testChartDataPointAccessibility() {
    let point = ChartDataPoint(
      date: Date(),
      value: 150.50,
      transactions: []
    )

    // Verify point has accessible data
    XCTAssertNotNil(point.date)
    XCTAssertNotNil(point.value)

    // Date and value should be usable for VoiceOver labels
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    let dateString = formatter.string(from: point.date)
    XCTAssertFalse(dateString.isEmpty)
  }

  // MARK: - Performance Tests

  func testChartDataCalculationPerformance() {
    measure {
      _ = createMockDataPoints(count: 30)
    }
  }

  func testLargeDatasetHandling() {
    let points = createMockDataPoints(count: 30)
    let dateRange = Date()...Date().addingTimeInterval(86400 * 29)

    let data = SpendingTrendsData(
      points: points,
      maxValue: 1000.0,
      minValue: 0.0,
      dateRange: dateRange
    )

    XCTAssertEqual(data.points.count, 30)
    XCTAssertLessThanOrEqual(data.points.count, 30, "Should not exceed 30 days as per spec")
  }

  // MARK: - Helper Methods

  private func createMockDataPoints(count: Int) -> [ChartDataPoint] {
    return (0..<count).map { i in
      ChartDataPoint(
        date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
        value: Double.random(in: 50...300),
        transactions: []
      )
    }
  }

  private func createMockSpendingTrendsData() -> SpendingTrendsData {
    let points = createMockDataPoints(count: 7)
    let dateRange = Date()...Date().addingTimeInterval(86400 * 6)

    return SpendingTrendsData(
      points: points,
      maxValue: 300.0,
      minValue: 50.0,
      dateRange: dateRange
    )
  }
}
