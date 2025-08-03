//
//  BudgetSummaryCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct BudgetSummaryCard: View {
  let budget: Budget
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: budget.category.icon)
          .foregroundColor(.blue)
          .font(.caption)
        
        Text(budget.name)
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
        
        Spacer()
      }
      
      ProgressView(value: budget.percentageUsed, total: 1.0)
        .tint(budget.isOverBudget ? .red :
                budget.shouldAlert ? .orange : .green)
        .scaleEffect(x: 1, y: 1.5)
      
      HStack {
        Text(budget.formattedSpent)
          .font(.caption2)
          .fontWeight(.semibold)
        
        Spacer()
        
        Text("\(Int(budget.percentageUsed * 100))%")
          .font(.caption2)
          .foregroundColor(budget.isOverBudget ? .red :
                            budget.shouldAlert ? .orange : .green)
      }
    }
    .padding(12)
    .frame(width: 140)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}
