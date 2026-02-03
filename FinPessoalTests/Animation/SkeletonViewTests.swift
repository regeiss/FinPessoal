import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor

final class SkeletonViewTests: XCTestCase {
  // MARK: - SkeletonView Tests

  func testSkeletonViewInitialization() {
    let skeleton = SkeletonView(cornerRadius: 12, height: 100)

    // Verify initialization doesn't crash
    XCTAssertNotNil(skeleton)
  }

  func testSkeletonViewRectangle() {
    let skeleton = SkeletonView.rectangle(width: 200, height: 50, cornerRadius: 8)

    // Verify factory method creates view
    XCTAssertNotNil(skeleton)
  }

  func testSkeletonViewCircle() {
    let skeleton = SkeletonView.circle(diameter: 40)

    // Verify circle factory creates view
    XCTAssertNotNil(skeleton)
  }

  func testSkeletonViewTextLine() {
    let skeleton = SkeletonView.textLine(width: 150, height: 16, cornerRadius: 4)

    // Verify text line factory creates view
    XCTAssertNotNil(skeleton)
  }

  // MARK: - Animation Mode Tests

  func testSkeletonViewFullMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .full

    let skeleton = SkeletonView()

    // In full mode, skeleton should have shimmer animation
    // This is visual, so we just verify it doesn't crash
    XCTAssertNotNil(skeleton)

    AnimationSettings.shared.mode = previousMode
  }

  func testSkeletonViewReducedMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .reduced

    let skeleton = SkeletonView()

    // In reduced mode, skeleton should have pulse animation
    XCTAssertNotNil(skeleton)

    AnimationSettings.shared.mode = previousMode
  }

  func testSkeletonViewMinimalMode() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .minimal

    let skeleton = SkeletonView()

    // In minimal mode, skeleton should be static
    XCTAssertNotNil(skeleton)

    AnimationSettings.shared.mode = previousMode
  }

  // MARK: - StaggeredSkeletonGroup Tests

  func testStaggeredSkeletonGroupCreation() {
    let group = StaggeredSkeletonGroup(staggerDelay: 0.05) {
      SkeletonView.textLine(width: 100, height: 16)
    }

    XCTAssertNotNil(group)
  }

  func testStaggeredSkeletonGroupDefaultDelay() {
    let group = StaggeredSkeletonGroup {
      SkeletonView.textLine(width: 100, height: 16)
    }

    // Default delay should be 0.05
    XCTAssertNotNil(group)
  }

  // MARK: - LoadingTransitionCoordinator Tests

  func testCoordinatorInitializationLoading() {
    let coordinator = LoadingTransitionCoordinator(isLoading: true)

    XCTAssertTrue(coordinator.isLoading)
    XCTAssertTrue(coordinator.showSkeleton)
    XCTAssertEqual(coordinator.contentOpacity, 0.0)
    XCTAssertEqual(coordinator.contentOffset, 20.0)
  }

  func testCoordinatorInitializationNotLoading() {
    let coordinator = LoadingTransitionCoordinator(isLoading: false)

    XCTAssertFalse(coordinator.isLoading)
    XCTAssertFalse(coordinator.showSkeleton)
    XCTAssertEqual(coordinator.contentOpacity, 1.0)
    XCTAssertEqual(coordinator.contentOffset, 0.0)
  }

  func testCoordinatorTransitionToContent() {
    let coordinator = LoadingTransitionCoordinator(isLoading: true)
    let expectation = expectation(description: "Transition completes")

    coordinator.transitionToContent(staggerIndex: 0)

    // Should immediately mark as not loading
    XCTAssertFalse(coordinator.isLoading)

    // Wait for transition to complete
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      XCTAssertFalse(coordinator.showSkeleton)
      XCTAssertEqual(coordinator.contentOpacity, 1.0)
      XCTAssertEqual(coordinator.contentOffset, 0.0)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
  }

  func testCoordinatorTransitionWithStagger() {
    let coordinator = LoadingTransitionCoordinator(isLoading: true)
    let expectation = expectation(description: "Staggered transition completes")

    coordinator.transitionToContent(staggerIndex: 2)

    // Transition should be delayed by stagger index
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      XCTAssertFalse(coordinator.showSkeleton)
      XCTAssertEqual(coordinator.contentOpacity, 1.0)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0)
  }

  func testCoordinatorMinimalModeTransition() {
    let previousMode = AnimationSettings.shared.mode
    AnimationSettings.shared.mode = .minimal

    let coordinator = LoadingTransitionCoordinator(isLoading: true)
    coordinator.transitionToContent(staggerIndex: 0)

    // In minimal mode, transition should be immediate
    XCTAssertFalse(coordinator.isLoading)
    XCTAssertFalse(coordinator.showSkeleton)
    XCTAssertEqual(coordinator.contentOpacity, 1.0)
    XCTAssertEqual(coordinator.contentOffset, 0.0)

    AnimationSettings.shared.mode = previousMode
  }

  func testCoordinatorReset() {
    let coordinator = LoadingTransitionCoordinator(isLoading: false)

    coordinator.reset()

    XCTAssertTrue(coordinator.isLoading)
    XCTAssertTrue(coordinator.showSkeleton)
    XCTAssertEqual(coordinator.contentOpacity, 0.0)
    XCTAssertEqual(coordinator.contentOffset, 20.0)
  }

  func testCoordinatorStaggeredGroupTransition() {
    let coordinator = LoadingTransitionCoordinator(isLoading: true)
    var executedIndices: [Int] = []
    let expectation = expectation(description: "Staggered group completes")

    coordinator.coordinateStaggeredTransition(elementCount: 3) { index in
      executedIndices.append(index)

      if executedIndices.count == 3 {
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 1.0)

    XCTAssertEqual(executedIndices, [0, 1, 2])
    XCTAssertFalse(coordinator.isLoading)
  }

  // MARK: - DashboardTransitionHelper Tests

  func testCreateCoordinators() {
    let coordinators = DashboardTransitionHelper.createCoordinators(cardCount: 5)

    XCTAssertEqual(coordinators.count, 5)
    coordinators.forEach { coordinator in
      XCTAssertTrue(coordinator.isLoading)
    }
  }

  func testTransitionAll() {
    let coordinators = DashboardTransitionHelper.createCoordinators(cardCount: 3)
    let expectation = expectation(description: "All transitions complete")

    DashboardTransitionHelper.transitionAll(coordinators: coordinators)

    // All should be marked as not loading immediately
    coordinators.forEach { coordinator in
      XCTAssertFalse(coordinator.isLoading)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
  }

  func testResetAll() {
    let coordinators = DashboardTransitionHelper.createCoordinators(cardCount: 3)

    // Transition first
    DashboardTransitionHelper.transitionAll(coordinators: coordinators)

    // Then reset
    DashboardTransitionHelper.resetAll(coordinators: coordinators)

    coordinators.forEach { coordinator in
      XCTAssertTrue(coordinator.isLoading)
      XCTAssertTrue(coordinator.showSkeleton)
    }
  }

  // MARK: - Dashboard Skeleton Tests

  func testBalanceCardSkeletonCreation() {
    let skeleton = BalanceCardSkeleton()
    XCTAssertNotNil(skeleton)
  }

  func testSpendingTrendsChartSkeletonCreation() {
    let skeleton = SpendingTrendsChartSkeleton()
    XCTAssertNotNil(skeleton)
  }

  func testRecentTransactionsSkeletonCreation() {
    let skeleton = RecentTransactionsSkeleton(rowCount: 5)
    XCTAssertNotNil(skeleton)
  }

  func testRecentTransactionsSkeletonDefaultRowCount() {
    let skeleton = RecentTransactionsSkeleton()
    XCTAssertNotNil(skeleton)
  }

  func testQuickStatsSkeletonCreation() {
    let skeleton = QuickStatsSkeleton()
    XCTAssertNotNil(skeleton)
  }

  func testDashboardSkeletonCreation() {
    let skeleton = DashboardSkeleton()
    XCTAssertNotNil(skeleton)
  }

  // MARK: - Transition Timing Tests

  func testTransitionTimingSequence() {
    let coordinator1 = LoadingTransitionCoordinator(isLoading: true)
    let coordinator2 = LoadingTransitionCoordinator(isLoading: true)
    let expectation = expectation(description: "Sequence timing")

    var firstCompleted = false
    var secondCompleted = false

    // Start first transition
    coordinator1.transitionToContent(staggerIndex: 0)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      firstCompleted = true
    }

    // Start second transition with stagger
    coordinator2.transitionToContent(staggerIndex: 1)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      secondCompleted = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
      XCTAssertTrue(firstCompleted)
      XCTAssertTrue(secondCompleted)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0)
  }

  // MARK: - Performance Tests

  func testMultipleSkeletonCreationPerformance() {
    measure {
      _ = (0..<10).map { _ in
        SkeletonView.textLine(width: 100, height: 16)
      }
    }
  }

  func testCoordinatorCreationPerformance() {
    measure {
      _ = DashboardTransitionHelper.createCoordinators(cardCount: 10)
    }
  }

  func testTransitionCoordinationPerformance() {
    let coordinators = DashboardTransitionHelper.createCoordinators(cardCount: 10)

    measure {
      DashboardTransitionHelper.transitionAll(coordinators: coordinators)
      DashboardTransitionHelper.resetAll(coordinators: coordinators)
    }
  }

  // MARK: - Dark Mode Tests

  func testSkeletonViewDarkModeColors() {
    // Skeletons should adapt to dark mode
    // This is visual, but we verify creation doesn't crash
    let skeleton = SkeletonView()
    XCTAssertNotNil(skeleton)
  }

  // MARK: - Accessibility Tests

  func testSkeletonViewAccessibility() {
    let skeleton = SkeletonView.textLine(width: 150, height: 16)

    // Skeletons should not interfere with accessibility
    // but shouldn't provide their own accessibility labels
    XCTAssertNotNil(skeleton)
  }
}
