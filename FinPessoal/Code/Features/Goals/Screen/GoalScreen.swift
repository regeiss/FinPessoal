//
//  GoalScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct GoalScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @StateObject private var goalViewModel = GoalViewModel()
  @State private var showingAddGoal = false
  @State private var selectedViewMode: ViewMode = .cards
  
  enum ViewMode: String, CaseIterable {
    case cards = "Cards"
    case list = "List"
    
    var icon: String {
      switch self {
      case .cards: return "rectangle.grid.2x2"
      case .list: return "list.bullet"
      }
    }
  }
  
  var activeGoals: [Goal] {
    financeViewModel.goals.filter { $0.isActive }
  }
  
  var completedGoals: [Goal] {
    financeViewModel.goals.filter { $0.isCompleted }
  }
  
  var body: some View {
    NavigationView {
      Group {
        if financeViewModel.goals.isEmpty {
          EmptyStateView(
            icon: "target",
            title: "goals.empty.title",
            subtitle: "goals.empty.subtitle"
          )
        } else {
          ScrollView {
            LazyVStack(spacing: 16) {
              if !activeGoals.isEmpty {
                Section {
                  if selectedViewMode == .cards {
                    LazyVGrid(columns: [
                      GridItem(.flexible()),
                      GridItem(.flexible())
                    ], spacing: 12) {
                      ForEach(activeGoals) { goal in
                        GoalCard(goal: goal)
                      }
                    }
                  } else {
                    LazyVStack(spacing: 8) {
                      ForEach(activeGoals) { goal in
                        GoalRowView(goal: goal)
                          .background(Color(.systemBackground))
                          .clipShape(RoundedRectangle(cornerRadius: 8))
                          .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                      }
                    }
                  }
                } header: {
                  HStack {
                    Text(String(localized: "goals.active"))
                      .font(.headline)
                      .foregroundColor(.primary)
                    Spacer()
                  }
                  .padding(.horizontal)
                }
              }
              
              if !completedGoals.isEmpty {
                Section {
                  LazyVStack(spacing: 8) {
                    ForEach(completedGoals) { goal in
                      GoalRowView(goal: goal)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .opacity(0.7)
                    }
                  }
                } header: {
                  HStack {
                    Text(String(localized: "goals.completed"))
                      .font(.headline)
                      .foregroundColor(.primary)
                    Spacer()
                  }
                  .padding(.horizontal)
                  .padding(.top)
                }
              }
            }
            .padding()
          }
        }
      }
      .navigationTitle(String(localized: "goals.title"))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if !financeViewModel.goals.isEmpty {
            Picker("View Mode", selection: $selectedViewMode) {
              ForEach(ViewMode.allCases, id: \.self) { mode in
                Image(systemName: mode.icon)
                  .tag(mode)
              }
            }
            .pickerStyle(.segmented)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddGoal = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddGoal) {
        AddGoalScreen()
          .environmentObject(goalViewModel)
          .environmentObject(financeViewModel)
      }
    }
  }
}
