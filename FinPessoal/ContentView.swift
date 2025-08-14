//
//  ContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var authViewModel: AuthenticationViewModel
  
  var body: some View {
    Group {
      if !appState.hasCompletedOnboarding {
        OnboardingView()
      } else if authViewModel.isAuthenticated {
        MainTabView()
      } else {
        AuthenticationView()
      }
    }
    .alert(item: $appState.errorToShow) { error in
      Alert(
        title: Text("error.title"),
        message: Text(error.errorDescription ?? ""),
        primaryButton: .default(Text("error.retry")) {
          // Retry logic
        },
        secondaryButton: .cancel()
      )
    }
  }
}
