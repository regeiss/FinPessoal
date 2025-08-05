//
//  Enums.swift
//  Financas pessoais
//
//  Created by Roberto Edgar Geiss on 13/07/25.
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
  case food = "alimentação"
  case transport = "transporte"
  case entertainment = "entreteinimento"
  case healthcare = "saúde"
  case shopping = "compras"
  case bills = "contas"
  case salary = "salario"
  case investment = "investimentos"
  case other = "outros"
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
