//
//  BillsScreen.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import SwiftUI

struct BillsScreen: View {
  @StateObject private var viewModel: BillsViewModel
  @State private var showingFilterSheet = false
  @State private var showingSettings = false

  init(repository: BillRepositoryProtocol) {
    _viewModel = StateObject(wrappedValue: BillsViewModel(repository: repository))
  }

  var body: some View {
    ZStack {
      if viewModel.isLoading && viewModel.bills.isEmpty {
        ProgressView()
          .scaleEffect(1.5)
          .accessibilityLabel("Loading Bills")
          .accessibilityHint("Please wait while bills are being loaded")
      } else if !viewModel.hasBills {
        emptyStateView
      } else {
        contentView
      }
    }
    .coordinateSpace(name: "scroll")
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.oldMoney.background)
    .navigationTitle(String(localized: "bills.title"))
    .blurredNavigationBar()
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        if UIDevice.current.userInterfaceIdiom != .pad {
          Button {
            showingSettings = true
          } label: {
            Image(systemName: "gearshape")
          }
          .accessibilityLabel(String(localized: "Settings"))
          .accessibilityHint(String(localized: "Open application settings"))
        }

        Button(action: {
          viewModel.showAddBill()
        }) {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Add Bill")
        .accessibilityHint("Opens form to add a new bill")
      }

      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          showingFilterSheet = true
        }) {
          HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal.decrease.circle")
            if viewModel.isFiltered {
              Circle()
                .fill(Color.oldMoney.accent)
                .frame(width: 8, height: 8)
            }
          }
        }
        .accessibilityLabel("Filter Bills")
        .accessibilityHint("Opens filter options for bills")
        .accessibilityValue(viewModel.isFiltered ? "Filters active" : "No filters active")
      }
    }
    .frostedSheet(isPresented: $viewModel.showingAddBill) {
      AddBillScreen(viewModel: viewModel)
    }
    .frostedSheet(isPresented: $viewModel.showingBillDetail) {
      if let bill = viewModel.selectedBill {
        BillDetailView(bill: bill, viewModel: viewModel)
      }
    }
    .frostedSheet(isPresented: $showingFilterSheet) {
      filterSheet
    }
    .sheet(isPresented: $showingSettings) {
      SettingsScreen()
    }
    .refreshable {
      await viewModel.fetchBills()
    }
    .onAppear {
      if viewModel.bills.isEmpty {
        Task {
          await viewModel.fetchBills()
        }
      }
    }
  }

  // MARK: - Content View

  private var contentView: some View {
    VStack(spacing: 0) {
      // Statistics cards
      statisticsView
        .padding(.horizontal)
        .padding(.top, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Bills Statistics")

      // Search bar
      SearchBar(text: $viewModel.searchQuery, placeholder: String(localized: "bills.search.placeholder"))
        .padding(.horizontal)
        .padding(.vertical, 8)

      // Bills list
      if viewModel.hasFilteredBills {
        billsList
      } else {
        noResultsView
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  // MARK: - Statistics View

  private var statisticsView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        StatCard(
          title: String(localized: "bills.stat.unpaid"),
          value: viewModel.formattedTotalUnpaid,
          icon: "exclamationmark.circle",
          color: .orange
        )

        if viewModel.overdueCount > 0 {
          StatCard(
            title: String(localized: "bills.stat.overdue"),
            value: "\(viewModel.overdueCount)",
            icon: "exclamationmark.triangle",
            color: .red
          )
        }

        if viewModel.billsDueSoonCount > 0 {
          StatCard(
            title: String(localized: "bills.stat.due.soon"),
            value: "\(viewModel.billsDueSoonCount)",
            icon: "clock",
            color: .blue
          )
        }
      }
      .padding(.vertical, 4)
    }
  }

  // MARK: - Bills List

  private var groupedBills: [(String, [Bill], Double)] {
    let unpaidBills = viewModel.filteredBills.filter { !$0.isPaid }

    var groups: [(String, [Bill], Double)] = []

    // Overdue bills
    let overdueBills = unpaidBills.filter { $0.isOverdue }
    if !overdueBills.isEmpty {
      let total = overdueBills.reduce(0) { $0 + $1.amount }
      groups.append((String(localized: "bills.section.overdue", defaultValue: "Atrasadas"), overdueBills, total))
    }

    // Due today
    let todayBills = unpaidBills.filter { $0.daysUntilDue == 0 && !$0.isOverdue }
    if !todayBills.isEmpty {
      let total = todayBills.reduce(0) { $0 + $1.amount }
      groups.append((String(localized: "bills.section.today", defaultValue: "Vencendo Hoje"), todayBills, total))
    }

    // Upcoming bills
    let upcomingBills = unpaidBills.filter { $0.daysUntilDue > 0 }
    if !upcomingBills.isEmpty {
      let total = upcomingBills.reduce(0) { $0 + $1.amount }
      groups.append((String(localized: "bills.section.upcoming", defaultValue: "Próximas"), upcomingBills, total))
    }

    // Paid bills (optional, can be shown at the end)
    let paidBills = viewModel.filteredBills.filter { $0.isPaid }
    if !paidBills.isEmpty {
      let total = paidBills.reduce(0) { $0 + $1.amount }
      groups.append((String(localized: "bills.section.paid", defaultValue: "Pagas"), paidBills, total))
    }

    return groups
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }

  private var billsList: some View {
    List {
      ForEach(groupedBills, id: \.0) { section, bills, total in
        Section {
          ForEach(bills) { bill in
            InteractiveListRow(
              onTap: {
                viewModel.selectBill(bill)
              },
              leadingActions: bill.isPaid ? [] : [
                .markPaid {
                  await viewModel.markBillAsPaid(bill.id)
                }
              ],
              trailingActions: [
                .delete {
                  await viewModel.deleteBill(bill.id)
                }
              ]
            ) {
              BillRow(bill: bill, onMarkAsPaid: nil)
            }
            .listRowSeparator(.hidden)
          }
        } header: {
          HStack {
            Text(section)
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundStyle(Color.oldMoney.text)

            Spacer()

            Text(formatCurrency(total))
              .font(.title3)
              .fontWeight(.bold)
              .foregroundStyle(Color.oldMoney.accent)
          }
          .textCase(nil)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
        }
      }
    }
    .listStyle(.plain)
    .accessibilityLabel("Bills List")
  }

  // MARK: - Empty State

  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 60))
        .foregroundStyle(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      Text(String(localized: "bills.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "bills.empty.message"))
        .font(.body)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Button(action: {
        viewModel.showAddBill()
      }) {
        Label(String(localized: "bills.add.first"), systemImage: "plus.circle.fill")
          .font(.headline)
          .foregroundStyle(Color.oldMoney.background)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .background(Color.oldMoney.accent)
          .cornerRadius(10)
      }
      .padding(.top, 8)
      .accessibilityLabel("Add First Bill")
      .accessibilityHint("Opens form to create your first bill")
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("No Bills Yet")
  }

  // MARK: - No Results View

  private var noResultsView: some View {
    VStack(spacing: 16) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 50))
        .foregroundStyle(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      Text(String(localized: "bills.no.results"))
        .font(.title3)
        .fontWeight(.semibold)

      Button(String(localized: "bills.clear.filters")) {
        viewModel.clearFilters()
      }
      .font(.subheadline)
      .foregroundStyle(Color.oldMoney.accent)
      .accessibilityLabel("Clear Filters")
      .accessibilityHint("Removes all applied filters to show all bills")
    }
    .padding(.top, 60)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("No Results Found")
  }

  // MARK: - Filter Sheet

  private var filterSheet: some View {
    NavigationView {
      Form {
        Section(header: Text(String(localized: "bills.filter.status"))) {
          Picker(String(localized: "bills.filter"), selection: $viewModel.selectedFilter) {
            ForEach(BillFilter.allCases, id: \.self) { filter in
              Text(filter.displayName).tag(filter)
            }
          }
          .pickerStyle(.inline)
        }

        Section(header: Text(String(localized: "bills.filter.category"))) {
          Picker(String(localized: "common.category"), selection: $viewModel.selectedCategory) {
            Text(String(localized: "common.all")).tag(nil as TransactionCategory?)

            ForEach(TransactionCategory.allCases, id: \.self) { category in
              Text(category.displayName).tag(category as TransactionCategory?)
            }
          }
          .pickerStyle(.inline)
        }
      }
      .navigationTitle(String(localized: "bills.filters"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            showingFilterSheet = false
          }
          .accessibilityLabel("Done")
          .accessibilityHint("Closes filter options and applies selected filters")
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "bills.clear.filters")) {
            viewModel.clearFilters()
          }
          .disabled(!viewModel.isFiltered)
          .accessibilityLabel("Clear Filters")
          .accessibilityHint("Removes all applied filters")
          .accessibilityAddTraits(viewModel.isFiltered ? [] : .isButton)
        }
      }
    }
  }
}

// MARK: - Search Bar Component

struct SearchBar: View {
  @Binding var text: String
  let placeholder: String

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      TextField(placeholder, text: $text)
        .textFieldStyle(.plain)
        .accessibilityLabel("Search Bills")
        .accessibilityHint("Enter bill name to search")
        .accessibilityValue(text.isEmpty ? "Empty" : text)

      if !text.isEmpty {
        Button(action: {
          text = ""
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(Color.oldMoney.textSecondary)
        }
        .accessibilityLabel("Clear Search")
        .accessibilityHint("Clears the search text")
      }
    }
    .padding(8)
    .background(Color.oldMoney.surface)
    .cornerRadius(10)
  }
}

#Preview {
  BillsScreen(repository: MockBillRepository())
}
