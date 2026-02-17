//
//  CelebrationFactoryTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 17/02/26.
//

import XCTest
@testable import FinPessoal

final class CelebrationFactoryTests: XCTestCase {

  // MARK: - Goal Category Tests

  func testVacationConfigHasConfettiPreset() {
    let config = CelebrationFactory.config(for: .vacation)
    XCTAssertEqual(config.particlePreset, .confetti)
  }

  func testWeddingConfigHasHeartsPreset() {
    let config = CelebrationFactory.config(for: .wedding)
    XCTAssertEqual(config.particlePreset, .hearts)
  }

  func testHouseConfigHasSparklePreset() {
    let config = CelebrationFactory.config(for: .house)
    XCTAssertEqual(config.particlePreset, .sparkle)
  }

  func testRetirementConfigHasStarsPreset() {
    let config = CelebrationFactory.config(for: .retirement)
    XCTAssertEqual(config.particlePreset, .stars)
  }

  func testEducationConfigHasSparklePreset() {
    let config = CelebrationFactory.config(for: .education)
    XCTAssertEqual(config.particlePreset, .sparkle)
  }

  func testCarConfigHasNoParticles() {
    let config = CelebrationFactory.config(for: .car)
    XCTAssertNil(config.particlePreset)
  }

  func testVacationConfigHasMessage() {
    let config = CelebrationFactory.config(for: .vacation)
    XCTAssertNotNil(config.message)
  }

  func testCarConfigHasNoMessage() {
    let config = CelebrationFactory.config(for: .car)
    XCTAssertNil(config.message)
  }

  // MARK: - Milestone Tier Tests

  func testSmallMilestoneTierAt1000() {
    XCTAssertEqual(MilestoneTier.tier(for: 1000), .small)
  }

  func testMediumMilestoneTierAt5000() {
    XCTAssertEqual(MilestoneTier.tier(for: 5000), .medium)
  }

  func testLargeMilestoneTierAt25000() {
    XCTAssertEqual(MilestoneTier.tier(for: 25000), .large)
  }

  func testEpicMilestoneTierAt100000() {
    XCTAssertEqual(MilestoneTier.tier(for: 100000), .epic)
  }

  func testSmallMilestoneTierAt4999() {
    XCTAssertEqual(MilestoneTier.tier(for: 4999), .small)
  }

  func testMilestoneCelebrationConfigHasCoinsPreset() {
    let config = CelebrationFactory.config(for: .small)
    XCTAssertEqual(config.particlePreset, .coinsBurst)
  }

  func testEpicMilestoneDurationIsLonger() {
    let small = CelebrationFactory.config(for: .small)
    let epic = CelebrationFactory.config(for: .epic)
    XCTAssertGreaterThan(epic.duration, small.duration)
  }
}
