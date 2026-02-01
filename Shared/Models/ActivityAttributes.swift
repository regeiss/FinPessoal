//
//  ActivityAttributes.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation
import ActivityKit

// MARK: - Bill Reminder Activity

/// Live Activity for bill payment reminders
struct BillReminderAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var daysUntilDue: Int
    var isPaid: Bool
  }

  var billId: String
  var billName: String
  var amount: Double
  var dueDate: Date
  var categoryIcon: String
}

// MARK: - Budget Alert Activity

/// Live Activity for budget threshold alerts
struct BudgetAlertAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var currentSpent: Double
    var percentageUsed: Double
  }

  var budgetId: String
  var budgetName: String
  var budgetLimit: Double
  var categoryIcon: String
}

// MARK: - Goal Milestone Activity

/// Live Activity for goal progress milestones
struct GoalMilestoneAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var currentAmount: Double
    var progressPercentage: Double
  }

  var goalId: String
  var goalName: String
  var targetAmount: Double
  var categoryIcon: String
}

// MARK: - Credit Card Reminder Activity

/// Live Activity for credit card payment reminders
struct CreditCardReminderAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var daysUntilDue: Int
    var currentBalance: Double
  }

  var cardId: String
  var cardName: String
  var dueDate: Date
  var minimumPayment: Double
  var brand: String
}

// MARK: - Quick Expense Tracking Activity

/// Live Activity for tracking daily expenses
struct ExpenseTrackingAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var todayTotal: Double
    var transactionCount: Int
    var lastTransactionDescription: String?
  }

  var date: Date
  var dailyBudget: Double?
}
