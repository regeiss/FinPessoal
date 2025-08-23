//
//  LoginView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//

import SwiftUI

struct LoginView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var email = ""
  @State private var password = ""
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 32) {
          headerSection
          loginForm
          socialLoginButtons
          errorSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
      }
      .navigationTitle(String(localized: "login.title"))
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  private var headerSection: some View {
    VStack(spacing: 16) {
      Image(systemName: "dollarsign.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(.green)
      
      Text(String(localized: "app.name"))
        .font(.largeTitle)
        .fontWeight(.bold)
      
      Text(String(localized: "app.tagline"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
  }
  
  private var loginForm: some View {
    VStack(spacing: 16) {
      TextField(String(localized: "login.email.placeholder"), text: $email)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.emailAddress)
        .autocapitalization(.none)
      
      SecureField(String(localized: "login.password.placeholder"), text: $password)
        .textFieldStyle(.roundedBorder)
      
      Button(String(localized: "login.signin.button")) {
        Task {
          await authViewModel.signInWithEmail(email, password: password)
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
      .frame(maxWidth: .infinity)
    }
  }
  
  private var socialLoginButtons: some View {
    VStack(spacing: 12) {
      Text(String(localized: "login.or.continue.with"))
        .font(.caption)
        .foregroundColor(.secondary)
      
      VStack(spacing: 12) {
        Button(String(localized: "login.continue.google")) {
          Task {
            await authViewModel.signInWithGoogle()
          }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
        
        Button(String(localized: "login.continue.apple")) {
          Task {
            await authViewModel.signInWithApple()
          }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
      }
      .disabled(authViewModel.isLoading)
    }
  }
  
  private var errorSection: some View {
    Group {
      if authViewModel.isLoading {
        ProgressView(String(localized: "login.signing.in"))
          .progressViewStyle(CircularProgressViewStyle())
      }
      
      if let errorMessage = authViewModel.errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .font(.caption)
          .multilineTextAlignment(.center)
      }
    }
  }
}
