//
//  Account.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct Account: Identifiable, Codable {
  let id: String
  let name: String
  let type: AccountType
  let balance: Double
  let currency: String
  let isActive: Bool
  
  var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: balance)) ?? "R$ 0,00"
  }
}
