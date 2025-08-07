//
//  CrossPlatformHelpers.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 06/08/25.
//

import SwiftUI
import Combine
#if os(iOS)
import UIKit
#endif

// MARK: - Platform Detection

struct PlatformInfo {
  static var isIOS: Bool {
#if os(iOS)
    return true
#else
    return false
#endif
  }
  
  static var isMacOS: Bool {
#if os(macOS)
    return true
#else
    return false
#endif
  }
  
  static var isIPad: Bool {
#if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .pad
#else
    return false
#endif
  }
  
  static var isCompact: Bool {
#if os(iOS)
    return UIScreen.main.bounds.width < 768
#else
    return false
#endif
  }
}

// MARK: - Navigation Coordinator

@MainActor
class NavigationCoordinator: ObservableObject {
  @Published var isShowingSheet = false
  @Published var isShowingAlert = false
  @Published var alertTitle = ""
  @Published var alertMessage = ""
  
  func presentSheet() {
    isShowingSheet = true
  }
  
  func dismissSheet() {
    isShowingSheet = false
  }
  
  func showAlert(title: String, message: String) {
    alertTitle = title
    alertMessage = message
    isShowingAlert = true
  }
  
  func dismissAlert() {
    isShowingAlert = false
  }
}

// MARK: - Cross-Platform Modifiers

struct CrossPlatformNavigationModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
#if os(iOS)
      .navigationBarTitleDisplayMode(.large)
#endif
      .toolbarBackground(
        Color(.systemBackground),
        for: .navigationBar
      )
      .toolbarBackground(.visible, for: .navigationBar)
  }
}

extension View {
  func crossPlatformNavigation() -> some View {
    modifier(CrossPlatformNavigationModifier())
  }
}

// MARK: - Cross-Platform Toolbar

struct CrossPlatformToolbarContent: ToolbarContent {
  let leadingAction: (() -> Void)?
  let trailingAction: (() -> Void)?
  let leadingTitle: String
  let trailingTitle: String
  
  init(
    leadingTitle: String = "Cancelar",
    trailingTitle: String = "Adicionar",
    leadingAction: (() -> Void)? = nil,
    trailingAction: (() -> Void)? = nil
  ) {
    self.leadingTitle = leadingTitle
    self.trailingTitle = trailingTitle
    self.leadingAction = leadingAction
    self.trailingAction = trailingAction
  }
  
  var body: some ToolbarContent {
#if os(iOS)
    if let action = leadingAction {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(leadingTitle, action: action)
      }
    }
    
    if let action = trailingAction {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(trailingTitle, action: action)
          .fontWeight(.semibold)
      }
    }
#else
    if let action = leadingAction {
      ToolbarItem(placement: .cancellationAction) {
        Button(leadingTitle, action: action)
      }
    }
    
    if let action = trailingAction {
      ToolbarItem(placement: .confirmationAction) {
        Button(trailingTitle, action: action)
          .fontWeight(.semibold)
      }
    }
#endif
  }
}

// MARK: - Responsive Layout Components

struct SafeContentContainer<Content: View>: View {
  let content: Content
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        LazyVStack(spacing: 0) {
          content
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .frame(maxWidth: maxContentWidth)
        }
        .frame(maxWidth: .infinity)
      }
      .background(Color(.systemGroupedBackground))
    }
  }
  
  private var horizontalPadding: CGFloat {
    if PlatformInfo.isIPad || PlatformInfo.isMacOS {
      return horizontalSizeClass == .regular ? 32 : 20
    } else {
      return 16
    }
  }
  
  private var topPadding: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 24 : 16
  }
  
  private var maxContentWidth: CGFloat {
    if PlatformInfo.isIPad || PlatformInfo.isMacOS {
      return horizontalSizeClass == .regular ? 1000 : 600
    } else {
      return .infinity
    }
  }
}

// MARK: - Responsive Card

struct ResponsiveCard<Content: View>: View {
  let content: Content
  @Environment(\.colorScheme) var colorScheme
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    VStack(spacing: 0) {
      content
    }
    .padding(PlatformInfo.isIPad || PlatformInfo.isMacOS ? 24 : 16)
    .background(
      RoundedRectangle(cornerRadius: PlatformInfo.isIPad || PlatformInfo.isMacOS ? 16 : 12)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(
          color: colorScheme == .dark ? .clear : .black.opacity(0.05),
          radius: PlatformInfo.isIPad || PlatformInfo.isMacOS ? 12 : 8,
          x: 0,
          y: PlatformInfo.isIPad || PlatformInfo.isMacOS ? 4 : 2
        )
    )
    .padding(.horizontal, 4)
    .padding(.vertical, 8)
  }
}

// MARK: - Responsive Grid

struct ResponsiveGrid<Content: View>: View {
  let content: Content
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
      content
    }
  }
  
  private var gridColumns: [GridItem] {
    let columnCount: Int
    
    if PlatformInfo.isIPad || PlatformInfo.isMacOS {
      columnCount = horizontalSizeClass == .regular ? 3 : 2
    } else {
      columnCount = 2
    }
    
    return Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)
  }
  
  private var gridSpacing: CGFloat {
    PlatformInfo.isIPad || PlatformInfo.isMacOS ? 20 : 16
  }
}

// MARK: - Safe Presentation

struct SafePresentationModifier: ViewModifier {
  func body(content: Content) -> some View {
    if PlatformInfo.isIPad || PlatformInfo.isMacOS {
      content
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
        .presentationBackground(.regularMaterial)
    } else {
      content
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(16)
    }
  }
}

extension View {
  func safePresentationStyle() -> some View {
    modifier(SafePresentationModifier())
  }
}

// MARK: - Responsive Theming

extension Color {
  static var income: Color { Color.green }
  static var expense: Color { Color.red }
  static var neutral: Color { Color.blue }
  
  static var adaptiveBackground: Color {
    Color(UIColor.systemBackground)
  }
  
  static var adaptiveSecondaryBackground: Color {
    Color(UIColor.secondarySystemBackground)
  }
  
  static var adaptiveTertiaryBackground: Color {
    Color(UIColor.tertiarySystemBackground)
  }
  
  static var adaptiveLabel: Color {
    Color(UIColor.label)
  }
  
  static var adaptiveSecondaryLabel: Color {
    Color(UIColor.secondaryLabel)
  }
  
  static var adaptiveTertiaryLabel: Color {
    Color(UIColor.tertiaryLabel)
  }
}

