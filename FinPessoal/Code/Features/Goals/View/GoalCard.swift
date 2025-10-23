//
//  GoalCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct GoalCard: View {
  let goal: Goal
  @State private var showingProgressSheet = false
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var goalViewModel: GoalViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        HStack(spacing: 8) {
          Image(systemName: goal.category.icon)
            .foregroundColor(Color(goal.category.color))
            .frame(width: 24, height: 24)
          
          VStack(alignment: .leading, spacing: 2) {
            Text(goal.name)
              .font(.headline)
              .foregroundColor(.primary)
            
            if let description = goal.description {
              Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
          }
        }
        
        Spacer()
        
        if goal.isCompleted {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.title2)
        }
      }
      
      // Progress
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 4) {
          VStack(alignment: .leading, spacing: 2) {
            Text(CurrencyFormatter.shared.string(from: goal.currentAmount))
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(.primary)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
            
            HStack(spacing: 2) {
              Text("de")
                .font(.caption)
                .foregroundColor(.secondary)
              Text(CurrencyFormatter.shared.string(from: goal.targetAmount))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
          }
          
          Spacer()
          
          Text("\(Int(goal.progressPercentage))%")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color(goal.category.color))
        }
        
        ProgressView(value: goal.progressPercentage / 100.0)
          .progressViewStyle(LinearProgressViewStyle(tint: Color(goal.category.color)))
          .scaleEffect(x: 1, y: 1.5, anchor: .center)
      }
      
      // Stats
      HStack(spacing: 8) {
        VStack(alignment: .leading, spacing: 2) {
          Text(String(localized: "goal.remaining"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(CurrencyFormatter.shared.string(from: goal.remainingAmount))
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack(alignment: .trailing, spacing: 2) {
          Text(String(localized: "goal.days.left"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text("\(goal.daysRemaining) dias")
            .font(.caption)
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      
      // Monthly contribution needed
      if !goal.isCompleted {
        HStack(spacing: 4) {
          Image(systemName: "calendar")
            .foregroundColor(.blue)
            .font(.caption2)
          Text(String(localized: "goal.monthly.needed"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Spacer()
          Text(CurrencyFormatter.shared.string(from: goal.monthlyContributionNeeded))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 4))
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    .onTapGesture {
      showingProgressSheet = true
    }
    .sheet(isPresented: $showingProgressSheet) {
      GoalProgressSheet(goal: goal)
        .environmentObject(financeViewModel)
        .environmentObject(goalViewModel)
    }
  }
}

struct GoalProgressSheet: View {
  let goal: Goal
  @State private var newContribution = ""
  @State private var contributionAmount: Double = 0
  @State private var showingDeleteConfirmation = false
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var goalViewModel: GoalViewModel

  private var remainingAmount: Double {
    goal.targetAmount - goal.currentAmount
  }

  private var formattedContribution: String {
    if contributionAmount == 0 {
      return ""
    }
    return CurrencyHelper.format(contributionAmount)
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header with icon and title
          VStack(spacing: 16) {
            ZStack {
              Circle()
                .fill(Color(goal.category.color).opacity(0.15))
                .frame(width: 80, height: 80)

              Image(systemName: goal.category.icon)
                .font(.system(size: 36))
                .foregroundColor(Color(goal.category.color))
            }

            VStack(spacing: 4) {
              Text(goal.name)
                .font(.title2)
                .fontWeight(.bold)

              if let description = goal.description {
                Text(description)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
              }
            }
          }
          .padding(.top, 8)

          // Progress section
          VStack(spacing: 20) {
            // Progress circle
            ZStack {
              Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                .frame(width: 160, height: 160)

              if goal.progressPercentage > 0 {
                Circle()
                  .trim(from: 0, to: min(goal.progressPercentage / 100.0, 1.0))
                  .stroke(
                    goal.isCompleted ? Color.green : goal.category.swiftUIColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                  )
                  .frame(width: 160, height: 160)
                  .rotationEffect(.degrees(-90))
                  .animation(.easeInOut(duration: 0.8), value: goal.progressPercentage)
              }

              VStack(spacing: 4) {
                if goal.isCompleted {
                  Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)

                  Text(String(localized: "goal.completed"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                } else {
                  Text("\(Int(min(goal.progressPercentage, 100)))%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(goal.category.swiftUIColor)

                  Text(String(localized: "goal.progress"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }
            }

            // Amount details
            VStack(spacing: 12) {
              HStack {
                Text(String(localized: "goal.current"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(CurrencyHelper.format(goal.currentAmount))
                  .font(.headline)
                  .foregroundColor(.primary)
              }

              Divider()

              HStack {
                Text(String(localized: "goal.target"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(CurrencyHelper.format(goal.targetAmount))
                  .font(.headline)
                  .foregroundColor(.primary)
              }

              Divider()

              HStack {
                Text(String(localized: "goal.remaining"))
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
                Text(CurrencyHelper.format(max(remainingAmount, 0)))
                  .font(.headline)
                  .fontWeight(.semibold)
                  .foregroundColor(goal.category.swiftUIColor)
              }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
          }
          .padding(.horizontal)

          // Add contribution section
          VStack(spacing: 16) {
            Text(String(localized: "goal.add.contribution"))
              .font(.headline)
              .frame(maxWidth: .infinity, alignment: .leading)

            // Money input field
            VStack(alignment: .leading, spacing: 8) {
              HStack(spacing: 12) {
                Text(CurrencyHelper.getCurrentCurrency().symbol)
                  .font(.title3)
                  .fontWeight(.medium)
                  .foregroundColor(.secondary)
                  .frame(width: 30)

                TextField("0,00", text: $newContribution)
                  .keyboardType(.decimalPad)
                  .font(.title2)
                  .fontWeight(.semibold)
                  .onChange(of: newContribution) { _, newValue in
                    formatMoneyInput(newValue)
                  }
              }
              .padding()
              .background(Color(.secondarySystemGroupedBackground))
              .cornerRadius(12)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(contributionAmount > 0 ? goal.category.swiftUIColor : Color.clear, lineWidth: 2)
              )

              if contributionAmount > 0 {
                Text("Valor: \(formattedContribution)")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.leading, 4)
              }
            }

            // Quick amount buttons
            if remainingAmount > 0 {
              VStack(alignment: .leading, spacing: 8) {
                Text("Atalhos rápidos")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding(.leading, 4)

                HStack(spacing: 12) {
                  QuickAmountButton(
                    title: "25%",
                    amount: remainingAmount * 0.25,
                    color: Color(goal.category.color)
                  ) {
                    setContribution(remainingAmount * 0.25)
                  }

                  QuickAmountButton(
                    title: "50%",
                    amount: remainingAmount * 0.5,
                    color: Color(goal.category.color)
                  ) {
                    setContribution(remainingAmount * 0.5)
                  }

                  QuickAmountButton(
                    title: "100%",
                    amount: remainingAmount,
                    color: Color(goal.category.color)
                  ) {
                    setContribution(remainingAmount)
                  }
                }
              }
            }

            // Add button
            Button {
              addContribution()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                  .font(.system(size: 18))
                Text(String(localized: "goal.add.amount"))
                  .fontWeight(.semibold)
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .padding(.horizontal, 24)
              .background(contributionAmount > 0 ? Color.blue : Color.gray.opacity(0.3))
              .foregroundColor(.white)
              .cornerRadius(12)
              .shadow(color: contributionAmount > 0 ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
            .disabled(contributionAmount <= 0)
            .animation(.easeInOut(duration: 0.2), value: contributionAmount > 0)
          }
          .padding()
          .background(Color(.systemGroupedBackground))
          .cornerRadius(16)
          .padding(.horizontal)

          Spacer(minLength: 20)
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle(String(localized: "goal.progress"))
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
        String(localized: "goal.delete.confirmation"),
        isPresented: $showingDeleteConfirmation
      ) {
        Button(String(localized: "common.cancel"), role: .cancel) {}
        Button(String(localized: "goal.delete.button"), role: .destructive) {
          deleteGoal()
        }
      } message: {
        Text(String(localized: "goal.delete.message"))
      }
    }
  }

  private func deleteGoal() {
    financeViewModel.goals.removeAll { $0.id == goal.id }
    dismiss()
  }

  private func formatMoneyInput(_ input: String) {
    // Remove all non-numeric characters
    let digitsOnly = input.filter { "0123456789".contains($0) }

    // If empty, reset
    guard !digitsOnly.isEmpty else {
      contributionAmount = 0
      newContribution = ""
      return
    }

    // Convert to cents (integer)
    guard let cents = Int(digitsOnly) else {
      contributionAmount = 0
      return
    }

    // Convert cents to actual value
    let value = Double(cents) / 100.0
    contributionAmount = value

    // Format the display value
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ","
    formatter.groupingSeparator = "."

    if let formattedValue = formatter.string(from: NSNumber(value: value)) {
      newContribution = formattedValue
    }
  }

  private func setContribution(_ amount: Double) {
    contributionAmount = amount
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ","
    formatter.groupingSeparator = "."
    newContribution = formatter.string(from: NSNumber(value: amount)) ?? ""
  }

  private func addContribution() {
    guard contributionAmount > 0 else { return }
    let newTotal = goal.currentAmount + contributionAmount
    goalViewModel.updateGoalProgress(goal.id, newAmount: newTotal, in: &financeViewModel.goals)
    newContribution = ""
    contributionAmount = 0
    dismiss()
  }
}

// Quick amount button component
struct QuickAmountButton: View {
  let title: String
  let amount: Double
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Text(title)
          .font(.caption)
          .fontWeight(.semibold)
        Text(CurrencyHelper.format(amount))
          .font(.caption2)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(color.opacity(0.1))
      .foregroundColor(color)
      .cornerRadius(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(color.opacity(0.3), lineWidth: 1)
      )
    }
  }
}
