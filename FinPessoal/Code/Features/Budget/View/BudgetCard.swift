//
//  BudgetCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import SwiftUI

struct BudgetCard: View {
  let budget: Budget
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: budget.category.icon)
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 32, height: 32)
        
        VStack(alignment: .leading, spacing: 2) {
          Text(budget.name)
            .font(.headline)
            .foregroundColor(.primary)
          
          Text(budget.category.displayName)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 2) {
          Text(budget.formattedSpent)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(budget.isOverBudget ? .red : .primary)
          
          Text("de \(budget.formattedBudgetAmount)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      VStack(spacing: 8) {
        ProgressView(value: budget.percentageUsed, total: 1.0)
          .tint(budget.isOverBudget ? .red :
                  budget.shouldAlert ? .orange : .green)
        
        HStack {
          Text("Restante: \(budget.formattedRemaining)")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Text("\(Int(budget.percentageUsed * 100))%")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(budget.isOverBudget ? .red :
                              budget.shouldAlert ? .orange : .green)
        }
      }
      
      if budget.isOverBudget {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .font(.caption)
          
          Text("Orçamento ultrapassado!")
            .font(.caption)
            .foregroundColor(.red)
            .fontWeight(.medium)
          
          Spacer()
        }
      } else if budget.shouldAlert {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
            .font(.caption)
          
          Text("Próximo ao limite (\(Int(budget.alertThreshold * 100))%)")
            .font(.caption)
            .foregroundColor(.orange)
            .fontWeight(.medium)
          
          Spacer()
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
