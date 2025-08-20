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
  @State private var showOnboarding = !UserDefaults.standard.hasShownOnboarding
  
  var body: some View {
    if showOnboarding {
      OnboardingScreen()
    } else {
      loginContent
    }
  }
  
  private var loginContent: some View {
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
      .navigationTitle("Entrar")
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  private var headerSection: some View {
    VStack(spacing: 16) {
      Image(systemName: "dollarsign.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(.green)
      
      Text("FinPessoal")
        .font(.largeTitle)
        .fontWeight(.bold)
      
      Text("Gerencie suas finanças de forma inteligente")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
  }
  
  private var loginForm: some View {
    VStack(spacing: 16) {
      TextField("Email", text: $email)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.emailAddress)
        .autocapitalization(.none)
        .textContentType(.emailAddress)
      
      SecureField("Senha", text: $password)
        .textFieldStyle(.roundedBorder)
        .textContentType(.password)
      
      Button("Entrar") {
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
      Text("ou continue com")
        .font(.caption)
        .foregroundColor(.secondary)
      
      VStack(spacing: 12) {
        Button("Continuar com Google") {
          Task {
            await authViewModel.signInWithGoogle()
          }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
        
        Button("Continuar com Apple") {
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
    VStack(spacing: 16) {
      if authViewModel.isLoading {
        ProgressView("Entrando...")
          .progressViewStyle(CircularProgressViewStyle())
      }
      
      if let errorMessage = authViewModel.errorMessage {
        VStack(spacing: 8) {
          Text(errorMessage)
            .foregroundColor(.red)
            .font(.caption)
            .multilineTextAlignment(.center)
          
          Button("OK") {
            authViewModel.clearError()
          }
          .buttonStyle(.bordered)
          .controlSize(.small)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
      }
    }
  }
}
