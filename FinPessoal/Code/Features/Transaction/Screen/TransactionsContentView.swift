//
//  TransactionsContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct TransactionsContentView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var selectedTransaction: Transaction?
  @State private var showingAddTransaction = false
  @State private var searchText = ""
  @State private var selectedFilter: TransactionFilter = .all
  @State private var selectedSort: TransactionSort = .dateDesc
  
  var filteredTransactions: [Transaction] {
    var transactions = financeViewModel.transactions
    
    // Filtrar por texto de busca
    if !searchText.isEmpty {
      transactions = transactions.filter {
        $0.description.localizedCaseInsensitiveContains(searchText) ||
        $0.category.displayName.localizedCaseInsensitiveContains(searchText)
      }
    }
    
    // Filtrar por tipo
    switch selectedFilter {
    case .all:
      break
    case .income:
      transactions = transactions.filter { $0.type == .income }
    case .expense:
      transactions = transactions.filter { $0.type == .expense }
    case .thisMonth:
      let calendar = Calendar.current
      transactions = transactions.filter {
        calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
      }
    }
    
    // Ordenar
    switch selectedSort {
    case .dateDesc:
      transactions.sort { $0.date > $1.date }
    case .dateAsc:
      transactions.sort { $0.date < $1.date }
    case .amountDesc:
      transactions.sort { $0.amount > $1.amount }
    case .amountAsc:
      transactions.sort { $0.amount < $1.amount }
    }
    
    return transactions
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Filtros e ordenação
        filterSection
        
        // Lista de transações
        if filteredTransactions.isEmpty {
          emptyStateView
        } else {
          transactionsList
        }
      }
      .navigationTitle("Transações")
      .searchable(text: $searchText, prompt: "Buscar transações...")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            showingAddTransaction = true
          }
        }
      }
      .sheet(isPresented: $showingAddTransaction) {
        AddTransactionView()
          .environmentObject(financeViewModel)
      }
      .sheet(item: $selectedTransaction) { transaction in
        TransactionDetailView(transaction: transaction)
          .environmentObject(financeViewModel)
      }
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }
  
  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        // Filtros
        Menu {
          Button("Todas") { selectedFilter = .all }
          Button("Receitas") { selectedFilter = .income }
          Button("Despesas") { selectedFilter = .expense }
          Button("Este Mês") { selectedFilter = .thisMonth }
        } label: {
          HStack {
            Text(selectedFilter.title)
            Image(systemName: "chevron.down")
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color(.systemGray6))
          .cornerRadius(8)
        }
        
        // Ordenação
        Menu {
          Button("Mais Recentes") { selectedSort = .dateDesc }
          Button("Mais Antigas") { selectedSort = .dateAsc }
          Button("Maior Valor") { selectedSort = .amountDesc }
          Button("Menor Valor") { selectedSort = .amountAsc }
        } label: {
          HStack {
            Image(systemName: "arrow.up.arrow.down")
            Text(selectedSort.title)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color(.systemGray6))
          .cornerRadius(8)
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical, 8)
  }
  
  private var transactionsList: some View {
    List {
      ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
        Section(header: Text(date, style: .date)) {
          ForEach(groupedTransactions[date] ?? []) { transaction in
            Button {
              selectedTransaction = transaction
            } label: {
              TransactionRow(transaction: transaction)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
    .listStyle(.insetGrouped)
  }
  
  private var groupedTransactions: [Date: [Transaction]] {
    Dictionary(grouping: filteredTransactions) { transaction in
      Calendar.current.startOfDay(for: transaction.date)
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "list.bullet")
        .font(.system(size: 60))
        .foregroundColor(.secondary)
      
      Text("Nenhuma transação encontrada")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Adicione sua primeira transação ou ajuste os filtros de busca")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      Button("Adicionar Transação") {
        showingAddTransaction = true
      }
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

enum TransactionFilter: CaseIterable {
  case all, income, expense, thisMonth
  
  var title: String {
    switch self {
    case .all: return "Todas"
    case .income: return "Receitas"
    case .expense: return "Despesas"
    case .thisMonth: return "Este Mês"
    }
  }
}

enum TransactionSort: CaseIterable {
  case dateDesc, dateAsc, amountDesc, amountAsc
  
  var title: String {
    switch self {
    case .dateDesc: return "Mais Recentes"
    case .dateAsc: return "Mais Antigas"
    case .amountDesc: return "Maior Valor"
    case .amountAsc: return "Menor Valor"
    }
  }
}

#Preview {
  TransactionsContentView()
    .environmentObject(FinanceViewModel())
}
