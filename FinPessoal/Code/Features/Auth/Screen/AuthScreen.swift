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
  @State private var name = ""
  @State private var isSignUp = false
  
  var body: some View {
    NavigationView {
      VStack(spacing: 30) {
        // Logo and title
        VStack(spacing: 16) {
          Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.blue)
            .accessibilityHidden(true)
          
          Text("app.name")
            .font(.largeTitle)
            .fontWeight(.bold)
        }
        
        // Form
        VStack(spacing: 16) {
          if isSignUp {
            TextField("auth.name.placeholder", text: $name)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .accessibilityLabel("auth.name.label")
          }
          
          TextField("auth.email.placeholder", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .accessibilityLabel("auth.email.label")
          
          SecureField("auth.password.placeholder", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .accessibilityLabel("auth.password.label")
        }
        
        // Buttons
        VStack(spacing: 16) {
          Button(action: {
            if isSignUp {
              authViewModel.signUp(name: name, email: email, password: password)
            } else {
              authViewModel.signInWithEmail(email: email, password: password)
            }
          }) {
            if authViewModel.isLoading {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Text(isSignUp ? "auth.sign_up" : "auth.sign_in")
            }
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(12)
          .disabled(authViewModel.isLoading)
          
          Divider()
          
          // Social login buttons
          VStack(spacing: 12) {
            Button(action: authViewModel.signInWithApple) {
              HStack {
                Image(systemName: "applelogo")
                Text("auth.sign_in_apple")
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.black)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
            
            Button(action: authViewModel.signInWithGoogle) {
              HStack {
                Image(systemName: "globe")
                Text("auth.sign_in_google")
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
          }
        }
        
        // Toggle sign up/sign in
        Button(action: {
          isSignUp.toggle()
        }) {
          Text(isSignUp ? "auth.have_account" : "auth.no_account")
            .foregroundColor(.blue)
        }
        
        Spacer()
      }
      .padding()
      .navigationTitle("")
      .navigationBarHidden(true)
    }
    .alert(item: $authViewModel.error) { error in
      Alert(
        title: Text("error.title"),
        message: Text(error.errorDescription ?? ""),
        dismissButton: .default(Text("error.ok"))
      )
    }
  }
}
