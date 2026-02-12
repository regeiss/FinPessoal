//
//  FrostedSheetModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-10.
//  Copyright © 2026 FinPessoal. All rights reserved.
//

import SwiftUI

// MARK: - Frosted Sheet Modifier (isPresented)

/// Applies frosted glass background to sheet presentations using a boolean binding
struct FrostedSheetModifier<SheetContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  let sheetContent: () -> SheetContent

  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $isPresented) {
        ZStack {
          // Frosted background layer
          Color.clear
            .frostedGlass(
              intensity: effectiveIntensity,
              tintColor: effectiveTintColor
            )
            .ignoresSafeArea()

          // Sheet content
          sheetContent()
        }
        .onAppear {
          animationMode = AnimationSettings.shared.effectiveMode
        }
      }
  }

  private var effectiveIntensity: Double {
    switch animationMode {
    case .full:
      return 1.0
    case .reduced:
      return 0.7
    case .minimal:
      return 0.0
    }
  }

  private var effectiveTintColor: Color? {
    guard animationMode != .minimal else { return nil }

    let opacity = animationMode == .full ? 0.05 : 0.02
    return Color.oldMoney.surface.opacity(opacity)
  }
}

// MARK: - Frosted Sheet Modifier (item)

/// Applies frosted glass background to sheet presentations using an item binding
struct FrostedSheetItemModifier<Item: Identifiable, SheetContent: View>: ViewModifier {
  @Binding var item: Item?
  let sheetContent: (Item) -> SheetContent

  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  func body(content: Content) -> some View {
    content
      .sheet(item: $item) { selectedItem in
        ZStack {
          // Frosted background layer
          Color.clear
            .frostedGlass(
              intensity: effectiveIntensity,
              tintColor: effectiveTintColor
            )
            .ignoresSafeArea()

          // Sheet content
          sheetContent(selectedItem)
        }
        .onAppear {
          animationMode = AnimationSettings.shared.effectiveMode
        }
      }
  }

  private var effectiveIntensity: Double {
    switch animationMode {
    case .full:
      return 1.0
    case .reduced:
      return 0.7
    case .minimal:
      return 0.0
    }
  }

  private var effectiveTintColor: Color? {
    guard animationMode != .minimal else { return nil }

    let opacity = animationMode == .full ? 0.05 : 0.02
    return Color.oldMoney.surface.opacity(opacity)
  }
}

// MARK: - View Extensions

extension View {
  /// Presents a sheet with frosted glass background
  ///
  /// This modifier wraps SwiftUI's native `.sheet()` presentation with a frosted glass
  /// background that adapts to the current animation mode. In full mode, it uses a
  /// translucent material with a warm tint. In minimal mode (or when Reduce Motion is
  /// enabled), it falls back to a solid background.
  ///
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet
  ///   - content: A closure returning the content of the sheet
  /// - Returns: A view that presents a sheet with frosted glass background when the binding is true
  ///
  /// ## Accessibility
  /// - Respects Reduce Motion preference (falls back to solid background)
  /// - Respects Reduce Transparency preference (uses more opaque material)
  /// - VoiceOver compatible (purely decorative, doesn't affect navigation)
  ///
  /// ## Example
  /// ```swift
  /// .frostedSheet(isPresented: $showingAddGoal) {
  ///   AddGoalScreen()
  ///     .environmentObject(viewModel)
  /// }
  /// ```
  public func frostedSheet<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    modifier(FrostedSheetModifier(
      isPresented: isPresented,
      sheetContent: content
    ))
  }

  /// Presents a sheet with frosted glass background using an optional item
  ///
  /// This modifier wraps SwiftUI's native `.sheet(item:)` presentation with a frosted glass
  /// background. Use this when you need to pass data to the sheet content.
  ///
  /// - Parameters:
  ///   - item: A binding to an optional identifiable item that determines whether to present the sheet
  ///   - content: A closure that takes the unwrapped item and returns the content of the sheet
  /// - Returns: A view that presents a sheet with frosted glass background when the item is non-nil
  ///
  /// ## Accessibility
  /// - Respects Reduce Motion preference (falls back to solid background)
  /// - Respects Reduce Transparency preference (uses more opaque material)
  /// - VoiceOver compatible (purely decorative, doesn't affect navigation)
  ///
  /// ## Example
  /// ```swift
  /// .frostedSheet(item: $selectedBudget) { budget in
  ///   BudgetDetailView(budget: budget)
  ///     .environmentObject(viewModel)
  /// }
  /// ```
  public func frostedSheet<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    modifier(FrostedSheetItemModifier(
      item: item,
      sheetContent: content
    ))
  }
}

// MARK: - Accessibility

extension FrostedSheetModifier {
  var accessibilityLabel: String {
    "Frosted sheet presentation"
  }
}

extension FrostedSheetItemModifier {
  var accessibilityLabel: String {
    "Frosted sheet presentation"
  }
}
