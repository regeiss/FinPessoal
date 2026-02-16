//
//  HeroTransitionIntegrationTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/02/26.
//

import XCTest
@testable import FinPessoal
import SwiftUI

@MainActor
final class HeroTransitionIntegrationTests: XCTestCase {

  func testHeroTransitionLinkExists() {
    // Basic compilation test
    let namespace = Namespace().wrappedValue
    let testItem = TestItem(id: "1", name: "Test")

    // This should compile
    let _ = HeroTransitionLink(
      item: testItem,
      namespace: namespace
    ) {
      Text("Source")
    } destination: { item in
      Text("Destination: \(item.name)")
    }

    XCTAssertTrue(true, "HeroTransitionLink compiles")
  }
}

// Test model
struct TestItem: Identifiable {
  let id: String
  let name: String
}
