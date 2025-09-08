//
//  ReportsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct ReportsScreen: View {
  @State private var showingSettings = false
  
  var body: some View {
    NavigationView {
      EmptyStateView(
        icon: "chart.bar",
        title: "reports.empty.title",
        subtitle: "reports.empty.subtitle"
      )
      .navigationTitle("reports.title")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingSettings = true
          } label: {
            Image(systemName: "gear")
          }
        }
      }
    }
    .sheet(isPresented: $showingSettings) {
      SettingsScreen()
    }
  }
}
