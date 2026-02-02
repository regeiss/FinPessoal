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
            .accessibilityHidden(true)

            VStack(spacing: 4) {
              Text(budget.name)
                .font(.title2)
                .fontWeight(.bold)

              Text(budget.category.displayName)
                .font(.subheadline)
                .foregroundStyle(Color.oldMoney.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(budget.name), \(budget.category.displayName)")
            .accessibilityAddTraits(.isHeader)
          }
          .padding(.top, 8)

          // Progress circle
          VStack(spacing: 20) {
            ZStack {
              Circle()
                .stroke(Color.oldMoney.divider, lineWidth: 12)
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
                    .foregroundStyle(Color.oldMoney.expense)
                    .accessibilityHidden(true)

                  Text(String(localized: "budget.over.budget"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.oldMoney.expense)
                } else {
                  Text("\(Int(budget.percentageUsed * 100))%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(budget.category.swiftUIColor)

                  Text(String(localized: "budget.used"))
                    .font(.caption)
                    .foregroundStyle(Color.oldMoney.textSecondary)
                }
              }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Budget Usage")
            .accessibilityValue(budget.isOverBudget ? "Over budget: \(Int(budget.percentageUsed * 100))% used" : "\(Int(budget.percentageUsed * 100))% used")
            .accessibilityAddTraits(.updatesFrequently)

            // Budget details
            VStack(spacing: 12) {
              HStack {
                Text(String(localized: "budget.budgeted"))
                  .font(.subheadline)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Spacer()
                Text(budget.formattedBudgetAmount)
                  .font(.headline)
                  .foregroundStyle(Color.oldMoney.text)
              }
              .accessibilityElement(children: .combine)
              .accessibilityLabel("Total Budgeted")
              .accessibilityValue(budget.formattedBudgetAmount)

              Divider()

              HStack {
                Text(String(localized: "budget.spent"))
                  .font(.subheadline)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Spacer()
                Text(budget.formattedSpent)
                  .font(.headline)
                  .foregroundColor(budget.isOverBudget ? .red : .primary)
              }
              .accessibilityElement(children: .combine)
              .accessibilityLabel(budget.isOverBudget ? "Amount Spent (Over Budget)" : "Amount Spent")
              .accessibilityValue(budget.formattedSpent)

              Divider()

              HStack {
                Text(String(localized: "budget.remaining"))
                  .font(.subheadline)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Spacer()
                Text(budget.formattedRemaining)
                  .font(.headline)
                  .fontWeight(.semibold)
                  .foregroundColor(budget.remaining >= 0 ? budget.category.swiftUIColor : .red)
              }
              .accessibilityElement(children: .combine)
              .accessibilityLabel("Amount Remaining")
              .accessibilityValue(budget.formattedRemaining)
            }
            .padding()
            .background(Color.oldMoney.surface)
            .cornerRadius(12)
            .accessibilityElement(children: .contain)
          }
          .padding(.horizontal)

          // Period info
          VStack(spacing: 16) {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "budget.period"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Text(budget.period.displayName)
                  .font(.subheadline)
                  .fontWeight(.medium)
              }
              .accessibilityElement(children: .combine)
              .accessibilityLabel("Budget Period")
              .accessibilityValue(budget.period.displayName)

              Spacer()

              VStack(alignment: .trailing, spacing: 4) {
                Text(String(localized: "budget.days.remaining"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Text("\(daysRemaining) dias")
                  .font(.subheadline)
                  .fontWeight(.medium)
              }
              .accessibilityElement(children: .combine)
              .accessibilityLabel("Days Remaining")
              .accessibilityValue("\(daysRemaining) days")
            }

            if !budget.isOverBudget && daysRemaining > 0 {
              HStack(spacing: 4) {
                Image(systemName: "calendar")
                  .foregroundStyle(Color.oldMoney.accent)
                  .font(.caption2)
                  .accessibilityHidden(true)
                Text(String(localized: "budget.daily.available"))
                  .font(.caption2)
                  .foregroundStyle(Color.oldMoney.textSecondary)
                Spacer()
                Text(formatCurrency(dailyBudget))
                  .font(.caption)
                  .fontWeight(.medium)
                  .foregroundStyle(Color.oldMoney.accent)
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 6)
              .background(Color.oldMoney.accentBackground)
              .clipShape(RoundedRectangle(cornerRadius: 6))
              .accessibilityElement(children: .combine)
              .accessibilityLabel("Daily Available Budget")
              .accessibilityValue(formatCurrency(dailyBudget))
            }

            HStack(spacing: 4) {
              Image(systemName: "calendar.badge.clock")
                .foregroundStyle(Color.oldMoney.textSecondary)
                .font(.caption2)
                .accessibilityHidden(true)
              Text(String(localized: "budget.period.dates"))
                .font(.caption2)
                .foregroundStyle(Color.oldMoney.textSecondary)
              Spacer()
              Text("\(budget.startDate.formatted(date: .abbreviated, time: .omitted)) - \(budget.endDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(Color.oldMoney.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.oldMoney.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Budget Period Dates")
            .accessibilityValue("\(budget.startDate.formatted(date: .long, time: .omitted)) to \(budget.endDate.formatted(date: .long, time: .omitted))")
          }
          .padding(.horizontal)

          Spacer(minLength: 20)
        }
      }
      .background(Color.oldMoney.background)
      .navigationTitle(String(localized: "budget.details"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingDeleteConfirmation = true
          } label: {
            Image(systemName: "trash")
              .foregroundStyle(Color.oldMoney.expense)
          }
          .accessibilityLabel("Delete Budget")
          .accessibilityHint("Deletes this budget permanently")
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            dismiss()
          }
          .accessibilityLabel("Done")
          .accessibilityHint("Closes the budget detail view")
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
