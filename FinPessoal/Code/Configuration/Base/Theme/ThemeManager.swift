//
//  ThemeManager.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine
import Firebase
import SwiftUI
import UIKit

class ThemeManager: ObservableObject {
    @Published var isDarkMode = false
    @Published var currentTheme: ThemeMode = .system
    
    private var cancellables = Set<AnyCancellable>()
    
    enum ThemeMode: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var displayName: String {
            switch self {
            case .system: return "Sistema"
            case .light: return "Claro"
            case .dark: return "Escuro"
            }
        }
    }
    
    var colorScheme: ColorScheme? {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
        let themeMode = ThemeMode(rawValue: savedTheme) ?? .system
        
        switch themeMode {
        case .system:
            return nil // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    init() {
        loadThemePreference()
        observeSystemThemeChanges()
        configureAppearance()
    }
    
    private func loadThemePreference() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
        let themeMode = ThemeMode(rawValue: savedTheme) ?? .system
        currentTheme = themeMode
        
        switch themeMode {
        case .system:
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        }
    }
    
    private func observeSystemThemeChanges() {
        // Listen for system theme changes when in system mode
        NotificationCenter.default.publisher(for: .init("UITraitCollectionDidChange"))
            .sink { [weak self] _ in
                let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
                if savedTheme == "system" {
                    self?.isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
                }
            }
            .store(in: &cancellables)
    }
    
    func setTheme(_ mode: ThemeMode) {
        currentTheme = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedTheme")
        
        switch mode {
        case .system:
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        }
        
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        
        // Apply the new theme appearance
        configureAppearance()
        
        // Log theme change for analytics (only if not using mock data)
        if !AppConfiguration.shared.useMockData {
            Analytics.logEvent("theme_changed", parameters: [
                "theme_mode": mode.rawValue,
                "is_dark_mode": isDarkMode
            ])
        }
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(isDarkMode ? "dark" : "light", forKey: "selectedTheme")
        currentTheme = isDarkMode ? .dark : .light
        
        configureAppearance()
        
        if !AppConfiguration.shared.useMockData {
            Analytics.logEvent("theme_changed", parameters: ["dark_mode": isDarkMode])
        }
    }
    
    private func configureAppearance() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light

                    // Apply color palette to window
                    if !self.isDarkMode {
                        window.tintColor = UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0) // Leather
                    }
                }
            }

            // Configure global text color appearances for light mode
            if !self.isDarkMode {
                // Set global label color
                UILabel.appearance().textColor = UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0) // Shark

                // Set global text field colors
                UITextField.appearance().textColor = UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0) // Shark

                // Set global text view colors
                UITextView.appearance().textColor = UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0) // Shark

                // Set global tint color (affects buttons, switches, etc.)
                UIView.appearance(whenContainedInInstancesOf: [UIWindow.self]).tintColor = UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0) // Leather

                // Set table view background
                UITableView.appearance().backgroundColor = UIColor.white

                // Set collection view background
                UICollectionView.appearance().backgroundColor = UIColor.white
            } else {
                // Reset to default dark mode colors
                UILabel.appearance().textColor = UIColor.label
                UITextField.appearance().textColor = UIColor.label
                UITextView.appearance().textColor = UIColor.label
            }

            let appearance = UINavigationBarAppearance()
            let tabBarAppearance = UITabBarAppearance()

            if self.isDarkMode {
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
                tabBarAppearance.selectionIndicatorTintColor = UIColor(red: 0.40, green: 0.86, blue: 0.18, alpha: 1.0)
            } else {
                // Light mode with custom color palette
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0)] // Shark
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0)] // Shark

                tabBarAppearance.configureWithOpaqueBackground()
                tabBarAppearance.backgroundColor = UIColor.white
                tabBarAppearance.selectionIndicatorTintColor = UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0) // Leather
            }

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = self.isDarkMode ? .white : UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0) // Leather for buttons

            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            UITabBar.appearance().tintColor = self.isDarkMode ? UIColor(red: 0.40, green: 0.86, blue: 0.18, alpha: 1.0) : UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0)
        }
    }
}
