//
//  ContentView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()

  var body: some View {
    Group {
      if authViewModel.isAuthenticated {
        if UIDevice.current.userInterfaceIdiom == .pad {
          IPadMainView()
        } else {
          IPhoneMainView()
        } 
      } else {
        LoginView()
      }
    }
    .environmentObject(authViewModel)
    .environmentObject(financeViewModel)
    .environmentObject(navigationState)
  }
}
