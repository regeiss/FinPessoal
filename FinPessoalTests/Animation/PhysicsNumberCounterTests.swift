// FinPessoalTests/Animation/PhysicsNumberCounterTests.swift
import XCTest
import SwiftUI
@testable import FinPessoal

@MainActor
final class PhysicsNumberCounterTests: XCTestCase {

  func testInitialValue() {
    let counter = PhysicsNumberCounter(value: 1000.0, format: .currency(code: "BRL"))
    XCTAssertEqual(counter.value, 1000.0)
  }

  func testValueUpdate() {
    // Test with different initial value
    let counter = PhysicsNumberCounter(value: 2000.0, format: .currency(code: "BRL"))
    XCTAssertEqual(counter.value, 2000.0)
  }
}
