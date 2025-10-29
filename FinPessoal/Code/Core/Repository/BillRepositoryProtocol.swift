//
//  BillRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation

/// Protocol defining bill repository operations
protocol BillRepositoryProtocol {
  /// Fetch all bills for the current user
  func fetchBills() async throws -> [Bill]

  /// Fetch a specific bill by ID
  func fetchBill(id: String) async throws -> Bill

  /// Add a new bill
  func addBill(_ bill: Bill) async throws

  /// Update an existing bill
  func updateBill(_ bill: Bill) async throws

  /// Delete a bill
  func deleteBill(_ billId: String) async throws

  /// Mark a bill as paid
  func markBillAsPaid(_ billId: String) async throws

  /// Mark a bill as unpaid
  func markBillAsUnpaid(_ billId: String) async throws

  /// Fetch bills due soon (within reminder days)
  func fetchBillsDueSoon() async throws -> [Bill]

  /// Fetch overdue bills
  func fetchOverdueBills() async throws -> [Bill]

  /// Calculate total amount of unpaid bills
  func calculateTotalUnpaidAmount() async throws -> Double
}
