//
//  LoanAmortizationView.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import SwiftUI

struct LoanAmortizationView: View {
  let loan: Loan
  @ObservedObject var loanService: LoanService
  @Environment(\.dismiss) private var dismiss
  
  @State private var amortizationSchedule: [LoanAmortizationEntry] = []
  @State private var selectedYear: Int?
  @State private var showingAllPayments = false
  
  private var years: [Int] {
    let calendar = Calendar.current
    let startYear = calendar.component(.year, from: loan.startDate)
    let endYear = calendar.component(.year, from: loan.endDate)
    return Array(startYear...endYear)
  }
  
  private var filteredSchedule: [LoanAmortizationEntry] {
    guard let selectedYear = selectedYear else { return amortizationSchedule }
    
    let calendar = Calendar.current
    return amortizationSchedule.filter { entry in
      calendar.component(.year, from: entry.paymentDate) == selectedYear
    }
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Summary Header
        summaryHeader
        
        // Year Filter
        yearFilterSection
        
        // Amortization Table
        amortizationTable
      }
      .navigationTitle(String(localized: "loan.amortization.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(showingAllPayments ? String(localized: "loan.amortization.filter") : String(localized: "loan.amortization.show_all")) {
            showingAllPayments.toggle()
            if showingAllPayments {
              selectedYear = nil
            } else {
              selectedYear = years.first
            }
          }
        }
      }
      .onAppear {
        loadAmortizationSchedule()
        selectedYear = years.first
      }
    }
  }
  
  private var summaryHeader: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "loan.amortization.loan_summary"))
            .font(.headline)
          Text(loan.name)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
      }
      
      HStack(spacing: 20) {
        SummaryItem(
          title: String(localized: "loan.principal_amount"),
          value: loan.formattedPrincipalAmount,
          color: .blue
        )
        
        SummaryItem(
          title: String(localized: "loan.total_interest"),
          value: loan.formattedTotalInterest,
          color: .orange
        )
        
        SummaryItem(
          title: String(localized: "loan.monthly_payment"),
          value: loan.formattedMonthlyPayment,
          color: .green
        )
      }
    }
    .padding()
    .background(Color(.systemGray6))
  }
  
  private var yearFilterSection: some View {
    if !showingAllPayments && years.count > 1 {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(years, id: \.self) { year in
            Button {
              selectedYear = year
            } label: {
              Text("\(year)")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedYear == year ? Color.blue : Color(.systemGray5))
                .foregroundColor(selectedYear == year ? .white : .primary)
                .cornerRadius(20)
            }
          }
        }
        .padding(.horizontal)
      }
      .padding(.vertical, 8) as! EmptyView
    } else {
      EmptyView()
    }
  }
  
  private var amortizationTable: some View {
    List {
      ForEach(showingAllPayments ? amortizationSchedule : filteredSchedule) { entry in
        AmortizationRowView(entry: entry)
      }
    }
    .listStyle(PlainListStyle())
  }
  
  private func loadAmortizationSchedule() {
    amortizationSchedule = loanService.getAmortizationSchedule(for: loan)
  }
}

// MARK: - Summary Item
struct SummaryItem: View {
  let title: String
  let value: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 4) {
      Text(value)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(color)
      
      Text(title)
        .font(.caption2)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Amortization Row
struct AmortizationRowView: View {
  let entry: LoanAmortizationEntry
  
  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Text(String(localized: "loan.amortization.payment_number", defaultValue: "Payment #\(entry.paymentNumber)"))
          .font(.subheadline)
          .fontWeight(.medium)
        
        Spacer()
        
        Text(formatDate(entry.paymentDate))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(String(localized: "loan.payment.total"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(entry.formattedTotalPayment)
            .font(.caption)
            .fontWeight(.medium)
        }
        
        Spacer()
        
        VStack(alignment: .center, spacing: 2) {
          Text(String(localized: "loan.principal"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(entry.formattedPrincipalPayment)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
        }
        
        Spacer()
        
        VStack(alignment: .center, spacing: 2) {
          Text(String(localized: "loan.interest"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(entry.formattedInterestPayment)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.orange)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 2) {
          Text(String(localized: "loan.balance"))
            .font(.caption2)
            .foregroundColor(.secondary)
          Text(entry.formattedRemainingBalance)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(entry.remainingBalance > 0 ? .primary : .green)
        }
      }
      
      if entry.remainingBalance <= 0 {
        HStack {
          Spacer()
          Text(String(localized: "loan.amortization.loan_paid_off"))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.green)
          Spacer()
        }
        .padding(.top, 4)
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .background(Color(.systemGray6).opacity(0.3))
    .cornerRadius(8)
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
}

#Preview {
  LoanAmortizationView(
    loan: Loan(
      name: "Financiamento Imobiliário",
      loanType: .home,
      principalAmount: 250000,
      currentBalance: 235000,
      interestRate: 8.5,
      term: 360,
      startDate: Date(),
      paymentDay: 15,
      bankName: "Banco do Brasil",
      purpose: "Compra de imóvel residencial",
      userId: "user"
    ),
    loanService: LoanService(repository: MockLoanRepository())
  )
}
