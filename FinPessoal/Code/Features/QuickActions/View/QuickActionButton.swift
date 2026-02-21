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
          .foregroundColor(.oldMoney.text)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.oldMoney.background)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(Color.oldMoney.accent.opacity(0.2), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
      )
      .cornerRadius(8)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(LocalizedStringKey(title)))
    .accessibilityHint("Double tap to \(title)")
    .accessibilityAddTraits(.isButton)
  }
}

