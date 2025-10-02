//
//  ContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var onboardingManager: OnboardingManager
  @EnvironmentObject var themeManager: ThemeManager

  var body: some View {
    Group {
      if !onboardingManager.hasCompletedOnboarding {
        // Primeiro: Mostra o onboarding
        OnboardingScreen()
          .environmentObject(onboardingManager)
      } else if authViewModel.isAuthenticated {
        // Segundo: Se completou onboarding E está autenticado → Dashboard
        if UIDevice.current.userInterfaceIdiom == .pad {
          iPadMainView()
        } else {
          iPhoneMainView()
        }
      } else {
        // Terceiro: Se completou onboarding mas NÃO está autenticado → Login
        LoginView()
      }
    }
    .environmentObject(authViewModel)
    .environmentObject(financeViewModel)
    .environmentObject(navigationState)
    .preferredColorScheme(themeManager.colorScheme)
    .background(themeManager.isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .clear)
    .animation(
      .easeInOut(duration: 0.3),
      value: onboardingManager.hasCompletedOnboarding
    )
    .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
  }
}
