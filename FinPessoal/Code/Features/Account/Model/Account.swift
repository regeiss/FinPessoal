//
//  Account.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct Account: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String
  let type: AccountType
  let balance: Double
  let currency: String
  
  enum AccountType: String, Codable, CaseIterable {
    case checking = "checking"
    case savings = "savings"
    
    var localizedName: String {
      switch self {
      case .checking:
        return NSLocalizedString("account.type.checking", comment: "Checking account")
      case .savings:
        return NSLocalizedString("account.type.savings", comment: "Savings account")
      }
    }
  }
}
