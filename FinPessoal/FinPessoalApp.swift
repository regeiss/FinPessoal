//
//  FinPessoalApp.swift (Cross-Platform Enhanced)
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import SwiftUI
import FirebaseCore

// Imports condicionais para melhor organização
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@main
struct MoneyManagerApp: App {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  @StateObject private var themeManager = ThemeManager()
  
  init() {
    FirebaseApp.configure()
    configureAppearance()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(navigationState)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
        .onChange(of: themeManager.currentTheme) { _, newTheme in
          updateAppearance(for: newTheme)
        }
    }
    .applyPlatformSpecificModifiers()
    .commands {
      CrossPlatformCommands()
        .environmentObject(navigationState)
    }
  }
  
  private func configureAppearance() {
#if os(iOS)
    configureIOSAppearance()
#elseif os(macOS)
    configureMacOSAppearance()
#endif
  }
  
#if os(iOS)
  private func configureIOSAppearance() {
    // Configuração específica do iOS
    let navigationAppearance = UINavigationBarAppearance()
    navigationAppearance.configureWithOpaqueBackground()
    navigationAppearance.backgroundColor = UIColor.systemGroupedBackground
    navigationAppearance.shadowColor = .clear
    navigationAppearance.titleTextAttributes = [
      .foregroundColor: UIColor.label
    ]
    navigationAppearance.largeTitleTextAttributes = [
      .foregroundColor: UIColor.label
    ]
    
    UINavigationBar.appearance().standardAppearance = navigationAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
    UINavigationBar.appearance().compactAppearance = navigationAppearance
    
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = UIColor.systemGroupedBackground
    
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    
    // Configuração adicional para melhor UX
    UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel
    UITabBar.appearance().tintColor = UIColor.systemBlue
  }
#endif
  
#if os(macOS)
  private func configureMacOSAppearance() {
    // Configuração específica do macOS
    
    // Configurar NSApplication se necessário
    if let app = NSApplication.shared.delegate as? NSApplicationDelegate {
      // Configurações adicionais da aplicação
    }
    
    // Configurar aparência padrão
    NSApp.appearance = NSAppearance(named: .aqua)
    
    // Configurar preferências de janela
    UserDefaults.standard.register(defaults: [
      "NSQuitAlwaysKeepsWindows": false
    ])
  }
#endif
  
  private func updateAppearance(for theme: AppTheme) {
#if os(iOS)
    updateIOSAppearance(for: theme)
#elseif os(macOS)
    updateMacOSAppearance(for: theme)
#endif
  }
  
#if os(iOS)
  private func updateIOSAppearance(for theme: AppTheme) {
    DispatchQueue.main.async {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
      }
      
      for window in windowScene.windows {
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
          window.overrideUserInterfaceStyle = theme.uiUserInterfaceStyle
        }
      }
    }
  }
#endif
  
#if os(macOS)
  private func updateMacOSAppearance(for theme: AppTheme) {
    DispatchQueue.main.async {
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.3
        context.allowsImplicitAnimation = true
        
        for window in NSApplication.shared.windows {
          window.appearance = theme.nsAppearance
        }
      }
    }
  }
#endif
}

// MARK: - Platform-Specific Scene Modifiers

extension Scene {
  func applyPlatformSpecificModifiers() -> some Scene {
#if os(macOS)
    self
      .windowStyle(.titleBar)
      .windowToolbarStyle(.unified(showsTitle: true))
      .defaultSize(width: 1200, height: 800)
      .defaultPosition(.center)
#else
    self
#endif
  }
}

// MARK: - Cross-Platform Commands

struct CrossPlatformCommands: Commands {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some Commands {
#if os(macOS)
    // Menu principal
    CommandGroup(after: .newItem) {
      Button("Nova Transação") {
        // Ação para nova transação
        navigationState.navigate(to: .transactions)
      }
      .keyboardShortcut("n", modifiers: [.command, .shift])
      
      Button("Novo Orçamento") {
        // Ação para novo orçamento
        navigationState.navigate(to: .budgets)
      }
      .keyboardShortcut("b", modifiers: [.command, .shift])
      
      Divider()
      
      Button("Ir para Dashboard") {
        navigationState.navigate(to: .dashboard)
      }
      .keyboardShortcut("1", modifiers: [.command])
      
      Button("Ver Contas") {
        navigationState.navigate(to: .accounts)
      }
      .keyboardShortcut("2", modifiers: [.command])
      
      Button("Ver Transações") {
        navigationState.navigate(to: .transactions)
      }
      .keyboardShortcut("3", modifiers: [.command])
    }
    
    // Menu de visualização
    CommandGroup(after: .sidebar) {
      Button("Alternar Sidebar") {
        navigationState.columnVisibility =
        navigationState.columnVisibility == .all ? .detailOnly : .all
      }
      .keyboardShortcut("s", modifiers: [.command, .control])
    }
    
    // Menu de ajuda
    CommandGroup(replacing: .help) {
      Button("Ajuda do Money Manager") {
        // Ação de ajuda
        if let url = URL(string: "https://github.com/seu-usuario/finpessoal") {
          NSWorkspace.shared.open(url)
        }
      }
      
      Button("Reportar Bug") {
        // Ação para reportar bug
        if let url = URL(string: "https://github.com/seu-usuario/finpessoal/issues") {
          NSWorkspace.shared.open(url)
        }
      }
      
      Button("Sobre Money Manager") {
        // Mostrar informações sobre o app
      }
      .keyboardShortcut(",", modifiers: [.command])
    }
#endif
  }
}

// MARK: - Theme Extensions

extension AppTheme {
#if os(iOS)
  var uiUserInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .system: return .unspecified
    case .light: return .light
    case .dark: return .dark
    }
  }
#endif
  
#if os(macOS)
  var nsAppearance: NSAppearance? {
    switch self {
    case .system: return nil
    case .light: return NSAppearance(named: .aqua)
    case .dark: return NSAppearance(named: .darkAqua)
    }
  }
#endif
}

extension ColorScheme {
#if os(iOS)
  var uiUserInterfaceStyle: UIUserInterfaceStyle {
    switch self {
    case .light: return .light
    case .dark: return .dark
    @unknown default: return .unspecified
    }
  }
#endif
}
