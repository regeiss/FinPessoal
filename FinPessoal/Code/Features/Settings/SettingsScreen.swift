//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var onboardingManager: OnboardingManager
  @EnvironmentObject var themeManager: ThemeManager
  @State private var showingProfile = false
  @State private var showingThemeSettings = false
  @State private var showingCurrencySettings = false
  @State private var showingLanguageSettings = false
  @State private var showingHelp = false
  @State private var showingCategoryManagement = false
  
  private var currentThemeDescription: String {
    let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
    switch savedTheme {
    case "system":
      return String(localized: "theme.system", defaultValue: "Automático")
    case "light":
      return String(localized: "theme.light", defaultValue: "Claro")
    case "dark":
      return String(localized: "theme.dark", defaultValue: "Escuro")
    default:
      return String(localized: "theme.system", defaultValue: "Automático")
    }
  }
  
  private var currentCurrencyDescription: String {
    let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "BRL"
    return CurrencyHelper.supportedCurrencies.first { $0.code == savedCurrency }?.displayName ?? "Real Brasileiro"
  }
  
  private var currentLanguageDescription: String {
    let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "system"
    switch savedLanguage {
    case "system":
      return String(localized: "language.system", defaultValue: "Automático")
    case "pt-BR":
      return String(localized: "language.portuguese", defaultValue: "Português")
    case "en":
      return String(localized: "language.english", defaultValue: "English")
    default:
      return String(localized: "language.system", defaultValue: "Automático")
    }
  }
  
  var body: some View {
    NavigationView {
      List {
        Section(String(localized: "profile.title", defaultValue: "Perfil")) {
          if let user = authViewModel.currentUser {
            Button {
              showingProfile = true
            } label: {
              HStack {
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                } placeholder: {
                  Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                  Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                  Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
          }
        }
        
        Section(String(localized: "settings.appearance.section", defaultValue: "Aparência")) {
          // Theme settings row with current theme indicator
          Button {
            showingThemeSettings = true
          } label: {
            HStack {
              Image(systemName: "paintbrush")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text(String(localized: "settings.theme", defaultValue: "Tema"))
                .foregroundColor(.primary)
              
              Spacer()
              
              Text(currentThemeDescription)
                .font(.caption)
                .foregroundColor(.secondary)
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .buttonStyle(.plain)
          
          // Quick dark mode toggle (only show if not in system mode)
          if UserDefaults.standard.string(forKey: "selectedTheme") != "system" {
            HStack {
              Image(systemName: "moon.fill")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text(String(localized: "settings.dark.mode", defaultValue: "Modo Escuro"))
                .foregroundColor(.primary)
              
              Spacer()
              
              Toggle("", isOn: $themeManager.isDarkMode)
                .onChange(of: themeManager.isDarkMode) { _, newValue in
                  themeManager.setTheme(newValue ? .dark : .light)
                }
            }
          }
        }
        
        Section(String(localized: "settings.preferences.section")) {
          // Category management
          Button {
            print("🔧 Category management button tapped")
            showingCategoryManagement = true
          } label: {
            HStack {
              Image(systemName: "tag.circle")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text(String(localized: "settings.categories.title"))
                .foregroundColor(.primary)
              
              Spacer()
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .buttonStyle(.plain)
          
          SettingsRow(title: String(localized: "settings.notifications"), icon: "bell", action: {})
          
          // Currency settings row with current currency indicator
          Button {
            showingCurrencySettings = true
          } label: {
            HStack {
              Image(systemName: "dollarsign.circle")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text(String(localized: "settings.currency"))
                .foregroundColor(.primary)
              
              Spacer()
              
              Text(currentCurrencyDescription)
                .font(.caption)
                .foregroundColor(.secondary)
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .buttonStyle(.plain)
          
          // Language settings row with current language indicator
          Button {
            showingLanguageSettings = true
          } label: {
            HStack {
              Image(systemName: "globe")
                .foregroundColor(.blue)
                .frame(width: 24)
              
              Text(String(localized: "settings.language"))
                .foregroundColor(.primary)
              
              Spacer()
              
              Text(currentLanguageDescription)
                .font(.caption)
                .foregroundColor(.secondary)
              
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .buttonStyle(.plain)
        }
        
        Section(String(localized: "settings.data.section", defaultValue: "Dados")) {
          SettingsRow(title: String(localized: "profile.export.data", defaultValue: "Exportar Dados"), icon: "square.and.arrow.up", action: {})
          SettingsRow(title: String(localized: "settings.import.data", defaultValue: "Importar Dados"), icon: "square.and.arrow.down", action: {})
          SettingsRow(title: String(localized: "settings.backup", defaultValue: "Backup"), icon: "icloud", action: {})
        }
        
        Section(String(localized: "settings.support.section")) {
          SettingsRow(title: String(localized: "settings.help"), icon: "questionmark.circle", action: {
            showingHelp = true
          })
          SettingsRow(title: String(localized: "settings.contact"), icon: "envelope", action: {})
          SettingsRow(title: String(localized: "settings.rate.app"), icon: "star", action: {})
        }
        
        Section(String(localized: "settings.development.section", defaultValue: "Desenvolvimento")) {
          Button(String(localized: "settings.reset.onboarding", defaultValue: "Resetar Onboarding")) {
            onboardingManager.resetOnboarding()
          }
          .foregroundColor(.orange)
        }
        
        Section(String(localized: "settings.account.section")) {
          Button(String(localized: "settings.signout.button")) {
            Task {
              await authViewModel.signOut()
            }
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle(String(localized: "settings.title"))
      .sheet(isPresented: $showingProfile) {
        ProfileView()
          .environmentObject(authViewModel)
      }
      .sheet(isPresented: $showingThemeSettings) {
        ThemeSettingsView()
          .environmentObject(themeManager)
      }
      .sheet(isPresented: $showingCurrencySettings) {
        CurrencySettingsView()
      }
      .sheet(isPresented: $showingLanguageSettings) {
        LanguageSettingsView()
      }
      .sheet(isPresented: $showingHelp) {
        HelpScreen()
      }
      .sheet(isPresented: $showingCategoryManagement) {
        CategoryManagementView(transactionRepository: MockTransactionRepository())
          .environmentObject(authViewModel)
      }
    }
  }
}

struct SettingsRow: View {
  let title: String
  let icon: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(.blue)
          .frame(width: 24)
        
        Text(title)
          .foregroundColor(.primary)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Currency Models and Extensions
struct CurrencyInfo {
  let code: String
  let displayName: String
  let symbol: String
}

extension CurrencyHelper {
  static let supportedCurrencies: [CurrencyInfo] = [
    CurrencyInfo(code: "BRL", displayName: "Real Brasileiro", symbol: "R$"),
    CurrencyInfo(code: "USD", displayName: "US Dollar", symbol: "$"),
    CurrencyInfo(code: "EUR", displayName: "Euro", symbol: "€"),
    CurrencyInfo(code: "GBP", displayName: "British Pound", symbol: "£"),
    CurrencyInfo(code: "JPY", displayName: "Japanese Yen", symbol: "¥"),
    CurrencyInfo(code: "CAD", displayName: "Canadian Dollar", symbol: "C$"),
    CurrencyInfo(code: "AUD", displayName: "Australian Dollar", symbol: "A$"),
    CurrencyInfo(code: "CHF", displayName: "Swiss Franc", symbol: "CHF"),
    CurrencyInfo(code: "CNY", displayName: "Chinese Yuan", symbol: "¥"),
    CurrencyInfo(code: "MXN", displayName: "Mexican Peso", symbol: "$"),
    CurrencyInfo(code: "ARS", displayName: "Argentine Peso", symbol: "$")
  ]
  
  static func setCurrency(_ code: String) {
    UserDefaults.standard.set(code, forKey: "selectedCurrency")
  }
  
  static func getCurrentCurrency() -> CurrencyInfo {
    let savedCode = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "BRL"
    return supportedCurrencies.first { $0.code == savedCode } ?? supportedCurrencies[0]
  }
}

// MARK: - Currency Settings View
struct CurrencySettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedCurrency = CurrencyHelper.getCurrentCurrency().code
  
  var body: some View {
    NavigationView {
      List {
        Section(String(localized: "settings.currency.choose", defaultValue: "Escolha a moeda")) {
          ForEach(CurrencyHelper.supportedCurrencies, id: \.code) { currency in
            Button {
              selectedCurrency = currency.code
              CurrencyHelper.setCurrency(currency.code)
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text(currency.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                  
                  Text("\(currency.code) • \(currency.symbol)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedCurrency == currency.code {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.headline)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
        
        Section {
          Text(String(localized: "settings.currency.note", defaultValue: "A mudança de moeda será aplicada imediatamente em todo o aplicativo."))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .navigationTitle(String(localized: "settings.currency"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done", defaultValue: "Concluído")) {
            dismiss()
          }
        }
      }
    }
  }
}

// MARK: - Language Settings View
struct LanguageSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "system"
  
  private let languages = [
    (code: "system", name: String(localized: "language.system", defaultValue: "Automático"), flag: "🌍"),
    (code: "pt-BR", name: String(localized: "language.portuguese", defaultValue: "Português"), flag: "🇧🇷"),
    (code: "en", name: String(localized: "language.english", defaultValue: "English"), flag: "🇺🇸")
  ]
  
  var body: some View {
    NavigationView {
      List {
        Section(String(localized: "settings.language.choose", defaultValue: "Escolha o idioma")) {
          ForEach(languages, id: \.code) { language in
            Button {
              selectedLanguage = language.code
              UserDefaults.standard.set(language.code, forKey: "selectedLanguage")
              
              // Apply language change if not system
              if language.code != "system" {
                // Note: Full app restart may be required for complete language change
              }
            } label: {
              HStack {
                Text(language.flag)
                  .font(.title2)
                
                Text(language.name)
                  .font(.headline)
                  .foregroundColor(.primary)
                
                Spacer()
                
                if selectedLanguage == language.code {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.headline)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
        
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "settings.language.note", defaultValue: "Algumas mudanças de idioma podem exigir o reinício do aplicativo."))
              .font(.caption)
              .foregroundColor(.secondary)
            
            if selectedLanguage == "system" {
              Text(String(localized: "settings.language.system.note", defaultValue: "O idioma automático usa a configuração do sistema do seu dispositivo."))
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
      }
      .navigationTitle(String(localized: "settings.language"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done", defaultValue: "Concluído")) {
            dismiss()
          }
        }
      }
    }
  }
}
