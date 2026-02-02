// FinPessoalTests/Animation/ParticleEmitterTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ParticleEmitterTests: XCTestCase {

  func testParticleEmitterInitialization() {
    let emitter = ParticleEmitter(preset: .goldShimmer)
    XCTAssertNotNil(emitter)
  }

  func testPresetConfigurations() {
    let gold = ParticleEmitter(preset: .goldShimmer)
    let celebration = ParticleEmitter(preset: .celebration)

    XCTAssertNotNil(gold)
    XCTAssertNotNil(celebration)
  }
}
