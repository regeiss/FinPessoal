//
//  OnboardingPageView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct OnboardingPageView: View {
  let page: OnboardingPage
  
  var body: some View {
    VStack(spacing: 40) {
      Spacer()
      
      // Ícone animado com gradiente
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [page.color.opacity(0.1), page.color.opacity(0.05)]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 160, height: 160)
        
        Image(systemName: page.imageName)
          .font(.system(size: 80, weight: .light))
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(colors: [page.color, page.color.opacity(0.7)]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      }
      
      // Conteúdo de texto melhorado
      VStack(spacing: 20) {
        Text(page.title)
          .font(.system(size: 32, weight: .bold, design: .rounded))
          .multilineTextAlignment(.center)
          .foregroundStyle(
            LinearGradient(
              gradient: Gradient(colors: [.primary, .primary.opacity(0.8)]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .padding(.horizontal, 20)
        
        Text(page.description)
          .font(.title3)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .lineSpacing(4)
          .padding(.horizontal, 40)
      }
      
      Spacer()
      
      // Espaço reservado para os botões (eles estão no OnboardingScreen)
      Color.clear
        .frame(height: 180)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      LinearGradient(
        gradient: Gradient(colors: [
          Color(.systemBackground),
          page.color.opacity(0.02)
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }
}
