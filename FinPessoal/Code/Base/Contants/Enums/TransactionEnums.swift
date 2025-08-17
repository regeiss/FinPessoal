//
//  TransactionEnums.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import Foundation

enum TransactionType: String, CaseIterable, Codable {
  case income = "income"
  case expense = "expense"
  
  var displayName: String {
    switch self {
    case .income: return "Receita"
    case .expense: return "Despesa"
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
    case .food: return "Alimentação"
    case .transport: return "Transporte"
    case .entertainment: return "Entretenimento"
    case .healthcare: return "Saúde"
    case .shopping: return "Compras"
    case .bills: return "Contas"
    case .salary: return "Salário"
    case .investment: return "Investimento"
    case .housing: return "Moradia"
    case .other: return "Outros"
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
  
  static func < (lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {
    return lhs.displayName < rhs.displayName
  }
}
