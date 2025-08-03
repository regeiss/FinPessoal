//
//  iPadMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//
import SwiftUI

struct iPadMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    NavigationSplitView {
      SidebarView()
        .navigationSplitViewColumnWidth(min: 250, ideal: 300)
    } detail: {
      DetailView()
    }
    .navigationSplitViewStyle(.prominentDetail)
    .task {
      await financeViewModel.loadData()
    }
  }
}
