//
//  OnBoardingScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct OnboardingScreen: View {
  @EnvironmentObject var onboardingManager: OnboardingManager
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
            onboardingManager.completeOnboarding()
          }) {
            Text("onboarding.get_started")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(12)
          }
          .accessibilityLabel("Get Started")
          .accessibilityHint("Complete onboarding and start using the app")
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
          .accessibilityLabel("Next")
          .accessibilityHint("Go to page \(currentPage + 2) of \(pages.count)")
        }

        Button(action: {
          onboardingManager.completeOnboarding()
        }) {
          Text("onboarding.skip")
            .foregroundColor(.secondary)
        }
        .accessibilityLabel("Skip Onboarding")
        .accessibilityHint("Skip onboarding and go directly to the app")
      }
      .padding()
    }
  }
}

