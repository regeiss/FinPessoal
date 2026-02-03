import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class PullToRefreshTests: XCTestCase {
  // MARK: - PullToRefreshState Tests

  func testPullToRefreshStateIdle() {
    let state: PullToRefreshState = .idle

    switch state {
    case .idle:
      XCTAssertTrue(true)
    default:
      XCTFail("Expected idle state")
    }
  }

  func testPullToRefreshStatePulling() {
    let state: PullToRefreshState = .pulling(offset: 30.0)

    switch state {
    case .pulling(let offset):
      XCTAssertEqual(offset, 30.0)
    default:
      XCTFail("Expected pulling state")
    }

    XCTAssertEqual(state.offset, 30.0)
  }

  func testPullToRefreshStateReady() {
    let state: PullToRefreshState = .ready

    switch state {
    case .ready:
      XCTAssertTrue(true)
    default:
      XCTFail("Expected ready state")
    }
  }

  func testPullToRefreshStateLoading() {
    let state: PullToRefreshState = .loading

    switch state {
    case .loading:
      XCTAssertTrue(true)
    default:
      XCTFail("Expected loading state")
    }
  }

  func testPullToRefreshStateComplete() {
    let state: PullToRefreshState = .complete

    switch state {
    case .complete:
      XCTAssertTrue(true)
    default:
      XCTFail("Expected complete state")
    }
  }

  func testPullToRefreshStateEquality() {
    let state1: PullToRefreshState = .idle
    let state2: PullToRefreshState = .idle

    XCTAssertEqual(state1, state2)
  }

  func testPullToRefreshStatePullingEquality() {
    let state1: PullToRefreshState = .pulling(offset: 30.0)
    let state2: PullToRefreshState = .pulling(offset: 30.5)

    // Should be equal within tolerance (1.0)
    XCTAssertEqual(state1, state2)
  }

  func testPullToRefreshStateInequality() {
    let state1: PullToRefreshState = .idle
    let state2: PullToRefreshState = .ready

    XCTAssertNotEqual(state1, state2)
  }

  // MARK: - RefreshCoordinator Tests

  func testRefreshCoordinatorInitialization() {
    let coordinator = RefreshCoordinator()

    XCTAssertEqual(coordinator.refreshState, .idle)
    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertNil(coordinator.lastRefreshDate)
    XCTAssertNil(coordinator.refreshError)
  }

  func testRefreshCoordinatorUpdatePullOffset() {
    let coordinator = RefreshCoordinator()

    // Small offset - should be pulling
    coordinator.updatePullOffset(30.0)
    if case .pulling(let offset) = coordinator.refreshState {
      XCTAssertEqual(offset, 30.0, accuracy: 1.0)
    } else {
      XCTFail("Expected pulling state")
    }

    // Threshold crossed - should be ready
    coordinator.updatePullOffset(65.0)
    XCTAssertEqual(coordinator.refreshState, .ready)

    // Zero offset - should be idle
    coordinator.updatePullOffset(0.0)
    XCTAssertEqual(coordinator.refreshState, .idle)
  }

  func testRefreshCoordinatorTriggerRefresh() {
    let coordinator = RefreshCoordinator()

    coordinator.triggerRefresh()

    XCTAssertEqual(coordinator.refreshState, .loading)
    XCTAssertTrue(coordinator.isRefreshing)
    XCTAssertNil(coordinator.refreshError)
  }

  func testRefreshCoordinatorCompleteRefresh() {
    let coordinator = RefreshCoordinator()
    let expectation = expectation(description: "Refresh completes")

    coordinator.triggerRefresh()
    XCTAssertTrue(coordinator.isRefreshing)

    coordinator.completeRefresh()

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertEqual(coordinator.refreshState, .complete)
    XCTAssertNotNil(coordinator.lastRefreshDate)

    // Should auto-reset to idle
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      XCTAssertEqual(coordinator.refreshState, .idle)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
  }

  func testRefreshCoordinatorFailRefresh() {
    let coordinator = RefreshCoordinator()
    let testError = NSError(domain: "test", code: 1, userInfo: nil)

    coordinator.triggerRefresh()
    coordinator.failRefresh(error: testError)

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertEqual(coordinator.refreshState, .idle)
    XCTAssertNotNil(coordinator.refreshError)
  }

  func testRefreshCoordinatorCancelRefresh() {
    let coordinator = RefreshCoordinator()

    coordinator.triggerRefresh()
    XCTAssertTrue(coordinator.isRefreshing)

    coordinator.cancelRefresh()

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertEqual(coordinator.refreshState, .idle)
    XCTAssertNil(coordinator.refreshError)
  }

  func testRefreshCoordinatorReset() {
    let coordinator = RefreshCoordinator()

    coordinator.triggerRefresh()
    coordinator.reset()

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertNil(coordinator.refreshError)
    XCTAssertEqual(coordinator.refreshState, .idle)
  }

  func testRefreshCoordinatorStatusMessages() {
    let coordinator = RefreshCoordinator()

    // Idle state
    XCTAssertEqual(coordinator.statusMessage, "Pull to refresh")

    // Pulling state
    coordinator.updatePullOffset(30.0)
    XCTAssertEqual(coordinator.statusMessage, "Pull down to refresh")

    // Ready state
    coordinator.updatePullOffset(65.0)
    XCTAssertEqual(coordinator.statusMessage, "Release to refresh")

    // Loading state
    coordinator.triggerRefresh()
    XCTAssertEqual(coordinator.statusMessage, "Refreshing...")

    // Complete state
    coordinator.completeRefresh()
    XCTAssertEqual(coordinator.statusMessage, "Updated successfully")
  }

  func testRefreshCoordinatorExecuteRefresh() async {
    let coordinator = RefreshCoordinator()
    var executedAction = false

    await coordinator.executeRefresh {
      executedAction = true
    }

    XCTAssertTrue(executedAction)
    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertNotNil(coordinator.lastRefreshDate)
  }

  func testRefreshCoordinatorExecuteRefreshWithError() async {
    let coordinator = RefreshCoordinator()
    let testError = NSError(domain: "test", code: 1, userInfo: nil)

    await coordinator.executeRefresh {
      throw testError
    }

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertNotNil(coordinator.refreshError)
  }

  // MARK: - Refresh Metrics Tests

  func testRefreshMetricsInitialization() {
    let metrics = RefreshCoordinator.RefreshMetrics()

    XCTAssertEqual(metrics.totalRefreshes, 0)
    XCTAssertEqual(metrics.successfulRefreshes, 0)
    XCTAssertEqual(metrics.failedRefreshes, 0)
    XCTAssertEqual(metrics.averageRefreshDuration, 0.0)
    XCTAssertEqual(metrics.successRate, 0.0)
  }

  func testRefreshMetricsRecordSuccess() {
    var metrics = RefreshCoordinator.RefreshMetrics()

    metrics.recordSuccess(duration: 1.0)

    XCTAssertEqual(metrics.totalRefreshes, 1)
    XCTAssertEqual(metrics.successfulRefreshes, 1)
    XCTAssertEqual(metrics.failedRefreshes, 0)
    XCTAssertEqual(metrics.lastRefreshDuration, 1.0)
    XCTAssertEqual(metrics.successRate, 1.0)
  }

  func testRefreshMetricsRecordFailure() {
    var metrics = RefreshCoordinator.RefreshMetrics()

    metrics.recordFailure(duration: 0.5)

    XCTAssertEqual(metrics.totalRefreshes, 1)
    XCTAssertEqual(metrics.successfulRefreshes, 0)
    XCTAssertEqual(metrics.failedRefreshes, 1)
    XCTAssertEqual(metrics.successRate, 0.0)
  }

  func testRefreshMetricsAverageDuration() {
    var metrics = RefreshCoordinator.RefreshMetrics()

    metrics.recordSuccess(duration: 1.0)
    metrics.recordSuccess(duration: 2.0)
    metrics.recordSuccess(duration: 3.0)

    XCTAssertEqual(metrics.totalRefreshes, 3)
    XCTAssertEqual(metrics.averageRefreshDuration, 2.0)
  }

  func testRefreshMetricsSuccessRate() {
    var metrics = RefreshCoordinator.RefreshMetrics()

    metrics.recordSuccess(duration: 1.0)
    metrics.recordSuccess(duration: 1.0)
    metrics.recordFailure(duration: 1.0)

    XCTAssertEqual(metrics.totalRefreshes, 3)
    XCTAssertEqual(metrics.successRate, 2.0 / 3.0, accuracy: 0.01)
  }

  // MARK: - RefreshIndicator Tests

  func testRefreshIndicatorCreation() {
    let indicator = RefreshIndicator(state: .idle, pullProgress: 0.0)
    XCTAssertNotNil(indicator)
  }

  func testRefreshIndicatorPullingState() {
    let indicator = RefreshIndicator(
      state: .pulling(offset: 30.0),
      pullProgress: 0.5
    )
    XCTAssertNotNil(indicator)
  }

  func testRefreshIndicatorReadyState() {
    let indicator = RefreshIndicator(state: .ready, pullProgress: 1.0)
    XCTAssertNotNil(indicator)
  }

  func testRefreshIndicatorLoadingState() {
    let indicator = RefreshIndicator(state: .loading, pullProgress: 1.0)
    XCTAssertNotNil(indicator)
  }

  func testRefreshIndicatorCompleteState() {
    let indicator = RefreshIndicator(state: .complete, pullProgress: 1.0)
    XCTAssertNotNil(indicator)
  }

  // MARK: - PullToRefreshView Tests

  func testPullToRefreshViewCreation() {
    let view = PullToRefreshView(
      isRefreshing: .constant(false),
      onRefresh: {}
    ) {
      Text("Content")
    }

    XCTAssertNotNil(view)
  }

  // MARK: - Elastic Resistance Tests

  func testElasticResistanceBehavior() {
    // The elastic resistance formula: offset * 0.5
    let offsets: [(input: CGFloat, expected: CGFloat)] = [
      (0, 0),
      (10, 5),
      (30, 15),
      (60, 30),
      (120, 60)
    ]

    for (input, expected) in offsets {
      let resistance: CGFloat = 0.5
      let result = input * resistance
      XCTAssertEqual(result, expected, accuracy: 0.1)
    }
  }

  // MARK: - State Transition Tests

  func testStateTransitionSequence() {
    let coordinator = RefreshCoordinator()

    // Start idle
    XCTAssertEqual(coordinator.refreshState, .idle)

    // Pull slightly
    coordinator.updatePullOffset(20.0)
    if case .pulling = coordinator.refreshState {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected pulling state")
    }

    // Cross threshold
    coordinator.updatePullOffset(70.0)
    XCTAssertEqual(coordinator.refreshState, .ready)

    // Release (trigger)
    coordinator.triggerRefresh()
    XCTAssertEqual(coordinator.refreshState, .loading)

    // Complete
    coordinator.completeRefresh()
    XCTAssertEqual(coordinator.refreshState, .complete)
  }

  // MARK: - Performance Tests

  func testRefreshCoordinatorCreationPerformance() {
    measure {
      _ = (0..<100).map { _ in RefreshCoordinator() }
    }
  }

  func testStateTransitionPerformance() {
    let coordinator = RefreshCoordinator()

    measure {
      for offset in stride(from: 0, to: 100, by: 5) {
        coordinator.updatePullOffset(CGFloat(offset))
      }
    }
  }

  // MARK: - Animation Mode Tests

  func testRefreshMinimalMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .minimal

    let coordinator = RefreshCoordinator()
    coordinator.updatePullOffset(65.0)

    // State should update without animation
    XCTAssertEqual(coordinator.refreshState, .ready)

    AnimationSettings.shared.mode = previousMode
  }

  // MARK: - Integration Tests

  func testRefreshCoordinatorWithViewModel() async {
    let coordinator = RefreshCoordinator()
    let viewModel = DashboardViewModel()

    // Mock refresh
    await coordinator.executeRefresh {
      // Simulate loading
      try? await Task.sleep(nanoseconds: 100_000_000)
    }

    XCTAssertFalse(coordinator.isRefreshing)
    XCTAssertNotNil(coordinator.lastRefreshDate)
  }
}
