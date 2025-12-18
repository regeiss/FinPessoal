//
//  LockScreenWidgets.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Balance Lock Screen Widget

struct BalanceLockWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BalanceLockEntry {
    BalanceLockEntry(date: Date(), balance: 0)
  }

  func getSnapshot(in context: Context, completion: @escaping (BalanceLockEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    completion(BalanceLockEntry(date: Date(), balance: data.totalBalance))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceLockEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BalanceLockEntry(date: Date(), balance: data.totalBalance)
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }
}

struct BalanceLockEntry: TimelineEntry {
  let date: Date
  let balance: Double
}

struct BalanceLockWidgetView: View {
  let entry: BalanceLockEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectangularView
    case .accessoryInline:
      inlineView
    default:
      circularView
    }
  }

  private var circularView: some View {
    VStack(spacing: 2) {
      Image(systemName: "banknote")
        .font(.caption)
      Text(formatCompact(entry.balance))
        .font(.caption2)
        .fontWeight(.bold)
        .minimumScaleFactor(0.5)
    }
    .accessibilityLabel("Saldo: \(formatCurrency(entry.balance))")
  }

  private var rectangularView: some View {
    HStack {
      Image(systemName: "banknote")
      VStack(alignment: .leading) {
        Text("Saldo")
          .font(.caption2)
        Text(formatCurrency(entry.balance))
          .font(.caption)
          .fontWeight(.bold)
          .minimumScaleFactor(0.7)
      }
    }
    .accessibilityLabel("Saldo total: \(formatCurrency(entry.balance))")
  }

  private var inlineView: some View {
    Text("Saldo: \(formatCompact(entry.balance))")
      .accessibilityLabel("Saldo: \(formatCurrency(entry.balance))")
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }

  private func formatCompact(_ value: Double) -> String {
    if abs(value) >= 1000 {
      return String(format: "R$%.1fk", value / 1000)
    }
    return String(format: "R$%.0f", value)
  }
}

struct BalanceLockWidget: Widget {
  let kind = "BalanceLockWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BalanceLockWidgetProvider()) { entry in
      BalanceLockWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Saldo")
    .description("Saldo rápido na tela de bloqueio.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

// MARK: - Bills Lock Screen Widget

struct BillsLockWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BillsLockEntry {
    BillsLockEntry(date: Date(), nextBill: nil, billCount: 0)
  }

  func getSnapshot(in context: Context, completion: @escaping (BillsLockEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    completion(BillsLockEntry(
      date: Date(),
      nextBill: data.upcomingBills.first,
      billCount: data.upcomingBills.count
    ))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BillsLockEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BillsLockEntry(
      date: Date(),
      nextBill: data.upcomingBills.first,
      billCount: data.upcomingBills.count
    )
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }
}

struct BillsLockEntry: TimelineEntry {
  let date: Date
  let nextBill: BillSummary?
  let billCount: Int
}

struct BillsLockWidgetView: View {
  let entry: BillsLockEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectangularView
    case .accessoryInline:
      inlineView
    default:
      circularView
    }
  }

  private var circularView: some View {
    VStack(spacing: 2) {
      if let bill = entry.nextBill {
        Image(systemName: bill.isOverdue ? "exclamationmark.triangle" : "calendar")
          .font(.caption)
        Text("\(bill.daysUntilDue)d")
          .font(.caption2)
          .fontWeight(.bold)
      } else {
        Image(systemName: "checkmark.circle")
          .font(.title3)
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var rectangularView: some View {
    HStack {
      Image(systemName: "calendar.badge.clock")
      VStack(alignment: .leading) {
        if let bill = entry.nextBill {
          Text(bill.name)
            .font(.caption2)
            .lineLimit(1)
          Text(bill.daysText)
            .font(.caption)
            .fontWeight(.bold)
        } else {
          Text("Contas em dia")
            .font(.caption)
        }
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var inlineView: some View {
    Group {
      if let bill = entry.nextBill {
        Text("\(bill.name): \(bill.daysText)")
      } else {
        Text("Contas em dia ✓")
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var accessibilityText: String {
    if let bill = entry.nextBill {
      return bill.accessibilityLabel
    }
    return "Todas as contas em dia"
  }
}

struct BillsLockWidget: Widget {
  let kind = "BillsLockWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BillsLockWidgetProvider()) { entry in
      BillsLockWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Contas")
    .description("Próxima conta na tela de bloqueio.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

// MARK: - Budget Lock Screen Widget

struct BudgetLockWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BudgetLockEntry {
    BudgetLockEntry(date: Date(), topBudget: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (BudgetLockEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    completion(BudgetLockEntry(date: Date(), topBudget: data.budgets.first))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetLockEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BudgetLockEntry(date: Date(), topBudget: data.budgets.first)
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }
}

struct BudgetLockEntry: TimelineEntry {
  let date: Date
  let topBudget: BudgetSummary?
}

struct BudgetLockWidgetView: View {
  let entry: BudgetLockEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectangularView
    case .accessoryInline:
      inlineView
    default:
      circularView
    }
  }

  private var circularView: some View {
    Group {
      if let budget = entry.topBudget {
        Gauge(value: min(budget.percentage, 100), in: 0...100) {
          Image(systemName: "chart.pie")
        } currentValueLabel: {
          Text("\(Int(budget.percentage))%")
            .font(.caption2)
        }
        .gaugeStyle(.accessoryCircular)
      } else {
        Image(systemName: "chart.pie")
          .font(.title3)
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var rectangularView: some View {
    HStack {
      Image(systemName: "chart.pie")
      VStack(alignment: .leading) {
        if let budget = entry.topBudget {
          Text(budget.name)
            .font(.caption2)
            .lineLimit(1)
          Text("\(Int(budget.percentage))% usado")
            .font(.caption)
            .fontWeight(.bold)
        } else {
          Text("Sem orçamentos")
            .font(.caption)
        }
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var inlineView: some View {
    Group {
      if let budget = entry.topBudget {
        Text("\(budget.name): \(Int(budget.percentage))%")
      } else {
        Text("Sem orçamentos")
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var accessibilityText: String {
    if let budget = entry.topBudget {
      return budget.accessibilityLabel
    }
    return "Nenhum orçamento cadastrado"
  }
}

struct BudgetLockWidget: Widget {
  let kind = "BudgetLockWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BudgetLockWidgetProvider()) { entry in
      BudgetLockWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Orçamento")
    .description("Progresso do orçamento na tela de bloqueio.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

// MARK: - Goals Lock Screen Widget

struct GoalsLockWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> GoalsLockEntry {
    GoalsLockEntry(date: Date(), topGoal: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (GoalsLockEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    completion(GoalsLockEntry(date: Date(), topGoal: data.goals.first))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<GoalsLockEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = GoalsLockEntry(date: Date(), topGoal: data.goals.first)
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }
}

struct GoalsLockEntry: TimelineEntry {
  let date: Date
  let topGoal: GoalSummary?
}

struct GoalsLockWidgetView: View {
  let entry: GoalsLockEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      circularView
    case .accessoryRectangular:
      rectangularView
    case .accessoryInline:
      inlineView
    default:
      circularView
    }
  }

  private var circularView: some View {
    Group {
      if let goal = entry.topGoal {
        Gauge(value: goal.percentage, in: 0...100) {
          Image(systemName: "target")
        } currentValueLabel: {
          Text("\(Int(goal.percentage))%")
            .font(.caption2)
        }
        .gaugeStyle(.accessoryCircular)
      } else {
        Image(systemName: "target")
          .font(.title3)
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var rectangularView: some View {
    HStack {
      Image(systemName: "target")
      VStack(alignment: .leading) {
        if let goal = entry.topGoal {
          Text(goal.name)
            .font(.caption2)
            .lineLimit(1)
          Text("\(Int(goal.percentage))%")
            .font(.caption)
            .fontWeight(.bold)
        } else {
          Text("Sem metas")
            .font(.caption)
        }
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var inlineView: some View {
    Group {
      if let goal = entry.topGoal {
        Text("\(goal.name): \(Int(goal.percentage))%")
      } else {
        Text("Sem metas")
      }
    }
    .accessibilityLabel(accessibilityText)
  }

  private var accessibilityText: String {
    if let goal = entry.topGoal {
      return goal.accessibilityLabel
    }
    return "Nenhuma meta cadastrada"
  }
}

struct GoalsLockWidget: Widget {
  let kind = "GoalsLockWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: GoalsLockWidgetProvider()) { entry in
      GoalsLockWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Meta")
    .description("Progresso da meta na tela de bloqueio.")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}
