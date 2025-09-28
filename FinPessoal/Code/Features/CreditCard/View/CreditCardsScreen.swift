//
//  CreditCardsScreen.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import SwiftUI

struct CreditCardsScreen: View {
    @StateObject private var creditCardService: CreditCardService
    @State private var showingAddCard = false
    @State private var selectedCard: CreditCard?
    @State private var showingCardDetail = false
    
    init(creditCardService: CreditCardService? = nil) {
        if let service = creditCardService {
            self._creditCardService = StateObject(wrappedValue: service)
        } else {
            let repository = AppConfiguration.shared.createCreditCardRepository()
            self._creditCardService = StateObject(wrappedValue: CreditCardService(repository: repository))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if creditCardService.isLoading {
                    ProgressView(String(localized: "creditcard.loading"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if creditCardService.creditCards.isEmpty {
                    emptyStateView
                } else {
                    creditCardsContent
                }
            }
            .navigationTitle(String(localized: "creditcard.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCard = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCreditCardView(creditCardService: creditCardService)
            }
            .sheet(isPresented: $showingCardDetail) {
                if let selectedCard = selectedCard {
                    CreditCardDetailView(creditCard: selectedCard, creditCardService: creditCardService)
                }
            }
            .alert(String(localized: "common.error"), isPresented: .constant(creditCardService.errorMessage != nil)) {
                Button(String(localized: "common.ok")) {
                    creditCardService.clearError()
                }
            } message: {
                if let errorMessage = creditCardService.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await creditCardService.loadCreditCards()
            }
            .refreshable {
                await creditCardService.loadCreditCards()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(String(localized: "creditcard.empty.title"))
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(String(localized: "creditcard.empty.description"))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(String(localized: "creditcard.add.button")) {
                showingAddCard = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var creditCardsContent: some View {
        VStack(spacing: 0) {
            // Summary Cards
            summarySection
            
            // Credit Cards List
            List {
                Section {
                    ForEach(creditCardService.creditCards) { card in
                        CreditCardRow(
                            creditCard: card,
                            onTap: {
                                selectedCard = card
                                showingCardDetail = true
                            }
                        )
                    }
                } header: {
                    HStack {
                        Text(String(localized: "creditcard.cards.header"))
                            .font(.headline)
                        Spacer()
                        Text("\(creditCardService.creditCards.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text(String(localized: "creditcard.cards.footer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Due Soon Section
                if !creditCardService.getCardsDueSoon().isEmpty {
                    Section {
                        ForEach(creditCardService.getCardsDueSoon()) { card in
                            DueSoonCardRow(creditCard: card)
                        }
                    } header: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(String(localized: "creditcard.due_soon.header"))
                                .font(.headline)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    private var summarySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                CreditCardSummaryCard(
                    title: String(localized: "creditcard.summary.total_limit"),
                    value: formatCurrency(creditCardService.getTotalCreditLimit()),
                    icon: "creditcard",
                    color: .blue
                )
                
                CreditCardSummaryCard(
                    title: String(localized: "creditcard.summary.available"),
                    value: formatCurrency(creditCardService.getTotalAvailableCredit()),
                    icon: "checkmark.circle",
                    color: .green
                )
                
                CreditCardSummaryCard(
                    title: String(localized: "creditcard.summary.current_balance"),
                    value: formatCurrency(creditCardService.getTotalCurrentBalance()),
                    icon: "exclamationmark.circle",
                    color: .orange
                )
                
                CreditCardSummaryCard(
                    title: String(localized: "creditcard.summary.minimum_payment"),
                    value: formatCurrency(creditCardService.getTotalMinimumPayment()),
                    icon: "calendar",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }
}

// MARK: - Credit Card Summary Card
struct CreditCardSummaryCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: 150)
    }
}

// MARK: - Credit Card Row
struct CreditCardRow: View {
    let creditCard: CreditCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Brand Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(creditCard.brand.color.opacity(0.2))
                        .frame(width: 50, height: 32)
                    
                    Image(systemName: creditCard.brand.icon)
                        .font(.system(size: 18))
                        .foregroundColor(creditCard.brand.color)
                }
                
                // Card Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(creditCard.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("•••• \(creditCard.lastFourDigits)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(creditCard.brand.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Utilization Bar
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(String(localized: "creditcard.utilization"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(creditCard.utilizationPercentage))%")
                                .font(.caption2)
                                .foregroundColor(creditCard.utilizationColor)
                        }
                        
                        ProgressView(value: creditCard.utilizationPercentage, total: 100)
                            .tint(creditCard.utilizationColor)
                            .scaleEffect(y: 0.5)
                    }
                }
                
                // Balance Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text(creditCard.formattedBalance)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(creditCard.statusText)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(creditCard.statusColor.opacity(0.2))
                        .foregroundColor(creditCard.statusColor)
                        .cornerRadius(4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

// MARK: - Due Soon Card Row
struct DueSoonCardRow: View {
    let creditCard: CreditCard
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(creditCard.name)
                    .font(.headline)
                
                Text(String(localized: "creditcard.due_date_format", defaultValue: "Due: \(formatDate(creditCard.nextDueDate))"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(creditCard.formattedMinimumPayment)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(String(localized: "creditcard.minimum_payment"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
    CreditCardsScreen()
}