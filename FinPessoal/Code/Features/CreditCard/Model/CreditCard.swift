//
//  CreditCard.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import Foundation
import SwiftUI

struct CreditCard: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let lastFourDigits: String
    let brand: CreditCardBrand
    let creditLimit: Double
    let availableCredit: Double
    let currentBalance: Double
    let dueDate: Int // Day of month (1-31)
    let closingDate: Int // Day of month (1-31)
    let minimumPayment: Double
    let annualFee: Double
    let interestRate: Double // Annual percentage rate
    let isActive: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var usedCredit: Double {
        creditLimit - availableCredit
    }
    
    var utilizationPercentage: Double {
        guard creditLimit > 0 else { return 0 }
        return (usedCredit / creditLimit) * 100
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: currentBalance)) ?? "R$ 0,00"
    }
    
    var formattedCreditLimit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: creditLimit)) ?? "R$ 0,00"
    }
    
    var formattedAvailableCredit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: availableCredit)) ?? "R$ 0,00"
    }
    
    var formattedMinimumPayment: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: minimumPayment)) ?? "R$ 0,00"
    }
    
    var nextDueDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        
        var dueDateComponents = DateComponents()
        dueDateComponents.year = currentComponents.year
        dueDateComponents.month = currentComponents.month
        dueDateComponents.day = dueDate
        
        guard let proposedDate = calendar.date(from: dueDateComponents) else {
            return now
        }
        
        // If the due date has passed this month, move to next month
        if proposedDate < now {
            return calendar.date(byAdding: .month, value: 1, to: proposedDate) ?? now
        }
        
        return proposedDate
    }
    
    var nextClosingDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        
        var closingDateComponents = DateComponents()
        closingDateComponents.year = currentComponents.year
        closingDateComponents.month = currentComponents.month
        closingDateComponents.day = closingDate
        
        guard let proposedDate = calendar.date(from: closingDateComponents) else {
            return now
        }
        
        // If the closing date has passed this month, move to next month
        if proposedDate < now {
            return calendar.date(byAdding: .month, value: 1, to: proposedDate) ?? now
        }
        
        return proposedDate
    }
    
    var utilizationColor: Color {
        switch utilizationPercentage {
        case 0..<30:
            return .green
        case 30..<70:
            return .orange
        default:
            return .red
        }
    }
    
    var statusText: String {
        if !isActive {
            return String(localized: "creditcard.status.inactive")
        }
        
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
        
        if daysUntilDue <= 3 && currentBalance > 0 {
            return String(localized: "creditcard.status.due_soon")
        } else if currentBalance > minimumPayment {
            return String(localized: "creditcard.status.balance_due")
        } else {
            return String(localized: "creditcard.status.current")
        }
    }
    
    var statusColor: Color {
        if !isActive {
            return .gray
        }
        
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
        
        if daysUntilDue <= 3 && currentBalance > 0 {
            return .red
        } else if currentBalance > minimumPayment {
            return .orange
        } else {
            return .green
        }
    }
}

enum CreditCardBrand: String, CaseIterable, Codable {
    case visa = "visa"
    case mastercard = "mastercard"
    case amex = "amex"
    case elo = "elo"
    case hipercard = "hipercard"
    case diners = "diners"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        case .amex: return "American Express"
        case .elo: return "Elo"
        case .hipercard: return "Hipercard"
        case .diners: return "Diners Club"
        case .other: return String(localized: "creditcard.brand.other")
        }
    }
    
    var color: Color {
        switch self {
        case .visa: return Color.blue
        case .mastercard: return Color.red
        case .amex: return Color.green
        case .elo: return Color.yellow
        case .hipercard: return Color.orange
        case .diners: return Color.purple
        case .other: return Color.gray
        }
    }
    
    var icon: String {
        switch self {
        case .visa: return "creditcard"
        case .mastercard: return "creditcard"
        case .amex: return "creditcard"
        case .elo: return "creditcard"
        case .hipercard: return "creditcard"
        case .diners: return "creditcard"
        case .other: return "creditcard"
        }
    }
}

// MARK: - Credit Card Transaction
struct CreditCardTransaction: Identifiable, Codable, Hashable {
    let id: String
    let creditCardId: String
    let amount: Double
    let description: String
    let category: TransactionCategory
    let subcategory: TransactionSubcategory?
    let date: Date
    let installments: Int
    let currentInstallment: Int
    let isRecurring: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }
    
    var installmentText: String {
        if installments > 1 {
            return "\(currentInstallment)/\(installments)"
        }
        return String(localized: "creditcard.payment.single")
    }
}

// MARK: - Credit Card Statement
struct CreditCardStatement: Identifiable, Codable, Hashable {
    let id: String
    let creditCardId: String
    let period: StatementPeriod
    let transactions: [CreditCardTransaction]
    let totalAmount: Double
    let minimumPayment: Double
    let dueDate: Date
    let isPaid: Bool
    let paidAmount: Double
    let paidDate: Date?
    let createdAt: Date
    
    var remainingBalance: Double {
        totalAmount - paidAmount
    }
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "R$ 0,00"
    }
    
    var formattedRemainingBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: remainingBalance)) ?? "R$ 0,00"
    }
}

struct StatementPeriod: Codable, Hashable {
    let startDate: Date
    let endDate: Date
    
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}