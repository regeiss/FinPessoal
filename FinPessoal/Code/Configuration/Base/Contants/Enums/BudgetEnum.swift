//
//  BudgetEnum.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation

enum BudgetPeriod: String, CaseIterable, Codable {
  case weekly = "Semanal"
  case monthly = "Mensal"
  case quarterly = "Trimestral"
  case yearly = "Anual"
  
  var icon: String {
    switch self {
    case .weekly: return "calendar.badge.clock"
    case .monthly: return "calendar"
    case .quarterly: return "calendar.badge.plus"
    case .yearly: return "calendar.circle"
    }
  }
  
  var displayName: String {
    switch self {
    case .weekly: return String(localized: "budget.period.weekly")
    case .monthly: return String(localized: "budget.period.monthly")
    case .quarterly: return String(localized: "budget.period.quarterly")
    case .yearly: return String(localized: "budget.period.yearly")
    }
  }
  
  func nextPeriodStart(from date: Date) -> Date {
    let calendar = Calendar.current
    switch self {
    case .weekly:
      return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
    case .monthly:
      return calendar.date(byAdding: .month, value: 1, to: date) ?? date
    case .quarterly:
      return calendar.date(byAdding: .month, value: 3, to: date) ?? date
    case .yearly:
      return calendar.date(byAdding: .year, value: 1, to: date) ?? date
    }
  }
}

