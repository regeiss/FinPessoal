//
//  ResponsiveLayoutHelper.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 05/08/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Helpers para layout responsivo
#if canImport(UIKit)
struct DeviceInfo {
  static var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
  }
  
  static var isIPhone: Bool {
    UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
  }
  
  static var isCompact: Bool {
    UIScreen.main.bounds.width < 768
  }
}
#endif

#if !canImport(UIKit)
struct DeviceInfo {
  static var isIPad: Bool { false }
  static var isIPhone: Bool { false }
  static var isCompact: Bool { true }
}
#endif

// Modificador para aplicar estilos responsivos
struct ResponsiveModifier: ViewModifier {
  let phoneStyle: () -> AnyView
  let padStyle: () -> AnyView
  
  func body(content: Content) -> some View {
    if DeviceInfo.isIPad {
      content.overlay(padStyle())
    } else {
      content.overlay(phoneStyle())
    }
  }
}

extension View {
  func responsive<PhoneContent: View, PadContent: View>(
    phone: @escaping () -> PhoneContent,
    pad: @escaping () -> PadContent
  ) -> some View {
    modifier(ResponsiveModifier(
      phoneStyle: { AnyView(phone()) },
      padStyle: { AnyView(pad()) }
    ))
  }
}

// Container para conteúdo principal que evita sobreposições
struct SafeContentContainer<Content: View>: View {
  let content: Content
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  
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
    if DeviceInfo.isIPad {
      return horizontalSizeClass == .regular ? 32 : 20
    } else {
      return 16
    }
  }
  
  private var topPadding: CGFloat {
    DeviceInfo.isIPad ? 24 : 16
  }
  
  private var maxContentWidth: CGFloat {
    if DeviceInfo.isIPad {
      return horizontalSizeClass == .regular ? 1000 : 600
    } else {
      return .infinity
    }
  }
}

// Card container responsivo
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
    .padding(DeviceInfo.isIPad ? 24 : 16)
    .background(
      RoundedRectangle(cornerRadius: DeviceInfo.isIPad ? 16 : 12)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(
          color: colorScheme == .dark ? .clear : .black.opacity(0.05),
          radius: DeviceInfo.isIPad ? 12 : 8,
          x: 0,
          y: DeviceInfo.isIPad ? 4 : 2
        )
    )
    .padding(.horizontal, 4)
    .padding(.vertical, 8)
  }
}

// Grid responsivo
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
    
    if DeviceInfo.isIPad {
      columnCount = horizontalSizeClass == .regular ? 3 : 2
    } else {
      columnCount = 2
    }
    
    return Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)
  }
  
  private var gridSpacing: CGFloat {
    DeviceInfo.isIPad ? 20 : 16
  }
}

// Wrapper para toolbars responsivas
struct ResponsiveToolbar: ToolbarContent {
  let actions: [ToolbarAction]
  
  var body: some ToolbarContent {
    if DeviceInfo.isIPad {
      ToolbarItemGroup(placement: .primaryAction) {
        HStack(spacing: 12) {
          ForEach(actions.indices, id: \.self) { index in
            actions[index].button
          }
        }
      }
    } else {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        ForEach(actions.indices, id: \.self) { index in
          actions[index].button
        }
      }
    }
  }
}

struct ToolbarAction {
  let title: String
  let icon: String
  let action: () -> Void
  
  var button: some View {
    Button(action: action) {
      if DeviceInfo.isIPad {
        Label(title, systemImage: icon)
          .font(.body)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      } else {
        Image(systemName: icon)
          .font(.title3)
      }
    }
  }
}

// Modificador para evitar sobreposições em sheets e modais
struct SafePresentationModifier: ViewModifier {
  func body(content: Content) -> some View {
    if DeviceInfo.isIPad {
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

