//
//  AddCreditCardView.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import SwiftUI

struct AddCreditCardView: View {
    @ObservedObject var creditCardService: CreditCardService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var lastFourDigits = ""
    @State private var selectedBrand: CreditCardBrand = .visa
    @State private var creditLimit = ""
    @State private var dueDate = 15
    @State private var closingDate = 10
    @State private var annualFee = ""
    @State private var interestRate = ""
    @State private var isActive = true
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, lastFourDigits, creditLimit, annualFee, interestRate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    StyledTextField(
                      text: $name,
                      placeholder: String(localized: "creditcard.name.placeholder")
                    )
                    .focused($focusedField, equals: .name)

                    StyledTextField(
                      text: $lastFourDigits,
                      placeholder: String(localized: "creditcard.last_four.placeholder"),
                      keyboardType: .numberPad
                    )
                    .focused($focusedField, equals: .lastFourDigits)
                    .onChange(of: lastFourDigits) { _, newValue in
                      // Limit to 4 digits
                      if newValue.count > 4 {
                        lastFourDigits = String(newValue.prefix(4))
                      }
                    }
                    
                    Picker(String(localized: "creditcard.brand"), selection: $selectedBrand) {
                        ForEach(CreditCardBrand.allCases, id: \.self) { brand in
                            HStack {
                                Circle()
                                    .fill(brand.color)
                                    .frame(width: 12, height: 12)
                                Text(brand.displayName)
                            }
                            .tag(brand)
                        }
                    }
                } header: {
                    Text(String(localized: "creditcard.basic_info.header"))
                } footer: {
                    Text(String(localized: "creditcard.basic_info.footer"))
                }
                
                Section {
                    HStack {
                        Text(String(localized: "creditcard.credit_limit"))
                        Spacer()
                        StyledTextField(
                          text: $creditLimit,
                          placeholder: String(localized: "creditcard.amount.placeholder"),
                          keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .creditLimit)
                        .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text(String(localized: "creditcard.annual_fee"))
                        Spacer()
                        StyledTextField(
                          text: $annualFee,
                          placeholder: String(localized: "creditcard.amount.placeholder"),
                          keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .annualFee)
                        .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text(String(localized: "creditcard.interest_rate"))
                        Spacer()
                        StyledTextField(
                          text: $interestRate,
                          placeholder: String(localized: "creditcard.percentage.placeholder"),
                          keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .interestRate)
                        .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text(String(localized: "creditcard.financial_info.header"))
                } footer: {
                    Text(String(localized: "creditcard.financial_info.footer"))
                }
                
                Section {
                    Picker(String(localized: "creditcard.due_date"), selection: $dueDate) {
                        ForEach(1...31, id: \.self) { day in
                            Text(String(localized: "creditcard.day_of_month", defaultValue: "Day \(day)"))
                                .tag(day)
                        }
                    }
                    
                    Picker(String(localized: "creditcard.closing_date"), selection: $closingDate) {
                        ForEach(1...31, id: \.self) { day in
                            Text(String(localized: "creditcard.day_of_month", defaultValue: "Day \(day)"))
                                .tag(day)
                        }
                    }
                } header: {
                    Text(String(localized: "creditcard.billing_info.header"))
                } footer: {
                    Text(String(localized: "creditcard.billing_info.footer"))
                }
                
                Section {
                    Toggle(String(localized: "creditcard.is_active"), isOn: $isActive)
                } footer: {
                    Text(String(localized: "creditcard.active_status.footer"))
                }
            }
            .navigationTitle(String(localized: "creditcard.add.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.save")) {
                        Task {
                            await createCreditCard()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "common.done")) {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        lastFourDigits.count == 4 &&
        !creditLimit.isEmpty &&
        Double(creditLimit.replacingOccurrences(of: ",", with: ".")) != nil
    }
    
    private func createCreditCard() async {
        guard isFormValid else { return }
        
        let creditLimitValue = Double(creditLimit.replacingOccurrences(of: ",", with: ".")) ?? 0
        let annualFeeValue = Double(annualFee.replacingOccurrences(of: ",", with: ".")) ?? 0
        let interestRateValue = Double(interestRate.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        let creditCard = CreditCard(
            id: UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            lastFourDigits: lastFourDigits,
            brand: selectedBrand,
            creditLimit: creditLimitValue,
            availableCredit: creditLimitValue, // Initially full credit is available
            currentBalance: 0, // No balance initially
            dueDate: dueDate,
            closingDate: closingDate,
            minimumPayment: 0, // No minimum payment initially
            annualFee: annualFeeValue,
            interestRate: interestRateValue,
            isActive: isActive,
            userId: "", // Will be set by the repository
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await creditCardService.createCreditCard(creditCard)
        
        if creditCardService.errorMessage == nil {
            dismiss()
        }
    }
}

#Preview {
    AddCreditCardView(creditCardService: CreditCardService(repository: MockCreditCardRepository()))
}