//
//  InteractiveListRow.swift
//  FinPessoal
//
//  Created by Claude Code on 07/02/26.
//

import SwiftUI

/// Interactive list row with pressed depth, swipe actions, loading state, and dividers
public struct InteractiveListRow<Content: View>: View {
  // MARK: - State
  @State private var isPressed = false
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  // MARK: - Properties
  private let content: Content
  private let onTap: (() -> Void)?
  private let leadingActions: [RowAction]
  private let trailingActions: [RowAction]
  private let isLoading: Bool
  private let showDivider: Bool
  private let backgroundColor: Color?

  // MARK: - Initialization

  public init(
    isLoading: Bool = false,
    showDivider: Bool = true,
    backgroundColor: Color? = nil,
    onTap: (() -> Void)? = nil,
    leadingActions: [RowAction] = [],
    trailingActions: [RowAction] = [],
    @ViewBuilder content: () -> Content
  ) {
    self.isLoading = isLoading
    self.showDivider = showDivider
    self.backgroundColor = backgroundColor
    self.onTap = onTap
    self.leadingActions = leadingActions
    self.trailingActions = trailingActions
    self.content = content()
  }

  // MARK: - Body

  public var body: some View {
    Group {
      if isLoading {
        RowShimmerView()
      } else {
        content
          .background(backgroundView)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .scaleEffect(isPressed ? 0.98 : 1.0)
          .brightness(isPressed ? -0.03 : 0)
          .opacity(isPressed ? 0.97 : 1.0)
          .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
          .animation(pressAnimation, value: isPressed)
          .gesture(tapGesture)
      }
    }
    .overlay(alignment: .bottom) {
      if showDivider {
        dividerView
      }
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      ForEach(leadingActions) { action in
        swipeButton(for: action)
      }
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
      ForEach(trailingActions) { action in
        swipeButton(for: action)
      }
    }
    .accessibilityAddTraits(.isButton)
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
  }

  // MARK: - Computed Properties

  private var backgroundView: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(backgroundColor ?? Color.oldMoney.surface)
  }

  private var shadowColor: Color {
    let opacity = isPressed
      ? (colorScheme == .dark ? 0.05 : 0.03)
      : (colorScheme == .dark ? 0.08 : 0.05)
    return Color.black.opacity(opacity)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 1 : 2
  }

  private var shadowY: CGFloat {
    isPressed ? 0.5 : 1
  }

  private var pressAnimation: Animation? {
    switch animationMode {
    case .full:
      return isPressed ? AnimationEngine.snappySpring : AnimationEngine.gentleSpring
    case .reduced:
      return .easeInOut(duration: 0.2)
    case .minimal:
      return nil
    }
  }

  private var tapGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        guard !isPressed else { return }
        isPressed = true
        if animationMode == .full {
          HapticEngine.shared.light()
        }
      }
      .onEnded { _ in
        isPressed = false
        onTap?()
      }
  }

  private var dividerView: some View {
    Rectangle()
      .fill(dividerColor)
      .frame(height: 1)
      .padding(.leading, 16)
  }

  private var dividerColor: Color {
    Color.oldMoney.divider.opacity(0.3)
  }

  private func swipeButton(for action: RowAction) -> some View {
    Button(role: action.role) {
      Task { await action.action() }
    } label: {
      Label(action.title, systemImage: action.icon)
    }
    .tint(action.tint)
  }
}

// MARK: - Shimmer Loading View

private struct RowShimmerView: View {
  @State private var offset: CGFloat = -300
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  var body: some View {
    HStack(spacing: 16) {
      // Icon placeholder
      Circle()
        .fill(shimmerBase)
        .frame(width: 40, height: 40)
        .overlay(shimmerGradient)

      // Content placeholders
      VStack(alignment: .leading, spacing: 8) {
        RoundedRectangle(cornerRadius: 4)
          .fill(shimmerBase)
          .frame(height: 16)
          .frame(maxWidth: .infinity)

        RoundedRectangle(cornerRadius: 4)
          .fill(shimmerBase)
          .frame(width: 100, height: 12)
      }

      // Value placeholder
      RoundedRectangle(cornerRadius: 4)
        .fill(shimmerBase)
        .frame(width: 60, height: 20)
    }
    .padding()
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
      if animationMode == .full {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
          offset = 300
        }
      } else if animationMode == .reduced {
        // Pulse animation for reduced mode
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
          offset = 100
        }
      }
    }
  }

  private var shimmerBase: Color {
    Color.oldMoney.divider.opacity(0.2)
  }

  @ViewBuilder
  private var shimmerGradient: some View {
    if animationMode == .full {
      LinearGradient(
        colors: [
          Color.clear,
          Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
          Color.clear
        ],
        startPoint: .leading,
        endPoint: .trailing
      )
      .offset(x: offset)
      .mask(RoundedRectangle(cornerRadius: 4))
    } else if animationMode == .reduced {
      shimmerBase.opacity(abs(offset) / 100.0)
    }
  }
}

// MARK: - Preview

#Preview("InteractiveListRow - Normal") {
  List {
    InteractiveListRow(
      onTap: { print("Tapped") },
      leadingActions: [.edit { print("Edit") }],
      trailingActions: [.delete { print("Delete") }]
    ) {
      HStack {
        Image(systemName: "dollarsign.circle.fill")
          .font(.title2)
          .foregroundStyle(Color.oldMoney.income)

        VStack(alignment: .leading) {
          Text("Sample Transaction")
            .font(.headline)
          Text("Category • Date")
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
        }

        Spacer()

        Text("R$ 1.234,56")
          .font(.headline)
      }
      .padding()
    }
  }
  .listStyle(.plain)
}

#Preview("InteractiveListRow - Loading") {
  List {
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
    InteractiveListRow(isLoading: true) {
      EmptyView()
    }
  }
  .listStyle(.plain)
}
