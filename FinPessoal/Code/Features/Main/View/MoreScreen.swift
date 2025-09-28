//
//  MoreScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 08/09/25.
//

import SwiftUI

struct MoreScreen: View {
  
  var body: some View {
    NavigationView {
      List {
        Section {
          NavigationLink {
            GoalScreen()
          } label: {
            HStack {
              Image(systemName: "target")
                .foregroundColor(.purple)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.goals"))
                  .font(.headline)
                Text(String(localized: "sidebar.goals.description"))
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
          
          NavigationLink {
            CreditCardsScreen()
          } label: {
            HStack {
              Image(systemName: "creditcard.fill")
                .foregroundColor(.purple)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "creditcard.title"))
                  .font(.headline)
                Text(String(localized: "creditcard.description"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
          
          NavigationLink {
            LoansScreen()
          } label: {
            HStack {
              Image(systemName: "building.columns.fill")
                .foregroundColor(.indigo)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "loan.title"))
                  .font(.headline)
                Text(String(localized: "loan.empty.description"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text(String(localized: "more.features.header"))
        }
        
        Section {
          NavigationLink {
            CategoriesManagementScreen(transactionRepository: AppConfiguration.shared.createTransactionRepository())
          } label: {
            HStack {
              Image(systemName: "tag.fill")
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "categories.management.title"))
                  .font(.headline)
                Text(String(localized: "categories.management.description"))
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text(String(localized: "more.settings.header"))
        }
      }
      .navigationTitle(String(localized: "tab.more"))
    }
  }
}