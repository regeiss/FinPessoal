//
//  Loan.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import Foundation

struct Loan: Identifiable, Codable, Hashable {
  let id: String
  let name: String
  let loanType: LoanType
  let principalAmount: Double
  let currentBalance: Double
  let interestRate: Double
  let term: Int // in months
  let monthlyPayment: Double
  let startDate: Date
  let endDate: Date
  let paymentDay: Int // day of month (1-31)
  let bankName: String
  let purpose: String
  let isActive: Bool
  let userId: String
  let createdAt: Date
  let updatedAt: Date
  
  init(id: String = UUID().uuidString, name: String, loanType: LoanType, principalAmount: Double, currentBalance: Double? = nil, interestRate: Double, term: Int, monthlyPayment: Double? = nil, startDate: Date, paymentDay: Int, bankName: String, purpose: String, isActive: Bool = true, userId: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
    self.id = id
    self.name = name
    self.loanType = loanType
    self.principalAmount = principalAmount
    self.currentBalance = currentBalance ?? principalAmount
    self.interestRate = interestRate
    self.term = term
    self.startDate = startDate
    self.paymentDay = paymentDay
    self.bankName = bankName
    self.purpose = purpose
    self.isActive = isActive
    self.userId = userId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    
    // Calculate monthly payment if not provided
    let monthlyRate = interestRate / 100 / 12
    if monthlyRate > 0 {
      let payment = principalAmount * (monthlyRate * pow(1 + monthlyRate, Double(term))) / (pow(1 + monthlyRate, Double(term)) - 1)
      self.monthlyPayment = monthlyPayment ?? payment
    } else {
      self.monthlyPayment = monthlyPayment ?? (principalAmount / Double(term))
    }
    
    // Calculate end date
    let calendar = Calendar.current
    self.endDate = calendar.date(byAdding: .month, value: term, to: startDate) ?? startDate
  }
}

extension Loan {
  var formattedPrincipalAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: principalAmount)) ?? "R$ 0,00"
  }
  
  var formattedCurrentBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: currentBalance)) ?? "R$ 0,00"
  }
  
  var formattedMonthlyPayment: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: monthlyPayment)) ?? "R$ 0,00"
  }
  
  var totalInterestPaid: Double {
    return (monthlyPayment * Double(term)) - principalAmount
  }
  
  var formattedTotalInterest: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: totalInterestPaid)) ?? "R$ 0,00"
  }
  
  var progressPercentage: Double {
    guard principalAmount > 0 else { return 0 }
    return ((principalAmount - currentBalance) / principalAmount) * 100
  }
  
  var remainingPayments: Int {
    let calendar = Calendar.current
    let today = Date()
    
    if today >= endDate {
      return 0
    }
    
    let monthsElapsed = calendar.dateComponents([.month], from: startDate, to: today).month ?? 0
    return max(0, term - monthsElapsed)
  }
  
  var nextPaymentDate: Date {
    let calendar = Calendar.current
    let today = Date()
    
    var components = calendar.dateComponents([.year, .month], from: today)
    components.day = paymentDay
    
    if let currentMonthPayment = calendar.date(from: components),
       currentMonthPayment > today {
      return currentMonthPayment
    } else {
      components.month = (components.month ?? 0) + 1
      return calendar.date(from: components) ?? today
    }
  }
  
  var statusColor: String {
    let daysUntilPayment = Calendar.current.dateComponents([.day], from: Date(), to: nextPaymentDate).day ?? 0
    
    if !isActive {
      return "gray"
    } else if currentBalance <= 0 {
      return "green"
    } else if daysUntilPayment <= 5 {
      return "red"
    } else if daysUntilPayment <= 10 {
      return "orange"
    } else {
      return "blue"
    }
  }
  
  var statusText: String {
    if !isActive {
      return String(localized: "loan.status.inactive")
    } else if currentBalance <= 0 {
      return String(localized: "loan.status.paid_off")
    } else if Calendar.current.dateComponents([.day], from: Date(), to: nextPaymentDate).day ?? 0 <= 5 {
      return String(localized: "loan.status.due_soon")
    } else {
      return String(localized: "loan.status.current")
    }
  }
}

enum LoanType: String, CaseIterable, Codable {
  case personal = "personal"
  case home = "home"
  case auto = "auto"
  case student = "student"
  case business = "business"
  case consolidation = "consolidation"
  case other = "other"
  
  var displayName: String {
    switch self {
    case .personal:
      return String(localized: "loan.type.personal")
    case .home:
      return String(localized: "loan.type.home")
    case .auto:
      return String(localized: "loan.type.auto")
    case .student:
      return String(localized: "loan.type.student")
    case .business:
      return String(localized: "loan.type.business")
    case .consolidation:
      return String(localized: "loan.type.consolidation")
    case .other:
      return String(localized: "loan.type.other")
    }
  }
  
  var icon: String {
    switch self {
    case .personal:
      return "person.circle"
    case .home:
      return "house"
    case .auto:
      return "car"
    case .student:
      return "graduationcap"
    case .business:
      return "briefcase"
    case .consolidation:
      return "arrow.triangle.merge"
    case .other:
      return "ellipsis.circle"
    }
  }
  
  var color: String {
    switch self {
    case .personal:
      return "blue"
    case .home:
      return "green"
    case .auto:
      return "red"
    case .student:
      return "purple"
    case .business:
      return "orange"
    case .consolidation:
      return "indigo"
    case .other:
      return "gray"
    }
  }
}

struct LoanPayment: Identifiable, Codable, Hashable {
  let id: String
  let loanId: String
  let amount: Double
  let principalAmount: Double
  let interestAmount: Double
  let paymentDate: Date
  let paymentMethod: String
  let notes: String?
  let userId: String
  let createdAt: Date
  
  init(id: String = UUID().uuidString, loanId: String, amount: Double, principalAmount: Double, interestAmount: Double, paymentDate: Date, paymentMethod: String, notes: String? = nil, userId: String, createdAt: Date = Date()) {
    self.id = id
    self.loanId = loanId
    self.amount = amount
    self.principalAmount = principalAmount
    self.interestAmount = interestAmount
    self.paymentDate = paymentDate
    self.paymentMethod = paymentMethod
    self.notes = notes
    self.userId = userId
    self.createdAt = createdAt
  }
}

extension LoanPayment {
  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
  
  var formattedPrincipalAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: principalAmount)) ?? "R$ 0,00"
  }
  
  var formattedInterestAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: interestAmount)) ?? "R$ 0,00"
  }
}

struct LoanAmortizationEntry: Identifiable, Hashable {
  let id: String
  let paymentNumber: Int
  let paymentDate: Date
  let totalPayment: Double
  let principalPayment: Double
  let interestPayment: Double
  let remainingBalance: Double
  let isPaid: Bool
  
  init(paymentNumber: Int, paymentDate: Date, totalPayment: Double, principalPayment: Double, interestPayment: Double, remainingBalance: Double, isPaid: Bool = false) {
    self.id = "\(paymentNumber)"
    self.paymentNumber = paymentNumber
    self.paymentDate = paymentDate
    self.totalPayment = totalPayment
    self.principalPayment = principalPayment
    self.interestPayment = interestPayment
    self.remainingBalance = remainingBalance
    self.isPaid = isPaid
  }
}

extension LoanAmortizationEntry {
  var formattedTotalPayment: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: totalPayment)) ?? "R$ 0,00"
  }
  
  var formattedPrincipalPayment: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: principalPayment)) ?? "R$ 0,00"
  }
  
  var formattedInterestPayment: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: interestPayment)) ?? "R$ 0,00"
  }
  
  var formattedRemainingBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: remainingBalance)) ?? "R$ 0,00"
  }
}