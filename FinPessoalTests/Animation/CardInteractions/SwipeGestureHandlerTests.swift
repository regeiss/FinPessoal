//
//  SwipeGestureHandlerTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal
import SwiftUI

@MainActor
final class SwipeGestureHandlerTests: XCTestCase {

  var handler: SwipeGestureHandler!

  override func setUp() async throws {
    try await super.setUp()
    handler = SwipeGestureHandler()
  }

  override func tearDown() async throws {
    handler = nil
    try await super.tearDown()
  }

  // MARK: - Initialization Tests

  func testInitialState() {
    XCTAssertEqual(handler.offset, 0, "Initial offset should be zero")
    XCTAssertFalse(handler.isDragging, "Should not be dragging initially")
    XCTAssertNil(handler.revealedSide, "No side should be revealed initially")
    XCTAssertFalse(handler.isRevealed, "Should not be revealed initially")
  }

  // MARK: - Drag Handling Tests

  func testDragChangedUpdatesOffset() {
    let maxDistance: CGFloat = 120
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 50, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)

    XCTAssertTrue(handler.isDragging, "Should be dragging")
    XCTAssertGreaterThan(handler.offset, 0, "Offset should be positive for right swipe")
    XCTAssertLessThanOrEqual(abs(handler.offset), maxDistance, "Offset should not exceed max distance")
  }

  func testDragChangedAppliesResistanceCurve() {
    let maxDistance: CGFloat = 120
    let largeTranslation: CGFloat = 150

    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: largeTranslation, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)

    // Offset should be less than translation due to resistance
    XCTAssertLessThan(abs(handler.offset), largeTranslation, "Resistance curve should dampen offset")
    XCTAssertLessThanOrEqual(abs(handler.offset), maxDistance, "Offset should be clamped to max distance")
  }

  func testDragEndedBelowThresholdBouncesBack() {
    let maxDistance: CGFloat = 120
    let threshold: CGFloat = 60

    // Simulate small drag
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 40, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    handler.handleDragEnded(
      threshold: threshold,
      maxDistance: maxDistance,
      leadingActionsCount: 1,
      trailingActionsCount: 1
    )

    XCTAssertEqual(handler.offset, 0, "Offset should reset to zero")
    XCTAssertNil(handler.revealedSide, "No side should be revealed")
    XCTAssertFalse(handler.isDragging, "Should not be dragging")
  }

  func testDragEndedAboveThresholdRevealsActions() {
    let maxDistance: CGFloat = 120
    let threshold: CGFloat = 60

    // Simulate large drag right
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 80, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    handler.handleDragEnded(
      threshold: threshold,
      maxDistance: maxDistance,
      leadingActionsCount: 1,
      trailingActionsCount: 0
    )

    XCTAssertEqual(handler.revealedSide, .leading, "Leading side should be revealed")
    XCTAssertTrue(handler.isRevealed, "Should be revealed")
    XCTAssertFalse(handler.isDragging, "Should not be dragging")
  }

  func testDragEndedLeftRevealsTrailingActions() {
    let maxDistance: CGFloat = 120
    let threshold: CGFloat = 60

    // Simulate large drag left (negative)
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: -80, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    handler.handleDragEnded(
      threshold: threshold,
      maxDistance: maxDistance,
      leadingActionsCount: 0,
      trailingActionsCount: 1
    )

    XCTAssertEqual(handler.revealedSide, .trailing, "Trailing side should be revealed")
    XCTAssertTrue(handler.isRevealed, "Should be revealed")
  }

  func testDragEndedWithoutActionsBouncesBack() {
    let maxDistance: CGFloat = 120
    let threshold: CGFloat = 60

    // Simulate large drag but no actions available
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 80, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    handler.handleDragEnded(
      threshold: threshold,
      maxDistance: maxDistance,
      leadingActionsCount: 0,  // No actions
      trailingActionsCount: 0
    )

    XCTAssertEqual(handler.offset, 0, "Offset should reset when no actions available")
    XCTAssertNil(handler.revealedSide, "No side should be revealed")
  }

  // MARK: - Reset Tests

  func testResetClearsAllState() {
    let maxDistance: CGFloat = 120

    // Set some state
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 80, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    handler.handleDragEnded(
      threshold: 60,
      maxDistance: maxDistance,
      leadingActionsCount: 1,
      trailingActionsCount: 0
    )

    // Now reset
    handler.reset()

    XCTAssertEqual(handler.offset, 0, "Offset should be reset")
    XCTAssertNil(handler.revealedSide, "Revealed side should be nil")
    XCTAssertFalse(handler.isDragging, "Should not be dragging")
    XCTAssertFalse(handler.isRevealed, "Should not be revealed")
  }

  // MARK: - Query Methods Tests

  func testSwipeProgress() {
    let maxDistance: CGFloat = 120

    // Test 0% progress
    XCTAssertEqual(handler.swipeProgress(maxDistance: maxDistance), 0.0, accuracy: 0.01)

    // Simulate 50% swipe
    let mockDragValue = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 60, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )

    handler.handleDragChanged(mockDragValue, maxDistance: maxDistance)
    let progress = handler.swipeProgress(maxDistance: maxDistance)

    XCTAssertGreaterThan(progress, 0.0, "Progress should be greater than 0")
    XCTAssertLessThanOrEqual(progress, 1.0, "Progress should not exceed 1.0")
  }

  func testActionOpacity() {
    let maxDistance: CGFloat = 120

    // At 0px: opacity should be 0
    XCTAssertEqual(handler.actionOpacity(maxDistance: maxDistance), 0.0)

    // At 30px: opacity should start fading in
    let mockDragValue30 = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 30, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )
    handler.handleDragChanged(mockDragValue30, maxDistance: maxDistance)
    XCTAssertEqual(handler.actionOpacity(maxDistance: maxDistance), 0.0, accuracy: 0.01)

    // At 60px: opacity should be 1.0
    let mockDragValue60 = DragGesture.Value(
      time: Date(),
      location: CGPoint(x: 60, y: 0),
      startLocation: CGPoint(x: 0, y: 0)
    )
    handler.handleDragChanged(mockDragValue60, maxDistance: maxDistance)
    XCTAssertGreaterThanOrEqual(handler.actionOpacity(maxDistance: maxDistance), 1.0)
  }
}
