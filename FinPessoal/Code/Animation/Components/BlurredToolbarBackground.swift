//
//  BlurredToolbarBackground.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-10.
//  Copyright © 2026 FinPessoal. All rights reserved.
//

import SwiftUI

// MARK: - Blurred Toolbar Background

/// Toolbar background with frosted glass effect
///
/// A reusable component that provides a frosted glass background for toolbars
/// and navigation bars. The effect adapts to the current animation mode,
/// falling back to a solid background in minimal mode.
///
/// ## Usage
/// ```swift
/// NavigationView {
///   ScrollView {
///     // content
///   }
///   .navigationTitle("Title")
///   .toolbar {
///     ToolbarItem(placement: .principal) {
///       BlurredToolbarBackground()
///     }
///   }
/// }
/// ```
///
/// ## Accessibility
/// - Respects Reduce Motion (solid background)
/// - Respects Reduce Transparency (more opaque)
/// - Purely decorative, doesn't affect VoiceOver
public struct BlurredToolbarBackground: View {
  let intensity: Double
  let tintColor: Color

  @State private var animationMode: AnimationMode = .full
  @Environment(\.colorScheme) private var colorScheme

  /// Creates a blurred toolbar background
  ///
  /// - Parameters:
  ///   - intensity: Blur intensity from 0.0 to 1.0 (default: 1.0)
  ///   - tintColor: Optional tint color overlay (default: Color.oldMoney.surface with opacity)
  public init(
    intensity: Double = 1.0,
    tintColor: Color? = nil
  ) {
    self.intensity = intensity
    self.tintColor = tintColor ?? Color.oldMoney.surface.opacity(0.1)
  }

  public var body: some View {
    ZStack {
      // Base color fallback for minimal mode
      if animationMode == .minimal {
        backgroundColor
          .opacity(0.95)
      } else {
        // Frosted glass effect
        Color.clear
          .frostedGlass(
            intensity: effectiveIntensity,
            tintColor: self.tintColor
          )
      }

      // Subtle divider line at bottom
      VStack {
        Spacer()
        Rectangle()
          .fill(dividerColor)
          .frame(height: 0.5)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
  }

  private var effectiveIntensity: Double {
    switch animationMode {
    case .full:
      return intensity
    case .reduced:
      return intensity * 0.7
    case .minimal:
      return 0.0
    }
  }

  private var backgroundColor: Color {
    Color.oldMoney.surface
  }

  private var dividerColor: Color {
    Color.oldMoney.divider.opacity(0.2)
  }
}

// MARK: - View Extension

extension View {
  /// Applies blurred toolbar background
  ///
  /// This modifier adds a frosted glass background to the toolbar with
  /// configurable intensity. The effect adapts to the current animation mode.
  ///
  /// ## Example
  /// ```swift
  /// NavigationView {
  ///   ScrollView {
  ///     // content
  ///   }
  ///   .navigationTitle("Title")
  ///   .blurredToolbar(intensity: 0.8)
  /// }
  /// ```
  ///
  /// - Parameter intensity: Blur intensity from 0.0 to 1.0 (default: 1.0)
  /// - Returns: A view with a blurred toolbar background
  public func blurredToolbar(intensity: Double = 1.0) -> some View {
    self.toolbar {
      ToolbarItem(placement: .principal) {
        BlurredToolbarBackground(intensity: intensity)
      }
    }
  }
}

// MARK: - Preview

#if DEBUG
struct BlurredToolbarBackground_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          ForEach(0..<20) { i in
            HStack {
              Circle()
                .fill(Color.oldMoney.accent)
                .frame(width: 40, height: 40)

              Text("Item \(i)")
                .font(.headline)
                .foregroundColor(Color.oldMoney.text)

              Spacer()
            }
            .padding()
            .background(Color.oldMoney.surface)
            .cornerRadius(12)
          }
        }
        .padding()
      }
      .background(Color.oldMoney.background)
      .navigationTitle("Blurred Toolbar")
      .blurredToolbar()
    }
    .previewDisplayName("Light Mode")

    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          ForEach(0..<20) { i in
            HStack {
              Circle()
                .fill(Color.oldMoney.accent)
                .frame(width: 40, height: 40)

              Text("Item \(i)")
                .font(.headline)
                .foregroundColor(Color.oldMoney.text)

              Spacer()
            }
            .padding()
            .background(Color.oldMoney.surface)
            .cornerRadius(12)
          }
        }
        .padding()
      }
      .background(Color.oldMoney.background)
      .navigationTitle("Blurred Toolbar")
      .blurredToolbar()
    }
    .preferredColorScheme(.dark)
    .previewDisplayName("Dark Mode")
  }
}
#endif
