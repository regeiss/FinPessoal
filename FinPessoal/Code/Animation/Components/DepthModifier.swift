//
//  DepthModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 03/02/26.
//

import SwiftUI

// MARK: - Depth Levels

/// Elevation levels for consistent depth across the app
enum DepthLevel {
  case flat        // No shadow (0dp)
  case subtle      // Very subtle depth (2dp)
  case raised      // Slightly raised (4dp)
  case moderate    // Moderate elevation (8dp)
  case elevated    // Elevated cards (12dp)
  case floating    // Floating elements (16dp)
  case modal       // Modals and sheets (20dp)

  var shadowRadius: CGFloat {
    switch self {
    case .flat:      return 0
    case .subtle:    return 2
    case .raised:    return 4
    case .moderate:  return 8
    case .elevated:  return 12
    case .floating:  return 16
    case .modal:     return 20
    }
  }

  var shadowY: CGFloat {
    switch self {
    case .flat:      return 0
    case .subtle:    return 1
    case .raised:    return 2
    case .moderate:  return 4
    case .elevated:  return 6
    case .floating:  return 8
    case .modal:     return 10
    }
  }

  var shadowOpacity: Double {
    switch self {
    case .flat:      return 0.0
    case .subtle:    return 0.05
    case .raised:    return 0.08
    case .moderate:  return 0.12
    case .elevated:  return 0.16
    case .floating:  return 0.20
    case .modal:     return 0.24
    }
  }

  func shadowColor(for colorScheme: ColorScheme) -> Color {
    switch colorScheme {
    case .light:
      return Color.black.opacity(shadowOpacity)
    case .dark:
      return Color.black.opacity(shadowOpacity * 1.5)
    @unknown default:
      return Color.black.opacity(shadowOpacity)
    }
  }
}

// MARK: - Basic Depth Modifiers

/// View modifier that applies consistent depth/elevation
struct DepthModifier: ViewModifier {
  let level: DepthLevel
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .shadow(
        color: level.shadowColor(for: colorScheme),
        radius: level.shadowRadius,
        x: 0,
        y: level.shadowY
      )
  }
}

/// Layered shadow modifier for premium depth effect
struct LayeredDepthModifier: ViewModifier {
  let level: DepthLevel
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      // Close shadow (definition)
      .shadow(
        color: level.shadowColor(for: colorScheme).opacity(0.6),
        radius: level.shadowRadius * 0.5,
        x: 0,
        y: level.shadowY * 0.5
      )
      // Far shadow (ambient)
      .shadow(
        color: level.shadowColor(for: colorScheme).opacity(0.4),
        radius: level.shadowRadius * 1.5,
        x: 0,
        y: level.shadowY * 1.5
      )
  }
}

/// Premium depth card with layered shadows
struct DepthCardModifier: ViewModifier {
  let elevation: DepthLevel
  let cornerRadius: CGFloat

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(backgroundMaterial)
          .shadow(
            color: shadowColor.opacity(elevation.shadowOpacity),
            radius: elevation.shadowRadius,
            x: 0,
            y: elevation.shadowY
          )
          .shadow(
            color: shadowColor.opacity(elevation.shadowOpacity * 0.5),
            radius: elevation.shadowRadius * 0.5,
            x: 0,
            y: elevation.shadowY * 0.5
          )
      )
  }

  private var backgroundMaterial: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : .white
  }

  private var shadowColor: Color {
    colorScheme == .dark
      ? .black
      : Color(white: 0.2)
  }
}

// MARK: - Interactive Depth Modifiers

/// Interactive depth modifier for press states
struct InteractiveDepthModifier: ViewModifier {
  let normalLevel: DepthLevel
  let pressedLevel: DepthLevel
  @State private var isPressed = false
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .shadow(
        color: currentLevel.shadowColor(for: colorScheme),
        radius: currentLevel.shadowRadius,
        x: 0,
        y: currentLevel.shadowY
      )
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
      .simultaneousGesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            if !isPressed {
              isPressed = true
              HapticEngine.shared.light()
            }
          }
          .onEnded { _ in
            isPressed = false
          }
      )
  }

  private var currentLevel: DepthLevel {
    isPressed ? pressedLevel : normalLevel
  }
}

/// Pressed state depth effect
struct PressedDepthModifier: ViewModifier {
  let isPressed: Bool

  func body(content: Content) -> some View {
    content
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .brightness(isPressed ? -0.05 : 0)
      .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
  }
}

// MARK: - Surface Effect Modifiers

/// Frosted glass blur effect
struct FrostedGlassModifier: ViewModifier {
  let intensity: Double
  let tintColor: Color?

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          // Blur layer
          if #available(iOS 15.0, *) {
            Rectangle()
              .fill(.ultraThinMaterial)
          } else {
            Rectangle()
              .fill(fallbackColor)
          }

          // Tint overlay
          if let tint = tintColor {
            Rectangle()
              .fill(tint.opacity(intensity * 0.1))
          }
        }
      )
  }

  private var fallbackColor: Color {
    colorScheme == .dark
      ? Color(white: 0.2, opacity: 0.9)
      : Color(white: 1.0, opacity: 0.9)
  }
}

/// Inner shadow for recessed appearance
struct InnerShadowModifier: ViewModifier {
  let cornerRadius: CGFloat
  let intensity: Double

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
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
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                Color.black.opacity(intensity * 0.05),
                Color.clear
              ],
              startPoint: .top,
              endPoint: .center
            )
          )
          .allowsHitTesting(false)
      )
  }
}

/// Layered background with subtle gradients
struct LayeredBackgroundModifier: ViewModifier {
  let cornerRadius: CGFloat

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          // Base layer
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(baseColor)

          // Gradient overlay for depth
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
              LinearGradient(
                colors: [
                  Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1),
                  Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )

          // Subtle noise texture (simulated with grain)
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(white: 0.5, opacity: 0.02))
        }
      )
  }

  private var baseColor: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : .white
  }
}

// MARK: - View Extensions

extension View {
  /// Applies depth/elevation shadow to the view
  /// - Parameter level: The depth level to apply
  func depth(_ level: DepthLevel) -> some View {
    modifier(DepthModifier(level: level))
  }

  /// Applies layered depth effect (multiple shadows for richer depth)
  /// - Parameter level: Base depth level
  func layeredDepth(_ level: DepthLevel = .elevated) -> some View {
    modifier(LayeredDepthModifier(level: level))
  }

  /// Adds premium depth effect with layered shadows
  /// - Parameters:
  ///   - elevation: Depth level for the shadow
  ///   - cornerRadius: Corner radius for the card
  func depthCard(
    elevation: DepthLevel = .moderate,
    cornerRadius: CGFloat = 16
  ) -> some View {
    modifier(DepthCardModifier(elevation: elevation, cornerRadius: cornerRadius))
  }

  /// Applies card-style depth with rounded corners and background
  /// - Parameters:
  ///   - level: Depth level for the shadow
  ///   - cornerRadius: Corner radius for the card
  ///   - backgroundColor: Optional background color (defaults to surface color)
  func cardDepth(
    _ level: DepthLevel = .elevated,
    cornerRadius: CGFloat = 16,
    backgroundColor: Color? = nil
  ) -> some View {
    CardDepthWrapper(
      level: level,
      cornerRadius: cornerRadius,
      backgroundColor: backgroundColor,
      content: self
    )
  }

  /// Applies interactive depth with press state
  /// - Parameters:
  ///   - normal: Normal depth level
  ///   - pressed: Depth level when pressed (usually lower)
  func interactiveDepth(normal: DepthLevel = .elevated, pressed: DepthLevel = .raised) -> some View {
    modifier(InteractiveDepthModifier(normalLevel: normal, pressedLevel: pressed))
  }

  /// Adds pressed state depth effect
  /// - Parameter isPressed: Whether the view is currently pressed
  func pressedDepth(isPressed: Bool) -> some View {
    modifier(PressedDepthModifier(isPressed: isPressed))
  }

  /// Adds frosted glass blur effect
  /// - Parameters:
  ///   - intensity: Blur intensity (0.0 to 1.0)
  ///   - tintColor: Optional tint color overlay
  func frostedGlass(
    intensity: Double = 1.0,
    tintColor: Color? = nil
  ) -> some View {
    modifier(FrostedGlassModifier(intensity: intensity, tintColor: tintColor))
  }

  /// Adds inner shadow for recessed appearance
  /// - Parameters:
  ///   - cornerRadius: Corner radius matching the view
  ///   - intensity: Shadow intensity (0.0 to 1.0)
  func innerShadow(
    cornerRadius: CGFloat = 12,
    intensity: Double = 1.0
  ) -> some View {
    modifier(InnerShadowModifier(cornerRadius: cornerRadius, intensity: intensity))
  }

  /// Adds layered background with subtle gradients
  /// - Parameter cornerRadius: Corner radius for the background
  func layeredBackground(cornerRadius: CGFloat = 16) -> some View {
    modifier(LayeredBackgroundModifier(cornerRadius: cornerRadius))
  }
}

// Helper wrapper to access environment
private struct CardDepthWrapper<Content: View>: View {
  let level: DepthLevel
  let cornerRadius: CGFloat
  let backgroundColor: Color?
  let content: Content

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(backgroundColor ?? surfaceColor)
      )
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .depth(level)
  }

  private var surfaceColor: Color {
    Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
  }
}

// MARK: - Premium Components

/// Premium card component with layered background and depth
struct PremiumCard<Content: View>: View {
  let elevation: DepthLevel
  let cornerRadius: CGFloat
  let content: Content

  @State private var isPressed = false

  init(
    elevation: DepthLevel = .moderate,
    cornerRadius: CGFloat = 16,
    @ViewBuilder content: () -> Content
  ) {
    self.elevation = elevation
    self.cornerRadius = cornerRadius
    self.content = content()
  }

  var body: some View {
    content
      .layeredBackground(cornerRadius: cornerRadius)
      .depthCard(elevation: elevation, cornerRadius: cornerRadius)
      .pressedDepth(isPressed: isPressed)
      .onTapGesture { }
      .simultaneousGesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            if !isPressed {
              HapticEngine.shared.light()
              isPressed = true
            }
          }
          .onEnded { _ in
            isPressed = false
          }
      )
  }
}

/// Floating action button with depth and haptic feedback
struct FloatingActionButton: View {
  let icon: String
  let action: () -> Void

  @State private var isPressed = false
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: {
      HapticEngine.shared.medium()
      action()
    }) {
      Image(systemName: icon)
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .frame(width: 56, height: 56)
        .background(
          ZStack {
            Circle()
              .fill(
                LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.opacity(0.8)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )

            Circle()
              .fill(
                RadialGradient(
                  colors: [
                    Color.white.opacity(0.3),
                    Color.clear
                  ],
                  center: .topLeading,
                  startRadius: 0,
                  endRadius: 40
                )
              )
          }
        )
        .shadow(
          color: accentColor.opacity(0.4),
          radius: 12,
          x: 0,
          y: 6
        )
        .shadow(
          color: .black.opacity(0.2),
          radius: 8,
          x: 0,
          y: 4
        )
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Floating action button")
    .accessibilityHint("Double tap to activate")
    .pressedDepth(isPressed: isPressed)
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in isPressed = true }
        .onEnded { _ in isPressed = false }
    )
  }

  private var accentColor: Color {
    OldMoneyColors.Accent.antiqueGold
  }
}

// MARK: - Preview

#if DEBUG
struct DepthModifier_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      VStack(spacing: 30) {
        Text("Depth System")
          .font(.title)
          .fontWeight(.bold)

        // Depth levels
        VStack(alignment: .leading, spacing: 16) {
          Text("Depth Levels")
            .font(.headline)

          depthCard("Flat", level: .flat)
          depthCard("Subtle", level: .subtle)
          depthCard("Raised", level: .raised)
          depthCard("Moderate", level: .moderate)
          depthCard("Elevated", level: .elevated)
          depthCard("Floating", level: .floating)
          depthCard("Modal", level: .modal)
        }

        Divider()

        // Interactive depth
        Text("Interactive Depth")
          .font(.title2)
          .fontWeight(.bold)

        VStack(spacing: 8) {
          Text("Tap to interact")
            .font(.caption)
            .foregroundColor(.secondary)

          Text("Interactive Card")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.oldMoney.surface)
            .cornerRadius(12)
            .interactiveDepth()
        }

        Divider()

        // Premium card
        Text("Premium Card")
          .font(.title2)
          .fontWeight(.bold)

        PremiumCard(elevation: .elevated) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Premium Card")
              .font(.headline)
            Text("With layered background and depth")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .padding(20)
        }

        Divider()

        // Layered depth
        Text("Layered Depth")
          .font(.title2)
          .fontWeight(.bold)

        Text("Premium Effect")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.oldMoney.surface)
          .cornerRadius(12)
          .layeredDepth()

        Divider()

        // Frosted glass
        Text("Frosted Glass")
          .font(.title2)
          .fontWeight(.bold)

        ZStack {
          LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .frame(height: 200)
          .cornerRadius(16)

          VStack {
            Text("Frosted Glass")
              .font(.headline)
            Text("Blur background")
              .font(.subheadline)
          }
          .padding(20)
          .frostedGlass(intensity: 1.0)
          .cornerRadius(12)
        }

        Divider()

        // Inner shadow
        Text("Inner Shadow")
          .font(.title2)
          .fontWeight(.bold)

        VStack(spacing: 8) {
          Text("Recessed appearance")
            .font(.caption)
            .foregroundColor(.secondary)

          Text("Inner Shadow Effect")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color(light: OldMoneyColors.Light.warmGray, dark: OldMoneyColors.Dark.slate))
            )
            .innerShadow(cornerRadius: 12, intensity: 1.0)
        }

        Divider()

        // Layered background
        Text("Layered Background")
          .font(.title2)
          .fontWeight(.bold)

        VStack(spacing: 8) {
          Text("Subtle gradients and texture")
            .font(.caption)
            .foregroundColor(.secondary)

          Text("Layered Background")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .layeredBackground(cornerRadius: 12)
            .depth(.elevated)
        }

        Divider()

        // Pressed depth comparison
        Text("Pressed State")
          .font(.title2)
          .fontWeight(.bold)

        HStack(spacing: 16) {
          VStack {
            Text("Normal")
              .font(.caption)
              .foregroundColor(.secondary)
            Text("Card")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate))
              )
              .depth(.elevated)
              .pressedDepth(isPressed: false)
          }

          VStack {
            Text("Pressed")
              .font(.caption)
              .foregroundColor(.secondary)
            Text("Card")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate))
              )
              .depth(.raised)
              .pressedDepth(isPressed: true)
          }
        }

        Divider()

        // Floating action button
        Text("Floating Action Button")
          .font(.title2)
          .fontWeight(.bold)

        HStack {
          Spacer()
          FloatingActionButton(icon: "plus") {
            print("Tapped")
          }
        }
      }
      .padding()
    }
    .background(PreviewBackgroundColor())
  }

  static func depthCard(_ title: String, level: DepthLevel) -> some View {
    DepthCardPreview(title: title, level: level)
  }
}

private struct DepthCardPreview: View {
  let title: String
  let level: DepthLevel

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Text(title)
      .font(.headline)
      .padding()
      .frame(maxWidth: .infinity)
      .background(surfaceColor)
      .cornerRadius(12)
      .depth(level)
  }

  private var surfaceColor: Color {
    Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
  }
}

private struct PreviewBackgroundColor: View {
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Color(light: OldMoneyColors.Light.ivory, dark: OldMoneyColors.Dark.charcoal)
  }
}
#endif
