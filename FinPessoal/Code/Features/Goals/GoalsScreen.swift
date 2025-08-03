//
//  GoalsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct GoalsScreen: View {
  var body: some View {
    VStack {
      Image(systemName: "target")
        .font(.system(size: 60))
        .foregroundColor(.orange)
      
      Text("Metas")
        .font(.title)
        .fontWeight(.bold)
      
      Text("Defina e acompanhe suas metas financeiras")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding()
    }
    .navigationTitle("Metas")
  }
}

