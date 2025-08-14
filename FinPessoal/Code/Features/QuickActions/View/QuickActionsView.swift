//
//  QuickActionsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct QuickActionsView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("dashboard.quick_actions")
        .font(.headline)
      
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
        QuickActionButton(
          icon: "plus.circle.fill",
          title: "dashboard.add_transaction",
          color: .blue
        ) {
          // Add transaction action
        }
        
        QuickActionButton(
          icon: "chart.pie.fill",
          title: "dashboard.create_budget",
          color: .green
        ) {
          // Create budget action
        }
        
        QuickActionButton(
          icon: "target",
          title: "dashboard.set_goal",
          color: .purple
        ) {
          // Set goal action
        }
        
        QuickActionButton(
          icon: "chart.bar.fill",
          title: "dashboard.view_reports",
          color: .orange
        ) {
          // View reports action
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
