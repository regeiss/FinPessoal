//
//  AddAccountView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AddAccountView: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      VStack {
        Image(systemName: "creditcard.and.123")
          .font(.system(size: 60))
          .foregroundColor(.blue)
        
        Text(String(localized: "accounts.add.title"))
          .font(.title2)
          .fontWeight(.semibold)
        
        Text(String(localized: "accounts.add.coming.soon"))
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding()
      }
      .navigationTitle(String(localized: "accounts.new.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
      }
    }
  }
}
