//
//  ThemedStatCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 05/08/25.
//

import SwiftUI

struct ThemedStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(color)
        Spacer()
      }
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Text(value)
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemGray6))
        .shadow(
          color: colorScheme == .dark ? .clear : .black.opacity(0.05),
          radius: 8,
          x: 0,
          y: 2
        )
    )
  }
}
