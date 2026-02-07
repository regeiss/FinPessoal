//
//  AuthScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct AuthView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var email = ""
  @State private var password = ""

  var body: some View {
    NavigationView {
      VStack(spacing: 30) {
        // Logo and title
        VStack(spacing: 16) {
          Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(Color.oldMoney.accent)
            .accessibilityHidden(true)

          Text("app.name")
            .font(.largeTitle)
            .fontWeight(.bold)
            .accessibilityAddTraits(.isHeader)
        }
        
        // Form
        VStack(spacing: 16) {
          StyledTextField(
            title: String(localized: "auth.email.label"),
            text: $email,
            placeholder: String(localized: "auth.email.placeholder"),
            keyboardType: .emailAddress,
            autocapitalization: .never
          )

          StyledSecureField(
            title: String(localized: "auth.password.label"),
            text: $password,
            placeholder: String(localized: "auth.password.placeholder")
          )
        }
        
        // Buttons
        VStack(spacing: 16) {
          Button(action: {
            Task {
              await authViewModel.signInWithEmail(email, password: password)
            }
          }) {
            if authViewModel.isLoading {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .accessibilityLabel("Signing in")
            } else {
              Text("auth.sign_in")
            }
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.oldMoney.accent)
          .foregroundStyle(Color.oldMoney.background)
          .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.medium))
          .disabled(authViewModel.isLoading)
          .accessibilityLabel("Sign In")
          .accessibilityHint("Sign in with your email and password")
          .accessibilityAddTraits(authViewModel.isLoading ? [] : .isButton)
          
          Divider()
          
          // Social login buttons
          VStack(spacing: 12) {
            Button(action: {
              Task {
                await authViewModel.signInWithApple()
              }
            }) {
              HStack {
                Image(systemName: "applelogo")
                  .accessibilityHidden(true)
                Text("auth.sign_in_apple")
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.black)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
            .accessibilityLabel("Sign in with Apple")
            .accessibilityHint("Continue using your Apple account")

            Button(action: {
              Task {
                await authViewModel.signInWithGoogle()
              }
            }) {
              HStack {
                Image(systemName: "globe")
                  .accessibilityHidden(true)
                Text("auth.sign_in_google")
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
            .accessibilityLabel("Sign in with Google")
            .accessibilityHint("Continue using your Google account")
          }
        }
        
        Spacer()
      }
      .padding()
      .navigationTitle("")
      .navigationBarHidden(true)
    }
    .alert("error.title", isPresented: $authViewModel.showError, actions: {
      Button("error.ok") {
        authViewModel.clearError()
      }
    }, message: {
      Text(authViewModel.errorMessage ?? "")
    })
  }
}

