//
//  CreditCardWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct CreditCardWidgetView: View {
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

  // MARK: - Small View (Total Utilization Gauge)

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Cartões", systemImage: "creditcard")
        .font(.caption)
        .foregroundStyle(.secondary)

      if data.creditCards.isEmpty {
        Spacer()
        emptyStateSmall
        Spacer()
      } else {
        Spacer()

        // Utilization gauge
        ZStack {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: 8)

          Circle()
            .trim(from: 0, to: totalUtilization / 100)
            .stroke(utilizationColor(totalUtilization), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .rotationEffect(.degrees(-90))

          VStack(spacing: 0) {
            Text("\(Int(totalUtilization))%")
              .font(.title3)
              .fontWeight(.bold)
            Text("usado")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        .frame(width: 70, height: 70)
        .frame(maxWidth: .infinity)

        Spacer()

        Text(formattedTotalBalance)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel(smallAccessibilityLabel)
  }

  // MARK: - Medium View (Per-card breakdown)

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Cartões de Crédito", systemImage: "creditcard")
          .font(.caption)
          .foregroundStyle(.secondary)

        Spacer()

        if !data.creditCards.isEmpty {
          Text("\(Int(totalUtilization))% utilizado")
            .font(.caption2)
            .foregroundStyle(utilizationColor(totalUtilization))
        }
      }

      if data.creditCards.isEmpty {
        emptyStateMedium
      } else {
        ForEach(data.creditCards.prefix(3)) { card in
          cardRow(card)
        }
      }
    }
    .padding()
  }

  // MARK: - Components

  private var emptyStateSmall: some View {
    VStack {
      Image(systemName: "creditcard")
        .font(.title)
        .foregroundStyle(.secondary)
      Text("Sem cartões")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }

  private var emptyStateMedium: some View {
    VStack {
      Spacer()
      Image(systemName: "creditcard")
        .font(.title)
        .foregroundStyle(.secondary)
      Text("Nenhum cartão cadastrado")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .accessibilityLabel("Nenhum cartão cadastrado")
  }

  private func cardRow(_ card: CardSummary) -> some View {
    HStack {
      // Brand icon
      Image(systemName: "creditcard.fill")
        .font(.caption)
        .foregroundStyle(brandColor(card.brand))
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 0) {
        Text(card.name)
          .font(.caption)
          .lineLimit(1)

        if let dueDate = card.formattedDueDate {
          Text("Vence \(dueDate)")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(card.formattedBalance)
          .font(.caption)
          .fontWeight(.medium)

        // Utilization mini bar
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
              .fill(Color.gray.opacity(0.2))

            RoundedRectangle(cornerRadius: 1)
              .fill(utilizationColor(card.utilizationPercentage))
              .frame(width: geometry.size.width * min(1, card.utilizationPercentage / 100))
          }
        }
        .frame(width: 40, height: 3)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(card.accessibilityLabel)
  }

  // MARK: - Computed Properties

  private var totalUtilization: Double {
    let totalLimit = data.creditCards.reduce(0.0) { $0 + $1.creditLimit }
    let totalBalance = data.creditCards.reduce(0.0) { $0 + $1.currentBalance }
    guard totalLimit > 0 else { return 0 }
    return (totalBalance / totalLimit) * 100
  }

  private var formattedTotalBalance: String {
    let total = data.creditCards.reduce(0.0) { $0 + $1.currentBalance }
    return formatCurrency(total)
  }

  // MARK: - Helpers

  private func utilizationColor(_ percentage: Double) -> Color {
    switch percentage {
    case 0..<30:
      return .green
    case 30..<70:
      return .yellow
    case 70..<90:
      return .orange
    default:
      return .red
    }
  }

  private func brandColor(_ brand: String) -> Color {
    switch brand.lowercased() {
    case "visa":
      return .blue
    case "mastercard":
      return .red
    case "amex":
      return .green
    case "elo":
      return .yellow
    default:
      return .gray
    }
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }

  private var smallAccessibilityLabel: String {
    if data.creditCards.isEmpty {
      return "Nenhum cartão cadastrado"
    }
    return "Utilização total de cartões: \(Int(totalUtilization)) por cento"
  }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
  CreditCardWidget()
} timeline: {
  CreditCardWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemMedium) {
  CreditCardWidget()
} timeline: {
  CreditCardWidgetEntry(date: Date(), data: .preview)
}
