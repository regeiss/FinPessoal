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
      .navigationTitle("Detalhes da Transação")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Fechar") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button("Editar") {
              showingEditView = true
            }
            
            Divider()
            
            Button("Deletar", role: .destructive) {
              showingDeleteAlert = true
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .alert("Deletar Transação", isPresented: $showingDeleteAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Deletar", role: .destructive) {
          deleteTransaction()
        }
      } message: {
        Text("Tem certeza que deseja deletar esta transação? Esta ação não pode ser desfeita.")
      }
      .sheet(isPresented: $showingEditView) {
        EditTransactionView(transaction: transaction)
          .environmentObject(financeViewModel)
      }
    }
  }
  
  private var transactionHeaderSection: some View {
    VStack(spacing: 16) {
      Image(systemName: transaction.category.icon)
        .font(.system(size: 60))
        .foregroundColor(transaction.type == .expense ? .red : .green)
        .frame(width: 100, height: 100)
        .background((transaction.type == .expense ? Color.red : Color.green).opacity(0.1))
        .cornerRadius(20)
      
      Text(transaction.description)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
      
      Text(transaction.formattedAmount)
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(transaction.type == .expense ? .red : .green)
      
      Text(transaction.type.displayName)
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background((transaction.type == .expense ? Color.red : Color.green).opacity(0.2))
        .foregroundColor(transaction.type == .expense ? .red : .green)
        .cornerRadius(8)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var transactionDetailsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Informações da Transação")
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 8) {
        DetailRow(
          label: "Data",
          value: transaction.date.formatted(date: .abbreviated, time: .shortened)
        )
        
        DetailRow(
          label: "Categoria",
          value: transaction.category.displayName
        )
        
        DetailRow(
          label: "Tipo",
          value: transaction.type.displayName
        )
        
        DetailRow(
          label: "Valor",
          value: String(format: "R$ %.2f", transaction.amount)
        )
      }
    }
  }
  
  private var accountInfoSection: some View {
    Group {
      if let account = relatedAccount {
        VStack(alignment: .leading, spacing: 12) {
          Text("Conta Associada")
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
      Text("Categoria")
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
          
          Text("Categoria de " + (transaction.type == .expense ? "gasto" : "receita"))
            .font(.caption)
            .foregroundColor(.secondary)
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
      Text("Transação Recorrente")
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
          Text("Repetição Automática")
            .font(.headline)
          
          Text("Esta transação se repete automaticamente")
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
        Text("Editar Transação")
          .font(.title)
        
        Text("Funcionalidade em desenvolvimento")
          .foregroundColor(.secondary)
      }
      .navigationTitle("Editar")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Salvar") {
            // TODO: Implementar edição
            dismiss()
          }
        }
      }
    }
  }
}
