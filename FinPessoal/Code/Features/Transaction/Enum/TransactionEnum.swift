//
//  TransactionEnum.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import Foundation

enum TransactionPeriod: CaseIterable {
  case today
  case thisWeek
  case thisMonth
  case all
  
  var displayName: String {
    switch self {
    case .today: return String(localized: "transactions.filter.today")
    case .thisWeek: return String(localized: "transactions.filter.week")
    case .thisMonth: return String(localized: "transactions.filter.month")
    case .all: return String(localized: "transactions.filter.all")
    }
  }
}

enum TransactionType: String, CaseIterable, Codable {
  case income = "income"
  case expense = "expense"
  
  var displayName: String {
    switch self {
    case .income: return String(localized: "transaction.type.income")
    case .expense: return String(localized: "transaction.type.expense")
    }
  }
}

enum TransactionCategory: String, CaseIterable, Codable, Comparable {
  case food = "food"
  case transport = "transport"
  case entertainment = "entertainment"
  case healthcare = "healthcare"
  case shopping = "shopping"
  case bills = "bills"
  case salary = "salary"
  case investment = "investment"
  case other = "other"
  case housing = "housing"
  
  var displayName: String {
    switch self {
    case .food: return String(localized: "transaction.category.food")
    case .transport: return String(localized: "transaction.category.transport")
    case .entertainment: return String(localized: "transaction.category.entertainment")
    case .healthcare: return String(localized: "transaction.category.healthcare")
    case .shopping: return String(localized: "transaction.category.shopping")
    case .bills: return String(localized: "transaction.category.bills")
    case .salary: return String(localized: "transaction.category.salary")
    case .investment: return String(localized: "transaction.category.investment")
    case .housing: return String(localized: "transaction.category.housing")
    case .other: return String(localized: "transaction.category.other")
    }
  }
  
  var icon: String {
    switch self {
    case .food: return "fork.knife"
    case .transport: return "car"
    case .entertainment: return "gamecontroller"
    case .healthcare: return "cross"
    case .shopping: return "bag"
    case .bills: return "doc.text"
    case .salary: return "dollarsign.circle"
    case .investment: return "chart.line.uptrend.xyaxis"
    case .housing: return "house"
    case .other: return "questionmark.circle"
    }
  }
  
  
  
  // MARK: - Comparable Implementation
  static func < (lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {
    return lhs.displayName < rhs.displayName
  }
  
  // Ordem customizada para organização lógica (opcional)
  var sortOrder: Int {
    switch self {
    case .salary: return 0  // Receitas primeiro
    case .investment: return 1
    case .food: return 2  // Despesas essenciais
    case .healthcare: return 3
    case .bills: return 4
    case .transport: return 5  // Despesas de mobilidade
    case .shopping: return 6  // Despesas opcionais
    case .entertainment: return 7
    case .other: return 8
    case .housing: return 9
    }
  }
  
  // Método para ordenação customizada (alternativa)
  static func sortedByLogicalOrder(_ categories: [TransactionCategory])
  -> [TransactionCategory]
  {
    return categories.sorted { $0.sortOrder < $1.sortOrder }
  }
}
