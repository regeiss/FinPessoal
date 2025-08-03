//
//  Formatters.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation

class CurrencyFormatter {
  static let shared = CurrencyFormatter()
  
  private let formatter: NumberFormatter
  
  private init() {
    formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR")
  }
  
  func string(from amount: Double, currency: String = "BRL") -> String {
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

extension DateFormatter {
  static let transaction: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()
  
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
}
