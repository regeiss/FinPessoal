//
//  StyledTextEditor.swift
//  FinPessoal
//
//  Created by Claude Code on 06/02/26.
//

import SwiftUI

/// Styled multi-line text editor with inner shadow, focus animation, and error states
struct StyledTextEditor: View {
  // MARK: - Properties

  let title: String
  @Binding var text: String
  let placeholder: String
  let minHeight: CGFloat
  let error: String?

  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = AnimationSettings.shared.effectiveMode

  // MARK: - Initialization

  init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    minHeight: CGFloat = 100,
    error: String? = nil
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.minHeight = minHeight
    self.error = error
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      // Label
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      // Text editor with styled background
      ZStack(alignment: .topLeading) {
        // Placeholder
        if text.isEmpty {
          Text(placeholder)
            .foregroundColor(Color.oldMoney.textSecondary.opacity(0.5))
            .padding(12)
            .accessibilityHidden(true)
        }

        TextEditor(text: $text)
          .padding(12)
          .frame(minHeight: minHeight)
          .scrollContentBackground(.hidden)
          .focused($isFocused)
      }
      .background(
        ZStack {
          // Layered background
          RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)

          // Inner shadow overlay
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(
              LinearGradient(
                colors: [
                  Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                  Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
              ),
              lineWidth: 1
            )

          RoundedRectangle(cornerRadius: 8)
            .fill(
              LinearGradient(
                colors: [
                  Color.black.opacity(innerShadowIntensity),
                  Color.clear
                ],
                startPoint: .top,
                endPoint: .center
              )
            )
            .allowsHitTesting(false)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(borderColor, lineWidth: borderWidth)
      )
      .accessibilityLabel(title)
      .accessibilityValue(text.isEmpty ? "Empty" : text)
      .accessibilityHint(error.map { "Error: \($0). Multi-line text input" } ?? "Multi-line text input")
      .onChange(of: isFocused) { _, newValue in
        if newValue && animationMode == .full {
          HapticEngine.shared.light()
        }
      }

      // Error message
      if let error = error {
        Text(error)
          .font(.caption)
          .foregroundColor(Color.oldMoney.error)
          .accessibilityHidden(true)
      }
    }
    .animation(focusAnimation, value: isFocused)
    .animation(focusAnimation, value: error)
  }

  // MARK: - Computed Properties

  private var backgroundColor: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : Color.oldMoney.surface
  }

  private var borderColor: Color {
    if error != nil {
      return Color.oldMoney.error
    } else if isFocused {
      return Color.oldMoney.accent
    } else {
      return Color.clear
    }
  }

  private var borderWidth: CGFloat {
    (isFocused || error != nil) ? 2 : 0
  }

  private var innerShadowIntensity: Double {
    if error != nil {
      return 0.08
    } else if isFocused {
      return 0.04
    } else {
      return 0.06
    }
  }

  private var focusAnimation: Animation? {
    switch animationMode {
    case .full:
      return AnimationEngine.snappySpring
    case .reduced:
      return AnimationEngine.quickFade
    case .minimal:
      return nil
    }
  }
}

// MARK: - Preview

#Preview("StyledTextEditor - Light") {
  VStack(spacing: 20) {
    StyledTextEditor(
      title: "Notes",
      text: .constant(""),
      placeholder: "Enter your notes here..."
    )

    StyledTextEditor(
      title: "Description",
      text: .constant("This is a longer description that spans multiple lines. It shows how the text editor handles content."),
      placeholder: "Enter description",
      minHeight: 120
    )

    StyledTextEditor(
      title: "Comments",
      text: .constant(""),
      placeholder: "Add your comments",
      minHeight: 80,
      error: "Comments are required"
    )
  }
  .padding()
}

#Preview("StyledTextEditor - Dark") {
  VStack(spacing: 20) {
    StyledTextEditor(
      title: "Notes",
      text: .constant(""),
      placeholder: "Enter your notes here..."
    )

    StyledTextEditor(
      title: "Description",
      text: .constant("This is a longer description that spans multiple lines. It shows how the text editor handles content."),
      placeholder: "Enter description",
      minHeight: 120
    )

    StyledTextEditor(
      title: "Comments",
      text: .constant(""),
      placeholder: "Add your comments",
      minHeight: 80,
      error: "Comments are required"
    )
  }
  .padding()
  .preferredColorScheme(.dark)
}
