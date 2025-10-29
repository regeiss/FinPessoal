//
//  FirebaseBillRepository.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

/// Firebase implementation of BillRepositoryProtocol
class FirebaseBillRepository: BillRepositoryProtocol {

  // MARK: - Properties

  private let db = Firestore.firestore()
  private let collectionName = "bills"

  // MARK: - Private Methods

  private func getCurrentUserId() throws -> String {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw AuthError.noCurrentUser
    }
    return userId
  }

  private func billsCollection() throws -> CollectionReference {
    let userId = try getCurrentUserId()
    return db.collection("users").document(userId).collection(collectionName)
  }

  // MARK: - BillRepositoryProtocol

  func fetchBills() async throws -> [Bill] {
    let collection = try billsCollection()

    let snapshot = try await collection
      .order(by: "nextDueDate", descending: false)
      .getDocuments()

    return try snapshot.documents.compactMap { document in
      try Bill.fromDictionary(document.data())
    }
  }

  func fetchBill(id: String) async throws -> Bill {
    let collection = try billsCollection()

    let document = try await collection.document(id).getDocument()

    guard let data = document.data() else {
      throw FirebaseError.documentNotFound
    }

    return try Bill.fromDictionary(data)
  }

  func addBill(_ bill: Bill) async throws {
    let collection = try billsCollection()
    let billData = try bill.toDictionary()

    try await collection.document(bill.id).setData(billData)
  }

  func updateBill(_ bill: Bill) async throws {
    let collection = try billsCollection()

    var updatedBill = bill
    updatedBill.updatedAt = Date()

    let billData = try updatedBill.toDictionary()

    try await collection.document(bill.id).updateData(billData)
  }

  func deleteBill(_ billId: String) async throws {
    let collection = try billsCollection()

    try await collection.document(billId).delete()
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

  func calculateTotalUnpaidAmount() async throws -> Double {
    let allBills = try await fetchBills()
    return allBills
      .filter { !$0.isPaid && $0.isActive }
      .reduce(0) { $0 + $1.amount }
  }
}
