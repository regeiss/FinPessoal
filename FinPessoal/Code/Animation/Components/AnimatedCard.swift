//
//  AnimatedCard.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-02.
//

import SwiftUI

/// Visual style variants for AnimatedCard
public enum CardStyle {
  case standard   // Layered background + elevated depth (default)
  case premium    // Layered background + floating depth + accent glow
  case frosted    // Frosted glass + moderate depth
  case recessed   // Inner shadow + subtle depth

  var depthLevel: DepthLevel {
    switch self {
    case .standard:  return .elevated
    case .premium:   return .floating
    case .frosted:   return .moderate
    case .recessed:  return .subtle
    }
  }

  var usesLayeredBackground: Bool {
    switch self {
    case .standard, .premium:  return true
    case .frosted, .recessed:  return false
    }
  }

  var usesFrostedGlass: Bool {
    self == .frosted
  }

  var usesInnerShadow: Bool {
    self == .recessed
  }
}

/// Animated card with press states, shadows, and optional hero transitions
public struct AnimatedCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isPressed = false
  @State private var opacity: Double = 0  // For fade-in animation

  public let style: CardStyle
  public let cornerRadius: CGFloat
  public let content: Content
  public let onTap: (() -> Void)?
  public let heroID: String?

  public init(
    style: CardStyle = .standard,
    cornerRadius: CGFloat = 16,
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }

  // Keep old initializer for backward compatibility
  public init(
    heroID: String? = nil,
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.style = .standard
    self.cornerRadius = 16
    self.heroID = heroID
    self.onTap = onTap
    self.content = content()
  }

  public var body: some View {
    content
      .background(backgroundView)
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .shadow(
        color: shadowColor,
        radius: shadowRadius,
        x: 0,
        y: isPressed ? 2 : 4
      )
      .opacity(opacity)
      .onAppear {
        withAnimation(.easeInOut(duration: 0.2)) {
          opacity = 1.0
        }
      }
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

  @ViewBuilder
  private var backgroundView: some View {
    if style.usesLayeredBackground {
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(Color.clear)
        .layeredBackground(cornerRadius: cornerRadius)
    } else if style.usesFrostedGlass {
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(Color.clear)
        .frostedGlass(intensity: 1.0)
    } else if style.usesInnerShadow {
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(surfaceColor)
        .innerShadow(cornerRadius: cornerRadius, intensity: 1.0)
    } else {
      Color.clear
    }
  }

  private var surfaceColor: Color {
    Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
  }

  private var shadowColor: Color {
    Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15)
  }

  private var shadowRadius: CGFloat {
    let baseRadius = style.depthLevel.shadowRadius
    return isPressed ? baseRadius * 0.67 : baseRadius
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
