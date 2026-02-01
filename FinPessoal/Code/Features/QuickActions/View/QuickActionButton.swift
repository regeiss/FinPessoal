//
//  QuickActionButton.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct QuickActionButton: View {
  let icon: String
  let title: String
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(color)
          .accessibilityHidden(true)

        Text(LocalizedStringKey(title))
          .font(.caption)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(8)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(LocalizedStringKey(title)))
    .accessibilityHint("Double tap to \(title)")
    .accessibilityAddTraits(.isButton)
  }
}

