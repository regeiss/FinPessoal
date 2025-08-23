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
      // Ícone da categoria
      Image(systemName: transaction.category.icon)
        .font(.title3)
        .foregroundColor(.white)
        .frame(width: 40, height: 40)
        .background(transaction.type == .income ? Color.green : Color.red)
        .cornerRadius(10)
      
      // Informações da transação
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(.headline)
          .fontWeight(.medium)
          .lineLimit(1)
        
        HStack {
          Text(LocalizedStringKey(transaction.category.displayName))
            .font(.caption)
            .foregroundColor(.secondary)
          
          if transaction.isRecurring {
            Image(systemName: "repeat")
              .font(.caption2)
              .foregroundColor(.blue)
          }
        }
      }
      
      Spacer()
      
      // Valor e data
      VStack(alignment: .trailing, spacing: 4) {
        Text(transaction.formattedAmount)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(transaction.type == .expense ? .red : .green)
        
        Text(transaction.date, format: .dateTime.hour().minute())
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}
