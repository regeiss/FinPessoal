//
//  BillsWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct BillsWidgetView: View {
  let data: WidgetData
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    default:
      smallView
    }
  }

  // MARK: - Small View

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Próxima Conta", systemImage: "calendar.badge.clock")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)

      if let nextBill = data.upcomingBills.first {
        Spacer()

        Text(nextBill.name)
          .font(.headline)
          .lineLimit(1)

        Text(nextBill.formattedAmount)
          .font(.title3)
          .fontWeight(.bold)

        Spacer()

        HStack {
          if nextBill.isOverdue {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(Color.widget.expense)
            Text("Vencido")
              .font(.caption)
              .foregroundStyle(Color.widget.expense)
          } else {
            Image(systemName: "clock")
              .foregroundStyle(colorForDays(nextBill.daysUntilDue))
            Text(nextBill.daysText)
              .font(.caption)
              .foregroundStyle(colorForDays(nextBill.daysUntilDue))
          }
        }
      } else {
        Spacer()
        VStack {
          Image(systemName: "checkmark.circle")
            .font(.title)
            .foregroundStyle(Color.widget.income)
          Text("Tudo em dia!")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
        .frame(maxWidth: .infinity)
        Spacer()
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel(smallAccessibilityLabel)
  }

  // MARK: - Medium View

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Contas a Pagar", systemImage: "calendar.badge.clock")
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)

        Spacer()

        if !data.upcomingBills.isEmpty {
          Text("\(data.upcomingBills.count) pendentes")
            .font(.caption2)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }

      if data.upcomingBills.isEmpty {
        emptyState
      } else {
        ForEach(data.upcomingBills.prefix(3)) { bill in
          billRow(bill)
        }
      }
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Image(systemName: "checkmark.circle")
        .font(.title)
        .foregroundStyle(Color.widget.income)
      Text("Tudo em dia!")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .accessibilityLabel("Nenhuma conta pendente")
  }

  private func billRow(_ bill: BillSummary) -> some View {
    HStack {
      Image(systemName: bill.categoryIcon)
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 0) {
        Text(bill.name)
          .font(.caption)
          .lineLimit(1)
        Text(bill.formattedDueDate)
          .font(.caption2)
          .foregroundStyle(Color.widget.textSecondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(bill.formattedAmount)
          .font(.caption)
          .fontWeight(.medium)

        if bill.isOverdue {
          Text("Vencido")
            .font(.caption2)
            .foregroundStyle(Color.widget.expense)
        } else {
          Text(bill.daysText)
            .font(.caption2)
            .foregroundStyle(colorForDays(bill.daysUntilDue))
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(bill.accessibilityLabel)
  }

  // MARK: - Helpers

  private func colorForDays(_ days: Int) -> Color {
    switch days {
    case ..<0:
      return Color.widget.expense
    case 0...1:
      return Color.widget.warning
    case 2...3:
      return Color.widget.warning.opacity(0.8)
    default:
      return Color.widget.textSecondary
    }
  }

  private var smallAccessibilityLabel: String {
    if let bill = data.upcomingBills.first {
      return bill.accessibilityLabel
    }
    return "Nenhuma conta pendente"
  }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
  BillsWidget()
} timeline: {
  BillsWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemMedium) {
  BillsWidget()
} timeline: {
  BillsWidgetEntry(date: Date(), data: .preview)
}
