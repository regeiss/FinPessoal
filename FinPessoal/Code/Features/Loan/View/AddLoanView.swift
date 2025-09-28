//
//  AddLoanView.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import SwiftUI

struct AddLoanView: View {
  @ObservedObject var loanService: LoanService
  @Environment(\.dismiss) private var dismiss
  
  @State private var name = ""
  @State private var loanType: LoanType = .personal
  @State private var principalAmount = ""
  @State private var interestRate = ""
  @State private var term = ""
  @State private var startDate = Date()
  @State private var paymentDay = 15
  @State private var bankName = ""
  @State private var purpose = ""
  @State private var isActive = true
  
  @State private var showingValidationAlert = false
  @State private var validationMessage = ""
  @State private var isSubmitting = false
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField(String(localized: "loan.name.placeholder"), text: $name)
          
          Picker(String(localized: "loan.type"), selection: $loanType) {
            ForEach(LoanType.allCases, id: \.self) { type in
              HStack {
                Image(systemName: type.icon)
                  .foregroundColor(Color(type.color))
                Text(type.displayName)
              }
              .tag(type)
            }
          }
          
          TextField(String(localized: "loan.bank_name.placeholder"), text: $bankName)
          
          TextField(String(localized: "loan.purpose.placeholder"), text: $purpose)
            .lineLimit(2...4)
        } header: {
          Text(String(localized: "loan.basic_info.header"))
        } footer: {
          Text(String(localized: "loan.basic_info.footer"))
        }
        
        Section {
          HStack {
            Text(String(localized: "loan.principal_amount"))
            Spacer()
            TextField(String(localized: "loan.amount.placeholder"), text: $principalAmount)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
          
          HStack {
            Text(String(localized: "loan.interest_rate"))
            Spacer()
            TextField(String(localized: "loan.percentage.placeholder"), text: $interestRate)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
          
          HStack {
            Text(String(localized: "loan.term_months"))
            Spacer()
            TextField(String(localized: "loan.term.placeholder"), text: $term)
              .keyboardType(.numberPad)
              .multilineTextAlignment(.trailing)
          }
          
          DatePicker(
            String(localized: "loan.start_date"),
            selection: $startDate,
            displayedComponents: .date
          )
          
          HStack {
            Text(String(localized: "loan.payment_day"))
            Spacer()
            Picker("", selection: $paymentDay) {
              ForEach(1...31, id: \.self) { day in
                Text(String(localized: "loan.day_of_month", defaultValue: "Day \(day)"))
                  .tag(day)
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
        } header: {
          Text(String(localized: "loan.financial_info.header"))
        } footer: {
          Text(String(localized: "loan.financial_info.footer"))
        }
        
        Section {
          Toggle(String(localized: "loan.is_active"), isOn: $isActive)
        } footer: {
          Text(String(localized: "loan.active_status.footer"))
        }
        
        if !principalAmount.isEmpty && !interestRate.isEmpty && !term.isEmpty {
          Section {
            monthlyPaymentPreview
          } header: {
            Text(String(localized: "loan.payment_preview.header"))
          }
        }
      }
      .navigationTitle(String(localized: "loan.add.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.save")) {
            submitLoan()
          }
          .disabled(isSubmitting || !isValidForm)
        }
      }
      .alert(String(localized: "common.validation_error"), isPresented: $showingValidationAlert) {
        Button(String(localized: "common.ok")) { }
      } message: {
        Text(validationMessage)
      }
    }
  }
  
  private var monthlyPaymentPreview: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let principal = Double(principalAmount.replacingOccurrences(of: ",", with: ".")),
         let rate = Double(interestRate.replacingOccurrences(of: ",", with: ".")),
         let termValue = Int(term) {
        
        let monthlyRate = rate / 100 / 12
        let monthlyPayment = calculateMonthlyPayment(principal: principal, rate: monthlyRate, term: termValue)
        let totalAmount = monthlyPayment * Double(termValue)
        let totalInterest = totalAmount - principal
        
        HStack {
          Text(String(localized: "loan.monthly_payment"))
            .font(.subheadline)
          Spacer()
          Text(formatCurrency(monthlyPayment))
            .font(.headline)
            .fontWeight(.semibold)
        }
        
        HStack {
          Text(String(localized: "loan.total_amount"))
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
          Text(formatCurrency(totalAmount))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        HStack {
          Text(String(localized: "loan.total_interest"))
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
          Text(formatCurrency(totalInterest))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.vertical, 4)
  }
  
  private var isValidForm: Bool {
    !name.isEmpty &&
    !bankName.isEmpty &&
    !principalAmount.isEmpty &&
    !interestRate.isEmpty &&
    !term.isEmpty &&
    Double(principalAmount.replacingOccurrences(of: ",", with: ".")) != nil &&
    Double(interestRate.replacingOccurrences(of: ",", with: ".")) != nil &&
    Int(term) != nil
  }
  
  private func calculateMonthlyPayment(principal: Double, rate: Double, term: Int) -> Double {
    if rate > 0 {
      return principal * (rate * pow(1 + rate, Double(term))) / (pow(1 + rate, Double(term)) - 1)
    } else {
      return principal / Double(term)
    }
  }
  
  private func submitLoan() {
    guard validateForm() else { return }
    
    isSubmitting = true
    
    let loan = Loan(
      name: name,
      loanType: loanType,
      principalAmount: Double(principalAmount.replacingOccurrences(of: ",", with: ".")) ?? 0,
      interestRate: Double(interestRate.replacingOccurrences(of: ",", with: ".")) ?? 0,
      term: Int(term) ?? 0,
      startDate: startDate,
      paymentDay: paymentDay,
      bankName: bankName,
      purpose: purpose,
      isActive: isActive,
      userId: ""
    )
    
    Task {
      let success = await loanService.createLoan(loan)
      
      await MainActor.run {
        isSubmitting = false
        
        if success {
          dismiss()
        } else {
          validationMessage = loanService.errorMessage ?? String(localized: "loan.error.create_failed")
          showingValidationAlert = true
        }
      }
    }
  }
  
  private func validateForm() -> Bool {
    if name.isEmpty {
      validationMessage = String(localized: "loan.validation.name_required")
      showingValidationAlert = true
      return false
    }
    
    if bankName.isEmpty {
      validationMessage = String(localized: "loan.validation.bank_name_required")
      showingValidationAlert = true
      return false
    }
    
    guard let principal = Double(principalAmount.replacingOccurrences(of: ",", with: ".")),
          principal > 0 else {
      validationMessage = String(localized: "loan.validation.valid_amount_required")
      showingValidationAlert = true
      return false
    }
    
    guard let rate = Double(interestRate.replacingOccurrences(of: ",", with: ".")),
          rate >= 0 else {
      validationMessage = String(localized: "loan.validation.valid_rate_required")
      showingValidationAlert = true
      return false
    }
    
    guard let termValue = Int(term),
          termValue > 0 && termValue <= 600 else {
      validationMessage = String(localized: "loan.validation.valid_term_required")
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
  AddLoanView(loanService: LoanService(repository: MockLoanRepository()))
}