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
      VStack {
        TabView(selection: $currentPage) {
          ForEach(0..<pages.count, id: \.self) { index in
            OnboardingPageView(page: pages[index])
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        
        VStack(spacing: 16) {
          if currentPage == pages.count - 1 {
            Button("Começar") {
              showOnboarding = false
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
          } else {
            Button("Próximo") {
              withAnimation {
                currentPage += 1
              }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
          }
          
          Button("Pular") {
            showOnboarding = false
          }
          .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
      }
    }
  }
