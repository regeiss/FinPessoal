//
//  ThemedComponents.swift
//  FinPessoal
//
//  Created by Claude on 30/09/25.
//

import SwiftUI

// MARK: - Themed Card View

struct ThemedCard<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  let content: Content
  let padding: EdgeInsets

  init(
    padding: EdgeInsets = EdgeInsets(
      top: 16,
      leading: 16,
      bottom: 16,
      trailing: 16
    ),
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.padding = padding
  }

  var body: some View {
    content
      .padding(padding)
      .background(AppTheme.cardBackground(colorScheme))
      .cornerRadius(12)
      .shadow(
        color: colorScheme == .dark
          ? Color.black.opacity(0.3) : Color.gray.opacity(0.2),
        radius: colorScheme == .dark ? 8 : 4,
        x: 0,
        y: colorScheme == .dark ? 4 : 2
      )
  }
}

// MARK: - Themed Button

struct ThemedButton: View {
  @Environment(\.colorScheme) var colorScheme
  let title: String
  let style: ButtonStyle
  let action: () -> Void

  enum ButtonStyle {
    case primary
    case secondary
    case accent
    case income
    case expense
    case transfer
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .foregroundColor(textColor)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
  }

  private var backgroundColor: Color {
    switch style {
    case .primary:
      return AppTheme.accentColor(colorScheme)
    case .secondary:
      return AppTheme.secondaryBackground(colorScheme)
    case .accent:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxPurple : AppTheme.LightColors.syntaxPurple
    case .income:
      return AppTheme.incomeColor(colorScheme)
    case .expense:
      return AppTheme.expenseColor(colorScheme)
    case .transfer:
      return AppTheme.transferColor(colorScheme)
    }
  }

  private var textColor: Color {
    switch style {
    case .secondary:
      return AppTheme.primaryText(colorScheme)
    default:
      return colorScheme == .dark ? Color.black : Color.white
    }
  }
}

// MARK: - Themed Text Field

struct ThemedTextField: View {
  @Environment(\.colorScheme) var colorScheme
  let title: String
  @Binding var text: String
  let placeholder: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(AppTheme.primaryText(colorScheme))

      TextField(placeholder, text: $text)
        .padding(12)
        .background(AppTheme.secondaryBackground(colorScheme))
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(AppTheme.borderColor(colorScheme), lineWidth: 1)
        )
        .foregroundColor(AppTheme.primaryText(colorScheme))
    }
  }
}

// MARK: - Themed Amount Display

struct ThemedAmountDisplay: View {
  @Environment(\.colorScheme) var colorScheme
  let amount: Double
  let type: TransactionType?
  let showSign: Bool
  let fontSize: Font

  init(
    amount: Double,
    type: TransactionType? = nil,
    showSign: Bool = true,
    fontSize: Font = .title2
  ) {
    self.amount = amount
    self.type = type
    self.showSign = showSign
    self.fontSize = fontSize
  }

  var body: some View {
    HStack(spacing: 4) {
      if showSign, let type = type {
        Text(type == .income ? "+" : type == .expense ? "-" : "")
          .font(fontSize)
          .fontWeight(.bold)
          .foregroundColor(type.syntaxColor(colorScheme))
      }

      Text(formattedAmount)
        .font(fontSize)
        .fontWeight(.bold)
        .foregroundColor(
          type?.syntaxColor(colorScheme) ?? AppTheme.primaryText(colorScheme)
        )
    }
  }

  private var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00"
  }
}

// MARK: - Themed Section Header

struct ThemedSectionHeader: View {
  @Environment(\.colorScheme) var colorScheme
  let title: String
  let subtitle: String?

  init(_ title: String, subtitle: String? = nil) {
    self.title = title
    self.subtitle = subtitle
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(
          colorScheme == .dark
            ? AppTheme.DarkColors.syntaxBlue : AppTheme.LightColors.syntaxBlue
        )

      if let subtitle = subtitle {
        Text(subtitle)
          .font(.caption)
          .foregroundColor(AppTheme.secondaryText(colorScheme))
      }
    }
  }
}

// MARK: - Themed Status Badge

struct ThemedStatusBadge: View {
  @Environment(\.colorScheme) var colorScheme
  let text: String
  let status: StatusType

  enum StatusType {
    case success
    case warning
    case error
    case info
    case income
    case expense
  }

  var body: some View {
    Text(text)
      .font(.caption)
      .fontWeight(.medium)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(backgroundColor)
      .foregroundColor(textColor)
      .cornerRadius(6)
  }

  private var backgroundColor: Color {
    switch status {
    case .success, .income:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxGreen.opacity(0.2)
        : AppTheme.LightColors.syntaxGreen.opacity(0.2)
    case .warning:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxYellow.opacity(0.2)
        : AppTheme.LightColors.syntaxYellow.opacity(0.2)
    case .error, .expense:
      return colorScheme == .dark
        ? AppTheme.DarkColors.expenseRed.opacity(0.2)
        : AppTheme.LightColors.expenseRed.opacity(0.2)
    case .info:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxBlue.opacity(0.2)
        : AppTheme.LightColors.syntaxBlue.opacity(0.2)
    }
  }

  private var textColor: Color {
    switch status {
    case .success, .income:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxGreen : AppTheme.LightColors.syntaxGreen
    case .warning:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxYellow : AppTheme.LightColors.syntaxYellow
    case .error, .expense:
      return colorScheme == .dark
        ? AppTheme.DarkColors.expenseRed : AppTheme.LightColors.expenseRed
    case .info:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxBlue : AppTheme.LightColors.syntaxBlue
    }
  }
}

// MARK: - Themed List Row

struct ThemedListRow<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme
  let content: Content
  let showSeparator: Bool

  init(showSeparator: Bool = true, @ViewBuilder content: () -> Content) {
    self.content = content()
    self.showSeparator = showSeparator
  }

  var body: some View {
    VStack(spacing: 0) {
      content
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground(colorScheme))

      if showSeparator {
        Divider()
          .background(AppTheme.separatorColor(colorScheme))
      }
    }
  }
}
