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
          StyledTextField(
            text: $goalViewModel.name,
            placeholder: String(localized: "goal.name.placeholder")
          )

          StyledTextField(
            text: $goalViewModel.description,
            placeholder: String(localized: "goal.description.placeholder")
          )
        } header: {
          Text(String(localized: "goal.basic.info"))
        }
        .accessibilityElement(children: .contain)

        Section {
          Picker(String(localized: "goal.category"), selection: $goalViewModel.selectedCategory) {
            ForEach(GoalCategory.allCases, id: \.self) { category in
              HStack {
                Image(systemName: category.icon)
                  .foregroundColor(Color(category.color))
                  .frame(width: 20)
                  .accessibilityHidden(true)
                Text(category.displayName)
              }
              .tag(category)
            }
          }
          .pickerStyle(.navigationLink)
          .accessibilityLabel("Goal Category")
          .accessibilityHint("Select a category for this goal")
          .accessibilityValue(goalViewModel.selectedCategory.displayName)
        } header: {
          Text(String(localized: "goal.category.section"))
        }
        .accessibilityElement(children: .contain)

        Section {
          HStack {
            Text("R$")
              .foregroundColor(.secondary)
              .accessibilityHidden(true)
            StyledTextField(
              text: $goalViewModel.targetAmount,
              placeholder: String(localized: "goal.target.amount.placeholder"),
              keyboardType: .decimalPad
            )
          }

          HStack {
            Text("R$")
              .foregroundColor(.secondary)
              .accessibilityHidden(true)
            StyledTextField(
              text: $goalViewModel.currentAmount,
              placeholder: String(localized: "goal.current.amount.placeholder"),
              keyboardType: .decimalPad
            )
          }
        } header: {
          Text(String(localized: "goal.amount.section"))
        } footer: {
          Text(String(localized: "goal.amount.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .contain)

        Section {
          DatePicker(
            String(localized: "goal.target.date"),
            selection: $goalViewModel.targetDate,
            in: Date()...,
            displayedComponents: [.date]
          )
          .datePickerStyle(.compact)
          .accessibilityLabel("Target Date")
          .accessibilityHint("Select the date by which you want to achieve this goal")
        } header: {
          Text(String(localized: "goal.timeline.section"))
        }
        .accessibilityElement(children: .contain)

        Section {
          HStack {
            Image(systemName: "calendar")
              .foregroundColor(.blue)
              .frame(width: 20)
              .accessibilityHidden(true)
            Text(String(localized: "goal.monthly.contribution"))
            Spacer()
            Text(goalViewModel.formattedMonthlyContribution)
              .foregroundColor(.secondary)
              .font(.headline)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Monthly Contribution Needed")
          .accessibilityValue(goalViewModel.formattedMonthlyContribution)

          HStack {
            Image(systemName: "clock")
              .foregroundColor(.orange)
              .frame(width: 20)
              .accessibilityHidden(true)
            Text(String(localized: "goal.days.remaining"))
            Spacer()
            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: goalViewModel.targetDate).day ?? 0
            Text("\(daysRemaining)")
              .foregroundColor(.secondary)
              .font(.headline)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Days Remaining")
          .accessibilityValue("\(Calendar.current.dateComponents([.day], from: Date(), to: goalViewModel.targetDate).day ?? 0) days")
        } header: {
          Text(String(localized: "goal.calculations"))
        } footer: {
          Text(String(localized: "goal.calculations.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .contain)
      }
      .navigationTitle(String(localized: "goal.add.title"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(String(localized: "goal.save")) {
              saveGoal()
            }
            .disabled(!goalViewModel.isValidGoal || goalViewModel.isLoading)
            .accessibilityLabel("Save Goal")
            .accessibilityHint(goalViewModel.isValidGoal ? "Saves the goal and closes the form" : "Button is disabled. Please fill in all required fields")
            .accessibilityAddTraits(goalViewModel.isValidGoal ? [] : .isButton)

            Button(String(localized: "common.close")) {
              dismiss()
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Closes the form without saving")
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