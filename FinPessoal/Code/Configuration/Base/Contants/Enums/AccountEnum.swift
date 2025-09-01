//
//  AccountEnum.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import SwiftUI

enum AccountType: String, CaseIterable, Codable {
  case checking = "Conta Corrente"
  case savings = "Poupança"
  case credit = "Cartão de Crédito"
  case investment = "Investimentos"
  
  var icon: String {
    switch self {
    case .checking: return "creditcard.fill"
    case .savings: return "wallet.bifold.fill"
    case .credit: return "creditcard"
    case .investment: return "chart.line.uptrend.xyaxis"
    }
  }
  
  var color: Color {
    switch self {
    case .checking: return .blue
    case .savings: return .green
    case .credit: return .orange
    case .investment: return .purple
    }
  }
  
  var localizedName: String {
    switch self {
    case .checking:
      return NSLocalizedString("account.type.checking", comment: "Checking account")
    case .savings:
      return NSLocalizedString("account.type.savings", comment: "Savings account")
    case .credit:
      return NSLocalizedString("account.type.checking", comment: "Credit account")
    case .investment:
      return NSLocalizedString("account.type.checking", comment: "Investment account")
    }
  }
}
