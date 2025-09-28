//
//  CreditCardDetailView.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import SwiftUI

struct CreditCardDetailView: View {
    let creditCard: CreditCard
    @ObservedObject var creditCardService: CreditCardService
    @Environment(\.dismiss) private var dismiss
    
    @State private var transactions: [CreditCardTransaction] = []
    @State private var showingAddTransaction = false
    @State private var showingPayment = false
    @State private var isLoadingTransactions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Credit Card Visual
                    creditCardVisual
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding()
            }
            .navigationTitle(creditCard.name)
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
                            showingAddTransaction = true
                        } label: {
                            Label(String(localized: "creditcard.add_transaction"), systemImage: "plus")
                        }
                        
                        Button {
                            showingPayment = true
                        } label: {
                            Label(String(localized: "creditcard.make_payment"), systemImage: "creditcard")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            // TODO: Add edit/deactivate functionality
                        } label: {
                            Label(String(localized: "creditcard.deactivate"), systemImage: "pause")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddCreditCardTransactionView(
                    creditCard: creditCard,
                    creditCardService: creditCardService
                )
            }
            .sheet(isPresented: $showingPayment) {
                PayCreditCardView(
                    creditCard: creditCard,
                    creditCardService: creditCardService
                )
            }
            .task {
                await loadTransactions()
            }
        }
    }
    
    private var creditCardVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [creditCard.brand.color, creditCard.brand.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(creditCard.brand.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: creditCard.brand.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("•••• •••• •••• \(creditCard.lastFourDigits)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                HStack {
                    Text(creditCard.name)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(localized: "creditcard.due_date_short"))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(creditCard.dueDate)")
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
            // Current Balance vs Limit
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(localized: "creditcard.current_balance"))
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(creditCard.formattedBalance)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(creditCard.currentBalance > 0 ? .primary : .green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(String(localized: "creditcard.credit_utilization"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(creditCard.utilizationPercentage))%")
                            .font(.caption)
                            .foregroundColor(creditCard.utilizationColor)
                    }
                    
                    ProgressView(value: creditCard.utilizationPercentage, total: 100)
                        .tint(creditCard.utilizationColor)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                CreditCardStatCard(
                    title: String(localized: "creditcard.available_credit"),
                    value: creditCard.formattedAvailableCredit,
                    icon: "checkmark.circle",
                    color: .green
                )
                
                CreditCardStatCard(
                    title: String(localized: "creditcard.credit_limit"),
                    value: creditCard.formattedCreditLimit,
                    icon: "creditcard",
                    color: .blue
                )
                
                CreditCardStatCard(
                    title: String(localized: "creditcard.minimum_payment"),
                    value: creditCard.formattedMinimumPayment,
                    icon: "calendar",
                    color: .orange
                )
                
                CreditCardStatCard(
                    title: String(localized: "creditcard.next_due_date"),
                    value: formatDate(creditCard.nextDueDate),
                    icon: "clock",
                    color: creditCard.statusColor
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Button {
                showingAddTransaction = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text(String(localized: "creditcard.add_transaction"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button {
                showingPayment = true
            } label: {
                HStack {
                    Image(systemName: "creditcard")
                    Text(String(localized: "creditcard.pay"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(String(localized: "creditcard.recent_transactions"))
                    .font(.headline)
                
                Spacer()
                
                if isLoadingTransactions {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(String(localized: "creditcard.no_transactions"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(transactions.prefix(5)) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
                
                if transactions.count > 5 {
                    Button(String(localized: "creditcard.view_all_transactions")) {
                        // TODO: Navigate to full transactions list
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private func loadTransactions() async {
        isLoadingTransactions = true
        transactions = await creditCardService.getTransactions(for: creditCard.id)
        isLoadingTransactions = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

// MARK: - Credit Card Stat Card
struct CreditCardStatCard: View {
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

// MARK: - Transaction Row
struct TransactionRowView: View {
    let transaction: CreditCardTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(transaction.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if transaction.installments > 1 {
                        Text("• \(transaction.installmentText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(formatDate(transaction.date))
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

#Preview {
    CreditCardDetailView(
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