//
//  TransactionRow.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct TransactionRow: View {
  let transaction: Transaction
  
  var body: some View {
    HStack(spacing: 16) {
      // Ícone da categoria ou tipo (para transferências)
      Image(systemName: transaction.type == .transfer ? transaction.type.icon : (transaction.subcategory?.icon ?? transaction.category.icon))
        .font(.title2)
        .foregroundStyle(transaction.type == .income ? Color.oldMoney.income : transaction.type == .expense ? Color.oldMoney.expense : Color.oldMoney.accent)
        .frame(width: 40, height: 40)
        .background((transaction.type == .income ? Color.oldMoney.income : transaction.type == .expense ? Color.oldMoney.expense : Color.oldMoney.accent).opacity(0.1))
        .cornerRadius(8)
        .accessibilityHidden(true)

      // Informações da transação
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(.headline)
          .fontWeight(.medium)
          .lineLimit(1)

        HStack {
          if let subcategory = transaction.subcategory {
            Text(LocalizedStringKey(subcategory.displayName))
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)
          } else {
            Text(LocalizedStringKey(transaction.category.displayName))
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }

          if transaction.isRecurring {
            Image(systemName: "repeat")
              .font(.caption2)
              .foregroundStyle(Color.oldMoney.accent)
              .accessibilityLabel("Recurring")
          }
        }
      }

      Spacer()

      // Valor e data
      VStack(alignment: .trailing, spacing: 4) {
        Text(transaction.formattedAmount)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(transaction.type == .income ? Color.oldMoney.income : transaction.type == .expense ? Color.oldMoney.expense : Color.oldMoney.accent)

        Text(transaction.date, format: .dateTime.hour().minute())
          .font(.caption2)
          .foregroundStyle(Color.oldMoney.textSecondary)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(transaction.type.displayName): \(transaction.description), \(transaction.subcategory?.displayName ?? transaction.category.displayName), \(transaction.formattedAmount), \(transaction.date.formatted())\(transaction.isRecurring ? ", Recurring" : "")")
    .accessibilityHint("Double tap to view transaction details")
    .accessibilityAddTraits(.isButton)
  }
}
