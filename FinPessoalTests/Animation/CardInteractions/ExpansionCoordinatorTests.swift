//
//  ExpansionCoordinatorTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class ExpansionCoordinatorTests: XCTestCase {

  var coordinator: ExpansionCoordinator!

  override func setUp() async throws {
    try await super.setUp()
    coordinator = ExpansionCoordinator()
  }

  override func tearDown() async throws {
    coordinator = nil
    try await super.tearDown()
  }

  // MARK: - Initialization Tests

  func testInitialStateNothingExpanded() {
    XCTAssertNil(coordinator.expandedSectionID, "Initially no section should be expanded")
    XCTAssertFalse(coordinator.isExpanded("section1"), "Section should not be expanded")
  }

  func testInitializationWithExpandedSection() {
    let coordinator = ExpansionCoordinator(initiallyExpandedID: "section1")

    XCTAssertEqual(coordinator.expandedSectionID, "section1", "Section should be initially expanded")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section should be expanded")
  }

  // MARK: - Expand Tests

  func testExpandSection() {
    coordinator.expand("section1")

    XCTAssertEqual(coordinator.expandedSectionID, "section1", "Section1 should be expanded")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should report as expanded")
  }

  func testExpandSecondSectionCollapsesFirst() {
    // Expand first section
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should be expanded")

    // Expand second section
    coordinator.expand("section2")

    XCTAssertFalse(coordinator.isExpanded("section1"), "Section1 should be collapsed")
    XCTAssertTrue(coordinator.isExpanded("section2"), "Section2 should be expanded")
    XCTAssertEqual(coordinator.expandedSectionID, "section2", "Only section2 should be expanded")
  }

  // MARK: - Collapse Tests

  func testCollapseExpandedSection() {
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section should be expanded")

    coordinator.collapse("section1")

    XCTAssertFalse(coordinator.isExpanded("section1"), "Section should be collapsed")
    XCTAssertNil(coordinator.expandedSectionID, "No section should be expanded")
  }

  func testCollapseDifferentSectionDoesNothing() {
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should be expanded")

    coordinator.collapse("section2")

    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should still be expanded")
    XCTAssertEqual(coordinator.expandedSectionID, "section1", "Section1 should remain expanded")
  }

  // MARK: - Toggle Tests

  func testToggleCollapsedSectionExpands() {
    XCTAssertFalse(coordinator.isExpanded("section1"), "Section should be collapsed initially")

    coordinator.toggle("section1")

    XCTAssertTrue(coordinator.isExpanded("section1"), "Section should be expanded after toggle")
  }

  func testToggleExpandedSectionCollapses() {
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section should be expanded")

    coordinator.toggle("section1")

    XCTAssertFalse(coordinator.isExpanded("section1"), "Section should be collapsed after toggle")
    XCTAssertNil(coordinator.expandedSectionID, "No section should be expanded")
  }

  func testToggleDifferentSectionExpands() {
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should be expanded")

    coordinator.toggle("section2")

    XCTAssertFalse(coordinator.isExpanded("section1"), "Section1 should be collapsed")
    XCTAssertTrue(coordinator.isExpanded("section2"), "Section2 should be expanded")
  }

  // MARK: - CollapseAll Tests

  func testCollapseAllClearsExpandedSection() {
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"), "Section should be expanded")

    coordinator.collapseAll()

    XCTAssertFalse(coordinator.isExpanded("section1"), "Section should be collapsed")
    XCTAssertNil(coordinator.expandedSectionID, "No section should be expanded")
  }

  func testCollapseAllWhenNothingExpanded() {
    XCTAssertNil(coordinator.expandedSectionID, "Initially nothing expanded")

    coordinator.collapseAll()

    XCTAssertNil(coordinator.expandedSectionID, "Still nothing expanded")
  }

  // MARK: - isExpanded Tests

  func testIsExpandedReturnsFalseForNonExpandedSection() {
    coordinator.expand("section1")

    XCTAssertTrue(coordinator.isExpanded("section1"), "Section1 should be expanded")
    XCTAssertFalse(coordinator.isExpanded("section2"), "Section2 should not be expanded")
    XCTAssertFalse(coordinator.isExpanded("section3"), "Section3 should not be expanded")
  }

  func testIsExpandedReturnsFalseWhenNothingExpanded() {
    XCTAssertFalse(coordinator.isExpanded("section1"), "No section should be expanded")
    XCTAssertFalse(coordinator.isExpanded("section2"), "No section should be expanded")
  }

  // MARK: - Multiple Operations Tests

  func testMultipleOperationsSequence() {
    // Expand section1
    coordinator.expand("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"))

    // Toggle to collapse
    coordinator.toggle("section1")
    XCTAssertFalse(coordinator.isExpanded("section1"))

    // Toggle to expand again
    coordinator.toggle("section1")
    XCTAssertTrue(coordinator.isExpanded("section1"))

    // Expand section2 (should collapse section1)
    coordinator.expand("section2")
    XCTAssertFalse(coordinator.isExpanded("section1"))
    XCTAssertTrue(coordinator.isExpanded("section2"))

    // Collapse all
    coordinator.collapseAll()
    XCTAssertFalse(coordinator.isExpanded("section1"))
    XCTAssertFalse(coordinator.isExpanded("section2"))
  }
}
