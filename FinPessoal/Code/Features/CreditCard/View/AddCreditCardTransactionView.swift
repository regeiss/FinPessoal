//
//  AddCreditCardTransactionView.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import SwiftUI

struct AddCreditCardTransactionView: View {
    let creditCard: CreditCard
    @ObservedObject var creditCardService: CreditCardService
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory: TransactionCategory = .shopping
    @State private var selectedSubcategory: TransactionSubcategory?
    @State private var transactionDate = Date()
    @State private var installments = 1
    @State private var isRecurring = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case amount, description
    }
    
    var isFormValid: Bool {
        !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(amount.replacingOccurrences(of: ",", with: ".")) != nil &&
        (Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
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
                            Text(creditCard.formattedAvailableCredit)
                                .font(.headline)
                                .foregroundColor(.green)
                            Text(String(localized: "creditcard.available_credit"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text(String(localized: "creditcard.transaction.card_info"))
                }
                
                Section {
                    HStack {
                        Text(String(localized: "transaction.amount"))
                        Spacer()
                        TextField(
                            String(localized: "creditcard.amount.placeholder"),
                            text: $amount
                        )
                        .focused($focusedField, equals: .amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    TextField(
                        String(localized: "transaction.description.placeholder"),
                        text: $description
                    )
                    .focused($focusedField, equals: .description)
                    
                    DatePicker(
                        String(localized: "transaction.date"),
                        selection: $transactionDate,
                        displayedComponents: .date
                    )
                } header: {
                    Text(String(localized: "creditcard.transaction.basic_info"))
                } footer: {
                    if let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
                       amountValue > creditCard.availableCredit {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text(String(localized: "creditcard.transaction.exceeds_limit"))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    Picker(String(localized: "transaction.category"), selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    
                    if !selectedCategory.subcategories.isEmpty {
                        Picker(String(localized: "transaction.subcategory"), selection: $selectedSubcategory) {
                            Text(String(localized: "transaction.subcategory.none"))
                                .tag(Optional<TransactionSubcategory>.none)
                            
                            ForEach(selectedCategory.subcategories, id: \.self) { subcategory in
                                Text(subcategory.displayName)
                                    .tag(Optional(subcategory))
                            }
                        }
                    }
                } header: {
                    Text(String(localized: "transaction.category_info"))
                }
                
                Section {
                    Stepper(
                        String(localized: "creditcard.transaction.installments_count", defaultValue: "Installments: \(installments)"),
                        value: $installments,
                        in: 1...36
                    )
                    
                    if installments > 1 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(String(localized: "creditcard.transaction.installment_amount"))
                                Spacer()
                                if let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) {
                                    Text(formatCurrency(amountValue / Double(installments)))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text(String(localized: "creditcard.transaction.installment_info"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle(String(localized: "transaction.is_recurring"), isOn: $isRecurring)
                } header: {
                    Text(String(localized: "creditcard.transaction.payment_info"))
                } footer: {
                    Text(String(localized: "creditcard.transaction.installment_footer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(String(localized: "creditcard.transaction.add.title"))
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
                            await createTransaction()
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
            .onChange(of: selectedCategory) { _, _ in
                selectedSubcategory = nil
            }
        }
    }
    
    private func createTransaction() async {
        guard isFormValid else { return }
        
        let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        let transaction = CreditCardTransaction(
            id: UUID().uuidString,
            creditCardId: creditCard.id,
            amount: amountValue,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            subcategory: selectedSubcategory,
            date: transactionDate,
            installments: installments,
            currentInstallment: 1,
            isRecurring: isRecurring,
            userId: "", // Will be set by the repository
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await creditCardService.createTransaction(transaction)
        
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
    AddCreditCardTransactionView(
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