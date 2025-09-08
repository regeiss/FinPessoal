//
//  TransactionDetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct TransactionDetailView: View {
  let transaction: Transaction
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingDeleteAlert = false
  @State private var showingEditView = false
  
  var relatedAccount: Account? {
    financeViewModel.accounts.first { $0.id == transaction.accountId }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          transactionHeaderSection
          transactionDetailsSection
          accountInfoSection
          categoryInfoSection
          if transaction.isRecurring {
            recurringInfoSection
          }
        }
        .padding()
      }
      .navigationTitle(String(localized: "transaction.detail.title", defaultValue: "Detalhes da Transação"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(String(localized: "common.edit")) {
              showingEditView = true
            }
            
            Divider()
            
            Button(String(localized: "common.delete"), role: .destructive) {
              showingDeleteAlert = true
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .alert(String(localized: "transaction.delete.title", defaultValue: "Deletar Transação"), isPresented: $showingDeleteAlert) {
        Button(String(localized: "common.cancel"), role: .cancel) { }
        Button(String(localized: "common.delete"), role: .destructive) {
          deleteTransaction()
        }
      } message: {
        Text(String(localized: "transaction.delete.confirmation", defaultValue: "Tem certeza que deseja deletar esta transação? Esta ação não pode ser desfeita."))
      }
      .sheet(isPresented: $showingEditView) {
        EditTransactionView(transaction: transaction)
          .environmentObject(financeViewModel)
      }
    }
  }
  
  private var transactionHeaderSection: some View {
    VStack(spacing: 16) {
      Image(systemName: transaction.type == .transfer ? transaction.type.icon : transaction.category.icon)
        .font(.system(size: 60))
        .foregroundColor(transaction.type == .income ? .green : transaction.type == .expense ? .red : .blue)
        .frame(width: 100, height: 100)
        .background((transaction.type == .income ? Color.green : transaction.type == .expense ? Color.red : Color.blue).opacity(0.1))
        .cornerRadius(20)
      
      Text(transaction.description)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
      
      Text(transaction.formattedAmount)
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(transaction.type == .income ? .green : transaction.type == .expense ? .red : .blue)
      
      Text(transaction.type.displayName)
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background((transaction.type == .income ? Color.green : transaction.type == .expense ? Color.red : Color.blue).opacity(0.2))
        .foregroundColor(transaction.type == .income ? .green : transaction.type == .expense ? .red : .blue)
        .cornerRadius(8)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var transactionDetailsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "transaction.info.title", defaultValue: "Informações da Transação"))
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 8) {
        TransactionDetailRow(
          label: String(localized: "transaction.info.date", defaultValue: "Data"),
          value: transaction.date.formatted(date: .abbreviated, time: .shortened)
        )
        
        TransactionDetailRow(
          label: String(localized: "transaction.info.category", defaultValue: "Categoria"),
          value: transaction.category.displayName
        )
        
        TransactionDetailRow(
          label: String(localized: "transaction.info.type", defaultValue: "Tipo"),
          value: transaction.type.displayName
        )
        
        TransactionDetailRow(
          label: String(localized: "transaction.info.amount", defaultValue: "Valor"),
          value: String(format: "R$ %.2f", transaction.amount)
        )
      }
    }
  }
  
  private var accountInfoSection: some View {
    Group {
      if let account = relatedAccount {
        VStack(alignment: .leading, spacing: 12) {
          Text(String(localized: "transaction.account.title", defaultValue: "Conta Associada"))
            .font(.headline)
            .fontWeight(.semibold)
          
          HStack {
            Image(systemName: account.type.icon)
              .font(.title2)
              .foregroundColor(account.type.color)
              .frame(width: 40, height: 40)
              .background(account.type.color.opacity(0.1))
              .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
              Text(account.name)
                .font(.headline)
              
              Text(account.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(account.formattedBalance)
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(account.balance >= 0 ? .green : .red)
          }
          .padding()
          .background(Color(.systemGray6))
          .cornerRadius(12)
        }
      }
    }
  }
  
  private var categoryInfoSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "transaction.category.title", defaultValue: "Categoria"))
        .font(.headline)
        .fontWeight(.semibold)
      
      HStack {
        Image(systemName: transaction.category.icon)
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 40, height: 40)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(8)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(transaction.category.displayName)
            .font(.headline)
          
          if transaction.type == .expense {
            Text(String(localized: "transaction.category.expense.description", defaultValue: "Categoria de gasto"))
              .font(.caption)
              .foregroundColor(.secondary)
          } else {
            Text(String(localized: "transaction.category.income.description", defaultValue: "Categoria de receita"))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        Spacer()
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }
  
  private var recurringInfoSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "transaction.recurring.title", defaultValue: "Transação Recorrente"))
        .font(.headline)
        .fontWeight(.semibold)
      
      HStack {
        Image(systemName: "repeat")
          .font(.title2)
          .foregroundColor(.orange)
          .frame(width: 40, height: 40)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(8)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "transaction.recurring.label", defaultValue: "Repetição Automática"))
            .font(.headline)
          
          Text(String(localized: "transaction.recurring.description", defaultValue: "Esta transação se repete automaticamente"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }
  
  private func deleteTransaction() {
    // TODO: Implementar deleção da transação
    // await financeViewModel.deleteTransaction(transaction.id)
    dismiss()
  }
}

// MARK: - Edit Transaction View (Placeholder)
struct EditTransactionView: View {
  let transaction: Transaction
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      VStack {
        Text(String(localized: "transaction.edit.title", defaultValue: "Editar Transação"))
          .font(.title)
        
        Text(String(localized: "common.coming.soon", defaultValue: "Funcionalidade em desenvolvimento"))
          .foregroundColor(.secondary)
      }
      .navigationTitle(String(localized: "common.edit"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.save")) {
            // TODO: Implementar edição
            dismiss()
          }
        }
      }
    }
  }
}

// MARK: - Transaction Detail Row Component
struct TransactionDetailRow: View {
  let label: String
  let value: String
  
  var body: some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}

