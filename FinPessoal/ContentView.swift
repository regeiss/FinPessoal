//
//  ContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  @StateObject private var onboardingManager = OnboardingManager()

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
    .animation(
      .easeInOut(duration: 0.3),
      value: onboardingManager.hasCompletedOnboarding
    )
    .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
  }
}

//struct ContentView: View {
//  @EnvironmentObject var authViewModel: AuthViewModel
////  @EnvironmentObject var financeViewModel: FinanceViewModel
////  @EnvironmentObject var navigationState: NavigationState
//
//  var body: some View {
//    ZStack {
//      // Conteúdo principal
//      mainContent
//
//      // Overlay de desenvolvimento (apenas em modo mock)
//      if AppConfiguration.development.isEnabled {
//        developmentOverlay
//      }
//    }
//  }
//
//  @ViewBuilder
//  private var mainContent: some View {
//    Group {
//      if authViewModel.isAuthenticated {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//          iPadMainView()
//        } else {
//          iPhoneMainView()
//        }
//      } else {
//        LoginView()
//      }
//    }
//  }
//
//  @ViewBuilder
//  private var developmentOverlay: some View {
//    VStack {
//      Spacer()
//      HStack {
//        Spacer()
//
//        // Botão flutuante para ações de desenvolvimento
//        Menu {
//          developmentMenuItems
//        } label: {
//          Image(systemName: "hammer.fill")
//            .foregroundColor(.white)
//            .frame(width: 20, height: 20)
//        }
//        .frame(width: 50, height: 50)
//        .background(Color.orange)
//        .clipShape(Circle())
//        .shadow(radius: 4)
//        .padding(.trailing, 20)
//        .padding(.bottom, 100)
//      }
//    }
//  }
//
//  @ViewBuilder
//  private var developmentMenuItems: some View {
//    Button("Quick Login - Regular") {
//      Task {
//        await authViewModel.quickMockLogin(userType: .regular)
//      }
//    }
//
//    Button("Quick Login - Premium") {
//      Task {
//        await authViewModel.quickMockLogin(userType: .premium)
//      }
//    }
//
//    Button("Quick Login - New User") {
//      Task {
//        await authViewModel.quickMockLogin(userType: .newUser)
//      }
//    }
//
//    Divider()
//
//    Button("Force Logout") {
//      authViewModel.forceLogout()
//    }
//
//    Button("Simulate Network Error") {
//      authViewModel.simulateAuthError(.networkError)
//    }
//
//    Button("Simulate Invalid Credentials") {
//      authViewModel.simulateAuthError(.invalidCredentials)
//    }
//
//    Divider()
//
//    Button("Debug Info") {
//      print("=== Auth Debug Info ===")
//      print(authViewModel.debugInfo)
//      print("=====================")
//    }
//  }
//}
