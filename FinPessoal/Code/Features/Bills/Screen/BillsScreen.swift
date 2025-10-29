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

  init(repository: BillRepositoryProtocol) {
    _viewModel = StateObject(wrappedValue: BillsViewModel(repository: repository))
  }

  var body: some View {
    ZStack {
      if viewModel.isLoading && viewModel.bills.isEmpty {
        ProgressView()
          .scaleEffect(1.5)
      } else if !viewModel.hasBills {
        emptyStateView
      } else {
        contentView
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationTitle(String(localized: "bills.title"))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          viewModel.showAddBill()
        }) {
          Image(systemName: "plus")
        }
      }

      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          showingFilterSheet = true
        }) {
          HStack(spacing: 4) {
            Image(systemName: "line.3.horizontal.decrease.circle")
            if viewModel.isFiltered {
              Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            }
          }
        }
      }
    }
    .sheet(isPresented: $viewModel.showingAddBill) {
      AddBillScreen(viewModel: viewModel)
    }
    .sheet(isPresented: $viewModel.showingBillDetail) {
      if let bill = viewModel.selectedBill {
        BillDetailView(bill: bill, viewModel: viewModel)
      }
    }
    .sheet(isPresented: $showingFilterSheet) {
      filterSheet
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

  private var billsList: some View {
    List {
      ForEach(viewModel.filteredBills) { bill in
        BillRow(bill: bill) {
          Task {
            await viewModel.markBillAsPaid(bill.id)
          }
        }
        .onTapGesture {
          viewModel.selectBill(bill)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button(role: .destructive) {
            Task {
              await viewModel.deleteBill(bill.id)
            }
          } label: {
            Label(String(localized: "common.delete"), systemImage: "trash")
          }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
          if !bill.isPaid {
            Button {
              Task {
                await viewModel.markBillAsPaid(bill.id)
              }
            } label: {
              Label(String(localized: "bill.mark.paid"), systemImage: "checkmark.circle")
            }
            .tint(.green)
          }
        }
      }
    }
    .listStyle(.plain)
  }

  // MARK: - Empty State

  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 60))
        .foregroundColor(.gray)

      Text(String(localized: "bills.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "bills.empty.message"))
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Button(action: {
        viewModel.showAddBill()
      }) {
        Label(String(localized: "bills.add.first"), systemImage: "plus.circle.fill")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .background(Color.blue)
          .cornerRadius(10)
      }
      .padding(.top, 8)
    }
  }

  // MARK: - No Results View

  private var noResultsView: some View {
    VStack(spacing: 16) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 50))
        .foregroundColor(.gray)

      Text(String(localized: "bills.no.results"))
        .font(.title3)
        .fontWeight(.semibold)

      Button(String(localized: "bills.clear.filters")) {
        viewModel.clearFilters()
      }
      .font(.subheadline)
      .foregroundColor(.blue)
    }
    .padding(.top, 60)
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
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "bills.clear.filters")) {
            viewModel.clearFilters()
          }
          .disabled(!viewModel.isFiltered)
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
        .foregroundColor(.secondary)

      TextField(placeholder, text: $text)
        .textFieldStyle(.plain)

      if !text.isEmpty {
        Button(action: {
          text = ""
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(8)
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(10)
  }
}

#Preview {
  BillsScreen(repository: MockBillRepository())
}
