//
//  HelpScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import SwiftUI

struct HelpScreen: View {
  @StateObject private var helpProvider = HelpDataProvider.shared
  @State private var searchText = ""
  @State private var selectedCategory: HelpCategory?
  @State private var selectedTopic: HelpTopic?
  @State private var showingSearch = false
  
  var filteredTopics: [HelpTopic] {
    if searchText.isEmpty {
      return helpProvider.helpTopics
    } else {
      return helpProvider.searchTopics(searchText)
    }
  }
  
  var body: some View {
    NavigationView {
      List {
        if searchText.isEmpty {
          // Quick access section
          Section(String(localized: "help.quick.access")) {
            QuickHelpActionsView(selectedTopic: $selectedTopic)
          }
          
          // FAQ section
          Section(String(localized: "help.section.faq")) {
            ForEach(helpProvider.getFAQs().prefix(3)) { topic in
              HelpTopicRow(topic: topic) {
                selectedTopic = topic
              }
            }
            
            NavigationLink(String(localized: "help.view.all.faqs")) {
              HelpFAQScreen()
            }
          }
          
          // Categories section
          Section(String(localized: "help.categories")) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
              ForEach(HelpCategory.allCases) { category in
                HelpCategoryCard(category: category) {
                  selectedCategory = category
                }
              }
            }
            .padding(.vertical, 8)
          }
        } else {
          // Search results
          Section(String(localized: "help.search.results")) {
            if filteredTopics.isEmpty {
              HelpEmptySearchView(searchText: searchText)
            } else {
              ForEach(filteredTopics) { topic in
                HelpTopicRow(topic: topic) {
                  selectedTopic = topic
                }
              }
            }
          }
        }
      }
      .navigationTitle(String(localized: "help.title"))
      .searchable(text: $searchText, prompt: String(localized: "help.search.prompt"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            selectedTopic = HelpTopic(
              id: "contact_support",
              title: String(localized: "help.contact.support"),
              content: String(localized: "help.contact.support.content"),
              category: .troubleshooting
            )
          } label: {
            Image(systemName: "questionmark.circle")
          }
        }
      }
      .sheet(item: $selectedTopic) { topic in
        HelpTopicDetailView(topic: topic)
      }
      .sheet(item: $selectedCategory) { category in
        HelpCategoryView(category: category)
      }
    }
  }
}

struct QuickHelpActionsView: View {
  @Binding var selectedTopic: HelpTopic?
  
  var body: some View {
    VStack(spacing: 12) {
      HStack(spacing: 16) {
        HelpQuickActionButton(
          icon: "plus.circle.fill",
          title: String(localized: "help.quick.add.transaction"),
          color: .green
        ) {
          selectedTopic = HelpDataProvider.shared.helpTopics.first { $0.id == "add_transaction" }
        }
        
        HelpQuickActionButton(
          icon: "chart.pie.fill",
          title: String(localized: "help.quick.create.budget"),
          color: .orange
        ) {
          selectedTopic = HelpDataProvider.shared.helpTopics.first { $0.id == "create_budget" }
        }
      }
      
      HStack(spacing: 16) {
        HelpQuickActionButton(
          icon: "target",
          title: String(localized: "help.quick.set.goals"),
          color: .purple
        ) {
          selectedTopic = HelpDataProvider.shared.helpTopics.first { $0.id == "set_goals" }
        }
        
        HelpQuickActionButton(
          icon: "chart.bar.fill",
          title: String(localized: "help.quick.view.reports"),
          color: .red
        ) {
          selectedTopic = HelpDataProvider.shared.helpTopics.first { $0.id == "view_reports" }
        }
      }
    }
    .padding(.vertical, 8)
  }
}

struct HelpQuickActionButton: View {
  let icon: String
  let title: String
  let color: Color
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(color)
        
        Text(title)
          .font(.caption)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(Color(.systemGray6))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}

struct HelpCategoryCard: View {
  let category: HelpCategory
  let action: () -> Void
  
  var topicCount: Int {
    HelpDataProvider.shared.getTopicsByCategory(category).count
  }
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: category.icon)
          .font(.title2)
          .foregroundColor(colorForCategory(category.color))
        
        Text(category.displayName)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
        
        Text("\(topicCount) \(topicCount == 1 ? String(localized: "help.topic") : String(localized: "help.topics"))")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color(.systemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    .buttonStyle(.plain)
  }
  
  private func colorForCategory(_ colorName: String) -> Color {
    switch colorName {
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "red": return .red
    case "cyan": return .cyan
    case "yellow": return .yellow
    case "gray": return .gray
    default: return .blue
    }
  }
}

struct HelpTopicRow: View {
  let topic: HelpTopic
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(topic.title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .lineLimit(2)
          
          if !topic.content.isEmpty {
            Text(topic.content)
              .font(.caption)
              .foregroundColor(.secondary)
              .lineLimit(2)
          }
        }
        
        Spacer()
        
        VStack(spacing: 4) {
          if topic.hasVideo {
            Image(systemName: "play.circle.fill")
              .font(.caption)
              .foregroundColor(.blue)
          }
          
          if topic.steps?.isEmpty == false {
            Image(systemName: "list.number")
              .font(.caption)
              .foregroundColor(.green)
          }
          
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

struct HelpEmptySearchView: View {
  let searchText: String
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "magnifyingglass")
        .font(.largeTitle)
        .foregroundColor(.secondary)
      
      Text(String(localized: "help.search.no.results"))
        .font(.headline)
        .foregroundColor(.primary)
      
      Text(String(localized: "help.search.try.different.terms"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  HelpScreen()
}
