//
//  AddGoalScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct AddGoalScreen: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var goalViewModel: GoalViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAlert = false
  @State private var alertMessage = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField(String(localized: "goal.name.placeholder"), text: $goalViewModel.name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          
          TextField(String(localized: "goal.description.placeholder"), text: $goalViewModel.description, axis: .vertical)
            .lineLimit(2...4)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } header: {
          Text(String(localized: "goal.basic.info"))
        }
        
        Section {
          Picker(String(localized: "goal.category"), selection: $goalViewModel.selectedCategory) {
            ForEach(GoalCategory.allCases, id: \.self) { category in
              HStack {
                Image(systemName: category.icon)
                  .foregroundColor(Color(category.color))
                  .frame(width: 20)
                Text(category.displayName)
              }
              .tag(category)
            }
          }
          .pickerStyle(.navigationLink)
        } header: {
          Text(String(localized: "goal.category.section"))
        }
        
        Section {
          HStack {
            Text("R$")
              .foregroundColor(.secondary)
            TextField(String(localized: "goal.target.amount.placeholder"), text: $goalViewModel.targetAmount)
              .keyboardType(.decimalPad)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
          
          HStack {
            Text("R$")
              .foregroundColor(.secondary)
            TextField(String(localized: "goal.current.amount.placeholder"), text: $goalViewModel.currentAmount)
              .keyboardType(.decimalPad)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
        } header: {
          Text(String(localized: "goal.amount.section"))
        } footer: {
          Text(String(localized: "goal.amount.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Section {
          DatePicker(
            String(localized: "goal.target.date"),
            selection: $goalViewModel.targetDate,
            in: Date()...,
            displayedComponents: [.date]
          )
          .datePickerStyle(.compact)
        } header: {
          Text(String(localized: "goal.timeline.section"))
        }
        
        Section {
          HStack {
            Image(systemName: "calendar")
              .foregroundColor(.blue)
              .frame(width: 20)
            Text(String(localized: "goal.monthly.contribution"))
            Spacer()
            Text(goalViewModel.formattedMonthlyContribution)
              .foregroundColor(.secondary)
              .font(.headline)
          }
          
          HStack {
            Image(systemName: "clock")
              .foregroundColor(.orange)
              .frame(width: 20)
            Text(String(localized: "goal.days.remaining"))
            Spacer()
            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: goalViewModel.targetDate).day ?? 0
            Text("\(daysRemaining)")
              .foregroundColor(.secondary)
              .font(.headline)
          }
        } header: {
          Text(String(localized: "goal.calculations"))
        } footer: {
          Text(String(localized: "goal.calculations.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle(String(localized: "goal.add.title"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "goal.save")) {
            saveGoal()
          }
          .disabled(!goalViewModel.isValidGoal || goalViewModel.isLoading)
        }
      }
      .alert(String(localized: "common.error"), isPresented: $showingAlert) {
        Button("OK") { }
      } message: {
        Text(alertMessage)
      }
    }
  }
  
  private func saveGoal() {
    guard let newGoal = goalViewModel.createGoal() else {
      alertMessage = String(localized: "goal.error.invalid.data")
      showingAlert = true
      return
    }
    
    Task {
      goalViewModel.isLoading = true
      await financeViewModel.addGoal(newGoal)
      
      if financeViewModel.errorMessage == nil {
        await MainActor.run {
          goalViewModel.reset()
          dismiss()
        }
      } else {
        await MainActor.run {
          alertMessage = financeViewModel.errorMessage ?? String(localized: "goal.error.save.failed")
          showingAlert = true
          goalViewModel.isLoading = false
        }
      }
    }
  }
}