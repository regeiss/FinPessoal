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
    }
  }
}

struct GoalProgressSheet: View {
  let goal: Goal
  @State private var newContribution = ""
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var goalViewModel: GoalViewModel
  
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        // Goal info
        VStack(spacing: 12) {
          Image(systemName: goal.category.icon)
            .font(.system(size: 40))
            .foregroundColor(Color(goal.category.color))
          
          Text(goal.name)
            .font(.title2)
            .fontWeight(.semibold)
          
          if let description = goal.description {
            Text(description)
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }
        .padding()
        
        // Progress circle
        ZStack {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            .frame(width: 120, height: 120)
          
          Circle()
            .trim(from: 0, to: goal.progressPercentage / 100.0)
            .stroke(Color(goal.category.color), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .frame(width: 120, height: 120)
            .rotationEffect(.degrees(-90))
          
          Text("\(Int(goal.progressPercentage))%")
            .font(.title2)
            .fontWeight(.bold)
        }
        
        // Add contribution
        VStack(spacing: 12) {
          Text(String(localized: "goal.add.contribution"))
            .font(.headline)
          
          HStack {
            Text("R$")
              .foregroundColor(.secondary)
            TextField(String(localized: "goal.contribution.amount"), text: $newContribution)
              .keyboardType(.decimalPad)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
          
          Button(String(localized: "goal.add.amount")) {
            addContribution()
          }
          .buttonStyle(.borderedProminent)
          .disabled(newContribution.isEmpty || Double(newContribution) == nil)
        }
        .padding()
        
        Spacer()
      }
      .navigationTitle(String(localized: "goal.progress"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            dismiss()
          }
        }
      }
    }
  }
  
  private func addContribution() {
    guard let amount = Double(newContribution) else { return }
    let newTotal = goal.currentAmount + amount
    goalViewModel.updateGoalProgress(goal.id, newAmount: newTotal, in: &financeViewModel.goals)
    newContribution = ""
    dismiss()
  }
}