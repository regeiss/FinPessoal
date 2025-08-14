//
//  BudgetCategory.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct BudgetCategory: Codable, Identifiable {
  let id: String
  let name: String
  let icon: String
  let color: String
  let defaultAlertThreshold: Double
}
