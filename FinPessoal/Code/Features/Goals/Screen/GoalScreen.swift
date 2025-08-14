//
//  GoalsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct GoalScreen: View {
    var body: some View {
      NavigationView {
        EmptyStateView(
          icon: "target",
          title: "goals.empty.title",
          subtitle: "goals.empty.subtitle"
        )
        .navigationTitle("goals.title")
      }
    }
  }
