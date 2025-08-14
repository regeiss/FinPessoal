//
//  OnBoardingPageView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct OnboardingPageView: View {
  let page: OnboardingPage
  
  var body: some View {
    VStack(spacing: 30) {
      Spacer()
      
      Image(systemName: page.imageName)
        .font(.system(size: 80))
        .foregroundColor(page.color)
        .accessibilityHidden(true)
      
      VStack(spacing: 16) {
        Text(LocalizedStringKey(page.title))
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
        
        Text(LocalizedStringKey(page.subtitle))
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      
      Spacer()
    }
    .padding()
  }
}
