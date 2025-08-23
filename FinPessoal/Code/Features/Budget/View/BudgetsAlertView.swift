//
//  BudgetsAlertView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct BudgetAlertsView: View {
  let budgets: [Budget]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("dashboard.budget_alerts")
        .font(.headline)
      
      ForEach(budgets) { budget in
        BudgetAlertRowView(budget: budget)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

#Preview {
  BudgetAlertsView(budgets: [])
}
