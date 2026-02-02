//
//  AnimatedCard.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-02.
//

import SwiftUI

/// Animated card with press states, shadows, and optional hero transitions
public struct AnimatedCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false

  public let content: Content
  public let onTap: (() -> Void)?
  public let heroID: String?

  public init(
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }

  public var body: some View {
    content
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .shadow(
        color: shadowColor,
        radius: shadowRadius,
        x: 0,
        y: isPressed ? 2 : 4
      )
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            guard !isPressed else { return }
            withAnimation(AnimationEngine.snappySpring) {
              isPressed = true
            }
            HapticEngine.shared.light()
          }
          .onEnded { _ in
            withAnimation(AnimationEngine.gentleSpring) {
              isPressed = false
            }
            onTap?()
          }
      )
      .if(heroID != nil) { view in
        view.matchedGeometryEffect(id: heroID!, in: namespace)
      }
  }

  @Namespace private var namespace

  private var shadowColor: Color {
    Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15)
  }

  private var shadowRadius: CGFloat {
    isPressed ? 8 : 12
  }
}

// Helper extension for conditional view modifiers
extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
