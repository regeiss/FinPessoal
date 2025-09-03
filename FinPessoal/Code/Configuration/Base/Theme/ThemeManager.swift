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
    
    private var cancellables = Set<AnyCancellable>()
    
    enum ThemeMode: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
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
    }
    
    private func loadThemePreference() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
        let themeMode = ThemeMode(rawValue: savedTheme) ?? .system
        
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
        
        if !AppConfiguration.shared.useMockData {
            Analytics.logEvent("theme_changed", parameters: ["dark_mode": isDarkMode])
        }
    }
}
