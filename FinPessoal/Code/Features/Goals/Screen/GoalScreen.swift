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
    Group {
        if financeViewModel.goals.isEmpty {
          EmptyStateView(
            icon: "target",
            title: "goals.empty.title",
            subtitle: "goals.empty.subtitle"
          )
          .accessibilityElement(children: .combine)
          .accessibilityLabel(String(localized: "goals.empty.title"))
          .accessibilityHint(String(localized: "goals.empty.subtitle") + ". Tap the add button in the toolbar to create your first goal")
        } else {
          ScrollView {
            LazyVStack(spacing: 0) {
              if !activeGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                  Text(String(localized: "goals.active"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)

                  if selectedViewMode == .cards {
                    LazyVGrid(columns: [
                      GridItem(.flexible(minimum: 160)),
                      GridItem(.flexible(minimum: 160))
                    ], spacing: 12) {
                      ForEach(activeGoals) { goal in
                        GoalCard(goal: goal)
                      }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Active goals grid")
                  } else {
                    LazyVStack(spacing: 8) {
                      ForEach(activeGoals) { goal in
                        GoalRowView(goal: goal)
                          .background(Color(.systemBackground))
                          .clipShape(RoundedRectangle(cornerRadius: 8))
                          .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                      }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Active goals list")
                  }
                }
              }

              if !completedGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                  Text(String(localized: "goals.completed"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)

                  LazyVStack(spacing: 8) {
                    ForEach(completedGoals) { goal in
                      GoalRowView(goal: goal)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .opacity(0.7)
                    }
                  }
                  .padding(.horizontal, 20)
                  .padding(.bottom, 20)
                  .accessibilityElement(children: .contain)
                  .accessibilityLabel("Completed goals list")
                }
              }
            }
          }
          .background(Color(.systemBackground))
      }
    }
    .environmentObject(goalViewModel)
    .navigationTitle(String(localized: "sidebar.goals"))
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if !financeViewModel.goals.isEmpty {
          Picker("View Mode", selection: $selectedViewMode) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
              Image(systemName: mode.icon)
                .font(.system(size: 16, weight: .medium))
                .tag(mode)
            }
          }
          .pickerStyle(.segmented)
          .frame(width: 120)
          .scaleEffect(1.1)
          .accessibilityLabel("View Mode")
          .accessibilityHint("Switch between cards and list view for goals")
          .accessibilityValue(selectedViewMode.rawValue)
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showingAddGoal = true
        } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Add Goal")
        .accessibilityHint("Opens form to create a new goal")
      }
    }
    .sheet(isPresented: $showingAddGoal) {
      AddGoalScreen()
        .environmentObject(goalViewModel)
        .environmentObject(financeViewModel)
    }
  }
}
