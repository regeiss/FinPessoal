//
//  BudgetScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct BudgetScreen: View {
  var body: some View {
    NavigationView {
      EmptyStateView(
        icon: "chart.pie",
        title: "budgets.empty.title",
        subtitle: "budgets.empty.subtitle"
      )
      .navigationTitle("budgets.title")
    }
  }
}
