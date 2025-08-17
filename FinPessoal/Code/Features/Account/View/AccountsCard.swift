//
//  AccountsCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import SwiftUI

struct AccountCard: View {
  let account: Account
  
  var body: some View {
    HStack {
      Image(systemName: account.type.icon)
        .font(.title2)
        .foregroundColor(account.type.color)
        .frame(width: 40, height: 40)
        .background(account.type.color.opacity(0.1))
        .cornerRadius(8)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(account.name)
          .font(.headline)
        
        Text(account.type.rawValue)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Text(account.formattedBalance)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(account.balance >= 0 ? .green : .red)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
