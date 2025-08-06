//
//  OnboardingScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct OnboardingScreen: View {
  @Binding var showOnboarding: Bool
  @State private var currentPage = 0
  
  private let pages = [
    OnboardingPage(
      title: "Bem-vindo ao Money Manager",
      description: "Gerencie suas finanças pessoais de forma simples e inteligente",
      imageName: "dollarsign.circle.fill",
      color: .green
    ),
    OnboardingPage(
      title: "Controle suas Contas",
      description: "Organize todas as suas contas bancárias e cartões em um só lugar",
      imageName: "creditcard.fill",
      color: .blue
    ),
    OnboardingPage(
      title: "Acompanhe Gastos",
      description: "Monitore suas transações e categorize seus gastos automaticamente",
      imageName: "chart.bar.fill",
      color: .orange
    ),
    OnboardingPage(
      title: "Relatórios Detalhados",
      description: "Visualize relatórios completos sobre sua situação financeira",
      imageName: "chart.line.uptrend.xyaxis",
      color: .purple
    )
  ]
  
  var body: some View {
    VStack(spacing: 0) {
      TabView(selection: $currentPage) {
        ForEach(0..<pages.count, id: \.self) { index in
          OnboardingPageView(page: pages[index])
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .indexViewStyle(.page(backgroundDisplayMode: .always))
      
      // Área dos botões com mais espaço
      VStack(spacing: 20) {
        if currentPage == pages.count - 1 {
          // Botão "Começar" - maior e mais destacado
          Button("Começar") {
            showOnboarding = false
          }
          .font(.title2)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            LinearGradient(
              gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .foregroundColor(.white)
          .cornerRadius(16)
          .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
          .padding(.horizontal, 24)
          
        } else {
          // Botão "Próximo" - grande e atrativo
          Button("Próximo") {
            withAnimation(.easeInOut(duration: 0.5)) {
              currentPage += 1
            }
          }
          .font(.title3)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(pages[currentPage].color)
          .foregroundColor(.white)
          .cornerRadius(14)
          .shadow(color: pages[currentPage].color.opacity(0.3), radius: 6, x: 0, y: 3)
          .padding(.horizontal, 24)
        }
        
        // Botão "Pular" - maior mas secundário
        Button("Pular") {
          showOnboarding = false
        }
        .font(.callout)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color(.systemGray6))
        .foregroundColor(.secondary)
        .cornerRadius(12)
        .padding(.horizontal, 24)
        
        // Indicador de progresso personalizado
        HStack(spacing: 8) {
          ForEach(0..<pages.count, id: \.self) { index in
            Circle()
              .fill(index == currentPage ? pages[currentPage].color : Color(.systemGray4))
              .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
              .animation(.easeInOut(duration: 0.3), value: currentPage)
          }
        }
        .padding(.top, 8)
      }
      .padding(.bottom, 50)
      .padding(.top, 30)
      .background(
        LinearGradient(
          gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
    }
    .ignoresSafeArea(.all, edges: .bottom)
  }
  }
