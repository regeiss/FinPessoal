//
//  ParallaxScrollView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Enhanced ScrollView with layered parallax effects
public struct ParallaxScrollView<Background: View, Content: View>: View {

  // MARK: - Configuration

  /// Background layer speed (0.0-1.0, default 0.5 = 50% of scroll)
  private let backgroundSpeed: CGFloat

  /// Foreground layer speed (default 1.0 = normal scroll)
  private let foregroundSpeed: CGFloat

  /// Background view
  private let background: Background

  /// Content view
  private let content: Content

  // MARK: - State

  /// Current scroll offset
  @State private var scrollOffset: CGFloat = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a parallax scroll view
  /// - Parameters:
  ///   - backgroundSpeed: Background movement speed (default: 0.5)
  ///   - foregroundSpeed: Foreground movement speed (default: 1.0)
  ///   - background: Background view builder
  ///   - content: Content view builder
  public init(
    backgroundSpeed: CGFloat = 0.5,
    foregroundSpeed: CGFloat = 1.0,
    @ViewBuilder background: () -> Background,
    @ViewBuilder content: () -> Content
  ) {
    self.backgroundSpeed = backgroundSpeed
    self.foregroundSpeed = foregroundSpeed
    self.background = background()
    self.content = content()
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      // Background layer with parallax
      if !reduceMotion {
        background
          .offset(y: scrollOffset * (1 - backgroundSpeed))
      } else {
        background
      }

      // Scrollable content
      ScrollView {
        content
          .background(
            GeometryReader { geometry in
              Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: geometry.frame(in: .named("scroll")).minY
              )
            }
          )
      }
      .coordinateSpace(name: "scroll")
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
        scrollOffset = value
      }
    }
  }
}
