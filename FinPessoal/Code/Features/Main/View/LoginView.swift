//
//  LoginView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//

import SwiftUI
import AuthenticationServices

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
        .foregroundStyle(Color.oldMoney.accent)
        .accessibilityHidden(true)

      Text(String(localized: "app.name"))
        .font(OldMoneyTheme.Typography.largeTitle)
        .foregroundStyle(Color.oldMoney.text)
        .accessibilityAddTraits(.isHeader)

      Text(String(localized: "app.tagline"))
        .font(.subheadline)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .multilineTextAlignment(.center)
    }
  }
  
  private var loginForm: some View {
    VStack(spacing: 16) {
      StyledTextField(
        title: "Email Address",
        text: $email,
        placeholder: String(localized: "login.email.placeholder"),
        keyboardType: .emailAddress,
        autocapitalization: .never
      )

      StyledSecureField(
        title: "Password",
        text: $password,
        placeholder: String(localized: "login.password.placeholder")
      )

      Button(action: {
        Task {
          await authViewModel.signInWithEmail(email, password: password)
        }
      }) {
        Text(String(localized: "login.signin.button"))
          .foregroundStyle(Color.oldMoney.background)
          .fontWeight(.medium)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.oldMoney.accent)
          .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.small))
      }
      .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
      .accessibilityLabel("Sign In")
      .accessibilityHint("Sign in with your email and password")
      .accessibilityAddTraits(.isButton)
    }
  }
  
  private var socialLoginButtons: some View {
    VStack(spacing: 12) {
      Text(String(localized: "login.or.continue.with"))
        .font(.caption)
        .foregroundStyle(Color.oldMoney.textSecondary)

      VStack(spacing: 12) {
        // Google Sign-In Button
        Button(action: {
          Task {
            await authViewModel.signInWithGoogle()
          }
        }) {
          HStack {
            Image(systemName: "globe")
              .foregroundColor(.white)
              .accessibilityHidden(true)
            Text(String(localized: "login.continue.google"))
              .foregroundColor(.white)
              .fontWeight(.medium)
          }
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color(red: 0.26, green: 0.52, blue: 0.96))
          .cornerRadius(8)
        }
        .disabled(authViewModel.isLoading)
        .accessibilityLabel("Sign in with Google")
        .accessibilityHint("Continue using your Google account")

        // Apple Sign-In Button
        SignInWithAppleButton(
          onRequest: { request in
            // Configure the request here if needed
          },
          onCompletion: { result in
            Task {
              await authViewModel.signInWithApple()
            }
          }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(8)
        .disabled(authViewModel.isLoading)
        .accessibilityLabel("Sign in with Apple")
        .accessibilityHint("Continue using your Apple account")
      }
    }
  }
  
  private var errorSection: some View {
    Group {
      if authViewModel.isLoading {
        ProgressView(String(localized: "login.signing.in"))
          .progressViewStyle(CircularProgressViewStyle())
          .accessibilityLabel("Signing in, please wait")
      }

      if let errorMessage = authViewModel.errorMessage {
        Text(errorMessage)
          .foregroundStyle(Color.oldMoney.error)
          .font(.caption)
          .multilineTextAlignment(.center)
          .accessibilityLabel("Error: \(errorMessage)")
          .accessibilityAddTraits(.isStaticText)
      }
    }
  }
}
