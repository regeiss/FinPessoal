//
//  TransactionsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransactionsScreen: View {
  @StateObject private var transactionViewModel: TransactionViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var transactionToEdit: Transaction?

  init(transactionViewModel: TransactionViewModel? = nil) {
    if let existingViewModel = transactionViewModel {
      self._transactionViewModel = StateObject(wrappedValue: existingViewModel)
    } else {
      let repository = AppConfiguration.shared.createTransactionRepository()
      print("TransactionsScreen: Using repository type: \(type(of: repository))")
      print("TransactionsScreen: useMockData = \(AppConfiguration.shared.useMockData)")
      self._transactionViewModel = StateObject(wrappedValue: TransactionViewModel(repository: repository))
    }
  }
  
  private var groupedTransactions: [(String, [Transaction])] {
    let grouped = Dictionary(grouping: transactionViewModel.filteredTransactions) { transaction in
      DateFormatter.transactionGrouping.string(from: transaction.date)
    }
    
    return grouped.sorted { first, second in
      let date1 = DateFormatter.transactionGrouping.date(from: first.key) ?? Date.distantPast
      let date2 = DateFormatter.transactionGrouping.date(from: second.key) ?? Date.distantPast
      return date1 > date2
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if transactionViewModel.isLoading {
        ProgressView(String(localized: "transactions.loading"))
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .accessibilityLabel("Loading transactions, please wait")
      } else if !transactionViewModel.hasTransactions {
        emptyStateView
      } else {
        filtersSection
        transactionsList
      }
    }
    .coordinateSpace(name: "scroll")
    .navigationTitle(String(localized: "tab.transactions"))
    .blurredNavigationBar()
    .searchable(text: $transactionViewModel.searchQuery, prompt: String(localized: "transactions.search.prompt"))
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button {
          transactionViewModel.showImportPicker()
        } label: {
          Image(systemName: "square.and.arrow.down")
        }
        .accessibilityLabel("Import Transactions")
        .accessibilityHint("Import transactions from an OFX file")

        Button {
          transactionViewModel.showAddTransaction()
        } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Add Transaction")
        .accessibilityHint("Create a new transaction")
      }
    }
    .frostedSheet(isPresented: $transactionViewModel.showingAddTransaction) {
      if UIDevice.current.userInterfaceIdiom != .pad {
        AddTransactionView(transactionViewModel: transactionViewModel)
          .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
      }
    }
    .frostedSheet(isPresented: $transactionViewModel.showingTransactionDetail) {
      if UIDevice.current.userInterfaceIdiom != .pad {
        if let selectedTransaction = transactionViewModel.selectedTransaction {
          TransactionDetailView(transaction: selectedTransaction)
            .environmentObject(financeViewModel)
        }
      }
    }
    .frostedSheet(item: $transactionToEdit) { transaction in
      EditTransactionView(transaction: transaction)
        .environmentObject(financeViewModel)
    }
    .fileImporter(
      isPresented: $transactionViewModel.showingFilePicker,
      allowedContentTypes: [UTType(filenameExtension: "ofx") ?? UTType.data],
      allowsMultipleSelection: false
    ) { result in
      transactionViewModel.handleFileImport(result)
    }
    .frostedSheet(isPresented: $transactionViewModel.showingImportResult) {
      ImportResultView(result: transactionViewModel.importResult)
    }
    .refreshable {
      await transactionViewModel.fetchTransactions()
    }
    .onAppear {
      print("TransactionsScreen: onAppear called")
      print("TransactionsScreen: authViewModel.isAuthenticated = \(authViewModel.isAuthenticated)")
      print("TransactionsScreen: authViewModel.currentUser = \(String(describing: authViewModel.currentUser))")
      if authViewModel.isAuthenticated {
        print("TransactionsScreen: User authenticated, loading transactions...")
        transactionViewModel.loadTransactions()
      } else {
        print("TransactionsScreen: User not authenticated, not loading transactions")
      }
    }
    .onChange(of: authViewModel.isAuthenticated) { _, newValue in
      if newValue {
        transactionViewModel.loadTransactions()
      } else {
        transactionViewModel.transactions = []
      }
    }
    .alert("Ocorreu um erro", isPresented: .constant(transactionViewModel.errorMessage != nil)) {
      Button("OK") {
        transactionViewModel.clearError()
      }
    } message: {
      if let errorMessage = transactionViewModel.errorMessage {
        Text(errorMessage)
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "list.bullet.clipboard")
        .font(.system(size: 60))
        .foregroundStyle(Color.oldMoney.warning)
        .accessibilityHidden(true)

      Text(String(localized: "transactions.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)
        .accessibilityAddTraits(.isHeader)

      Text(String(localized: "transactions.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .padding(.horizontal)

      Button(String(localized: "transactions.add.button")) {
        transactionViewModel.showAddTransaction()
      }
      .buttonStyle(.borderedProminent)
      .accessibilityHint("Opens form to create your first transaction")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .contain)
  }
  
  private var filtersSection: some View {
    VStack(spacing: 12) {
      // Filtros de período
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(TransactionPeriod.allCases, id: \.self) { period in
            FilterChip(
              title: period.displayName,
              isSelected: transactionViewModel.selectedPeriod == period
            ) {
              transactionViewModel.selectedPeriod = period
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
              isSelected: transactionViewModel.selectedCategory == nil
            ) {
              transactionViewModel.selectedCategory = nil
            }
            
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              FilterChip(
                title: category.displayName,
                icon: category.icon,
                isSelected: transactionViewModel.selectedCategory == category
              ) {
                transactionViewModel.selectedCategory = category
              }
            }
          }
          .padding(.horizontal)
        }
      }
      
      // Resumo dos filtros
      if transactionViewModel.filteredTransactions.count != transactionViewModel.transactions.count {
        HStack {
          Text(String(localized: "transactions.filter.showing.count", defaultValue: "Mostrando \(transactionViewModel.filteredTransactions.count) de \(transactionViewModel.transactions.count) transações"))
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
          
          if transactionViewModel.isFiltered {
            Button(String(localized: "common.clear.filters")) {
              transactionViewModel.clearFilters()
            }
            .font(.caption)
            .foregroundStyle(Color.oldMoney.accent)
            .accessibilityHint("Remove all active filters")
          }
        }
        .padding(.horizontal)
      }
    }
    .padding(.vertical, 8)
    .background(Color.oldMoney.surface)
  }
  
  private var transactionsList: some View {
    List {
      ForEach(groupedTransactions, id: \.0) { date, transactions in
        Section {
          ForEach(transactions) { transaction in
            InteractiveListRow(
              onTap: {
                transactionToEdit = transaction
              },
              leadingActions: [
                .edit {
                  transactionToEdit = transaction
                }
              ],
              trailingActions: [
                .delete {
                  deleteTransaction(transaction)
                }
              ]
            ) {
              TransactionRow(transaction: transaction)
            }
          }
        } header: {
          HStack {
            Text(date)
              .font(.subheadline)
              .fontWeight(.semibold)
            
            Spacer()
            
            let dayTotal = transactions.reduce(0) { total, transaction in
              switch transaction.type {
              case .income: return total + transaction.amount
              case .expense: return total - transaction.amount
              case .transfer: return total // transfers don't affect balance
              }
            }
            
            Text(formatCurrency(dayTotal))
              .font(.caption)
              .fontWeight(.medium)
              .foregroundStyle(dayTotal >= 0 ? Color.oldMoney.income : Color.oldMoney.expense)
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

  private func deleteTransaction(_ transaction: Transaction) {
    financeViewModel.transactions.removeAll { $0.id == transaction.id }
    transactionViewModel.transactions.removeAll { $0.id == transaction.id }
  }
}

