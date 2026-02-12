//
//  LoansScreen.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import SwiftUI

struct LoansScreen: View {
  @StateObject private var loanService: LoanService
  @State private var showingAddLoan = false
  @State private var selectedLoan: Loan?
  @State private var showingLoanDetail = false
  
  init(loanService: LoanService? = nil) {
    if let service = loanService {
      self._loanService = StateObject(wrappedValue: service)
    } else {
      let repository = AppConfiguration.shared.createLoanRepository()
      self._loanService = StateObject(wrappedValue: LoanService(repository: repository))
    }
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        if loanService.isLoading {
          ProgressView(String(localized: "loan.loading"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if loanService.loans.isEmpty {
          emptyStateView
        } else {
          loansContent
        }
      }
      .coordinateSpace(name: "scroll")
      .navigationTitle(String(localized: "loan.title"))
      .blurredNavigationBar()
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddLoan = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .frostedSheet(isPresented: $showingAddLoan) {
        AddLoanView(loanService: loanService)
      }
      .frostedSheet(isPresented: $showingLoanDetail) {
        if let selectedLoan = selectedLoan {
          LoanDetailView(loan: selectedLoan, loanService: loanService)
        }
      }
      .alert(String(localized: "common.error"), isPresented: .constant(loanService.errorMessage != nil)) {
        Button(String(localized: "common.ok")) {
          loanService.clearError()
        }
      } message: {
        if let errorMessage = loanService.errorMessage {
          Text(errorMessage)
        }
      }
      .task {
        await loanService.loadLoans()
      }
      .refreshable {
        await loanService.loadLoans()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "building.columns")
        .font(.system(size: 60))
        .foregroundStyle(Color.oldMoney.accent)
      
      Text(String(localized: "loan.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)
      
      Text(String(localized: "loan.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .padding(.horizontal)
      
      Button(String(localized: "loan.add.button")) {
        showingAddLoan = true
      }
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var loansContent: some View {
    VStack(spacing: 0) {
      // Summary Cards
      summarySection
      
      // Loans List
      List {
        Section {
          ForEach(loanService.getActiveLoans()) { loan in
            LoanRow(
              loan: loan,
              onTap: {
                selectedLoan = loan
                showingLoanDetail = true
              }
            )
          }
        } header: {
          HStack {
            Text(String(localized: "loan.active.header"))
              .font(.headline)
            Spacer()
            Text("\(loanService.getActiveLoans().count)")
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }
        } footer: {
          Text(String(localized: "loan.active.footer"))
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
        }
        
        // Due Soon Section
        if !loanService.getLoansDueSoon().isEmpty {
          Section {
            ForEach(loanService.getLoansDueSoon()) { loan in
              DueSoonLoanRow(loan: loan)
            }
          } header: {
            HStack {
              Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color.oldMoney.warning)
              Text(String(localized: "loan.due_soon.header"))
                .font(.headline)
            }
          }
        }
        
        // Inactive Loans Section
        if !loanService.getInactiveLoans().isEmpty {
          Section {
            ForEach(loanService.getInactiveLoans()) { loan in
              LoanRow(
                loan: loan,
                onTap: {
                  selectedLoan = loan
                  showingLoanDetail = true
                }
              )
            }
          } header: {
            Text(String(localized: "loan.inactive.header"))
              .font(.headline)
          }
        }
      }
      .listStyle(InsetGroupedListStyle())
    }
  }
  
  private var summarySection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 16) {
        LoanSummaryCard(
          title: String(localized: "loan.summary.total_amount"),
          value: loanService.formatCurrency(loanService.getTotalLoanAmount()),
          icon: "banknote",
          color: Color.oldMoney.accent
        )

        LoanSummaryCard(
          title: String(localized: "loan.summary.current_balance"),
          value: loanService.formatCurrency(loanService.getTotalCurrentBalance()),
          icon: "scale.3d",
          color: Color.oldMoney.warning
        )

        LoanSummaryCard(
          title: String(localized: "loan.summary.monthly_payments"),
          value: loanService.formatCurrency(loanService.getTotalMonthlyPayments()),
          icon: "calendar",
          color: Color.oldMoney.expense
        )

        LoanSummaryCard(
          title: String(localized: "loan.summary.total_interest"),
          value: loanService.formatCurrency(loanService.getTotalInterestPaid()),
          icon: "percent",
          color: Color.oldMoney.income
        )
      }
      .padding(.horizontal)
    }
    .padding(.bottom)
  }
}

// MARK: - Loan Summary Card
struct LoanSummaryCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundStyle(color)
        Spacer()
      }
      
      Text(value)
        .font(.title2)
        .fontWeight(.bold)
      
      Text(title)
        .font(.caption)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .lineLimit(2)
    }
    .padding()
    .background(Color.oldMoney.surface)
    .cornerRadius(12)
    .frame(width: 150)
  }
}

// MARK: - Loan Row
struct LoanRow: View {
  let loan: Loan
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        // Loan Type Icon
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(loan.loanType.color).opacity(0.2))
            .frame(width: 50, height: 32)
          
          Image(systemName: loan.loanType.icon)
            .font(.system(size: 18))
            .foregroundColor(Color(loan.loanType.color))
        }
        
        // Loan Info
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(loan.name)
              .font(.headline)
            
            Spacer()
            
            Text(loan.bankName)
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }
          
          Text(loan.loanType.displayName)
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
          
          // Progress Bar
          VStack(alignment: .leading, spacing: 2) {
            HStack {
              Text(String(localized: "loan.progress"))
                .font(.caption2)
                .foregroundStyle(Color.oldMoney.textSecondary)
              
              Spacer()
              
              Text("\(Int(loan.progressPercentage))%")
                .font(.caption2)
                .foregroundColor(Color(loan.statusColor))
            }
            
            ProgressView(value: loan.progressPercentage, total: 100)
              .tint(Color(loan.statusColor))
              .scaleEffect(y: 0.5)
          }
        }
        
        // Balance Info
        VStack(alignment: .trailing, spacing: 4) {
          Text(loan.formattedCurrentBalance)
            .font(.subheadline)
            .fontWeight(.semibold)
          
          Text(loan.statusText)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(loan.statusColor).opacity(0.2))
            .foregroundColor(Color(loan.statusColor))
            .cornerRadius(4)
        }
      }
    }
    .buttonStyle(PlainButtonStyle())
    .padding(.vertical, 4)
  }
}

// MARK: - Due Soon Loan Row
struct DueSoonLoanRow: View {
  let loan: Loan
  
  var body: some View {
    HStack {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(Color.oldMoney.warning)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(loan.name)
          .font(.headline)
        
        Text(String(localized: "loan.next_payment_format", defaultValue: "Next payment: \(formatDate(loan.nextPaymentDate))"))
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 2) {
        Text(loan.formattedMonthlyPayment)
          .font(.subheadline)
          .fontWeight(.semibold)
        
        Text(String(localized: "loan.monthly_payment"))
          .font(.caption2)
          .foregroundStyle(Color.oldMoney.textSecondary)
      }
    }
    .padding(.vertical, 4)
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
}

#Preview {
  LoansScreen()
}