//
//  TransactionsContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct TransactionsContentView: View {
  @StateObject private var transactionViewModel: TransactionViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var selectedSort: TransactionSort = .dateDesc
  
  init() {
    let repository = AppConfiguration.shared.createTransactionRepository()
    self._transactionViewModel = StateObject(wrappedValue: TransactionViewModel(repository: repository))
  }
  
  var sortedTransactions: [Transaction] {
    var transactions = transactionViewModel.filteredTransactions
    
    // Apply sorting
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
        if transactionViewModel.isLoading {
          ProgressView(String(localized: "transactions.loading"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          // Filtros e ordenação
          filterSection
          
          // Lista de transações
          if !transactionViewModel.hasFilteredTransactions {
            emptyStateView
          } else {
            transactionsList
          }
        }
      }
      .navigationTitle(String(localized: "transactions.title"))
      .searchable(text: $transactionViewModel.searchQuery, prompt: String(localized: "transactions.search.prompt"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "transactions.add.button")) {
            transactionViewModel.showAddTransaction()
          }
        }
      }
      .sheet(isPresented: $transactionViewModel.showingAddTransaction) {
        AddTransactionView(transactionViewModel: transactionViewModel)
      }
      .sheet(isPresented: $transactionViewModel.showingTransactionDetail) {
        if let selectedTransaction = transactionViewModel.selectedTransaction {
          TransactionDetailView(transaction: selectedTransaction)
        }
      }
      .refreshable {
        await transactionViewModel.fetchTransactions()
      }
      .onAppear {
        if authViewModel.isAuthenticated {
          transactionViewModel.loadTransactions()
        }
      }
      .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
        if newValue {
          transactionViewModel.loadTransactions()
        } else {
          transactionViewModel.transactions = []
        }
      }
      .alert("Error", isPresented: .constant(transactionViewModel.errorMessage != nil)) {
        Button("OK") {
          transactionViewModel.clearError()
        }
      } message: {
        if let errorMessage = transactionViewModel.errorMessage {
          Text(errorMessage)
        }
      }
    }
  }
  
  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        // Period Filter
        Menu {
          ForEach(TransactionPeriod.allCases, id: \.self) { period in
            Button(period.displayName) { 
              transactionViewModel.selectedPeriod = period 
            }
          }
        } label: {
          HStack {
            Text(transactionViewModel.selectedPeriod.displayName)
            Image(systemName: "chevron.down")
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color(.systemGray6))
          .cornerRadius(8)
        }
        
        // Type Filter  
        Menu {
          Button(String(localized: "common.all")) { transactionViewModel.selectedType = nil }
          Button(String(localized: "transaction.type.income")) { transactionViewModel.selectedType = .income }
          Button(String(localized: "transaction.type.expense")) { transactionViewModel.selectedType = .expense }
        } label: {
          HStack {
            Text(transactionViewModel.selectedType?.displayName ?? String(localized: "common.all"))
            Image(systemName: "chevron.down")
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color(.systemGray6))
          .cornerRadius(8)
        }
        
        // Ordenação
        Menu {
          Button(String(localized: "transactions.sort.newest", defaultValue: "Mais Recentes")) { selectedSort = .dateDesc }
          Button(String(localized: "transactions.sort.oldest", defaultValue: "Mais Antigas")) { selectedSort = .dateAsc }
          Button(String(localized: "transactions.sort.highest", defaultValue: "Maior Valor")) { selectedSort = .amountDesc }
          Button(String(localized: "transactions.sort.lowest", defaultValue: "Menor Valor")) { selectedSort = .amountAsc }
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
              transactionViewModel.selectTransaction(transaction)
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
    Dictionary(grouping: sortedTransactions) { transaction in
      Calendar.current.startOfDay(for: transaction.date)
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "list.bullet")
        .font(.system(size: 60))
        .foregroundColor(.secondary)
      
      Text(String(localized: "transactions.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)
      
      Text(String(localized: "transactions.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      Button(String(localized: "transactions.add.button")) {
        transactionViewModel.showAddTransaction()
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
    case .all: return String(localized: "transactions.filter.all")
    case .income: return String(localized: "transaction.type.income")
    case .expense: return String(localized: "transaction.type.expense")
    case .thisMonth: return String(localized: "transactions.filter.this.month", defaultValue: "Este Mês")
    }
  }
}

enum TransactionSort: CaseIterable {
  case dateDesc, dateAsc, amountDesc, amountAsc
  
  var title: String {
    switch self {
    case .dateDesc: return String(localized: "transactions.sort.newest", defaultValue: "Mais Recentes")
    case .dateAsc: return String(localized: "transactions.sort.oldest", defaultValue: "Mais Antigas")
    case .amountDesc: return String(localized: "transactions.sort.highest", defaultValue: "Maior Valor")
    case .amountAsc: return String(localized: "transactions.sort.lowest", defaultValue: "Menor Valor")
    }
  }
}

#Preview {
  TransactionsContentView()
    .environmentObject(AuthViewModel(authRepository: MockAuthRepository()))
}
