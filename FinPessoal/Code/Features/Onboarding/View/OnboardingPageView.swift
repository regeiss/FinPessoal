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
    VStack(spacing: 32) {
      Spacer()
      
      Image(systemName: page.imageName)
        .font(.system(size: 100))
        .foregroundColor(page.color)
      
      VStack(spacing: 16) {
        Text(page.title)
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
        
        Text(page.description)
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }
      
      Spacer()
    }
  }
}
