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
    List {
        Section {
          NavigationLink {
            AIInsightsScreen()
          } label: {
            HStack {
              Image(systemName: "brain")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)

              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "ai.insights.title"))
                  .font(.headline)
                Text(String(localized: "ai.insights.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }

          NavigationLink {
            InsightsScreen()
          } label: {
            HStack {
              Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)

              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "insights.title"))
                  .font(.headline)
                Text(String(localized: "insights.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }

          NavigationLink {
            BudgetsScreen()
          } label: {
            HStack {
              Image(systemName: "chart.pie.fill")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)

              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.budgets"))
                  .font(.headline)
                Text(String(localized: "sidebar.budgets.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }

          NavigationLink {
            BillsScreen(repository: AppConfiguration.shared.createBillRepository())
          } label: {
            HStack {
              Image(systemName: "doc.text.fill")
                .foregroundStyle(Color.oldMoney.expense)
                .frame(width: 32, height: 32)

              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.bills"))
                  .font(.headline)
                Text(String(localized: "sidebar.bills.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }

          NavigationLink {
            GoalScreen()
          } label: {
            HStack {
              Image(systemName: "target")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)

              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.goals"))
                  .font(.headline)
                Text(String(localized: "sidebar.goals.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }

          NavigationLink {
            ReportsScreen()
          } label: {
            HStack {
              Image(systemName: "chart.bar.fill")
                .foregroundStyle(Color.oldMoney.income)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "sidebar.reports"))
                  .font(.headline)
                Text(String(localized: "sidebar.reports.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }
          
          NavigationLink {
            CreditCardsScreen()
          } label: {
            HStack {
              Image(systemName: "creditcard.fill")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "creditcard.title"))
                  .font(.headline)
                Text(String(localized: "creditcard.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }
          
          NavigationLink {
            LoansScreen()
          } label: {
            HStack {
              Image(systemName: "building.columns.fill")
                .foregroundStyle(Color.oldMoney.accent)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "loan.title"))
                  .font(.headline)
                Text(String(localized: "loan.empty.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text(String(localized: "more.features.header"))
        }
        
        Section {
          NavigationLink {
            CategoriesManagementScreen(
              transactionRepository: AppConfiguration.shared.createTransactionRepository(),
              categoryRepository: AppConfiguration.shared.createCategoryRepository()
            )
          } label: {
            HStack {
              Image(systemName: "tag.fill")
                .foregroundStyle(Color.oldMoney.warning)
                .frame(width: 32, height: 32)
              
              VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "categories.management.title"))
                  .font(.headline)
                Text(String(localized: "categories.management.description"))
                  .font(.caption)
                  .foregroundStyle(Color.oldMoney.textSecondary)
              }
            }
            .padding(.vertical, 4)
          }
        } header: {
          Text(String(localized: "more.settings.header"))
        }
      }
      .background(Color.oldMoney.background)
      .navigationTitle(String(localized: "tab.more"))
      .toolbar {
        if UIDevice.current.userInterfaceIdiom != .pad {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              showingSettings = true
            } label: {
              Image(systemName: "gearshape")
            }
            .accessibilityLabel(String(localized: "Settings"))
            .accessibilityHint(String(localized: "Open application settings"))
          }
        }
      }
      .sheet(isPresented: $showingSettings) {
        SettingsScreen()
      }
  }
}