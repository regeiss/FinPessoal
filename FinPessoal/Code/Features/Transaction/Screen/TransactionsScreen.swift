//
//  TransactionsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct TransactionsScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAddTransaction = false
  @State private var selectedCategory: TransactionCategory?
  @State private var searchText = ""
  @State private var selectedPeriod: TransactionPeriod = .all
  
  private var filteredTransactions: [Transaction] {
    var transactions = financeViewModel.transactions
    
    // Filtrar por categoria
    if let category = selectedCategory {
      transactions = transactions.filter { $0.category == category }
    }
    
    // Filtrar por período
    let now = Date()
    switch selectedPeriod {
    case .today:
      transactions = transactions.filter { Calendar.current.isDate($0.date, inSameDayAs: now) }
    case .thisWeek:
      let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
      transactions = transactions.filter { $0.date >= weekAgo }
    case .thisMonth:
      let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
      transactions = transactions.filter { $0.date >= monthAgo }
    case .all:
      break
    }
    
    // Filtrar por texto de busca
    if !searchText.isEmpty {
      transactions = transactions.filter {
        $0.description.localizedCaseInsensitiveContains(searchText) ||
        $0.category.displayName.localizedCaseInsensitiveContains(searchText)
      }
    }
    
    return transactions.sorted { $0.date > $1.date }
  }
  
  private var groupedTransactions: [(String, [Transaction])] {
    let grouped = Dictionary(grouping: filteredTransactions) { transaction in
      DateFormatter.transactionGrouping.string(from: transaction.date)
    }
    
    return grouped.sorted { first, second in
      let date1 = DateFormatter.transactionGrouping.date(from: first.key) ?? Date.distantPast
      let date2 = DateFormatter.transactionGrouping.date(from: second.key) ?? Date.distantPast
      return date1 > date2
    }
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        if financeViewModel.transactions.isEmpty {
          emptyStateView
        } else {
          filtersSection
          transactionsList
        }
      }
      .navigationTitle(String(localized: "transactions.title"))
      .searchable(text: $searchText, prompt: String(localized: "transactions.search.prompt"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddTransaction = true
          } label: {
            Image(systemName: "plus.circle.fill")
          }
        }
      }
      .sheet(isPresented: $showingAddTransaction) {
        AddTransactionView()
          .environmentObject(financeViewModel)
      }
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "list.bullet.clipboard")
        .font(.system(size: 60))
        .foregroundColor(.orange)
      
      Text(String(localized: "transactions.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)
      
      Text(String(localized: "transactions.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      Button(String(localized: "transactions.add.button")) {
        showingAddTransaction = true
      }
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var filtersSection: some View {
    VStack(spacing: 12) {
      // Filtros de período
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(TransactionPeriod.allCases, id: \.self) { period in
            FilterChip(
              title: period.displayName,
              isSelected: selectedPeriod == period
            ) {
              selectedPeriod = period
            }
          }
        }
        .padding(.horizontal)
      }
      
      // Filtros de categoria
      if !TransactionCategory.allCases.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            FilterChip(
              title: String(localized: "common.all"),
              isSelected: selectedCategory == nil
            ) {
              selectedCategory = nil
            }
            
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              FilterChip(
                title: category.displayName,
                icon: category.icon,
                isSelected: selectedCategory == category
              ) {
                selectedCategory = category
              }
            }
          }
          .padding(.horizontal)
        }
      }
      
      // Resumo dos filtros
      if filteredTransactions.count != financeViewModel.transactions.count {
        Text(String(localized: "transactions.filter.showing.count", defaultValue: "Mostrando \(filteredTransactions.count) de \(financeViewModel.transactions.count) transações"))
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 8)
    .background(Color(.systemGray6))
  }
  
  private var transactionsList: some View {
    List {
      ForEach(groupedTransactions, id: \.0) { date, transactions in
        Section {
          ForEach(transactions) { transaction in
            TransactionRow(transaction: transaction)
          }
        } header: {
          HStack {
            Text(date)
              .font(.subheadline)
              .fontWeight(.semibold)
            
            Spacer()
            
            let dayTotal = transactions.reduce(0) { total, transaction in
              total + (transaction.type == .income ? transaction.amount : -transaction.amount)
            }
            
            Text(formatCurrency(dayTotal))
              .font(.caption)
              .fontWeight(.medium)
              .foregroundColor(dayTotal >= 0 ? .green : .red)
          }
        }
      }
    }
    .listStyle(.grouped)
  }
  
  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    let prefix = amount >= 0 ? "+" : ""
    return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00")
  }
}
