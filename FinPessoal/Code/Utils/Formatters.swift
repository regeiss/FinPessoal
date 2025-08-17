//
//  Formatters.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import Foundation
class CurrencyFormatter {
  static let shared = CurrencyFormatter()
  
  private let formatter: NumberFormatter
  
  private init() {
    formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.currencyCode = "BRL"
  }
  
  func string(from amount: Double, currency: String = "BRL") -> String {
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
  
  func string(from amount: NSNumber, currency: String = "BRL") -> String {
    formatter.currencyCode = currency
    return formatter.string(from: amount) ?? "R$ 0,00"
  }
  
  func value(from string: String) -> Double? {
    // Remove símbolos de moeda e espaços
    let cleanString = string
      .replacingOccurrences(of: "R$", with: "")
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: ".", with: "")
      .replacingOccurrences(of: ",", with: ".")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    return Double(cleanString)
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
  
  static let transactionFull: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()
  
  static let month: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()
  
  static let monthShort: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()
  
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  static let dayOfWeek: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter
  }()
}

// MARK: - Number Formatters

extension NumberFormatter {
  static let currency: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.currencyCode = "BRL"
    return formatter
  }()
  
  static let decimal: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter
  }()
  
  static let percentage: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.maximumFractionDigits = 1
    return formatter
  }()
}

// MARK: - Helper Extensions

extension Double {
  var formattedAsCurrency: String {
    return CurrencyFormatter.shared.string(from: self)
  }
  
  var formattedAsPercentage: String {
    return NumberFormatter.percentage.string(from: NSNumber(value: self)) ?? "0%"
  }
  
  var formattedAsDecimal: String {
    return NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "0,00"
  }
}

extension Date {
  var formattedAsTransaction: String {
    return DateFormatter.transaction.string(from: self)
  }
  
  var formattedAsMonth: String {
    return DateFormatter.month.string(from: self)
  }
  
  var formattedAsMonthShort: String {
    return DateFormatter.monthShort.string(from: self)
  }
  
  var formattedAsDayOfWeek: String {
    return DateFormatter.dayOfWeek.string(from: self)
  }
}

// MARK: - Currency Helper

struct CurrencyHelper {
  static func format(_ amount: Double, style: CurrencyStyle = .currency) -> String {
    switch style {
    case .currency:
      return CurrencyFormatter.shared.string(from: amount)
    case .decimal:
      return NumberFormatter.decimal.string(from: NSNumber(value: amount)) ?? "0,00"
    case .abbreviated:
      return formatAbbreviated(amount)
    }
  }
  
  static func formatAbbreviated(_ amount: Double) -> String {
    let absAmount = abs(amount)
    let sign = amount < 0 ? "-" : ""
    
    if absAmount >= 1_000_000 {
      return "\(sign)R$ \(String(format: "%.1f", absAmount / 1_000_000))M"
    } else if absAmount >= 1_000 {
      return "\(sign)R$ \(String(format: "%.1f", absAmount / 1_000))K"
    } else {
      return "\(sign)R$ \(String(format: "%.0f", absAmount))"
    }
  }
  
  static func parseAmount(_ text: String) -> Double? {
    return CurrencyFormatter.shared.value(from: text)
  }
}

enum CurrencyStyle {
  case currency    // R$ 1.234,56
  case decimal     // 1.234,56
  case abbreviated // R$ 1.2K
}
