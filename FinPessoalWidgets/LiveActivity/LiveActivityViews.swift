//
//  LiveActivityViews.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - Bill Reminder Live Activity

struct BillReminderLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: BillReminderAttributes.self) { context in
      // Lock screen / banner view
      BillReminderLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded view
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: context.attributes.categoryIcon)
            .font(.title2)
            .foregroundStyle(context.state.isPaid ? .green : .orange)
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing) {
            Text(formatCurrency(context.attributes.amount))
              .font(.headline)
              .fontWeight(.bold)
            if context.state.isPaid {
              Text("Pago")
                .font(.caption)
                .foregroundStyle(.green)
            } else {
              Text(daysText(context.state.daysUntilDue))
                .font(.caption)
                .foregroundStyle(daysColor(context.state.daysUntilDue))
            }
          }
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.billName)
            .font(.headline)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          if !context.state.isPaid {
            Text("Vencimento: \(formatDate(context.attributes.dueDate))")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      } compactLeading: {
        Image(systemName: context.state.isPaid ? "checkmark.circle.fill" : "calendar.badge.clock")
          .foregroundStyle(context.state.isPaid ? .green : .orange)
      } compactTrailing: {
        if context.state.isPaid {
          Text("✓")
            .foregroundStyle(.green)
        } else {
          Text("\(context.state.daysUntilDue)d")
            .font(.caption)
            .fontWeight(.bold)
        }
      } minimal: {
        Image(systemName: context.state.isPaid ? "checkmark.circle.fill" : "calendar")
          .foregroundStyle(context.state.isPaid ? .green : .orange)
      }
    }
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }

  private func daysText(_ days: Int) -> String {
    switch days {
    case ..<0: return "Vencido"
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "em \(days) dias"
    }
  }

  private func daysColor(_ days: Int) -> Color {
    switch days {
    case ..<0: return .red
    case 0...1: return .orange
    default: return .secondary
    }
  }
}

struct BillReminderLockScreenView: View {
  let context: ActivityViewContext<BillReminderAttributes>

  var body: some View {
    HStack {
      Image(systemName: context.attributes.categoryIcon)
        .font(.title2)
        .foregroundStyle(context.state.isPaid ? .green : .orange)

      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.billName)
          .font(.headline)
          .lineLimit(1)
        Text(formatCurrency(context.attributes.amount))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()

      if context.state.isPaid {
        Label("Pago", systemImage: "checkmark.circle.fill")
          .font(.caption)
          .foregroundStyle(.green)
      } else {
        VStack(alignment: .trailing) {
          Text(daysText(context.state.daysUntilDue))
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(daysColor(context.state.daysUntilDue))
          Text(formatDate(context.attributes.dueDate))
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityLabel)
  }

  private var accessibilityLabel: String {
    if context.state.isPaid {
      return "\(context.attributes.billName), \(formatCurrency(context.attributes.amount)), pago"
    }
    return "\(context.attributes.billName), \(formatCurrency(context.attributes.amount)), \(daysText(context.state.daysUntilDue))"
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    return formatter.string(from: date)
  }

  private func daysText(_ days: Int) -> String {
    switch days {
    case ..<0: return "Vencido"
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "em \(days) dias"
    }
  }

  private func daysColor(_ days: Int) -> Color {
    switch days {
    case ..<0: return .red
    case 0...1: return .orange
    default: return .blue
    }
  }
}

// MARK: - Budget Alert Live Activity

struct BudgetAlertLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: BudgetAlertAttributes.self) { context in
      BudgetAlertLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: context.attributes.categoryIcon)
            .font(.title2)
            .foregroundStyle(percentageColor(context.state.percentageUsed))
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing) {
            Text("\(Int(context.state.percentageUsed))%")
              .font(.headline)
              .fontWeight(.bold)
              .foregroundStyle(percentageColor(context.state.percentageUsed))
            Text("usado")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.budgetName)
            .font(.headline)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          ProgressView(value: min(context.state.percentageUsed, 100), total: 100)
            .tint(percentageColor(context.state.percentageUsed))
        }
      } compactLeading: {
        Image(systemName: "chart.pie")
          .foregroundStyle(percentageColor(context.state.percentageUsed))
      } compactTrailing: {
        Text("\(Int(context.state.percentageUsed))%")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundStyle(percentageColor(context.state.percentageUsed))
      } minimal: {
        Image(systemName: "chart.pie.fill")
          .foregroundStyle(percentageColor(context.state.percentageUsed))
      }
    }
  }

  private func percentageColor(_ percentage: Double) -> Color {
    switch percentage {
    case 0..<75: return .green
    case 75..<90: return .yellow
    case 90..<100: return .orange
    default: return .red
    }
  }
}

struct BudgetAlertLockScreenView: View {
  let context: ActivityViewContext<BudgetAlertAttributes>

  var body: some View {
    HStack {
      Image(systemName: context.attributes.categoryIcon)
        .font(.title2)
        .foregroundStyle(percentageColor(context.state.percentageUsed))

      VStack(alignment: .leading, spacing: 4) {
        Text(context.attributes.budgetName)
          .font(.headline)
          .lineLimit(1)

        ProgressView(value: min(context.state.percentageUsed, 100), total: 100)
          .tint(percentageColor(context.state.percentageUsed))
      }

      VStack(alignment: .trailing) {
        Text("\(Int(context.state.percentageUsed))%")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(percentageColor(context.state.percentageUsed))
        Text(formatCurrency(context.attributes.budgetLimit - context.state.currentSpent))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(context.attributes.budgetName), \(Int(context.state.percentageUsed)) por cento usado")
  }

  private func percentageColor(_ percentage: Double) -> Color {
    switch percentage {
    case 0..<75: return .green
    case 75..<90: return .yellow
    case 90..<100: return .orange
    default: return .red
    }
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }
}

// MARK: - Goal Milestone Live Activity

struct GoalMilestoneLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: GoalMilestoneAttributes.self) { context in
      GoalMilestoneLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: context.attributes.categoryIcon)
            .font(.title2)
            .foregroundStyle(.blue)
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing) {
            Text("\(Int(context.state.progressPercentage))%")
              .font(.headline)
              .fontWeight(.bold)
            Text("completo")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.goalName)
            .font(.headline)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack {
            Text(formatCurrency(context.state.currentAmount))
              .font(.caption)
            Spacer()
            Text(formatCurrency(context.attributes.targetAmount))
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      } compactLeading: {
        Image(systemName: "target")
          .foregroundStyle(.blue)
      } compactTrailing: {
        Text("\(Int(context.state.progressPercentage))%")
          .font(.caption)
          .fontWeight(.bold)
      } minimal: {
        Image(systemName: "target")
          .foregroundStyle(.blue)
      }
    }
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }
}

struct GoalMilestoneLockScreenView: View {
  let context: ActivityViewContext<GoalMilestoneAttributes>

  var body: some View {
    HStack {
      ZStack {
        Circle()
          .stroke(Color.gray.opacity(0.2), lineWidth: 4)
        Circle()
          .trim(from: 0, to: context.state.progressPercentage / 100)
          .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
          .rotationEffect(.degrees(-90))
        Image(systemName: context.attributes.categoryIcon)
          .font(.caption)
      }
      .frame(width: 44, height: 44)

      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.goalName)
          .font(.headline)
          .lineLimit(1)
        Text("\(formatCurrency(context.state.currentAmount)) de \(formatCurrency(context.attributes.targetAmount))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Text("\(Int(context.state.progressPercentage))%")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(.blue)
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(context.attributes.goalName), \(Int(context.state.progressPercentage)) por cento completo")
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }
}

// MARK: - Credit Card Reminder Live Activity

struct CreditCardReminderLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: CreditCardReminderAttributes.self) { context in
      CreditCardReminderLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "creditcard.fill")
            .font(.title2)
            .foregroundStyle(brandColor(context.attributes.brand))
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing) {
            Text(formatCurrency(context.state.currentBalance))
              .font(.headline)
              .fontWeight(.bold)
            Text(daysText(context.state.daysUntilDue))
              .font(.caption)
              .foregroundStyle(daysColor(context.state.daysUntilDue))
          }
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.cardName)
            .font(.headline)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Mínimo: \(formatCurrency(context.attributes.minimumPayment))")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      } compactLeading: {
        Image(systemName: "creditcard")
          .foregroundStyle(brandColor(context.attributes.brand))
      } compactTrailing: {
        Text("\(context.state.daysUntilDue)d")
          .font(.caption)
          .fontWeight(.bold)
      } minimal: {
        Image(systemName: "creditcard")
          .foregroundStyle(brandColor(context.attributes.brand))
      }
    }
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }

  private func daysText(_ days: Int) -> String {
    switch days {
    case ..<0: return "Vencido"
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "em \(days)d"
    }
  }

  private func daysColor(_ days: Int) -> Color {
    switch days {
    case ..<0: return .red
    case 0...3: return .orange
    default: return .secondary
    }
  }

  private func brandColor(_ brand: String) -> Color {
    switch brand.lowercased() {
    case "visa": return .blue
    case "mastercard": return .red
    case "amex": return .green
    default: return .gray
    }
  }
}

struct CreditCardReminderLockScreenView: View {
  let context: ActivityViewContext<CreditCardReminderAttributes>

  var body: some View {
    HStack {
      Image(systemName: "creditcard.fill")
        .font(.title2)
        .foregroundStyle(brandColor(context.attributes.brand))

      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.cardName)
          .font(.headline)
          .lineLimit(1)
        Text("Mínimo: \(formatCurrency(context.attributes.minimumPayment))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing) {
        Text(formatCurrency(context.state.currentBalance))
          .font(.headline)
          .fontWeight(.bold)
        Text(daysText(context.state.daysUntilDue))
          .font(.caption)
          .foregroundStyle(daysColor(context.state.daysUntilDue))
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(context.attributes.cardName), \(formatCurrency(context.state.currentBalance)), \(daysText(context.state.daysUntilDue))")
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
  }

  private func daysText(_ days: Int) -> String {
    switch days {
    case ..<0: return "Vencido"
    case 0: return "Vence hoje"
    case 1: return "Vence amanhã"
    default: return "em \(days) dias"
    }
  }

  private func daysColor(_ days: Int) -> Color {
    switch days {
    case ..<0: return .red
    case 0...3: return .orange
    default: return .blue
    }
  }

  private func brandColor(_ brand: String) -> Color {
    switch brand.lowercased() {
    case "visa": return .blue
    case "mastercard": return .red
    case "amex": return .green
    default: return .gray
    }
  }
}
