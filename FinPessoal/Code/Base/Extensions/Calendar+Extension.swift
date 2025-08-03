//
//  Calendar+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation

extension Calendar {
  func startOfMonth(for date: Date) -> Date? {
    let components = dateComponents([.year, .month], from: date)
    return self.date(from: components)
  }
  
  func endOfMonth(for date: Date) -> Date? {
    guard let startOfMonth = startOfMonth(for: date) else { return nil }
    guard let nextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth) else { return nil }
    return self.date(byAdding: .day, value: -1, to: nextMonth)
  }
}
