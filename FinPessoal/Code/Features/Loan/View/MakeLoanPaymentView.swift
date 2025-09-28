//
//  MakeLoanPaymentView.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import SwiftUI

struct MakeLoanPaymentView: View {
  let loan: Loan
  @ObservedObject var loanService: LoanService
  @Environment(\.dismiss) private var dismiss
  
  @State private var paymentType: PaymentType = .scheduled
  @State private var customAmount = ""
  @State private var paymentDate = Date()
  @State private var paymentMethod = ""
  @State private var notes = ""
  
  @State private var showingValidationAlert = false
  @State private var validationMessage = ""
  @State private var isSubmitting = false
  
  private let paymentMethods = [
    "Débito Automático",
    "Transferência Bancária",
    "PIX",
    "Boleto Bancário",
    "Cartão de Débito",
    "Dinheiro",
    "Outros"
  ]
  
  enum PaymentType: String, CaseIterable {
    case scheduled = "scheduled"
    case extraPrincipal = "extra_principal"
    case custom = "custom"
    
    var displayName: String {
      switch self {
      case .scheduled:
        return String(localized: "loan.payment.scheduled")
      case .extraPrincipal:
        return String(localized: "loan.payment.extra_principal")
      case .custom:
        return String(localized: "loan.payment.custom")
      }
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          loanInfoSection
        } header: {
          Text(String(localized: "loan.payment.loan_info"))
        }
        
        Section {
          Picker(String(localized: "loan.payment.type"), selection: $paymentType) {
            ForEach(PaymentType.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          
          switch paymentType {
          case .scheduled:
            scheduledPaymentInfo
          case .extraPrincipal:
            extraPrincipalPaymentInfo
          case .custom:
            customPaymentInfo
          }
        } header: {
          Text(String(localized: "loan.payment.details"))
        }
        
        Section {
          DatePicker(
            String(localized: "loan.payment.date"),
            selection: $paymentDate,
            displayedComponents: .date
          )
          
          Picker(String(localized: "loan.payment.method"), selection: $paymentMethod) {
            ForEach(paymentMethods, id: \.self) { method in
              Text(method).tag(method)
            }
          }
          
          TextField(String(localized: "loan.payment.notes.placeholder"), text: $notes, axis: .vertical)
            .lineLimit(2...4)
        } header: {
          Text(String(localized: "loan.payment.additional_info"))
        } footer: {
          Text(String(localized: "loan.payment.notes.footer"))
        }
        
        Section {
          paymentSummary
        } header: {
          Text(String(localized: "loan.payment.summary"))
        } footer: {
          Text(String(localized: "loan.payment.summary.footer"))
        }
      }
      .navigationTitle(String(localized: "loan.payment.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "loan.payment.confirm")) {
            submitPayment()
          }
          .disabled(isSubmitting || !isValidPayment)
        }
      }
      .alert(String(localized: "common.validation_error"), isPresented: $showingValidationAlert) {
        Button(String(localized: "common.ok")) { }
      } message: {
        Text(validationMessage)
      }
      .onAppear {
        paymentMethod = paymentMethods.first ?? ""
      }
    }
  }
  
  private var loanInfoSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(loan.name)
          .font(.headline)
        Spacer()
        Text(loan.bankName)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      
      HStack {
        Text(String(localized: "loan.current_balance"))
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Text(loan.formattedCurrentBalance)
          .font(.subheadline)
          .fontWeight(.semibold)
      }
      
      HStack {
        Text(String(localized: "loan.monthly_payment"))
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Text(loan.formattedMonthlyPayment)
          .font(.subheadline)
          .fontWeight(.semibold)
      }
    }
    .padding(.vertical, 4)
  }
  
  private var scheduledPaymentInfo: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(String(localized: "loan.payment.amount"))
        Spacer()
        Text(loan.formattedMonthlyPayment)
          .fontWeight(.semibold)
      }
      
      Text(String(localized: "loan.payment.scheduled_info"))
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
  
  private var extraPrincipalPaymentInfo: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(String(localized: "loan.payment.extra_amount"))
        Spacer()
        TextField(String(localized: "loan.amount.placeholder"), text: $customAmount)
          .keyboardType(.decimalPad)
          .multilineTextAlignment(.trailing)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .frame(width: 120)
      }
      
      Text(String(localized: "loan.payment.extra_principal_info"))
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
  
  private var customPaymentInfo: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(String(localized: "loan.payment.custom_amount"))
        Spacer()
        TextField(String(localized: "loan.amount.placeholder"), text: $customAmount)
          .keyboardType(.decimalPad)
          .multilineTextAlignment(.trailing)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .frame(width: 120)
      }
      
      Text(String(localized: "loan.payment.custom_info"))
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
  
  private var paymentSummary: some View {
    VStack(spacing: 8) {
      let paymentAmount = calculatePaymentAmount()
      let (principalAmount, interestAmount) = calculatePrincipalAndInterest(paymentAmount)
      let newBalance = max(0, loan.currentBalance - principalAmount)
      
      HStack {
        Text(String(localized: "loan.payment.total_amount"))
          .font(.subheadline)
        Spacer()
        Text(formatCurrency(paymentAmount))
          .font(.headline)
          .fontWeight(.semibold)
      }
      
      HStack {
        Text(String(localized: "loan.payment.principal_portion"))
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
        Text(formatCurrency(principalAmount))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      HStack {
        Text(String(localized: "loan.payment.interest_portion"))
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
        Text(formatCurrency(interestAmount))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Divider()
      
      HStack {
        Text(String(localized: "loan.payment.new_balance"))
          .font(.subheadline)
          .fontWeight(.medium)
        Spacer()
        Text(formatCurrency(newBalance))
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(newBalance > 0 ? .primary : .green)
      }
    }
  }
  
  private var isValidPayment: Bool {
    let amount = calculatePaymentAmount()
    return amount > 0 && !paymentMethod.isEmpty
  }
  
  private func calculatePaymentAmount() -> Double {
    switch paymentType {
    case .scheduled:
      return loan.monthlyPayment
    case .extraPrincipal:
      let extraAmount = Double(customAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
      return loan.monthlyPayment + extraAmount
    case .custom:
      return Double(customAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
  }
  
  private func calculatePrincipalAndInterest(_ paymentAmount: Double) -> (principal: Double, interest: Double) {
    let monthlyRate = loan.interestRate / 100 / 12
    let interestAmount = loan.currentBalance * monthlyRate
    let principalAmount = max(0, paymentAmount - interestAmount)
    
    return (principalAmount, min(interestAmount, paymentAmount))
  }
  
  private func submitPayment() {
    guard validatePayment() else { return }
    
    isSubmitting = true
    
    let paymentAmount = calculatePaymentAmount()
    let (principalAmount, interestAmount) = calculatePrincipalAndInterest(paymentAmount)
    
    let payment = LoanPayment(
      loanId: loan.id,
      amount: paymentAmount,
      principalAmount: principalAmount,
      interestAmount: interestAmount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes.isEmpty ? nil : notes,
      userId: ""
    )
    
    Task {
      let success = await loanService.makePayment(payment)
      
      await MainActor.run {
        isSubmitting = false
        
        if success {
          dismiss()
        } else {
          validationMessage = loanService.errorMessage ?? String(localized: "loan.error.payment_failed")
          showingValidationAlert = true
        }
      }
    }
  }
  
  private func validatePayment() -> Bool {
    let amount = calculatePaymentAmount()
    
    if amount <= 0 {
      validationMessage = String(localized: "loan.validation.valid_amount_required")
      showingValidationAlert = true
      return false
    }
    
    if paymentMethod.isEmpty {
      validationMessage = String(localized: "loan.validation.payment_method_required")
      showingValidationAlert = true
      return false
    }
    
    return true
  }
  
  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

#Preview {
  MakeLoanPaymentView(
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