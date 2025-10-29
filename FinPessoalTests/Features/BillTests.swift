//
//  BillTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 26/10/25.
//

import XCTest
@testable import FinPessoal

final class BillTests: XCTestCase {

  // MARK: - Initialization Tests

  func testBillInitialization() throws {
    let calendar = Calendar.current
    let now = Date()
    let nextDueDate = calendar.date(byAdding: .month, value: 1, to: now)!

    let bill = Bill(
      id: "test-bill-id",
      name: "Internet Bill",
      amount: 99.90,
      dueDay: 15,
      category: .bills,
      subcategory: .internet,
      accountId: "test-account-id",
      isPaid: false,
      isActive: true,
      notes: "Test notes",
      reminderDaysBefore: 3,
      lastPaidDate: nil,
      nextDueDate: nextDueDate,
      userId: "test-user-id",
      createdAt: now,
      updatedAt: now
    )

    XCTAssertEqual(bill.id, "test-bill-id")
    XCTAssertEqual(bill.name, "Internet Bill")
    XCTAssertEqual(bill.amount, 99.90)
    XCTAssertEqual(bill.dueDay, 15)
    XCTAssertEqual(bill.category, .bills)
    XCTAssertEqual(bill.subcategory, .internet)
    XCTAssertEqual(bill.accountId, "test-account-id")
    XCTAssertFalse(bill.isPaid)
    XCTAssertTrue(bill.isActive)
    XCTAssertEqual(bill.notes, "Test notes")
    XCTAssertEqual(bill.reminderDaysBefore, 3)
    XCTAssertEqual(bill.userId, "test-user-id")
  }

  // MARK: - Computed Properties Tests

  func testFormattedAmount() throws {
    let bill = createTestBill(amount: 150.50)
    XCTAssertEqual(bill.formattedAmount, "R$ 150,50")
  }

  func testDaysUntilDue() throws {
    let calendar = Calendar.current
    let nextDueDate = calendar.date(byAdding: .day, value: 5, to: Date())!
    let bill = createTestBill(nextDueDate: nextDueDate)

    XCTAssertEqual(bill.daysUntilDue, 5)
  }

  func testIsOverdue() throws {
    let calendar = Calendar.current
    let overdueDate = calendar.date(byAdding: .day, value: -1, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: overdueDate)

    XCTAssertTrue(bill.isOverdue)
  }

  func testIsNotOverdueWhenPaid() throws {
    let calendar = Calendar.current
    let overdueDate = calendar.date(byAdding: .day, value: -1, to: Date())!
    let bill = createTestBill(isPaid: true, nextDueDate: overdueDate)

    XCTAssertFalse(bill.isOverdue)
  }

  func testIsDueSoon() throws {
    let calendar = Calendar.current
    let dueSoonDate = calendar.date(byAdding: .day, value: 2, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: dueSoonDate, reminderDaysBefore: 3)

    XCTAssertTrue(bill.isDueSoon)
  }

  func testIsNotDueSoonWhenFarAway() throws {
    let calendar = Calendar.current
    let farDate = calendar.date(byAdding: .day, value: 10, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: farDate, reminderDaysBefore: 3)

    XCTAssertFalse(bill.isDueSoon)
  }

  // MARK: - Status Tests

  func testStatusPaid() throws {
    let bill = createTestBill(isPaid: true)
    XCTAssertEqual(bill.status, .paid)
  }

  func testStatusOverdue() throws {
    let calendar = Calendar.current
    let overdueDate = calendar.date(byAdding: .day, value: -1, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: overdueDate)

    XCTAssertEqual(bill.status, .overdue)
  }

  func testStatusDueSoon() throws {
    let calendar = Calendar.current
    let dueSoonDate = calendar.date(byAdding: .day, value: 2, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: dueSoonDate, reminderDaysBefore: 3)

    XCTAssertEqual(bill.status, .dueSoon)
  }

  func testStatusUpcoming() throws {
    let calendar = Calendar.current
    let upcomingDate = calendar.date(byAdding: .day, value: 10, to: Date())!
    let bill = createTestBill(isPaid: false, nextDueDate: upcomingDate)

    XCTAssertEqual(bill.status, .upcoming)
  }

  // MARK: - Mark as Paid Tests

  func testMarkAsPaid() throws {
    var bill = createTestBill(isPaid: false)
    let originalDueDate = bill.nextDueDate

    bill.markAsPaid()

    XCTAssertTrue(bill.isPaid)
    XCTAssertNotNil(bill.lastPaidDate)
    XCTAssertNotEqual(bill.nextDueDate, originalDueDate)
    XCTAssertGreaterThan(bill.nextDueDate, originalDueDate)
  }

  func testMarkAsUnpaid() throws {
    var bill = createTestBill(isPaid: true)
    bill.lastPaidDate = Date()

    bill.markAsUnpaid()

    XCTAssertFalse(bill.isPaid)
    XCTAssertNil(bill.lastPaidDate)
  }

  // MARK: - Next Due Date Calculation Tests

  func testCalculateNextDueDate() throws {
    let bill = createTestBill(dueDay: 15)
    let now = Date()

    let nextDueDate = bill.calculateNextDueDate(after: now)

    let calendar = Calendar.current
    let day = calendar.component(.day, from: nextDueDate)

    XCTAssertEqual(day, 15)
    XCTAssertGreaterThan(nextDueDate, now)
  }

  // MARK: - Firestore Conversion Tests

  func testToDictionary() throws {
    let bill = createTestBill()
    let dictionary = try bill.toDictionary()

    XCTAssertEqual(dictionary["id"] as? String, bill.id)
    XCTAssertEqual(dictionary["name"] as? String, bill.name)
    XCTAssertEqual(dictionary["amount"] as? Double, bill.amount)
    XCTAssertEqual(dictionary["dueDay"] as? Int, bill.dueDay)
    XCTAssertEqual(dictionary["category"] as? String, bill.category.rawValue)
    XCTAssertEqual(dictionary["accountId"] as? String, bill.accountId)
    XCTAssertEqual(dictionary["isPaid"] as? Bool, bill.isPaid)
    XCTAssertEqual(dictionary["isActive"] as? Bool, bill.isActive)
    XCTAssertEqual(dictionary["reminderDaysBefore"] as? Int, bill.reminderDaysBefore)
    XCTAssertEqual(dictionary["userId"] as? String, bill.userId)
  }

  func testFromDictionary() throws {
    let now = Date()
    let nextDueDate = Calendar.current.date(byAdding: .month, value: 1, to: now)!

    let dictionary: [String: Any] = [
      "id": "dict-bill-id",
      "name": "Dictionary Bill",
      "amount": 75.50,
      "dueDay": 10,
      "category": "bills",
      "subcategory": "electricity",
      "accountId": "dict-account-id",
      "isPaid": false,
      "isActive": true,
      "notes": "Test notes",
      "reminderDaysBefore": 5,
      "nextDueDate": nextDueDate.timeIntervalSince1970,
      "userId": "dict-user-id",
      "createdAt": now.timeIntervalSince1970,
      "updatedAt": now.timeIntervalSince1970
    ]

    let bill = try Bill.fromDictionary(dictionary)

    XCTAssertEqual(bill.id, "dict-bill-id")
    XCTAssertEqual(bill.name, "Dictionary Bill")
    XCTAssertEqual(bill.amount, 75.50)
    XCTAssertEqual(bill.dueDay, 10)
    XCTAssertEqual(bill.category, .bills)
    XCTAssertEqual(bill.subcategory, .electricity)
    XCTAssertEqual(bill.accountId, "dict-account-id")
    XCTAssertFalse(bill.isPaid)
    XCTAssertTrue(bill.isActive)
    XCTAssertEqual(bill.notes, "Test notes")
    XCTAssertEqual(bill.reminderDaysBefore, 5)
    XCTAssertEqual(bill.userId, "dict-user-id")
  }

  func testFromDictionaryWithInvalidData() throws {
    let invalidDictionary: [String: Any] = [
      "id": "invalid-bill",
      "name": "Invalid Bill"
      // Missing required fields
    ]

    XCTAssertThrowsError(try Bill.fromDictionary(invalidDictionary))
  }

  // MARK: - Helper Methods

  private func createTestBill(
    id: String = "test-bill-id",
    name: String = "Test Bill",
    amount: Double = 100.0,
    dueDay: Int = 15,
    category: TransactionCategory = .bills,
    subcategory: TransactionSubcategory? = .internet,
    accountId: String = "test-account-id",
    isPaid: Bool = false,
    isActive: Bool = true,
    notes: String? = "Test notes",
    reminderDaysBefore: Int = 3,
    lastPaidDate: Date? = nil,
    nextDueDate: Date? = nil,
    userId: String = "test-user-id"
  ) -> Bill {
    let now = Date()
    let dueDate = nextDueDate ?? Calendar.current.date(byAdding: .month, value: 1, to: now)!

    return Bill(
      id: id,
      name: name,
      amount: amount,
      dueDay: dueDay,
      category: category,
      subcategory: subcategory,
      accountId: accountId,
      isPaid: isPaid,
      isActive: isActive,
      notes: notes,
      reminderDaysBefore: reminderDaysBefore,
      lastPaidDate: lastPaidDate,
      nextDueDate: dueDate,
      userId: userId,
      createdAt: now,
      updatedAt: now
    )
  }
}
