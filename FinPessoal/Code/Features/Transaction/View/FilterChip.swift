//
//  FilterChip.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct FilterChip: View {
  let title: String
  let icon: String?
  let isSelected: Bool
  let action: () -> Void
  
  init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
    self.title = title
    self.icon = icon
    self.isSelected = isSelected
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 6) {
        if let icon = icon {
          Image(systemName: icon)
            .font(.caption)
        }
        
        Text(title)
          .font(.caption)
          .fontWeight(.medium)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(isSelected ? Color.blue : Color(.systemGray5))
      .foregroundColor(isSelected ? .white : .primary)
      .cornerRadius(16)
    }
    .buttonStyle(.plain)
  }
}
