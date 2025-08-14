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
    HStack {
      Circle()
        .fill(transaction.type.color)
        .frame(width: 8, height: 8)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.description)
          .font(.subheadline)
          .fontWeight(.medium)
        
        Text(transaction.category)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Text(transaction.amount.formatted(.currency(code: "BRL")))
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(transaction.type == .income ? .green : .primary)
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(transaction.description), \(transaction.amount.formatted(.currency(code: "BRL")))")
  }
}
