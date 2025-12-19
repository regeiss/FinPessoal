//
//  EmptyStateView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI

struct EmptyStateView: View {
  let icon: String
  let title: String
  let subtitle: String

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: icon)
        .font(.system(size: 40))
        .foregroundStyle(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      VStack(spacing: 8) {
        Text(LocalizedStringKey(title))
          .font(.headline)
          .fontWeight(.medium)
          .foregroundStyle(Color.oldMoney.text)

        Text(LocalizedStringKey(subtitle))
          .font(.subheadline)
          .foregroundStyle(Color.oldMoney.textSecondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(40)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(LocalizedStringKey(title)))
    .accessibilityValue(Text(LocalizedStringKey(subtitle)))
    .accessibilityAddTraits(.isStaticText)
  }
}
