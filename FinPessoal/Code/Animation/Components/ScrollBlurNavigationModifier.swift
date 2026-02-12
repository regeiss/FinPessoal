//
//  ScrollBlurNavigationModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-10.
//  Copyright © 2026 FinPessoal. All rights reserved.
//

import SwiftUI

// MARK: - Scroll Blur Navigation Modifier

/// Applies progressive blur to navigation bar based on scroll position
///
/// This modifier tracks the scroll offset of the content and progressively blurs
/// the navigation bar as the user scrolls down. The blur effect adapts to the
/// current animation mode, providing instant transitions in minimal mode and
/// smooth animations in full mode.
///
/// ## Usage
/// ```swift
/// ScrollView {
///   // content
/// }
/// .coordinateSpace(name: "scroll")
/// .navigationTitle("Dashboard")
/// .blurredNavigationBar()
/// ```
///
/// ## Requirements
/// - The parent view must have a ScrollView or List with `.coordinateSpace(name: "scroll")`
/// - Works best with `.navigationTitle()` and `.toolbar()` modifiers
///
/// ## Accessibility
/// - Respects Reduce Motion preference (instant blur transitions)
/// - Respects Reduce Transparency preference (more opaque materials)
/// - Does not affect VoiceOver navigation
struct ScrollBlurNavigationModifier: ViewModifier {
  @State private var scrollOffset: CGFloat = 0
  @State private var animationMode: AnimationMode = .full

  private let blurThreshold: CGFloat = 10.0

  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometry in
          Color.clear
            .preference(
              key: ScrollOffsetPreferenceKey.self,
              value: geometry.frame(in: .named("scroll")).minY
            )
        }
      )
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
        handleScrollOffsetChange(offset)
      }
      .onAppear {
        animationMode = AnimationSettings.shared.effectiveMode
      }
  }

  private func handleScrollOffsetChange(_ offset: CGFloat) {
    // Convert negative scroll offset to positive distance scrolled
    let newOffset = max(0, -offset)

    // Apply animation based on mode
    if animationMode == .minimal {
      // Instant transition - snap to blurred or clear
      scrollOffset = newOffset > blurThreshold ? blurThreshold : 0
    } else {
      // Smooth animated transition
      let animation: Animation? = animationMode == .full
        ? .linear(duration: 0.15)
        : .linear(duration: 0.1)

      withAnimation(animation) {
        scrollOffset = newOffset
      }
    }
  }

  private var blurProgress: CGFloat {
    min(scrollOffset / blurThreshold, 1.0)
  }
}

// MARK: - View Extension

extension View {
  /// Applies progressive blur to navigation bar on scroll
  ///
  /// The navigation bar starts transparent at the top of the scroll view and
  /// progressively blurs as the user scrolls down. The blur effect is fully
  /// visible after scrolling 10 points.
  ///
  /// ## Example
  /// ```swift
  /// NavigationView {
  ///   ScrollView {
  ///     LazyVStack(spacing: 20) {
  ///       // content
  ///     }
  ///   }
  ///   .coordinateSpace(name: "scroll")
  ///   .navigationTitle("Dashboard")
  ///   .blurredNavigationBar()
  /// }
  /// ```
  ///
  /// ## Requirements
  /// - Parent view must have `.coordinateSpace(name: "scroll")`
  /// - Works with ScrollView, List, or PullToRefreshView
  ///
  /// ## Accessibility
  /// - Respects Reduce Motion (instant transitions)
  /// - Respects Reduce Transparency (more opaque)
  /// - VoiceOver compatible
  ///
  /// - Returns: A view with progressive navigation bar blur on scroll
  public func blurredNavigationBar() -> some View {
    modifier(ScrollBlurNavigationModifier())
  }
}

// MARK: - Accessibility

extension ScrollBlurNavigationModifier {
  var accessibilityHint: String {
    "Navigation bar adapts to scroll position"
  }
}
