//
//  ThemedDashboardExample.swift
//  FinPessoal
//
//  Created by Claude on 30/09/25.
//

import SwiftUI

struct ThemedDashboardExample: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var selectedPeriod = "Este Mês"

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Header with syntax-inspired colors
        headerSection

        // Balance Cards
        balanceCardsSection

        // Quick Actions
        quickActionsSection

        // Recent Transactions
        recentTransactionsSection
      }
      .padding()
    }
    .background(AppTheme.primaryBackground(colorScheme))
    .navigationBarHidden(true)
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        VStack(alignment: .leading) {
          Text("Olá, Roberto")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.primaryText(colorScheme))

          Text("Bem-vindo de volta")
            .font(.subheadline)
            .foregroundColor(AppTheme.secondaryText(colorScheme))
        }

        Spacer()

        // Settings button with syntax blue accent
        Button(action: {}) {
          Image(systemName: "gearshape.fill")
            .font(.title2)
            .foregroundColor(
              colorScheme == .dark
                ? AppTheme.DarkColors.syntaxBlue
                : AppTheme.LightColors.syntaxBlue
            )
        }
      }
    }
  }

  private var balanceCardsSection: some View {
    VStack(spacing: 16) {
      // Total Balance Card
      ThemedCard {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text("Saldo Total")
              .font(.subheadline)
              .foregroundColor(AppTheme.secondaryText(colorScheme))

            Spacer()

            ThemedStatusBadge(text: selectedPeriod, status: .info)
          }

          ThemedAmountDisplay(
            amount: 15750.50,
            fontSize: .largeTitle
          )
        }
      }

      // Income/Expense Cards
      HStack(spacing: 16) {
        // Income Card
        ThemedCard {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "arrow.down.circle.fill")
                .foregroundColor(
                  colorScheme == .dark
                    ? AppTheme.DarkColors.syntaxGreen
                    : AppTheme.LightColors.syntaxGreen
                )

              Text("Receitas")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText(colorScheme))
            }

            ThemedAmountDisplay(
              amount: 8500.00,
              type: .income,
              fontSize: .title3
            )
          }
        }

        // Expense Card
        ThemedCard {
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(
                  colorScheme == .dark
                    ? AppTheme.DarkColors.expenseRed
                    : AppTheme.LightColors.expenseRed
                )

              Text("Despesas")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText(colorScheme))
            }

            ThemedAmountDisplay(
              amount: 3250.00,
              type: .expense,
              fontSize: .title3
            )
          }
        }
      }
    }
  }

  private var quickActionsSection: some View {
    ThemedCard {
      VStack(alignment: .leading, spacing: 16) {
        ThemedSectionHeader("Ações Rápidas")

        HStack(spacing: 12) {
          ThemedButton(title: "Receita", style: .income) {
            // Add income action
          }

          ThemedButton(title: "Despesa", style: .expense) {
            // Add expense action
          }

          ThemedButton(title: "Transferir", style: .transfer) {
            // Transfer action
          }
        }
      }
    }
  }

  private var recentTransactionsSection: some View {
    ThemedCard(
      padding: EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    ) {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack {
          ThemedSectionHeader("Transações Recentes")

          Spacer()

          Button("Ver Todas") {
            // View all action
          }
          .font(.subheadline)
          .foregroundColor(
            colorScheme == .dark
              ? AppTheme.DarkColors.syntaxBlue : AppTheme.LightColors.syntaxBlue
          )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)

        // Transaction List
        VStack(spacing: 0) {
          transactionRow(
            icon: "fork.knife",
            title: "Supermercado",
            category: "Alimentação",
            amount: -150.00,
            type: .expense
          )

          transactionRow(
            icon: "dollarsign.circle",
            title: "Salário",
            category: "Trabalho",
            amount: 5000.00,
            type: .income
          )

          transactionRow(
            icon: "car.fill",
            title: "Combustível",
            category: "Transporte",
            amount: -120.00,
            type: .expense,
            showSeparator: false
          )
        }
      }
    }
  }

  private func transactionRow(
    icon: String,
    title: String,
    category: String,
    amount: Double,
    type: TransactionType,
    showSeparator: Bool = true
  ) -> some View {
    ThemedListRow(showSeparator: showSeparator) {
      HStack(spacing: 12) {
        // Icon
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(type.syntaxColor(colorScheme))
          .frame(width: 32, height: 32)
          .background(type.syntaxColor(colorScheme).opacity(0.1))
          .cornerRadius(8)

        // Transaction Info
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.headline)
            .foregroundColor(AppTheme.primaryText(colorScheme))

          Text(category)
            .font(.caption)
            .foregroundColor(AppTheme.secondaryText(colorScheme))
        }

        Spacer()

        // Amount
        ThemedAmountDisplay(
          amount: amount,
          type: type,
          fontSize: .headline
        )
      }
    }
  }
}

#Preview {
  NavigationView {
    ThemedDashboardExample()
  }
  .preferredColorScheme(.dark)
}
