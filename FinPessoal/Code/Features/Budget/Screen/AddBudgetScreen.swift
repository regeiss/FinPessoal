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
          TextField(String(localized: "budget.name.placeholder"), text: $budgetViewModel.name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } header: {
          Text(String(localized: "budget.name.section"))
        }
        
        Section {
          Picker(String(localized: "budget.category"), selection: $budgetViewModel.selectedCategory) {
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              HStack {
                Image(systemName: category.icon)
                  .foregroundColor(.blue)
                  .frame(width: 20)
                Text(category.displayName)
              }
              .tag(category)
            }
          }
          .pickerStyle(.navigationLink)
        } header: {
          Text(String(localized: "budget.category.section"))
        }
        
        Section {
          HStack {
            Text("R$")
              .foregroundColor(.secondary)
            TextField(String(localized: "budget.amount.placeholder"), text: $budgetViewModel.budgetAmount)
              .keyboardType(.decimalPad)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
        } header: {
          Text(String(localized: "budget.amount.section"))
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
                Text(period.rawValue)
              }
              .tag(period)
            }
          }
          .pickerStyle(.navigationLink)
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
          
          HStack {
            Text(String(localized: "budget.end.date"))
            Spacer()
            Text(budgetViewModel.endDate, format: .dateTime.day().month().year())
              .foregroundColor(.secondary)
          }
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
            
            Slider(
              value: $budgetViewModel.alertThreshold,
              in: 0.5...1.0,
              step: 0.05
            )
            .tint(.orange)
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
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "budget.save")) {
            saveBudget()
          }
          .disabled(!budgetViewModel.isValidBudget || budgetViewModel.isLoading)
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

