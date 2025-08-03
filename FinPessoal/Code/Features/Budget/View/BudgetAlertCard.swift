//
//  BudgetAlertCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct BudgetAlertCard: View {
  let budget: Budget
  
  var body: some View {
    HStack {
      Image(systemName: budget.isOverBudget ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
        .foregroundColor(budget.isOverBudget ? .red : .orange)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(budget.name)
          .font(.caption)
          .fontWeight(.medium)
        
        Text(budget.isOverBudget ? "Ultrapassou o orçamento" : "Próximo ao limite")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Text(budget.formattedSpent)
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(budget.isOverBudget ? .red : .orange)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(budget.isOverBudget ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
    .cornerRadius(8)
  }
}
