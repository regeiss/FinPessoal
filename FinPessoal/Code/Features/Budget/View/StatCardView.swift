//
//  StatCardView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct StatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
        Spacer()
      }
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Text(value)
        .font(.title3)
        .fontWeight(.semibold)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
