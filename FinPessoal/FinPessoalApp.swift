//
//  FinPessoalApp.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import SwiftUI
import FirebaseCore

@main
struct MoneyManagerApp: App {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  @StateObject private var themeManager = ThemeManager()
  
  init() {
    FirebaseApp.configure()
    configureNavigationAppearance()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(navigationState)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .withDeepLinkHandling()
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
        .onChange(of: themeManager.currentTheme) { _, newTheme in
          updateAppearance(for: newTheme)
        }
    }
  }
  
  private func configureNavigationAppearance() {
    // Configuração global da navegação para evitar sobreposições
    let navigationAppearance = UINavigationBarAppearance()
    navigationAppearance.configureWithOpaqueBackground()
    navigationAppearance.backgroundColor = UIColor.systemGroupedBackground
    navigationAppearance.shadowColor = .clear
    
    UINavigationBar.appearance().standardAppearance = navigationAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
    UINavigationBar.appearance().compactAppearance = navigationAppearance
    
    // Configuração da tab bar
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = UIColor.systemGroupedBackground
    
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
  }
  
  private func updateAppearance(for theme: AppTheme) {
    DispatchQueue.main.async {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
      }
      
      for window in windowScene.windows {
        window.overrideUserInterfaceStyle = theme.colorScheme?.uiUserInterfaceStyle ?? .unspecified
      }
    }
  }
}

extension ColorScheme {
  var uiUserInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .light: return .light
    case .dark: return .dark
    @unknown default: return .unspecified
    }
  }
}
