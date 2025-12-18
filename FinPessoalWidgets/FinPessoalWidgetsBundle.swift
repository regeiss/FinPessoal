//
//  FinPessoalWidgetsBundle.swift
//  FinPessoalWidgets
//
//  Created by Roberto Edgar Geiss on 16/12/25.
//

import WidgetKit
import SwiftUI

@main
struct FinPessoalWidgetsBundle: WidgetBundle {
  var body: some Widget {
    // Home Screen Widgets
    BalanceWidget()
    BudgetWidget()
    BillsWidget()
    GoalsWidget()
    CreditCardWidget()
    TransactionsWidget()

    // Lock Screen Widgets
    BalanceLockWidget()
    BillsLockWidget()
    BudgetLockWidget()
    GoalsLockWidget()

    // Keep existing widgets
    FinPessoalWidgets()
    FinPessoalWidgetsControl()
  }
}
