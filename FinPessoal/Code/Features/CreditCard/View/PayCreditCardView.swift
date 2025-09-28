//
//  PayCreditCardView.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import SwiftUI

struct PayCreditCardView: View {
    let creditCard: CreditCard
    @ObservedObject var creditCardService: CreditCardService
    @Environment(\.dismiss) private var dismiss
    
    @State private var paymentAmount = ""
    @State private var selectedPaymentType: PaymentType = .minimumPayment
    @State private var selectedAccount: String = ""
    @State private var paymentDate = Date()
    @State private var notes = ""
    
    @FocusState private var isAmountFieldFocused: Bool
    
    private enum PaymentType: CaseIterable {
        case minimumPayment
        case fullBalance
        case customAmount
        
        var displayName: String {
            switch self {
            case .minimumPayment:
                return String(localized: "creditcard.payment.minimum")
            case .fullBalance:
                return String(localized: "creditcard.payment.full_balance")
            case .customAmount:
                return String(localized: "creditcard.payment.custom_amount")
            }
        }
    }
    
    var calculatedAmount: Double {
        switch selectedPaymentType {
        case .minimumPayment:
            return creditCard.minimumPayment
        case .fullBalance:
            return creditCard.currentBalance
        case .customAmount:
            return Double(paymentAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
        }
    }
    
    var isFormValid: Bool {
        calculatedAmount > 0 && calculatedAmount <= creditCard.currentBalance
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(creditCard.name)
                                .font(.headline)
                            Text("•••• \(creditCard.lastFourDigits)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(creditCard.formattedBalance)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(String(localized: "creditcard.current_balance"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text(String(localized: "creditcard.payment.card_info"))
                }
                
                Section {
                    Picker(String(localized: "creditcard.payment.type"), selection: $selectedPaymentType) {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    HStack {
                        Text(String(localized: "creditcard.payment.amount"))
                        
                        Spacer()
                        
                        if selectedPaymentType == .customAmount {
                            TextField(
                                String(localized: "creditcard.amount.placeholder"),
                                text: $paymentAmount
                            )
                            .focused($isAmountFieldFocused)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        } else {
                            Text(formatCurrency(calculatedAmount))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if selectedPaymentType == .customAmount && calculatedAmount > creditCard.currentBalance {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(String(localized: "creditcard.payment.amount_exceeds_balance"))
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                } header: {
                    Text(String(localized: "creditcard.payment.details"))
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "creditcard.payment.minimum_info", defaultValue: "Minimum payment: \(creditCard.formattedMinimumPayment)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(localized: "creditcard.payment.full_balance_info", defaultValue: "Full balance: \(creditCard.formattedBalance)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    DatePicker(
                        String(localized: "creditcard.payment.date"),
                        selection: $paymentDate,
                        displayedComponents: .date
                    )
                    
                    TextField(
                        String(localized: "creditcard.payment.notes.placeholder"),
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3, reservesSpace: true)
                } header: {
                    Text(String(localized: "creditcard.payment.additional_info"))
                } footer: {
                    Text(String(localized: "creditcard.payment.notes.footer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "creditcard.payment.new_balance"))
                                .font(.headline)
                            
                            Text(String(localized: "creditcard.payment.after_payment"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(formatCurrency(max(0, creditCard.currentBalance - calculatedAmount)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                } footer: {
                    Text(String(localized: "creditcard.payment.summary.footer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(String(localized: "creditcard.payment.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "creditcard.payment.confirm")) {
                        Task {
                            await makePayment()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "common.done")) {
                        isAmountFieldFocused = false
                    }
                }
            }
        }
    }
    
    private func makePayment() async {
        // Create a mock statement for the payment
        let statement = CreditCardStatement(
            id: UUID().uuidString,
            creditCardId: creditCard.id,
            period: StatementPeriod(
                startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                endDate: Date()
            ),
            transactions: [],
            totalAmount: creditCard.currentBalance,
            minimumPayment: creditCard.minimumPayment,
            dueDate: creditCard.nextDueDate,
            isPaid: false,
            paidAmount: 0,
            paidDate: nil,
            createdAt: Date()
        )
        
        await creditCardService.payStatement(statement, amount: calculatedAmount)
        
        if creditCardService.errorMessage == nil {
            dismiss()
        }
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
    PayCreditCardView(
        creditCard: CreditCard(
            id: "1",
            name: "Cartão Principal",
            lastFourDigits: "1234",
            brand: .visa,
            creditLimit: 5000,
            availableCredit: 3000,
            currentBalance: 2000,
            dueDate: 15,
            closingDate: 10,
            minimumPayment: 100,
            annualFee: 120,
            interestRate: 12.5,
            isActive: true,
            userId: "user",
            createdAt: Date(),
            updatedAt: Date()
        ),
        creditCardService: CreditCardService(repository: MockCreditCardRepository())
    )
}