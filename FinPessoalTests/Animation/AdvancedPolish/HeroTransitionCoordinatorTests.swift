//
//  HeroTransitionCoordinatorTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class HeroTransitionCoordinatorTests: XCTestCase {

  var coordinator: HeroTransitionCoordinator!

  override func setUp() async throws {
    try await super.setUp()
    coordinator = HeroTransitionCoordinator()
  }

  override func tearDown() async throws {
    coordinator = nil
    try await super.tearDown()
  }

  func testInitialState() {
    XCTAssertNil(coordinator.activeTransition, "Initially no active transition")
    XCTAssertFalse(coordinator.isTransitioning, "Should not be transitioning initially")
  }

  func testBeginTransition() {
    coordinator.beginTransition(id: "test-transition")

    XCTAssertEqual(coordinator.activeTransition, "test-transition")
    XCTAssertTrue(coordinator.isTransitioning)
    XCTAssertTrue(coordinator.isActive("test-transition"))
  }

  func testEndTransition() {
    coordinator.beginTransition(id: "test-transition")
    coordinator.endTransition()

    XCTAssertNil(coordinator.activeTransition)
    XCTAssertFalse(coordinator.isTransitioning)
  }

  func testSingleTransitionOnly() {
    coordinator.beginTransition(id: "first")
    XCTAssertTrue(coordinator.isActive("first"))

    coordinator.beginTransition(id: "second")
    XCTAssertTrue(coordinator.isActive("second"))
    XCTAssertFalse(coordinator.isActive("first"))
  }
}
