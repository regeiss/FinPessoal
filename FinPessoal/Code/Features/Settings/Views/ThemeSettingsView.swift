//
//  ThemeSettingsView.swift
//  FinPessoal
//
//  Created by Claude Code on 02/09/25.
//

import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    enum ThemeOption: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var title: String {
            switch self {
            case .system:
                return String(localized: "theme.system", defaultValue: "Automático")
            case .light:
                return String(localized: "theme.light", defaultValue: "Claro")
            case .dark:
                return String(localized: "theme.dark", defaultValue: "Escuro")
            }
        }
        
        var icon: String {
            switch self {
            case .system:
                return "gear"
            case .light:
                return "sun.max"
            case .dark:
                return "moon"
            }
        }
    }
    
    @State private var selectedTheme: ThemeOption = .system
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ThemeOption.allCases, id: \.self) { theme in
                        ThemeOptionRow(
                            theme: theme,
                            isSelected: selectedTheme == theme
                        ) {
                            selectedTheme = theme
                            applyTheme(theme)
                        }
                    }
                } header: {
                    Text(String(localized: "theme.choose.title", defaultValue: "Escolha o tema do app"))
                } footer: {
                    Text(String(localized: "theme.choose.description", defaultValue: "O tema automático segue a configuração do sistema do seu dispositivo"))
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                        Text(String(localized: "theme.tip.title", defaultValue: "Dica"))
                            .font(.headline)
                    }
                    
                    Text(String(localized: "theme.tip.description", defaultValue: "O tema escuro pode ajudar a economizar bateria em dispositivos com tela OLED e proporciona melhor experiência em ambientes com pouca luz."))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(String(localized: "settings.theme", defaultValue: "Tema"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done", defaultValue: "Concluído")) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentTheme()
        }
    }
    
    private func loadCurrentTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
        selectedTheme = ThemeOption(rawValue: savedTheme) ?? .system
    }
    
    private func applyTheme(_ theme: ThemeOption) {
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
        
        switch theme {
        case .system:
            themeManager.isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            themeManager.isDarkMode = false
        case .dark:
            themeManager.isDarkMode = true
        }
        
        // Save the isDarkMode state as well for compatibility
        UserDefaults.standard.set(themeManager.isDarkMode, forKey: "isDarkMode")
        
        // Log theme change for analytics
        if !AppConfiguration.shared.useMockData {
            // Only log if not using mock data (to avoid Firebase calls in mock mode)
            // Note: ThemeManager.toggleDarkMode() handles analytics, but we're not using that method here
        }
    }
}

struct ThemeOptionRow: View {
    let theme: ThemeSettingsView.ThemeOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: theme.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(theme.title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.body.weight(.semibold))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager())
}