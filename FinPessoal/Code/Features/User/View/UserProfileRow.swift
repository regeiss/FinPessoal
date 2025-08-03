//
//  UserProfileRow.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct UserProfileRow: View {
  let user: User
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "person.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)
      
      VStack(spacing: 4) {
        Text(user.name)
          .font(.headline)
          .fontWeight(.medium)
        
        Text(user.email)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Button("Sair") {
        Task {
          await authViewModel.signOut()
        }
      }
      .buttonStyle(.bordered)
      .controlSize(.small)
    }
    .padding(.vertical, 16)
    .frame(maxWidth: .infinity)
  }
}
