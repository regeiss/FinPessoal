// FinPessoalTests/Animation/ChartGestureHandlerTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ChartGestureHandlerTests: XCTestCase {

  private var handler: ChartGestureHandler!

  override func setUp() async throws {
    try await super.setUp()
    handler = ChartGestureHandler()
  }

  override func tearDown() async throws {
    handler = nil
    try await super.tearDown()
  }

  func testTapSelectsSegment() {
    XCTAssertNil(handler.selectedID)

    handler.handleTap(segmentID: "food")
    XCTAssertEqual(handler.selectedID, "food")
  }

  func testTapTogglesSelection() {
    handler.handleTap(segmentID: "food")
    XCTAssertEqual(handler.selectedID, "food")

    // Tap same segment again to deselect
    handler.handleTap(segmentID: "food")
    XCTAssertNil(handler.selectedID)
  }

  func testDragUpdatesSelection() {
    XCTAssertFalse(handler.isDragging)

    handler.handleDragChanged(segmentID: "food")
    XCTAssertTrue(handler.isDragging)
    XCTAssertEqual(handler.selectedID, "food")

    handler.handleDragChanged(segmentID: "transport")
    XCTAssertEqual(handler.selectedID, "transport")

    handler.handleDragEnded()
    XCTAssertFalse(handler.isDragging)
    XCTAssertEqual(handler.selectedID, "transport") // Selection persists
  }
}
