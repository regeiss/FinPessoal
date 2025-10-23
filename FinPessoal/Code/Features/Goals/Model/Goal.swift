//
//  Goal.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

enum GoalCategory: String, CaseIterable, Codable {
  case emergency = "emergency"
  case vacation = "vacation"
  case house = "house"
  case car = "car"
  case education = "education"
  case investment = "investment"
  case wedding = "wedding"
  case retirement = "retirement"
  case other = "other"
  
  var displayName: String {
    switch self {
    case .emergency: return String(localized: "goal.category.emergency")
    case .vacation: return String(localized: "goal.category.vacation")
    case .house: return String(localized: "goal.category.house")
    case .car: return String(localized: "goal.category.car")
    case .education: return String(localized: "goal.category.education")
    case .investment: return String(localized: "goal.category.investment")
    case .wedding: return String(localized: "goal.category.wedding")
    case .retirement: return String(localized: "goal.category.retirement")
    case .other: return String(localized: "goal.category.other")
    }
  }
  
  var icon: String {
    switch self {
    case .emergency: return "shield.checkered"
    case .vacation: return "airplane"
    case .house: return "house"
    case .car: return "car"
    case .education: return "graduationcap"
    case .investment: return "chart.line.uptrend.xyaxis"
    case .wedding: return "heart"
    case .retirement: return "person.2"
    case .other: return "target"
    }
  }
  
  var color: String {
    switch self {
    case .emergency: return "red"
    case .vacation: return "blue"
    case .house: return "green"
    case .car: return "orange"
    case .education: return "purple"
    case .investment: return "mint"
    case .wedding: return "pink"
    case .retirement: return "brown"
    case .other: return "gray"
    }
  }

  var swiftUIColor: Color {
    switch self {
    case .emergency: return .red
    case .vacation: return .blue
    case .house: return .green
    case .car: return .orange
    case .education: return .purple
    case .investment: return .mint
    case .wedding: return .pink
    case .retirement: return .brown
    case .other: return .gray
    }
  }
}

struct Goal: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String
  let description: String?
  let targetAmount: Double
  let currentAmount: Double
  let targetDate: Date
  let category: GoalCategory
  let isActive: Bool
  let createdAt: Date
  let updatedAt: Date
  
  var progressPercentage: Double {
    guard targetAmount > 0 else { return 0 }
    return min((currentAmount / targetAmount) * 100, 100)
  }
  
  var remainingAmount: Double {
    return max(0, targetAmount - currentAmount)
  }
  
  var isCompleted: Bool {
    return currentAmount >= targetAmount
  }
  
  var daysRemaining: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let target = calendar.startOfDay(for: targetDate)
    let components = calendar.dateComponents([.day], from: today, to: target)
    return max(0, components.day ?? 0)
  }
  
  var monthlyContributionNeeded: Double {
    guard !isCompleted else { return 0 }
    let remaining = remainingAmount
    let monthsLeft = max(1, Double(daysRemaining) / 30.0)
    return remaining / monthsLeft
  }
}
