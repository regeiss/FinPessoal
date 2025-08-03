//
//  ReportsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct ReportsView: View {
  var body: some View {
    NavigationView {
      VStack {
        Image(systemName: "chart.bar.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
        
        Text("Relatórios")
          .font(.title)
          .fontWeight(.bold)
        
        Text("Em breve você terá acesso a relatórios detalhados sobre suas finanças")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding()
      }
      .navigationTitle("Relatórios")
    }
  }
}
