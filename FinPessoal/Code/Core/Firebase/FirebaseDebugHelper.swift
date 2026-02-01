//
//  FirebaseDebugHelper.swift
//  FinPessoal
//
//  Created by Claude Code on 24/12/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseDebugHelper {
  static func debugFirebaseAuth() {
    print("\n=== Firebase Auth Debug ===")

    if let currentUser = Auth.auth().currentUser {
      print("✅ User is authenticated")
      print("   User ID (UID): \(currentUser.uid)")
      print("   Email: \(currentUser.email ?? "N/A")")
      print("   Display Name: \(currentUser.displayName ?? "N/A")")
      print("   Email Verified: \(currentUser.isEmailVerified)")
    } else {
      print("❌ NO USER AUTHENTICATED")
      print("   This is the problem! User must be logged in to write to database.")
    }

    print("========================\n")
  }

  static func testTransactionWrite(userId: String, transactionId: String = "test-123") async {
    print("\n=== Testing Transaction Write ===")
    print("Attempting to write to: transactions/\(userId)/\(transactionId)")

    let database = Database.database().reference()
    let testData: [String: Any] = [
      "description": "Test Transaction",
      "amount": 100.0,
      "type": "expense",
      "date": Date().timeIntervalSince1970
    ]

    do {
      try await database
        .child("transactions")
        .child(userId)
        .child(transactionId)
        .setValue(testData)

      print("✅ SUCCESS: Transaction written successfully!")

      // Clean up test data
      try await database
        .child("transactions")
        .child(userId)
        .child(transactionId)
        .removeValue()
      print("🧹 Test data cleaned up")

    } catch {
      print("❌ ERROR: Failed to write transaction")
      print("   Error: \(error.localizedDescription)")
      print("   Error type: \(type(of: error))")

      // Check auth status
      if Auth.auth().currentUser == nil {
        print("   → Problem: User not authenticated!")
      } else if let currentUserId = Auth.auth().currentUser?.uid, currentUserId != userId {
        print("   → Problem: User ID mismatch!")
        print("      Authenticated as: \(currentUserId)")
        print("      Trying to write to: \(userId)")
      }
    }

    print("================================\n")
  }
}
