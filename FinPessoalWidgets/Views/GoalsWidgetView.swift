//
//  GoalsWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct GoalsWidgetView: View {
  let data: WidgetData
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      smallView
    }
  }

  // MARK: - Small View

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Meta", systemImage: "target")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)

      if let topGoal = data.goals.first {
        Spacer()

        Text(topGoal.name)
          .font(.headline)
          .lineLimit(1)

        // Circular progress
        ZStack {
          Circle()
            .stroke(Color.widget.divider, lineWidth: 6)

          Circle()
            .trim(from: 0, to: topGoal.percentage / 100)
            .stroke(progressColor(topGoal.percentage), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .rotationEffect(.degrees(-90))

          Text("\(Int(topGoal.percentage))%")
            .font(.caption)
            .fontWeight(.bold)
        }
        .frame(width: 50, height: 50)
        .frame(maxWidth: .infinity)

        Spacer()

        Text("Faltam \(topGoal.formattedRemaining)")
          .font(.caption2)
          .foregroundStyle(Color.widget.textSecondary)
          .lineLimit(1)
      } else {
        Spacer()
        emptyState
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
      Label("Metas", systemImage: "target")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)

      if data.goals.isEmpty {
        emptyState
      } else {
        ForEach(data.goals.prefix(2)) { goal in
          goalRowMedium(goal)
        }
      }
    }
    .padding()
  }

  // MARK: - Large View

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Metas", systemImage: "target")
          .font(.headline)

        Spacer()

        if !data.goals.isEmpty {
          Text("\(data.goals.count) ativas")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }

      if data.goals.isEmpty {
        emptyState
      } else {
        ForEach(data.goals) { goal in
          goalRowLarge(goal)
        }
      }

      Spacer()
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Image(systemName: "target")
        .font(.largeTitle)
        .foregroundStyle(Color.widget.textSecondary)
      Text("Nenhuma meta")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .accessibilityLabel("Nenhuma meta cadastrada")
  }

  private func goalRowMedium(_ goal: GoalSummary) -> some View {
    HStack(spacing: 12) {
      // Progress ring
      ZStack {
        Circle()
          .stroke(Color.widget.divider, lineWidth: 4)

        Circle()
          .trim(from: 0, to: goal.percentage / 100)
          .stroke(progressColor(goal.percentage), style: StrokeStyle(lineWidth: 4, lineCap: .round))
          .rotationEffect(.degrees(-90))

        Text("\(Int(goal.percentage))%")
          .font(.caption2)
          .fontWeight(.bold)
      }
      .frame(width: 40, height: 40)

      VStack(alignment: .leading, spacing: 2) {
        Text(goal.name)
          .font(.subheadline)
          .fontWeight(.medium)
          .lineLimit(1)

        HStack {
          Text(goal.formattedCurrentAmount)
            .font(.caption)
          Text("/")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
          Text(goal.formattedTargetAmount)
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }

      Spacer()

      if let daysRemaining = goal.daysRemaining {
        VStack(alignment: .trailing) {
          Text("\(daysRemaining)")
            .font(.title3)
            .fontWeight(.bold)
          Text("dias")
            .font(.caption2)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(goal.accessibilityLabel)
  }

  private func goalRowLarge(_ goal: GoalSummary) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Image(systemName: goal.categoryIcon)
          .foregroundStyle(progressColor(goal.percentage))
          .frame(width: 20)

        Text(goal.name)
          .font(.subheadline)
          .fontWeight(.medium)
          .lineLimit(1)

        Spacer()

        Text("\(Int(goal.percentage))%")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundStyle(progressColor(goal.percentage))
      }

      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3)
            .fill(Color.widget.divider)

          RoundedRectangle(cornerRadius: 3)
            .fill(progressColor(goal.percentage))
            .frame(width: geometry.size.width * (goal.percentage / 100))
        }
      }
      .frame(height: 6)

      HStack {
        Text(goal.formattedCurrentAmount)
          .font(.caption)
        Text("de")
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)
        Text(goal.formattedTargetAmount)
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)

        Spacer()

        if let contribution = goal.formattedMonthlyContribution {
          Text("\(contribution)/mês")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(goal.accessibilityLabel)
  }

  // MARK: - Helpers

  private func progressColor(_ percentage: Double) -> Color {
    switch percentage {
    case 0..<25:
      return Color.widget.expense
    case 25..<50:
      return Color.widget.warning
    case 50..<75:
      return Color.widget.warning.opacity(0.8)
    case 75..<100:
      return Color.widget.accent
    default:
      return Color.widget.income
    }
  }

  private var smallAccessibilityLabel: String {
    if let goal = data.goals.first {
      return goal.accessibilityLabel
    }
    return "Nenhuma meta cadastrada"
  }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
  GoalsWidget()
} timeline: {
  GoalsWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemMedium) {
  GoalsWidget()
} timeline: {
  GoalsWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemLarge) {
  GoalsWidget()
} timeline: {
  GoalsWidgetEntry(date: Date(), data: .preview)
}
