//
//  DashboardViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
  @Published var accounts: [Account] = []
  @Published var recentTransactions: [Transaction] = []
  @Published var budgets: [Budget] = []
  @Published var isLoading = false
  @Published var error: AppError?
  
  private var cancellables = Set<AnyCancellable>()
  
  var totalBalance: Double {
    accounts.reduce(0) { $0 + $1.balance }
  }
  
  var monthlyExpenses: Double {
    // Calculate current month expenses
    return 0.0 // Implementation needed
  }
  
  var budgetAlerts: [Budget] {
    budgets.filter { $0.shouldAlert }
  }
  
  func loadDashboardData() {
    isLoading = true
    error = nil
    
    // Load accounts, transactions, and budgets
    // Implementation with Firebase calls
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.isLoading = false
    }
  }
}
