//
//  LoanDetailView.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import SwiftUI

struct LoanDetailView: View {
  let loan: Loan
  @ObservedObject var loanService: LoanService
  @Environment(\.dismiss) private var dismiss
  
  @State private var payments: [LoanPayment] = []
  @State private var showingMakePayment = false
  @State private var showingAmortization = false
  @State private var isLoadingPayments = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          // Loan Visual Card
          loanVisualCard
          
          // Quick Stats
          quickStatsSection
          
          // Action Buttons
          actionButtonsSection
          
          // Recent Payments
          recentPaymentsSection
          
          // Loan Information
          loanInformationSection
        }
        .padding()
      }
      .navigationTitle(loan.name)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button {
              showingMakePayment = true
            } label: {
              Label(String(localized: "loan.make_payment"), systemImage: "creditcard")
            }
            
            Button {
              showingAmortization = true
            } label: {
              Label(String(localized: "loan.view_amortization"), systemImage: "list.number")
            }
            
            Divider()
            
            Button(role: .destructive) {
              // TODO: Add edit/deactivate functionality
            } label: {
              Label(String(localized: "loan.deactivate"), systemImage: "pause")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .sheet(isPresented: $showingMakePayment) {
        MakeLoanPaymentView(loan: loan, loanService: loanService)
      }
      .sheet(isPresented: $showingAmortization) {
        LoanAmortizationView(loan: loan, loanService: loanService)
      }
      .task {
        await loadPayments()
      }
    }
  }
  
  private var loanVisualCard: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(
          LinearGradient(
            colors: [Color(loan.loanType.color), Color(loan.loanType.color).opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(height: 200)
      
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text(loan.loanType.displayName)
            .font(.headline)
            .foregroundColor(.white)
          
          Spacer()
          
          Image(systemName: loan.loanType.icon)
            .font(.title)
            .foregroundColor(.white)
        }
        
        Spacer()
        
        Text(loan.bankName)
          .font(.title2)
          .fontWeight(.medium)
          .foregroundColor(.white)
        
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "loan.current_balance"))
              .font(.caption2)
              .foregroundColor(.white.opacity(0.7))
            
            Text(loan.formattedCurrentBalance)
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundColor(.white)
          }
          
          Spacer()
          
          VStack(alignment: .trailing, spacing: 2) {
            Text(String(localized: "loan.next_payment"))
              .font(.caption2)
              .foregroundColor(.white.opacity(0.7))
            
            Text(formatDate(loan.nextPaymentDate))
              .font(.caption)
              .foregroundColor(.white)
          }
        }
      }
      .padding(20)
    }
    .shadow(radius: 10)
  }
  
  private var quickStatsSection: some View {
    VStack(spacing: 16) {
      // Progress Section
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(String(localized: "loan.loan_progress"))
            .font(.headline)
          
          Spacer()
          
          Text("\(Int(loan.progressPercentage))%")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Color(loan.statusColor))
        }
        
        ProgressView(value: loan.progressPercentage, total: 100)
          .tint(Color(loan.statusColor))
        
        HStack {
          Text(String(localized: "loan.principal_paid"))
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Text(formatCurrency(loan.principalAmount - loan.currentBalance))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
      
      // Stats Grid
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        LoanStatCard(
          title: String(localized: "loan.monthly_payment"),
          value: loan.formattedMonthlyPayment,
          icon: "calendar",
          color: .blue
        )
        
        LoanStatCard(
          title: String(localized: "loan.remaining_payments"),
          value: "\(loan.remainingPayments)",
          icon: "number",
          color: .orange
        )
        
        LoanStatCard(
          title: String(localized: "loan.principal_amount"),
          value: loan.formattedPrincipalAmount,
          icon: "banknote",
          color: .green
        )
        
        LoanStatCard(
          title: String(localized: "loan.interest_rate"),
          value: "\(loan.interestRate, default: "%.1f")%",
          icon: "percent",
          color: .red
        )
      }
    }
  }
  
  private var actionButtonsSection: some View {
    HStack(spacing: 16) {
      Button {
        showingMakePayment = true
      } label: {
        HStack {
          Image(systemName: "creditcard")
          Text(String(localized: "loan.make_payment"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      
      Button {
        showingAmortization = true
      } label: {
        HStack {
          Image(systemName: "list.number")
          Text(String(localized: "loan.amortization"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
    }
  }
  
  private var recentPaymentsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text(String(localized: "loan.recent_payments"))
          .font(.headline)
        
        Spacer()
        
        if isLoadingPayments {
          ProgressView()
            .scaleEffect(0.8)
        }
      }
      
      if payments.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "list.bullet.clipboard")
            .font(.title2)
            .foregroundColor(.secondary)
          
          Text(String(localized: "loan.no_payments"))
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
      } else {
        LazyVStack(spacing: 8) {
          ForEach(payments.prefix(5)) { payment in
            PaymentRowView(payment: payment)
          }
        }
        
        if payments.count > 5 {
          Button(String(localized: "loan.view_all_payments")) {
            // TODO: Navigate to full payments list
          }
          .foregroundColor(.blue)
          .padding(.top, 8)
        }
      }
    }
  }
  
  private var loanInformationSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "loan.information"))
        .font(.headline)
      
      VStack(spacing: 12) {
        InfoRow(title: String(localized: "loan.purpose"), value: loan.purpose)
        InfoRow(title: String(localized: "loan.start_date"), value: formatDate(loan.startDate))
        InfoRow(title: String(localized: "loan.end_date"), value: formatDate(loan.endDate))
        InfoRow(title: String(localized: "loan.payment_day"), value: String(loan.paymentDay))
        InfoRow(title: String(localized: "loan.term"), value: "\(loan.term) " + String(localized: "loan.months"))
        InfoRow(title: String(localized: "loan.total_interest"), value: loan.formattedTotalInterest)
        InfoRow(title: String(localized: "loan.status"), value: loan.statusText)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }
  
  private func loadPayments() async {
    isLoadingPayments = true
    payments = await loanService.getPayments(for: loan.id)
    isLoadingPayments = false
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
  
  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

// MARK: - Loan Stat Card
struct LoanStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
        Spacer()
      }
      
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
        .lineLimit(2)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

// MARK: - Payment Row
struct PaymentRowView: View {
  let payment: LoanPayment
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(payment.paymentMethod)
          .font(.subheadline)
          .fontWeight(.medium)
        
        HStack {
          Text(String(localized: "loan.principal"))
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text(payment.formattedPrincipalAmount)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text("•")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text(String(localized: "loan.interest"))
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text(payment.formattedInterestAmount)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(payment.formattedAmount)
          .font(.subheadline)
          .fontWeight(.semibold)
        
        Text(formatDate(payment.paymentDate))
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .background(Color(.systemGray6).opacity(0.5))
    .cornerRadius(8)
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }
}

// MARK: - Info Row
struct InfoRow: View {
  let title: String
  let value: String
  
  var body: some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Spacer()
      
      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
    }
  }
}

#Preview {
  LoanDetailView(
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
