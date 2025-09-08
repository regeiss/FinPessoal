//
//  MoreScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 08/09/25.
//

import SwiftUI

struct MoreScreen: View {
  @State private var showingSettings = false
  
  var body: some View {
    NavigationView {
      List {
        Section {
          NavigationLink {
            BudgetsScreen()
          } label: {
            HStack {
              Image(systemName: "chart.pie.fill")
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.budgets"))
                  .font(.headline)
                Text(String(localized: "sidebar.budgets.description"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
          
          NavigationLink {
            ReportsScreen()
          } label: {
            HStack {
              Image(systemName: "chart.bar.fill")
                .foregroundColor(.green)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.reports"))
                  .font(.headline)
                Text(String(localized: "sidebar.reports.description"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text(String(localized: "more.features.header"))
        }
      }
      .navigationTitle(String(localized: "tab.more"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
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