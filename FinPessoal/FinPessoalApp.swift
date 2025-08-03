//
//  FinPessoalApp.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

@main
struct MoneyManagerApp: App {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  
  init() {
    FirebaseApp.configure()
    
    // Configurar persistência offline
    Database.database().isPersistenceEnabled = true
    
    // Configurar cache
    let settings = Database.database().reference().database.app?.options
    settings?.setCachePolicy(.cacheOnly)
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(navigationState)
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
    }
  }
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication
//      .LaunchOptionsKey: Any]? = nil
//  ) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}
//
//@main
//struct FinPessoalApp: App {
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//  var body: some Scene {
//    WindowGroup {
//      ContentView()
//    }
//  }
//}
