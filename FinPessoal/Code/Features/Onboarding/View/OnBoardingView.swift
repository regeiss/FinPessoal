//
//  OnBoardingView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
  @EnvironmentObject var appState: AppState
  @State private var currentPage = 0
  
  private let pages = [
    OnboardingPage(
      title: "onboarding.welcome.title",
      subtitle: "onboarding.welcome.subtitle",
      imageName: "chart.pie.fill",
      color: .blue
    ),
    OnboardingPage(
      title: "onboarding.budget.title",
      subtitle: "onboarding.budget.subtitle",
      imageName: "creditcard.fill",
      color: .green
    ),
    OnboardingPage(
      title: "onboarding.goals.title",
      subtitle: "onboarding.goals.subtitle",
      imageName: "target",
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
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
      
      VStack(spacing: 20) {
        if currentPage == pages.count - 1 {
          Button(action: {
            appState.completeOnboarding()
          }) {
            Text("onboarding.get_started")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(12)
          }
          .accessibilityLabel("onboarding.get_started")
        } else {
          Button(action: {
            withAnimation {
              currentPage += 1
            }
          }) {
            Text("onboarding.next")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(12)
          }
          .accessibilityLabel("onboarding.next")
        }
        
        Button(action: {
          appState.completeOnboarding()
        }) {
          Text("onboarding.skip")
            .foregroundColor(.secondary)
        }
        .accessibilityLabel("onboarding.skip")
      }
      .padding()
    }
  }
}

