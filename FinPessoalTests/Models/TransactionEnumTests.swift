//
//  TransactionEnumTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 26/10/25.
//

import XCTest
import SwiftUI
@testable import FinPessoal

final class TransactionEnumTests: XCTestCase {

  // MARK: - TransactionPeriod Tests

  func testTransactionPeriodDisplayNames() throws {
    XCTAssertFalse(TransactionPeriod.today.displayName.isEmpty)
    XCTAssertFalse(TransactionPeriod.thisWeek.displayName.isEmpty)
    XCTAssertFalse(TransactionPeriod.thisMonth.displayName.isEmpty)
    XCTAssertFalse(TransactionPeriod.all.displayName.isEmpty)
  }

  func testTransactionPeriodCaseIterable() throws {
    let allPeriods = TransactionPeriod.allCases
    XCTAssertEqual(allPeriods.count, 4)
    XCTAssertTrue(allPeriods.contains(.today))
    XCTAssertTrue(allPeriods.contains(.thisWeek))
    XCTAssertTrue(allPeriods.contains(.thisMonth))
    XCTAssertTrue(allPeriods.contains(.all))
  }

  // MARK: - TransactionType Tests

  func testTransactionTypeRawValues() throws {
    XCTAssertEqual(TransactionType.income.rawValue, "income")
    XCTAssertEqual(TransactionType.expense.rawValue, "expense")
    XCTAssertEqual(TransactionType.transfer.rawValue, "transfer")
  }

  func testTransactionTypeIcons() throws {
    XCTAssertEqual(TransactionType.income.icon, "plus.circle")
    XCTAssertEqual(TransactionType.expense.icon, "minus.circle")
    XCTAssertEqual(TransactionType.transfer.icon, "arrow.left.arrow.right.circle")
  }

  func testTransactionTypeDisplayNames() throws {
    XCTAssertFalse(TransactionType.income.displayName.isEmpty)
    XCTAssertFalse(TransactionType.expense.displayName.isEmpty)
    XCTAssertFalse(TransactionType.transfer.displayName.isEmpty)
  }

  // MARK: - TransactionCategory Tests

  func testTransactionCategoryIcons() throws {
    for category in TransactionCategory.allCases {
      XCTAssertFalse(category.icon.isEmpty, "\(category) should have an icon")
    }
  }

  func testTransactionCategoryDisplayNames() throws {
    for category in TransactionCategory.allCases {
      XCTAssertFalse(category.displayName.isEmpty, "\(category) should have a display name")
    }
  }

  func testTransactionCategoryColors() throws {
    for category in TransactionCategory.allCases {
      let color = category.swiftUIColor
      // Just verify that accessing the color doesn't crash
      XCTAssertNotNil(color)
    }
  }

  func testTransactionCategoryComparable() throws {
    let category1 = TransactionCategory.food
    let category2 = TransactionCategory.transport

    // Test that comparison works
    let result = category1 < category2 || category1 > category2 || category1 == category2
    XCTAssertTrue(result, "Categories should be comparable")
  }

  func testTransactionCategorySortOrder() throws {
    for category in TransactionCategory.allCases {
      XCTAssertGreaterThanOrEqual(category.sortOrder, 0, "\(category) should have a valid sort order")
      XCTAssertLessThan(category.sortOrder, 10, "\(category) sort order should be less than 10")
    }
  }

  func testTransactionCategorySortedByLogicalOrder() throws {
    let categories = TransactionCategory.allCases
    let sorted = TransactionCategory.sortedByLogicalOrder(Array(categories))

    XCTAssertEqual(sorted.count, categories.count)
    // Salary should be first (sortOrder = 0)
    XCTAssertEqual(sorted.first, .salary)
  }

  func testTransactionCategorySubcategories() throws {
    XCTAssertFalse(TransactionCategory.food.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.transport.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.entertainment.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.healthcare.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.shopping.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.bills.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.salary.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.investment.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.housing.subcategories.isEmpty)
    XCTAssertFalse(TransactionCategory.other.subcategories.isEmpty)
  }

  // MARK: - TransactionSubcategory Tests

  func testSubcategoryDisplayNames() throws {
    for subcategory in TransactionSubcategory.allCases {
      XCTAssertFalse(subcategory.displayName.isEmpty, "\(subcategory) should have a display name")
    }
  }

  func testSubcategoryIcons() throws {
    for subcategory in TransactionSubcategory.allCases {
      XCTAssertFalse(subcategory.icon.isEmpty, "\(subcategory) should have an icon")
    }
  }

  func testSubcategoryComparable() throws {
    let sub1 = TransactionSubcategory.restaurants
    let sub2 = TransactionSubcategory.groceries

    let result = sub1 < sub2 || sub1 > sub2 || sub1 == sub2
    XCTAssertTrue(result, "Subcategories should be comparable")
  }

  // MARK: - Specific Subcategory Arrays Tests

  func testFoodSubcategories() throws {
    let foodSubs = TransactionSubcategory.foodSubcategories
    XCTAssertTrue(foodSubs.contains(.restaurants))
    XCTAssertTrue(foodSubs.contains(.groceries))
    XCTAssertTrue(foodSubs.contains(.fastFood))
    XCTAssertTrue(foodSubs.contains(.delivery))
    XCTAssertTrue(foodSubs.contains(.coffee))
    XCTAssertTrue(foodSubs.contains(.alcohol))
  }

  func testTransportSubcategories() throws {
    let transportSubs = TransactionSubcategory.transportSubcategories
    XCTAssertTrue(transportSubs.contains(.fuel))
    XCTAssertTrue(transportSubs.contains(.publicTransport))
    XCTAssertTrue(transportSubs.contains(.taxi))
    XCTAssertTrue(transportSubs.contains(.parking))
    XCTAssertTrue(transportSubs.contains(.maintenance))
    XCTAssertTrue(transportSubs.contains(.insurance))
  }

  func testEntertainmentSubcategories() throws {
    let entertainmentSubs = TransactionSubcategory.entertainmentSubcategories
    XCTAssertTrue(entertainmentSubs.contains(.movies))
    XCTAssertTrue(entertainmentSubs.contains(.games))
    XCTAssertTrue(entertainmentSubs.contains(.concerts))
    XCTAssertTrue(entertainmentSubs.contains(.sports))
    XCTAssertTrue(entertainmentSubs.contains(.books))
    XCTAssertTrue(entertainmentSubs.contains(.streaming))
  }

  func testHealthcareSubcategories() throws {
    let healthcareSubs = TransactionSubcategory.healthcareSubcategories
    XCTAssertTrue(healthcareSubs.contains(.doctor))
    XCTAssertTrue(healthcareSubs.contains(.pharmacy))
    XCTAssertTrue(healthcareSubs.contains(.dental))
    XCTAssertTrue(healthcareSubs.contains(.hospital))
    XCTAssertTrue(healthcareSubs.contains(.therapy))
    XCTAssertTrue(healthcareSubs.contains(.supplements))
  }

  func testShoppingSubcategories() throws {
    let shoppingSubs = TransactionSubcategory.shoppingSubcategories
    XCTAssertTrue(shoppingSubs.contains(.clothing))
    XCTAssertTrue(shoppingSubs.contains(.electronics))
    XCTAssertTrue(shoppingSubs.contains(.homeGoods))
    XCTAssertTrue(shoppingSubs.contains(.beauty))
    XCTAssertTrue(shoppingSubs.contains(.gifts))
    XCTAssertTrue(shoppingSubs.contains(.accessories))
  }

  func testBillsSubcategories() throws {
    let billsSubs = TransactionSubcategory.billsSubcategories
    XCTAssertTrue(billsSubs.contains(.electricity))
    XCTAssertTrue(billsSubs.contains(.water))
    XCTAssertTrue(billsSubs.contains(.internet))
    XCTAssertTrue(billsSubs.contains(.phone))
    XCTAssertTrue(billsSubs.contains(.subscription))
    XCTAssertTrue(billsSubs.contains(.taxes))
  }

  func testSalarySubcategories() throws {
    let salarySubs = TransactionSubcategory.salarySubcategories
    XCTAssertTrue(salarySubs.contains(.primaryJob))
    XCTAssertTrue(salarySubs.contains(.secondaryJob))
    XCTAssertTrue(salarySubs.contains(.freelance))
    XCTAssertTrue(salarySubs.contains(.bonus))
    XCTAssertTrue(salarySubs.contains(.commission))
    XCTAssertTrue(salarySubs.contains(.benefits))
  }

  func testInvestmentSubcategories() throws {
    let investmentSubs = TransactionSubcategory.investmentSubcategories
    XCTAssertTrue(investmentSubs.contains(.stocks))
    XCTAssertTrue(investmentSubs.contains(.bonds))
    XCTAssertTrue(investmentSubs.contains(.realEstate))
    XCTAssertTrue(investmentSubs.contains(.cryptocurrency))
    XCTAssertTrue(investmentSubs.contains(.retirement))
    XCTAssertTrue(investmentSubs.contains(.savings))
  }

  func testHousingSubcategories() throws {
    let housingSubs = TransactionSubcategory.housingSubcategories
    XCTAssertTrue(housingSubs.contains(.rent))
    XCTAssertTrue(housingSubs.contains(.mortgage))
    XCTAssertTrue(housingSubs.contains(.repairs))
    XCTAssertTrue(housingSubs.contains(.furniture))
    XCTAssertTrue(housingSubs.contains(.utilities))
    XCTAssertTrue(housingSubs.contains(.cleaning))
  }

  func testOtherSubcategories() throws {
    let otherSubs = TransactionSubcategory.otherSubcategories
    XCTAssertTrue(otherSubs.contains(.fees))
    XCTAssertTrue(otherSubs.contains(.donations))
    XCTAssertTrue(otherSubs.contains(.education))
    XCTAssertTrue(otherSubs.contains(.pets))
    XCTAssertTrue(otherSubs.contains(.miscellaneous))
  }

  // MARK: - Integration Tests

  func testCategorySubcategoriesMatchStaticArrays() throws {
    XCTAssertEqual(
      Set(TransactionCategory.food.subcategories),
      Set(TransactionSubcategory.foodSubcategories)
    )
    XCTAssertEqual(
      Set(TransactionCategory.transport.subcategories),
      Set(TransactionSubcategory.transportSubcategories)
    )
    XCTAssertEqual(
      Set(TransactionCategory.entertainment.subcategories),
      Set(TransactionSubcategory.entertainmentSubcategories)
    )
  }

  func testAllSubcategoriesHaveValidRawValues() throws {
    for subcategory in TransactionSubcategory.allCases {
      XCTAssertFalse(subcategory.rawValue.isEmpty, "\(subcategory) should have a valid raw value")
    }
  }

  func testSpecificSubcategoryProperties() throws {
    // Test food subcategories
    XCTAssertEqual(TransactionSubcategory.restaurants.icon, "fork.knife.circle")
    XCTAssertEqual(TransactionSubcategory.groceries.icon, "cart")

    // Test transport subcategories
    XCTAssertEqual(TransactionSubcategory.fuel.icon, "fuelpump")
    XCTAssertEqual(TransactionSubcategory.taxi.icon, "car.circle")

    // Test healthcare subcategories
    XCTAssertEqual(TransactionSubcategory.doctor.icon, "stethoscope")
    XCTAssertEqual(TransactionSubcategory.pharmacy.icon, "pills")

    // Test investment subcategories
    XCTAssertEqual(TransactionSubcategory.stocks.icon, "chart.line.uptrend.xyaxis")
    XCTAssertEqual(TransactionSubcategory.cryptocurrency.icon, "bitcoinsign.circle")
  }

  // MARK: - Codable Tests

  func testTransactionTypeCodable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for type in TransactionType.allCases {
      let encoded = try encoder.encode(type)
      let decoded = try decoder.decode(TransactionType.self, from: encoded)
      XCTAssertEqual(type, decoded)
    }
  }

  func testTransactionCategoryCodable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    for category in TransactionCategory.allCases {
      let encoded = try encoder.encode(category)
      let decoded = try decoder.decode(TransactionCategory.self, from: encoded)
      XCTAssertEqual(category, decoded)
    }
  }

  func testTransactionSubcategoryCodable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    // Test a sample of subcategories
    let sampleSubcategories: [TransactionSubcategory] = [
      .restaurants, .fuel, .movies, .doctor, .clothing,
      .electricity, .primaryJob, .stocks, .rent, .fees
    ]

    for subcategory in sampleSubcategories {
      let encoded = try encoder.encode(subcategory)
      let decoded = try decoder.decode(TransactionSubcategory.self, from: encoded)
      XCTAssertEqual(subcategory, decoded)
    }
  }
}
