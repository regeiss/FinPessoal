//
//  Double+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import Foundation

extension Double {
  func formatted(as currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: self)) ?? ""
  }
}
