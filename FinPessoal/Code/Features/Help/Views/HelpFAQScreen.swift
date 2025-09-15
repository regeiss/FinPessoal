//
//  HelpFAQScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import SwiftUI

struct HelpFAQScreen: View {
  @StateObject private var helpProvider = HelpDataProvider.shared
  @State private var selectedTopic: HelpTopic?
  @State private var searchText = ""
  
  var filteredFAQs: [HelpTopic] {
    let faqs = helpProvider.getFAQs()
    if searchText.isEmpty {
      return faqs
    } else {
      return faqs.filter { topic in
        topic.title.localizedCaseInsensitiveContains(searchText) ||
        topic.content.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  var faqsByCategory: [HelpCategory: [HelpTopic]] {
    Dictionary(grouping: filteredFAQs) { $0.category }
  }
  
  var body: some View {
    List {
      if searchText.isEmpty {
        Section {
          HelpFAQHeaderView()
        }
      }
      
      if filteredFAQs.isEmpty {
        Section {
          HelpEmptyFAQView(searchText: searchText)
        }
      } else {
        ForEach(HelpCategory.allCases.filter { faqsByCategory[$0] != nil }) { category in
          Section(category.displayName) {
            ForEach(faqsByCategory[category] ?? []) { faq in
              HelpFAQRow(faq: faq) {
                selectedTopic = faq
              }
            }
          }
        }
      }
    }
    .navigationTitle(String(localized: "help.faq.title"))
    .navigationBarTitleDisplayMode(.large)
    .searchable(text: $searchText, prompt: String(localized: "help.faq.search.prompt"))
    .sheet(item: $selectedTopic) { topic in
      HelpTopicDetailView(topic: topic)
    }
  }
}

struct HelpFAQHeaderView: View {
  var faqCount: Int {
    HelpDataProvider.shared.getFAQs().count
  }
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "questionmark.circle.fill")
        .font(.largeTitle)
        .foregroundColor(.blue)
      
      Text(String(localized: "help.faq.header.title"))
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)
      
      Text(String(localized: "help.faq.header.subtitle"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      Text("\(faqCount) \(faqCount == 1 ? String(localized: "help.question.available") : String(localized: "help.questions.available"))")
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
}

struct HelpFAQRow: View {
  let faq: HelpTopic
  let action: () -> Void
  @State private var isExpanded = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button(action: {
        withAnimation(.easeInOut(duration: 0.3)) {
          isExpanded.toggle()
        }
      }) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(faq.title)
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.primary)
              .multilineTextAlignment(.leading)
            
            if !isExpanded {
              Text(faq.content.prefix(100) + (faq.content.count > 100 ? "..." : ""))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            }
          }
          
          Spacer()
          
          VStack(spacing: 4) {
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
              .font(.caption)
              .foregroundColor(.secondary)
            
            if faq.hasVideo {
              Image(systemName: "play.circle.fill")
                .font(.caption)
                .foregroundColor(.blue)
            }
          }
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      
      if isExpanded {
        VStack(alignment: .leading, spacing: 12) {
          Divider()
            .padding(.vertical, 8)
          
          Text(faq.content)
            .font(.body)
            .foregroundColor(.primary)
            .lineSpacing(2)
          
          if let steps = faq.steps, !steps.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text(String(localized: "help.quick.steps"))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
              
              ForEach(steps.prefix(3)) { step in
                HStack(alignment: .top, spacing: 8) {
                  Text("\(step.stepNumber).")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(width: 16, alignment: .leading)
                  
                  Text(step.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }
            }
            .padding(.top, 4)
          }
          
          HStack(spacing: 16) {
            Button(String(localized: "help.view.details")) {
              action()
            }
            .font(.caption)
            .foregroundColor(.blue)
            
            if faq.hasVideo {
              Button(String(localized: "help.watch.video")) {
                // Open video
              }
              .font(.caption)
              .foregroundColor(.blue)
            }
            
            Spacer()
          }
          .padding(.top, 8)
        }
      }
    }
    .padding(.vertical, 4)
  }
}

struct HelpEmptyFAQView: View {
  let searchText: String
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: searchText.isEmpty ? "questionmark.circle" : "magnifyingglass")
        .font(.largeTitle)
        .foregroundColor(.secondary)
      
      Text(searchText.isEmpty ? String(localized: "help.faq.empty.title") : String(localized: "help.faq.search.no.results"))
        .font(.headline)
        .foregroundColor(.primary)
      
      Text(searchText.isEmpty ? String(localized: "help.faq.empty.subtitle") : String(localized: "help.faq.try.different.search"))
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      if !searchText.isEmpty {
        Button(String(localized: "help.clear.search")) {
          // This would be handled by the parent view
        }
        .font(.subheadline)
        .foregroundColor(.blue)
      }
    }
    .padding()
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  NavigationView {
    HelpFAQScreen()
  }
}