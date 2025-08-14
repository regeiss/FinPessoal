//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var themeManager: ThemeManager
  @EnvironmentObject var authViewModel: AuthenticationViewModel
  
  var body: some View {
    NavigationView {
      List {
        Section("settings.appearance") {
          HStack {
            Image(systemName: "moon.circle.fill")
              .foregroundColor(.purple)
            
            Text("settings.dark_mode")
            
            Spacer()
            
            Toggle("", isOn: $themeManager.isDarkMode)
              .onChange(of: themeManager.isDarkMode) { _ in
                themeManager.toggleDarkMode()
              }
          }
          .accessibilityElement(children: .combine)
        }
        
        Section("settings.account") {
          HStack {
            Image(systemName: "person.circle.fill")
              .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
              Text(authViewModel.currentUser?.name ?? "")
                .font(.headline)
              Text(authViewModel.currentUser?.email ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          
          Button(action: {
            authViewModel.signOut()
          }) {
            HStack {
              Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundColor(.red)
              Text("settings.sign_out")
                .foregroundColor(.red)
            }
          }
        }
      }
      .navigationTitle("settings.title")
    }
  }
}
