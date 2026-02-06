//
//  AnimatedCardModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-02.
//

import SwiftUI

/// View modifier for applying animated card behavior
public struct AnimatedCardModifier: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false
  @MainActor private let settings = AnimationSettings.shared

  public let onTap: (() -> Void)?

  public init(onTap: (() -> Void)? = nil) {
    self.onTap = onTap
  }

  public func body(content: Content) -> some View {
    content
      .scaleEffect(isPressed ? 0.98 : 1.0)
      // Close shadow (definition)
      .shadow(
        color: shadowColor.opacity(0.6),
        radius: closeShadowRadius,
        x: 0,
        y: isPressed ? 1 : 2
      )
      // Far shadow (ambient depth)
      .shadow(
        color: shadowColor.opacity(0.4),
        radius: shadowRadius,
        x: 0,
        y: isPressed ? 4 : 8
      )
      .gesture(pressGesture)
  }

  private var pressGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { _ in
        guard !isPressed, settings.effectiveMode != .minimal else { return }

        let animation = settings.effectiveMode == .full
          ? AnimationEngine.snappySpring
          : AnimationEngine.quickFade

        withAnimation(animation) {
          isPressed = true
        }
        HapticEngine.shared.light()
      }
      .onEnded { _ in
        let animation = settings.effectiveMode == .full
          ? AnimationEngine.gentleSpring
          : AnimationEngine.quickFade

        withAnimation(animation) {
          isPressed = false
        }
        onTap?()
      }
  }

  private var shadowColor: Color {
    Color.black.opacity(colorScheme == .dark ? 0.5 : 0.15)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 10 : 16
  }

  private var closeShadowRadius: CGFloat {
    isPressed ? 4 : 6
  }
}

extension View {
  /// Applies animated card behavior to any view
  public func animatedCard(onTap: (() -> Void)? = nil) -> some View {
    modifier(AnimatedCardModifier(onTap: onTap))
  }
}
