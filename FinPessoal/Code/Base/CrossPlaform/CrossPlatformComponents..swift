//
//  CrossPlatformComponents..swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 06/08/25.
//

import SwiftUI

// MARK: - ThemedStatCard

struct ThemedStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack(alignment: .leading, spacing: cardSpacing) {
      HStack {
        Image(systemName: icon)
          .font(iconFont)
          .foregroundColor(color)
        Spacer()
      }
      
      Text(title)
        .font(titleFont)
        .foregroundColor(.adaptiveSecondaryLabel)
      
      Text(value)
        .font(valueFont)
        .fontWeight(.semibold)
        .foregroundColor(.adaptiveLabel)
    }
    .padding(cardPadding)
    .background(
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(
          color: colorScheme == .dark ? .clear : .black.opacity(0.05),
          radius: shadowRadius,
          x: 0,
          y: shadowOffset
        )
    )
  }
  
  // MARK: - Responsive Properties
  
  private var cardSpacing: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 12 : 8
  }
  
  private var cardPadding: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 20 : 16
  }
  
  private var cornerRadius: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 16 : 12
  }
  
  private var shadowRadius: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 12 : 8
  }
  
  private var shadowOffset: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 4 : 2
  }
  
  private var iconFont: Font {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? .title2 : .title3
  }
  
  private var titleFont: Font {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? .callout : .caption
  }
  
  private var valueFont: Font {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? .title2 : .title3
  }
}

// MARK: - CompactBudgetAlertCard

struct CompactBudgetAlertCard: View {
  let budget: Budget
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: budget.isOverBudget ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
          .foregroundColor(budget.isOverBudget ? .red : .orange)
          .font(.caption)
        
        Text(budget.name)
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
        
        Spacer()
      }
      
      Text(budget.formattedSpent)
        .font(.callout)
        .fontWeight(.semibold)
        .foregroundColor(budget.isOverBudget ? .red : .orange)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(budget.isOverBudget ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(budget.isOverBudget ? Color.red.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
    )
  }
}
