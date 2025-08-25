//
//  BudgetAlertCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct BudgetAlertCard: View {
  let budget: Budget
  
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(budget.isOverBudget ? .red : .orange)
                .font(.caption)
            
            Text(budget.isOverBudget ? 
                 String(localized: "budget.alert.over.budget") :
                 String(localized: "budget.alert.near.limit"))
                .font(.caption)
                .foregroundColor(budget.isOverBudget ? .red : .orange)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background((budget.isOverBudget ? Color.red : Color.orange).opacity(0.1))
        .cornerRadius(8)
    }
}
