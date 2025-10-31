//
//  CategorySpendingView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/09/25.
//

import SwiftUI

struct CategorySpendingView: View {
  let categorySpending: [CategorySpending]
  let showingChart: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "reports.spending.by.category"))
        .font(.headline)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)

      if categorySpending.isEmpty {
        EmptyStateView(
          icon: "chart.pie",
          title: "reports.empty.title",
          subtitle: "reports.empty.subtitle"
        )
        .frame(height: 200)
        .accessibilityLabel("No category spending data")
        .accessibilityHint("Add transactions to see category spending breakdown")
      } else if showingChart {
        CategoryChartView(categorySpending: categorySpending)
      } else {
        CategoryTableView(categorySpending: categorySpending)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
  }
}

struct CategoryChartView: View {
  let categorySpending: [CategorySpending]

  private var chartDescription: String {
    categorySpending.prefix(6).map { spending in
      "\(spending.category.displayName): \(Int(spending.percentage.rounded()))%"
    }.joined(separator: ", ")
  }

  var body: some View {
    VStack(spacing: 16) {
      // Simple pie chart representation using progress circles
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        ForEach(Array(categorySpending.prefix(6).enumerated()), id: \.offset) { index, spending in
          CategoryChartItem(
            spending: spending,
            color: categoryColor(for: index)
          )
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Category spending chart")
      .accessibilityValue(chartDescription)
      .accessibilityHint("Shows spending breakdown by category")

      if categorySpending.count > 6 {
        Text(String(localized: "reports.showing.top.categories").replacingOccurrences(of: "%d", with: "6"))
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private func categoryColor(for index: Int) -> Color {
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .teal]
    return colors[index % colors.count]
  }
}

struct CategoryChartItem: View {
  let spending: CategorySpending
  let color: Color

  private var amountString: String {
    NumberFormatter.currency.string(from: NSNumber(value: spending.amount)) ?? "R$ 0"
  }

  var body: some View {
    VStack(spacing: 8) {
      ZStack {
        Circle()
          .stroke(color.opacity(0.3), lineWidth: 8)
          .frame(width: 60, height: 60)
          .accessibilityHidden(true)

        Circle()
          .trim(from: 0.0, to: min(spending.percentage / 100.0, 1.0))
          .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
          .frame(width: 60, height: 60)
          .rotationEffect(.degrees(-90))
          .animation(.easeInOut(duration: 1.0), value: spending.percentage)
          .accessibilityHidden(true)

        Image(systemName: spending.category.icon)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(color)
          .accessibilityHidden(true)
      }

      VStack(spacing: 2) {
        Text(spending.category.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
          .minimumScaleFactor(0.8)

        Text(amountString)
          .font(.caption2)
          .foregroundColor(.secondary)
          .lineLimit(1)

        Text("\(Int(spending.percentage.rounded()))%")
          .font(.caption2)
          .fontWeight(.medium)
          .foregroundColor(color)
      }
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(spending.category.displayName) category")
    .accessibilityValue("\(amountString), \(Int(spending.percentage.rounded())) percent of total spending, \(spending.transactionCount) transactions")
  }
}

struct CategoryTableView: View {
  let categorySpending: [CategorySpending]

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text(String(localized: "reports.category"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)

        Spacer()

        Text(String(localized: "reports.amount"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)

        Text(String(localized: "reports.percentage"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 60, alignment: .trailing)
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 4)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)
      .accessibilityLabel("Category spending table: category, amount, percentage")
      
      Divider()
      
      // Rows
      LazyVStack(spacing: 0) {
        ForEach(Array(categorySpending.enumerated()), id: \.offset) { index, spending in
          CategoryTableRow(
            spending: spending,
            color: categoryColor(for: index)
          )
          
          if index < categorySpending.count - 1 {
            Divider()
              .padding(.leading, 40)
          }
        }
      }
    }
  }
  
  private func categoryColor(for index: Int) -> Color {
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .teal]
    return colors[index % colors.count]
  }
}

struct CategoryTableRow: View {
  let spending: CategorySpending
  let color: Color

  private var amountString: String {
    NumberFormatter.currency.string(from: NSNumber(value: spending.amount)) ?? "R$ 0"
  }

  var body: some View {
    HStack {
      HStack(spacing: 8) {
        Circle()
          .fill(color)
          .frame(width: 8, height: 8)
          .accessibilityHidden(true)

        Image(systemName: spending.category.icon)
          .font(.system(size: 14))
          .foregroundColor(color)
          .frame(width: 20)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 2) {
          Text(spending.category.displayName)
            .font(.subheadline)
            .fontWeight(.medium)

          Text("\(spending.transactionCount) transações")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      Text(amountString)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.primary)

      Text("\(Int(spending.percentage.rounded()))%")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(color)
        .frame(width: 60, alignment: .trailing)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(spending.category.displayName)
    .accessibilityValue("\(amountString), \(Int(spending.percentage.rounded())) percent, \(spending.transactionCount) transactions")
  }
}

#Preview {
  CategorySpendingView(
    categorySpending: [
      CategorySpending(category: .food, amount: 1200, percentage: 35.0, transactionCount: 15),
      CategorySpending(category: .transport, amount: 800, percentage: 23.5, transactionCount: 8),
      CategorySpending(category: .shopping, amount: 600, percentage: 17.6, transactionCount: 12),
      CategorySpending(category: .entertainment, amount: 400, percentage: 11.8, transactionCount: 6),
      CategorySpending(category: .bills, amount: 300, percentage: 8.8, transactionCount: 4),
      CategorySpending(category: .healthcare, amount: 100, percentage: 2.9, transactionCount: 2)
    ],
    showingChart: true
  )
  .padding()
}
