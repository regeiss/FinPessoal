//
//  DateFormatter+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import Foundation

extension DateFormatter {
  static let transactionGrouping: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.dateFormat = "EEEE, d 'de' MMMM"
    return formatter
  }()
}
