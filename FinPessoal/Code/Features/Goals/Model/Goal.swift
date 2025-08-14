//
//  Goal.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct Goal: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String
  let targetAmount: Double
  let currentAmount: Double
  let targetDate: Date
  let category: String
  let isActive: Bool
  let createdAt: Date
  
  var progressPercentage: Double {
    guard targetAmount > 0 else { return 0 }
    return (currentAmount / targetAmount) * 100
  }
  
  var remainingAmount: Double {
    return max(0, targetAmount - currentAmount)
  }
}
