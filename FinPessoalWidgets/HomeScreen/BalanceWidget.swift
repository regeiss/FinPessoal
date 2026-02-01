//
//  BalanceWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct BalanceWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BalanceWidgetEntry {
    BalanceWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BalanceWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BalanceWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BalanceWidgetEntry(date: Date(), data: data)

    // Refresh every 30 minutes
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct BalanceWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct BalanceWidget: Widget {
  let kind: String = "BalanceWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BalanceWidgetProvider()) { entry in
      BalanceWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Saldo")
    .description("Visualize seu saldo total rapidamente.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}

// MARK: - Preview Data

extension WidgetData {
  static let preview = WidgetData(
    lastUpdated: Date(),
    totalBalance: 15750.50,
    monthlyIncome: 8500,
    monthlyExpenses: 5200,
    accounts: [
      AccountSummary(id: "1", name: "Nubank", type: "Conta Corrente", balance: 5200, currency: "BRL"),
      AccountSummary(id: "2", name: "Poupança Itaú", type: "Poupança", balance: 8000, currency: "BRL"),
      AccountSummary(id: "3", name: "XP Investimentos", type: "Investimentos", balance: 2550.50, currency: "BRL")
    ],
    budgets: [
      BudgetSummary(id: "1", name: "Alimentação", category: "food", categoryIcon: "fork.knife", spent: 850, limit: 1000),
      BudgetSummary(id: "2", name: "Transporte", category: "transport", categoryIcon: "car", spent: 420, limit: 500),
      BudgetSummary(id: "3", name: "Lazer", category: "entertainment", categoryIcon: "gamecontroller", spent: 380, limit: 300)
    ],
    upcomingBills: [
      BillSummary(id: "1", name: "Aluguel", amount: 1500, dueDate: Date().addingTimeInterval(86400 * 3), status: "upcoming", categoryIcon: "house"),
      BillSummary(id: "2", name: "Internet", amount: 120, dueDate: Date().addingTimeInterval(86400 * 5), status: "upcoming", categoryIcon: "wifi"),
      BillSummary(id: "3", name: "Energia", amount: 180, dueDate: Date().addingTimeInterval(-86400), status: "overdue", categoryIcon: "bolt")
    ],
    goals: [
      GoalSummary(id: "1", name: "Viagem", currentAmount: 3500, targetAmount: 5000, targetDate: Date().addingTimeInterval(86400 * 90), categoryIcon: "airplane"),
      GoalSummary(id: "2", name: "Emergência", currentAmount: 8000, targetAmount: 10000, targetDate: nil, categoryIcon: "shield.checkered")
    ],
    creditCards: [
      CardSummary(id: "1", name: "Nubank", currentBalance: 1200, creditLimit: 5000, dueDate: Date().addingTimeInterval(86400 * 10), brand: "mastercard")
    ],
    recentTransactions: [
      TransactionSummary(id: "1", description: "Supermercado", amount: 250, date: Date(), type: "expense", category: "food", categoryIcon: "cart"),
      TransactionSummary(id: "2", description: "Salário", amount: 5000, date: Date().addingTimeInterval(-86400), type: "income", category: "salary", categoryIcon: "banknote")
    ]
  )
}
