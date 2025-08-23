//
//  StatCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import SwiftUI

struct StatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(color)
        
        Spacer()
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.caption)
          .foregroundColor(.secondary)
        
        Text(value)
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
