//
//  MockBillRepository.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation

/// Mock implementation of BillRepositoryProtocol for development and testing
class MockBillRepository: BillRepositoryProtocol {

  // MARK: - Properties

  private var bills: [Bill] = []
  var shouldFail = false
  var mockError: Error?
  var delay: TimeInterval = 0

  // MARK: - Initialization

  init() {
    setupMockData()
  }

  private func setupMockData() {
    let calendar = Calendar.current
    let now = Date()

    bills = [
      // Electricity bill - upcoming
      Bill(
        id: "bill-1",
        name: "Conta de Luz",
        amount: 250.00,
        dueDay: 15,
        category: .bills,
        subcategory: .electricity,
        accountId: "account-1",
        isPaid: false,
        isActive: true,
        notes: "Cemig",
        reminderDaysBefore: 3,
        lastPaidDate: calendar.date(byAdding: .month, value: -1, to: now),
        nextDueDate: calculateNextDueDate(dueDay: 15),
        userId: "mock-user-id",
        createdAt: calendar.date(byAdding: .month, value: -3, to: now)!,
        updatedAt: now
      ),

      // Internet bill - due soon
      Bill(
        id: "bill-2",
        name: "Internet",
        amount: 99.90,
        dueDay: getDayAfterTomorrow(),
        category: .bills,
        subcategory: .internet,
        accountId: "account-1",
        isPaid: false,
        isActive: true,
        notes: "Vivo Fibra",
        reminderDaysBefore: 3,
        lastPaidDate: calendar.date(byAdding: .month, value: -1, to: now),
        nextDueDate: calendar.date(byAdding: .day, value: 2, to: now)!,
        userId: "mock-user-id",
        createdAt: calendar.date(byAdding: .month, value: -6, to: now)!,
        updatedAt: now
      ),

      // Phone bill - paid
      Bill(
        id: "bill-3",
        name: "Celular",
        amount: 79.90,
        dueDay: 10,
        category: .bills,
        subcategory: .phone,
        accountId: "account-1",
        isPaid: true,
        isActive: true,
        notes: "Tim",
        reminderDaysBefore: 5,
        lastPaidDate: now,
        nextDueDate: calculateNextDueDate(dueDay: 10),
        userId: "mock-user-id",
        createdAt: calendar.date(byAdding: .year, value: -1, to: now)!,
        updatedAt: now
      ),

      // Water bill - overdue
      Bill(
        id: "bill-4",
        name: "Conta de Água",
        amount: 85.50,
        dueDay: getYesterday(),
        category: .bills,
        subcategory: .water,
        accountId: "account-1",
        isPaid: false,
        isActive: true,
        notes: "Copasa",
        reminderDaysBefore: 3,
        lastPaidDate: calendar.date(byAdding: .month, value: -1, to: now),
        nextDueDate: calendar.date(byAdding: .day, value: -1, to: now)!,
        userId: "mock-user-id",
        createdAt: calendar.date(byAdding: .month, value: -6, to: now)!,
        updatedAt: now
      ),

      // Streaming subscription
      Bill(
        id: "bill-5",
        name: "Netflix",
        amount: 55.90,
        dueDay: 25,
        category: .bills,
        subcategory: .subscription,
        accountId: "account-1",
        isPaid: false,
        isActive: true,
        notes: "Plano Premium",
        reminderDaysBefore: 2,
        lastPaidDate: calendar.date(byAdding: .month, value: -1, to: now),
        nextDueDate: calculateNextDueDate(dueDay: 25),
        userId: "mock-user-id",
        createdAt: calendar.date(byAdding: .month, value: -12, to: now)!,
        updatedAt: now
      )
    ]
  }

  // MARK: - Helper Methods

  private func calculateNextDueDate(dueDay: Int) -> Date {
    let calendar = Calendar.current
    let now = Date()
    var components = calendar.dateComponents([.year, .month], from: now)
    components.day = dueDay

    if let nextDate = calendar.date(from: components), nextDate > now {
      return nextDate
    } else {
      // Next month
      if let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) {
        components = calendar.dateComponents([.year, .month], from: nextMonth)
        components.day = dueDay
        return calendar.date(from: components) ?? now
      }
    }

    return now
  }

  private func getDayAfterTomorrow() -> Int {
    let calendar = Calendar.current
    if let date = calendar.date(byAdding: .day, value: 2, to: Date()) {
      return calendar.component(.day, from: date)
    }
    return 1
  }

  private func getYesterday() -> Int {
    let calendar = Calendar.current
    if let date = calendar.date(byAdding: .day, value: -1, to: Date()) {
      return calendar.component(.day, from: date)
    }
    return 1
  }

  private func simulateDelay() async {
    if delay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
  }

  private func checkForError() throws {
    if shouldFail {
      throw mockError ?? FirebaseError.databaseError("Mock error")
    }
  }

  // MARK: - BillRepositoryProtocol

  func fetchBills() async throws -> [Bill] {
    await simulateDelay()
    try checkForError()
    return bills.filter { $0.userId == "mock-user-id" }
  }

  func fetchBill(id: String) async throws -> Bill {
    await simulateDelay()
    try checkForError()

    guard let bill = bills.first(where: { $0.id == id }) else {
      throw FirebaseError.documentNotFound
    }

    return bill
  }

  func addBill(_ bill: Bill) async throws {
    await simulateDelay()
    try checkForError()
    bills.append(bill)
  }

  func updateBill(_ bill: Bill) async throws {
    await simulateDelay()
    try checkForError()

    guard let index = bills.firstIndex(where: { $0.id == bill.id }) else {
      throw FirebaseError.documentNotFound
    }

    bills[index] = bill
  }

  func deleteBill(_ billId: String) async throws {
    await simulateDelay()
    try checkForError()
    bills.removeAll { $0.id == billId }
  }

  func markBillAsPaid(_ billId: String) async throws {
    await simulateDelay()
    try checkForError()

    guard let index = bills.firstIndex(where: { $0.id == billId }) else {
      throw FirebaseError.documentNotFound
    }

    bills[index].markAsPaid()
  }

  func markBillAsUnpaid(_ billId: String) async throws {
    await simulateDelay()
    try checkForError()

    guard let index = bills.firstIndex(where: { $0.id == billId }) else {
      throw FirebaseError.documentNotFound
    }

    bills[index].markAsUnpaid()
  }

  func fetchBillsDueSoon() async throws -> [Bill] {
    await simulateDelay()
    try checkForError()

    return bills.filter { $0.isDueSoon && $0.isActive }
  }

  func fetchOverdueBills() async throws -> [Bill] {
    await simulateDelay()
    try checkForError()

    return bills.filter { $0.isOverdue && $0.isActive }
  }

  func calculateTotalUnpaidAmount() async throws -> Double {
    await simulateDelay()
    try checkForError()

    return bills
      .filter { !$0.isPaid && $0.isActive }
      .reduce(0) { $0 + $1.amount }
  }
}
