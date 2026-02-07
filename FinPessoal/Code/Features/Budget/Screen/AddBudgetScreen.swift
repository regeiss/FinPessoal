//
//  AddBudgetScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct AddBudgetScreen: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var budgetViewModel: BudgetViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAlert = false
  @State private var alertMessage = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          StyledTextField(
            title: String(localized: "budget.name.section"),
            text: $budgetViewModel.name,
            placeholder: String(localized: "budget.name.placeholder")
          )
          .accessibilityLabel("Budget Name")
          .accessibilityHint("Enter a descriptive name for this budget")
          .accessibilityValue(budgetViewModel.name.isEmpty ? "Empty" : budgetViewModel.name)
        }
        
        Section {
          Picker(String(localized: "budget.category"), selection: $budgetViewModel.selectedCategory) {
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              HStack {
                Image(systemName: category.icon)
                  .foregroundColor(.blue)
                  .frame(width: 20)
                  .accessibilityHidden(true)
                Text(category.displayName)
              }
              .tag(category)
            }
          }
          .pickerStyle(.navigationLink)
          .accessibilityLabel("Budget Category")
          .accessibilityHint("Select the category for this budget")
          .accessibilityValue(budgetViewModel.selectedCategory.displayName)
        } header: {
          Text(String(localized: "budget.category.section"))
        }
        
        Section {
          HStack(spacing: 8) {
            Text("R$")
              .font(.body)
              .foregroundColor(Color.oldMoney.textSecondary)
              .accessibilityHidden(true)

            StyledTextField(
              title: String(localized: "budget.amount.section"),
              text: $budgetViewModel.budgetAmount,
              placeholder: String(localized: "budget.amount.placeholder"),
              keyboardType: .decimalPad
            )
            .accessibilityLabel("Budget Amount in Brazilian Reais")
            .accessibilityHint("Enter the total budget amount")
            .accessibilityValue(budgetViewModel.budgetAmount.isEmpty ? "Empty" : "R$ \(budgetViewModel.budgetAmount)")
          }
        } footer: {
          Text(String(localized: "budget.amount.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Section {
          Picker(String(localized: "budget.period"), selection: $budgetViewModel.selectedPeriod) {
            ForEach(BudgetPeriod.allCases, id: \.self) { period in
              HStack {
                Image(systemName: period.icon)
                  .foregroundColor(.blue)
                  .frame(width: 20)
                  .accessibilityHidden(true)
                Text(period.rawValue)
              }
              .tag(period)
            }
          }
          .pickerStyle(.navigationLink)
          .accessibilityLabel("Budget Period")
          .accessibilityHint("Select how often this budget repeats")
          .accessibilityValue(budgetViewModel.selectedPeriod.rawValue)
        } header: {
          Text(String(localized: "budget.period.section"))
        }
        
        Section {
          DatePicker(
            String(localized: "budget.start.date"),
            selection: $budgetViewModel.startDate,
            displayedComponents: [.date]
          )
          .datePickerStyle(.compact)
          .accessibilityLabel("Budget Start Date")
          .accessibilityHint("Select when this budget period begins")

          HStack {
            Text(String(localized: "budget.end.date"))
            Spacer()
            Text(budgetViewModel.endDate, format: .dateTime.day().month().year())
              .foregroundColor(.secondary)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Budget End Date")
          .accessibilityValue(budgetViewModel.endDate.formatted(date: .long, time: .omitted))
          .accessibilityAddTraits(.isStaticText)
        } header: {
          Text(String(localized: "budget.period.dates"))
        }
        
        Section {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(String(localized: "budget.alert.threshold"))
              Spacer()
              Text("\(Int(budgetViewModel.alertThreshold * 100))%")
                .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Alert Threshold")
            .accessibilityValue("\(Int(budgetViewModel.alertThreshold * 100))%")
            .accessibilityAddTraits(.isStaticText)

            Slider(
              value: $budgetViewModel.alertThreshold,
              in: 0.5...1.0,
              step: 0.05
            )
            .tint(.orange)
            .accessibilityLabel("Alert Threshold Slider")
            .accessibilityHint("Adjust the percentage at which you'll be notified about budget usage. Current value is \(Int(budgetViewModel.alertThreshold * 100))%")
            .accessibilityValue("\(Int(budgetViewModel.alertThreshold * 100)) percent")
          }
        } header: {
          Text(String(localized: "budget.alerts.section"))
        } footer: {
          Text(String(localized: "budget.alert.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle(String(localized: "budget.add.title"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(String(localized: "budget.save")) {
              saveBudget()
            }
            .disabled(!budgetViewModel.isValidBudget || budgetViewModel.isLoading)
            .accessibilityLabel("Save Budget")
            .accessibilityHint(budgetViewModel.isValidBudget ? "Saves the new budget" : "Complete all required fields to save")

            Button(String(localized: "common.close")) {
              dismiss()
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Closes the budget form without saving")
          }
        }
      }
      .alert(String(localized: "common.error"), isPresented: $showingAlert) {
        Button("OK") { }
      } message: {
        Text(alertMessage)
      }
    }
  }
  
  private func saveBudget() {
    guard let newBudget = budgetViewModel.createBudget() else {
      alertMessage = String(localized: "budget.error.invalid.data")
      showingAlert = true
      return
    }
    
    Task {
      budgetViewModel.isLoading = true
      // In a real app, this would save to Firebase
      await MainActor.run {
        financeViewModel.budgets.append(newBudget)
        budgetViewModel.reset()
        budgetViewModel.isLoading = false
        dismiss()
      }
    }
  }
}

