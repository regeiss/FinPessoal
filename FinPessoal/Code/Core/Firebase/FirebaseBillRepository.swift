//
//  FirebaseBillRepository.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//  Converted to Realtime Database on 24/12/25
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

/// Firebase Realtime Database implementation of BillRepositoryProtocol
class FirebaseBillRepository: BillRepositoryProtocol {

  // MARK: - Properties

  private let database = Database.database().reference()
  private let billsPath = "bills"

  // MARK: - Private Methods

  private func getCurrentUserId() throws -> String {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw AuthError.noCurrentUser
    }
    return userId
  }

  // MARK: - BillRepositoryProtocol

  func fetchBills() async throws -> [Bill] {
    let userId = try getCurrentUserId()

    let snapshot = try await database
      .child(billsPath)
      .child(userId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let bills = try data.compactMap { (billId, billData) -> Bill? in
      var mutableData = billData
      mutableData["id"] = billId
      return try Bill.fromDictionary(mutableData)
    }

    return bills.sorted { $0.nextDueDate < $1.nextDueDate }
  }

  func fetchBill(id: String) async throws -> Bill {
    let userId = try getCurrentUserId()

    let snapshot = try await database
      .child(billsPath)
      .child(userId)
      .child(id)
      .getData()

    guard let data = snapshot.value as? [String: Any] else {
      throw FirebaseError.documentNotFound
    }

    var mutableData = data
    mutableData["id"] = id
    return try Bill.fromDictionary(mutableData)
  }

  func addBill(_ bill: Bill) async throws {
    let userId = try getCurrentUserId()
    let billData = try bill.toDictionary()

    try await database
      .child(billsPath)
      .child(userId)
      .child(bill.id)
      .setValue(billData)
  }

  func updateBill(_ bill: Bill) async throws {
    let userId = try getCurrentUserId()

    var updatedBill = bill
    updatedBill.updatedAt = Date()

    let billData = try updatedBill.toDictionary()

    try await database
      .child(billsPath)
      .child(userId)
      .child(bill.id)
      .updateChildValues(billData)
  }

  func deleteBill(_ billId: String) async throws {
    let userId = try getCurrentUserId()

    try await database
      .child(billsPath)
      .child(userId)
      .child(billId)
      .removeValue()
  }

  func markBillAsPaid(_ billId: String) async throws {
    var bill = try await fetchBill(id: billId)
    bill.markAsPaid()
    try await updateBill(bill)
  }

  func markBillAsUnpaid(_ billId: String) async throws {
    var bill = try await fetchBill(id: billId)
    bill.markAsUnpaid()
    try await updateBill(bill)
  }

  func fetchBillsDueSoon() async throws -> [Bill] {
    let allBills = try await fetchBills()
    return allBills.filter { $0.isDueSoon && $0.isActive }
  }

  func fetchOverdueBills() async throws -> [Bill] {
    let allBills = try await fetchBills()
    return allBills.filter { $0.isOverdue && $0.isActive }
  }

  func fetchUnpaidBills() async throws -> [Bill] {
    let allBills = try await fetchBills()
    return allBills.filter { !$0.isPaid && $0.isActive }
  }

  func calculateTotalUnpaidAmount() async throws -> Double {
    let unpaidBills = try await fetchUnpaidBills()
    return unpaidBills.reduce(0) { $0 + $1.amount }
  }
}
