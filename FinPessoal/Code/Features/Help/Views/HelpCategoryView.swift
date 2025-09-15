//
//  HelpCategoryView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import SwiftUI

struct HelpCategoryView: View {
  let category: HelpCategory
  @StateObject private var helpProvider = HelpDataProvider.shared
  @State private var selectedTopic: HelpTopic?
  @Environment(\.dismiss) private var dismiss
  
  var categoryTopics: [HelpTopic] {
    helpProvider.getTopicsByCategory(category)
  }
  
  var body: some View {
    NavigationView {
      List {
        if !categoryTopics.isEmpty {
          Section {
            HelpCategoryHeaderView(category: category)
          }
          
          Section(String(localized: "help.topics.in.category")) {
            ForEach(categoryTopics) { topic in
              HelpTopicRow(topic: topic) {
                selectedTopic = topic
              }
            }
          }
          
          Section(String(localized: "help.related.categories")) {
            HelpRelatedCategoriesView(currentCategory: category)
          }
        } else {
          Section {
            HelpEmptyCategoryView(category: category)
          }
        }
      }
      .navigationTitle(category.displayName)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            dismiss()
          }
        }
      }
      .sheet(item: $selectedTopic) { topic in
        HelpTopicDetailView(topic: topic)
      }
    }
  }
}

struct HelpCategoryHeaderView: View {
  let category: HelpCategory
  
  var topicCount: Int {
    HelpDataProvider.shared.getTopicsByCategory(category).count
  }
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: category.icon)
        .font(.largeTitle)
        .foregroundColor(colorForCategory(category.color))
      
      Text(category.displayName)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)
      
      Text(String(localized: "help.category.description.\(category.rawValue)"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      Text("\(topicCount) \(topicCount == 1 ? String(localized: "help.topic.available") : String(localized: "help.topics.available"))")
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct HelpRelatedCategoriesView: View {
  let currentCategory: HelpCategory
  @State private var selectedCategory: HelpCategory?
  
  var relatedCategories: [HelpCategory] {
    HelpCategory.allCases.filter { $0 != currentCategory }.prefix(3).map { $0 }
  }
  
  var body: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
      ForEach(relatedCategories) { category in
        HelpMiniCategoryCard(category: category) {
          selectedCategory = category
        }
      }
    }
    .padding(.vertical, 8)
    .sheet(item: $selectedCategory) { category in
      HelpCategoryView(category: category)
    }
  }
}

struct HelpMiniCategoryCard: View {
  let category: HelpCategory
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: category.icon)
          .font(.title3)
          .foregroundColor(colorForCategory(category.color))
        
        Text(category.displayName)
          .font(.caption)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(Color(.systemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
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

struct HelpEmptyCategoryView: View {
  let category: HelpCategory
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "doc.text")
        .font(.largeTitle)
        .foregroundColor(.secondary)
      
      Text(String(localized: "help.category.empty.title"))
        .font(.headline)
        .foregroundColor(.primary)
      
      Text(String(localized: "help.category.empty.subtitle"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  HelpCategoryView(category: .transactions)
}