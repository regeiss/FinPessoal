//
//  NavigationCoordinator.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 05/08/25.
//

import SwiftUI
import Combine

@MainActor
class NavigationCoordinator: ObservableObject {
  @Published var isShowingSheet = false
  @Published var isShowingAlert = false
  @Published var alertTitle = ""
  @Published var alertMessage = ""
  
  private var cancellables = Set<AnyCancellable>()
  
  // Gerenciar navegação programática
  func navigate(to destination: NavigationDestination, in navigationState: NavigationState) {
    navigationState.selectedSidebarItem = destination.screen
    
    if let id = destination.id {
      navigationState.pushToPath(destination)
    }
  }
  
  // Apresentar sheets de forma coordenada
  func presentSheet() {
    isShowingSheet = true
  }
  
  func dismissSheet() {
    isShowingSheet = false
  }
  
  // Gerenciar alertas
  func showAlert(title: String, message: String) {
    alertTitle = title
    alertMessage = message
    isShowingAlert = true
  }
  
  func dismissAlert() {
    isShowingAlert = false
  }
}

// Modificador para aplicar configurações de navegação consistentes
struct NavigationConfigurationModifier: ViewModifier {
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .navigationBarTitleDisplayMode(.large)
      .toolbarBackground(
        Color(.systemGroupedBackground),
        for: .navigationBar
      )
      .toolbarBackground(.visible, for: .navigationBar)
      .background(Color(.systemGroupedBackground))
  }
}

extension View {
  func modernNavigationStyle() -> some View {
    modifier(NavigationConfigurationModifier())
  }
}

// Componente para handling de navegação profunda
struct DeepLinkHandler: ViewModifier {
  @EnvironmentObject var navigationState: NavigationState
  @StateObject private var coordinator = NavigationCoordinator()
  
  func body(content: Content) -> some View {
    content
      .environmentObject(coordinator)
      .onOpenURL { url in
        handleDeepLink(url)
      }
  }
  
  private func handleDeepLink(_ url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let scheme = components.scheme,
          scheme == "finpessoal" else { return }
    
    switch components.host {
    case "dashboard":
      navigationState.selectedSidebarItem = .dashboard
    case "accounts":
      navigationState.selectedSidebarItem = .accounts
    case "transactions":
      navigationState.selectedSidebarItem = .transactions
    case "budgets":
      navigationState.selectedSidebarItem = .budgets
    case "reports":
      navigationState.selectedSidebarItem = .reports
    case "settings":
      navigationState.selectedSidebarItem = .settings
    default:
      break
    }
  }
}

extension View {
  func withDeepLinkHandling() -> some View {
    modifier(DeepLinkHandler())
  }
}
