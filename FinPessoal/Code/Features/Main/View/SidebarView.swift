//
//  SidebarView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct SidebarView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel

  var body: some View {
    List(selection: $navigationState.selectedSidebarItem) {
      Section {
        if let user = authViewModel.currentUser {
          UserProfileRow(user: user)
            .listRowInsets(EdgeInsets())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(String(localized: "sidebar.profile.label", defaultValue: "User Profile: \(user.name)"))
            .accessibilityHint(String(localized: "sidebar.profile.hint", defaultValue: "View profile and sign out"))
        }
      }
      .accessibilityLabel(String(localized: "sidebar.section.profile", defaultValue: "Profile Section"))

      Section(String(localized: "sidebar.section.main", defaultValue: "Menu Principal")) {
        ForEach(SidebarItem.allCases.prefix(4), id: \.self) { item in
          SidebarRow(item: item)
        }
      }

      Section(String(localized: "sidebar.section.tools", defaultValue: "Ferramentas")) {
        ForEach(Array(SidebarItem.allCases.dropFirst(4).dropLast(2)), id: \.self) { item in
          SidebarRow(item: item)
        }
      }

      Section(String(localized: "sidebar.section.configuration", defaultValue: "Configurações")) {
        SidebarRow(item: .categories)
      }

      Section {
        SidebarRow(item: .settings)
      }
    }
    .listStyle(.sidebar)
    .navigationTitle("Money Manager")
    .accessibilityLabel(String(localized: "sidebar.title", defaultValue: "Navigation Sidebar"))
  }
}
