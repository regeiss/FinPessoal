//
//  LoginScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct LoginView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var email = ""
  @State private var password = ""
  @State private var showOnboarding = true
  
  var body: some View {
    if showOnboarding {
      OnboardingScreen(showOnboarding: $showOnboarding)
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
      
      Text("Money Manager")
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
      
      SecureField("Senha", text: $password)
        .textFieldStyle(.roundedBorder)
      
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
        GoogleSignInButton(isLoading: authViewModel.isLoading) {
          Task {
            await authViewModel.signInWithGoogle()
          }
        }
        .frame(maxWidth: .infinity)
        
        AppleSignInButton(isLoading: authViewModel.isLoading) {
          Task {
            await authViewModel.signInWithApple()
          }
        }
        .frame(maxWidth: .infinity)
      }
      .disabled(authViewModel.isLoading)
    }
  }
  
  private var errorSection: some View {
    Group {
      if authViewModel.isLoading {
        ProgressView("Entrando...")
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

private struct GoogleSignInButton: View {
  let isLoading: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        // If "google.logo" exists in SF Symbols, use it:
        // Image(systemName: "google.logo")
        // else use image from assets named "google_logo"
        Image("google_logo")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
        Text(isLoading ? "" : "Continuar com Google")
          .foregroundColor(.black)
          .fontWeight(.medium)
        if isLoading {
          Spacer()
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
        }
      }
      .padding(.horizontal)
      .frame(height: 44)
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color(red: 224/255, green: 224/255, blue: 224/255), lineWidth: 1)
      )
      .cornerRadius(8)
    }
    .disabled(isLoading)
  }
}

private struct AppleSignInButton: View {
  let isLoading: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: "apple.logo")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(.white)
        if isLoading {
          Spacer()
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text("Continuar com Apple")
            .foregroundColor(.white)
            .fontWeight(.medium)
        }
      }
      .padding(.horizontal)
      .frame(height: 44)
      .frame(maxWidth: .infinity)
      .background(Color.black)
      .cornerRadius(8)
    }
    .disabled(isLoading)
  }
}
