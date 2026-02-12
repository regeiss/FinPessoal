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
  @State private var showingProfile = false
  @State private var showingCurrencySettings = false
  @State private var showingLanguageSettings = false
  @State private var showingHelp = false
  @AppStorage("userAppearance") private var userAppearance: AppearanceMode = .system
  
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
              .depth(.subtle)
              .accessibilityHidden(true)

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
                .accessibilityHidden(true)
            }
            .padding(.vertical, 4)
          }
          .buttonStyle(.plain)
          .accessibilityElement(children: .combine)
          .accessibilityLabel(String(localized: "settings.profile.button.label", defaultValue: "Profile: \(user.name), \(user.email)"))
          .accessibilityHint(String(localized: "settings.profile.button.hint", defaultValue: "View and edit your profile"))
          .accessibilityAddTraits(.isButton)
        }
      }

      Section(String(localized: "settings.preferences.section")) {
          // Dark Mode Toggle
          HStack {
            Image(systemName: userAppearance.iconName)
              .foregroundColor(.blue)
              .frame(width: 24)
              .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
              Text(String(localized: "settings.appearance", defaultValue: "Aparência"))
                .foregroundColor(.primary)
              Text(userAppearance.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Picker("", selection: $userAppearance) {
              ForEach(AppearanceMode.allCases, id: \.self) { mode in
                Text(mode.displayName).tag(mode)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel(String(localized: "settings.appearance.label", defaultValue: "Appearance: \(userAppearance.displayName)"))
          .accessibilityHint(String(localized: "settings.appearance.hint", defaultValue: "Change the app's appearance"))

          SettingsRow(title: String(localized: "settings.notifications"), icon: "bell", action: {})

          // Currency settings row with current currency indicator
          Button {
            showingCurrencySettings = true
          } label: {
            HStack {
              Image(systemName: "dollarsign.circle")
                .foregroundColor(.blue)
                .frame(width: 24)
                .accessibilityHidden(true)

              Text(String(localized: "settings.currency"))
                .foregroundColor(.primary)

              Spacer()

              Text(currentCurrencyDescription)
                .font(.caption)
                .foregroundColor(.secondary)

              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            }
          }
          .buttonStyle(.plain)
          .accessibilityElement(children: .combine)
          .accessibilityLabel(String(localized: "settings.currency.label", defaultValue: "Currency: \(currentCurrencyDescription)"))
          .accessibilityHint(String(localized: "settings.currency.hint", defaultValue: "Change your preferred currency"))
          .accessibilityAddTraits(.isButton)

          // Language settings row with current language indicator
          Button {
            showingLanguageSettings = true
          } label: {
            HStack {
              Image(systemName: "globe")
                .foregroundColor(.blue)
                .frame(width: 24)
                .accessibilityHidden(true)

              Text(String(localized: "settings.language"))
                .foregroundColor(.primary)

              Spacer()

              Text(currentLanguageDescription)
                .font(.caption)
                .foregroundColor(.secondary)

              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            }
          }
          .buttonStyle(.plain)
          .accessibilityElement(children: .combine)
          .accessibilityLabel(String(localized: "settings.language.label", defaultValue: "Language: \(currentLanguageDescription)"))
          .accessibilityHint(String(localized: "settings.language.hint", defaultValue: "Change your preferred language"))
          .accessibilityAddTraits(.isButton)
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
          .accessibilityLabel(String(localized: "settings.reset.onboarding.label", defaultValue: "Reset onboarding"))
          .accessibilityHint(String(localized: "settings.reset.onboarding.hint", defaultValue: "Reset the app to show onboarding screens again"))
        }

        Section(String(localized: "settings.account.section")) {
          Button(String(localized: "settings.signout.button")) {
            Task {
              await authViewModel.signOut()
            }
          }
          .foregroundColor(.red)
          .accessibilityLabel(String(localized: "settings.signout.label", defaultValue: "Sign out"))
          .accessibilityHint(String(localized: "settings.signout.hint", defaultValue: "Sign out of your account"))
          .accessibilityAddTraits(.isButton)
        }
    }
    .preferredColorScheme(userAppearance.colorScheme)
    .frostedSheet(isPresented: $showingProfile) {
      ProfileView()
        .environmentObject(authViewModel)
    }
    .frostedSheet(isPresented: $showingCurrencySettings) {
      CurrencySettingsView()
        .preferredColorScheme(userAppearance.colorScheme)
    }
    .frostedSheet(isPresented: $showingLanguageSettings) {
      LanguageSettingsView()
        .preferredColorScheme(userAppearance.colorScheme)
    }
    .frostedSheet(isPresented: $showingHelp) {
      HelpScreen()
        .preferredColorScheme(userAppearance.colorScheme)
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
          .accessibilityHidden(true)

        Text(title)
          .foregroundColor(.primary)

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
          .accessibilityHidden(true)
      }
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(title)
    .accessibilityHint(String(localized: "settings.row.hint", defaultValue: "Open \(title)"))
    .accessibilityAddTraits(.isButton)
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
  @AppStorage("userAppearance") private var userAppearance: AppearanceMode = .system

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
                    .accessibilityHidden(true)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(currency.displayName), \(currency.code)")
            .accessibilityHint(String(localized: "settings.currency.select.hint", defaultValue: "Select \(currency.displayName) as your currency"))
            .accessibilityAddTraits(selectedCurrency == currency.code ? [.isButton, .isSelected] : .isButton)
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
  @AppStorage("userAppearance") private var userAppearance: AppearanceMode = .system

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
                  .accessibilityHidden(true)

                Text(language.name)
                  .font(.headline)
                  .foregroundColor(.primary)

                Spacer()

                if selectedLanguage == language.code {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.headline)
                    .accessibilityHidden(true)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(language.name)
            .accessibilityHint(String(localized: "settings.language.select.hint", defaultValue: "Select \(language.name) as your language"))
            .accessibilityAddTraits(selectedLanguage == language.code ? [.isButton, .isSelected] : .isButton)
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
