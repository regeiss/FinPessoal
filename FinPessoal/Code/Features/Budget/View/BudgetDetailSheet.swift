//
//  BudgetDetailSheet.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/10/25.
//

import SwiftUI

struct BudgetDetailSheet: View {
  let budget: Budget
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingDeleteConfirmation = false

  private var daysRemaining: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let endDate = calendar.startOfDay(for: budget.endDate)
    let components = calendar.dateComponents([.day], from: today, to: endDate)
    return max(0, components.day ?? 0)
  }

  private var dailyBudget: Double {
    guard daysRemaining > 0 else { return 0 }
    return budget.remaining / Double(daysRemaining)
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header with icon and title
          VStack(spacing: 16) {
            ZStack {
              Circle()
                .fill(budget.category.swiftUIColor.opacity(0.15))
                .frame(width: 80, height: 80)

              Image(systemName: budget.category.icon)
                .font(.system(size: 36))
                .foregroundColor(budget.category.swiftUIColor)
            }

            VStack(spacing: 4) {
              Text(budget.name)
                .font(.title2)
                .fontWeight(.bold)

              Text(budget.category.displayName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
          }
          .padding(.top, 8)

          // Progress circle
          VStack(spacing: 20) {
            ZStack {
              Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                .frame(width: 160, height: 160)

              Circle()
                .trim(from: 0, to: min(budget.percentageUsed, 1.0))
                .stroke(
                  budget.isOverBudget ? Color.red : budget.category.swiftUIColor,
                  style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: budget.percentageUsed)

              VStack(spacing: 4) {
                if budget.isOverBudget {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)

                  Text(String(localized: "budget.over.budget"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                } else {
                  Text("\(Int(budget.percentageUsed * 100))%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(budget.category.swiftUIColor)

                  Text(String(localized: "budget.used"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }
            }

            // Budget details
            VStack(spacing: 12) {
              HStack {
                Text(String(localized: "budget.budgeted"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(budget.formattedBudgetAmount)
                  .font(.headline)
                  .foregroundColor(.primary)
              }

              Divider()

              HStack {
                Text(String(localized: "budget.spent"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(budget.formattedSpent)
                  .font(.headline)
                  .foregroundColor(budget.isOverBudget ? .red : .primary)
              }

              Divider()

              HStack {
                Text(String(localized: "budget.remaining"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(budget.formattedRemaining)
                  .font(.headline)
                  .fontWeight(.semibold)
                  .foregroundColor(budget.remaining >= 0 ? budget.category.swiftUIColor : .red)
              }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
          }
          .padding(.horizontal)

          // Period info
          VStack(spacing: 16) {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "budget.period"))
                  .font(.caption)
                  .foregroundColor(.secondary)
                Text(budget.period.displayName)
                  .font(.subheadline)
                  .fontWeight(.medium)
              }

              Spacer()

              VStack(alignment: .trailing, spacing: 4) {
                Text(String(localized: "budget.days.remaining"))
                  .font(.caption)
                  .foregroundColor(.secondary)
                Text("\(daysRemaining) dias")
                  .font(.subheadline)
                  .fontWeight(.medium)
              }
            }

            if !budget.isOverBudget && daysRemaining > 0 {
              HStack(spacing: 4) {
                Image(systemName: "calendar")
                  .foregroundColor(.blue)
                  .font(.caption2)
                Text(String(localized: "budget.daily.available"))
                  .font(.caption2)
                  .foregroundColor(.secondary)
                Spacer()
                Text(formatCurrency(dailyBudget))
                  .font(.caption)
                  .fontWeight(.medium)
                  .foregroundColor(.blue)
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 6)
              .background(Color.blue.opacity(0.1))
              .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            HStack(spacing: 4) {
              Image(systemName: "calendar.badge.clock")
                .foregroundColor(.secondary)
                .font(.caption2)
              Text(String(localized: "budget.period.dates"))
                .font(.caption2)
                .foregroundColor(.secondary)
              Spacer()
              Text("\(budget.startDate.formatted(date: .abbreviated, time: .omitted)) - \(budget.endDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
          }
          .padding(.horizontal)

          Spacer(minLength: 20)
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle(String(localized: "budget.details"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingDeleteConfirmation = true
          } label: {
            Image(systemName: "trash")
              .foregroundColor(.red)
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            dismiss()
          }
        }
      }
      .alert(
        String(localized: "budget.delete.confirmation"),
        isPresented: $showingDeleteConfirmation
      ) {
        Button(String(localized: "common.cancel"), role: .cancel) {}
        Button(String(localized: "budget.delete.button"), role: .destructive) {
          deleteBudget()
        }
      } message: {
        Text(String(localized: "budget.delete.message"))
      }
    }
  }

  private func deleteBudget() {
    financeViewModel.budgets.removeAll { $0.id == budget.id }
    dismiss()
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}
