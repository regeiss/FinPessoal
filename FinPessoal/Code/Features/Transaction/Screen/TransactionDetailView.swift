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
  
  var account: Account? {
    financeViewModel.accounts.first { $0.id == transaction.accountId }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          transactionHeaderSection
          transactionDetailsSection
          accountSection
          if transaction.isRecurring {
            recurringSection
          }
        }
        .padding()
      }
      .navigationTitle("Transação")
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
              // TODO: Implementar edição
            }
            
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
          // TODO: Implementar deleção
          dismiss()
        }
      } message: {
        Text("Tem certeza que deseja deletar esta transação? Esta ação não pode ser desfeita.")
      }
    }
  }
  
  private var transactionHeaderSection: some View {
    VStack(spacing: 16) {
      Image(systemName: transaction.category.icon)
        .font(.system(size: 60))
        .foregroundColor(transaction.type == .expense ? .red : .green)
        .frame(width: 80, height: 80)
        .background(
          (transaction.type == .expense ? Color.red : Color.green)
            .opacity(0.1)
        )
        .cornerRadius(20)
      
      Text(transaction.description)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
      
      Text(transaction.formattedAmount)
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundColor(transaction.type == .expense ? .red : .green)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var transactionDetailsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Detalhes")
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 8) {
        DetailRow(label: "Tipo", value: transaction.type.displayName)
        DetailRow(label: "Categoria", value: transaction.category.displayName)
        DetailRow(label: "Data", value: transaction.date.formatted(date: .abbreviated, time: .omitted))
        
        if transaction.isRecurring {
          DetailRow(label: "Recorrente", value: "Sim")
        }
      }
    }
  }
  
  private var accountSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Conta")
        .font(.headline)
        .fontWeight(.semibold)
      
      if let account = account {
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
      } else {
        Text("Conta não encontrada")
          .foregroundColor(.secondary)
          .italic()
      }
    }
  }
  
  private var recurringSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Informações de Recorrência")
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 8) {
        DetailRow(label: "Frequência", value: "Mensal") // TODO: Implementar enum de frequência
        DetailRow(label: "Próxima ocorrência", value: Calendar.current.date(byAdding: .month, value: 1, to: transaction.date)?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
      }
    }
  }
}
