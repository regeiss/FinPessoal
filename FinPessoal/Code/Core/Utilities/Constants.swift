//
//  Constants.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation

enum FirebaseConstants {
  static let usersCollection = "users"
  static let accountsCollection = "accounts"
  static let transactionsCollection = "transactions"
  static let budgetsCollection = "budgets"
  static let goalsCollection = "goals"
}

enum AppConstants {
  static let defaultCurrency = "BRL"
  static let defaultLanguage = "pt-BR"
  static let maxTransactionsPerLoad = 50
}

enum ValidationConstants {
  static let minPasswordLength = 6
  static let maxAccountNameLength = 50
  static let maxTransactionDescriptionLength = 100
}
