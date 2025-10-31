//
//  HelpTopicDetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import SwiftUI

struct HelpTopicDetailView: View {
  let topic: HelpTopic
  @Environment(\.dismiss) private var dismiss
  @State private var showingShareSheet = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // Header section
          HelpTopicHeaderView(topic: topic)
          
          // Content section
          HelpTopicContentView(topic: topic)
          
          // Steps section (if available)
          if let steps = topic.steps, !steps.isEmpty {
            HelpTopicStepsView(steps: steps)
          }
          
          // Video section (if available)
          if topic.hasVideo {
            HelpTopicVideoView(topic: topic)
          }
          
          // Related topics
          HelpRelatedTopicsView(currentTopic: topic)
          
          // Feedback section
          HelpFeedbackView(topic: topic)
        }
        .padding()
      }
      .navigationTitle(String(localized: "help.topic.detail"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close")) {
            dismiss()
          }
          .accessibilityLabel("Close")
          .accessibilityHint("Closes help topic detail")
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingShareSheet = true
          } label: {
            Image(systemName: "square.and.arrow.up")
          }
          .accessibilityLabel("Share topic")
          .accessibilityHint("Opens share options for this help topic")
        }
      }
      .sheet(isPresented: $showingShareSheet) {
        HelpShareSheet(topic: topic)
      }
    }
  }
}

struct HelpTopicHeaderView: View {
  let topic: HelpTopic

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: topic.category.icon)
          .font(.title2)
          .foregroundColor(colorForCategory(topic.category.color))
          .accessibilityHidden(true)

        Text(topic.category.displayName)
          .font(.subheadline)
          .foregroundColor(.secondary)

        Spacer()

        if topic.isFrequentlyAsked {
          Text(String(localized: "help.faq.badge"))
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.blue)
            .clipShape(Capsule())
            .accessibilityLabel("Frequently asked question")
        }
      }

      Text(topic.title)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(topic.title), \(topic.category.displayName) category\(topic.isFrequentlyAsked ? ", frequently asked question" : "")")
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

struct HelpTopicContentView: View {
  let topic: HelpTopic

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "help.topic.content"))
        .font(.headline)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)

      Text(topic.content)
        .font(.body)
        .foregroundColor(.primary)
        .lineSpacing(4)
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Topic content: \(topic.content)")
  }
}

struct HelpTopicStepsView: View {
  let steps: [HelpStep]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "help.step.by.step"))
        .font(.headline)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)

      VStack(spacing: 12) {
        ForEach(steps) { step in
          HelpStepRow(step: step)
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Step by step guide, \(steps.count) steps")
  }
}

struct HelpStepRow: View {
  let step: HelpStep
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // Step number
      Text("\(step.stepNumber)")
        .font(.headline)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .frame(width: 28, height: 28)
        .background(Color.blue)
        .clipShape(Circle())
      
      VStack(alignment: .leading, spacing: 6) {
        Text(step.title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        
        Text(step.description)
          .font(.body)
          .foregroundColor(.secondary)
          .lineSpacing(2)
        
        if let tip = step.tip {
          HStack(spacing: 6) {
            Image(systemName: "lightbulb")
              .font(.caption)
              .foregroundColor(.yellow)
            
            Text(tip)
              .font(.caption)
              .foregroundColor(.secondary)
              .italic()
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.yellow.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 6))
        }
      }
      
      Spacer()
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

struct HelpTopicVideoView: View {
  let topic: HelpTopic
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "help.video.tutorial"))
        .font(.headline)
        .foregroundColor(.primary)
      
      Button {
        // Open video URL or play video
        if let videoURL = topic.videoURL, let url = URL(string: videoURL) {
          UIApplication.shared.open(url)
        }
      } label: {
        HStack {
          Image(systemName: "play.circle.fill")
            .font(.title)
            .foregroundColor(.blue)
          
          VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "help.watch.video"))
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.primary)
            
            Text(String(localized: "help.video.duration"))
              .font(.caption)
              .foregroundColor(.secondary)
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .buttonStyle(.plain)
    }
  }
}

struct HelpRelatedTopicsView: View {
  let currentTopic: HelpTopic
  @State private var selectedTopic: HelpTopic?
  
  var relatedTopics: [HelpTopic] {
    HelpDataProvider.shared.getTopicsByCategory(currentTopic.category)
      .filter { $0.id != currentTopic.id }
      .prefix(3)
      .map { $0 }
  }
  
  var body: some View {
    if !relatedTopics.isEmpty {
      VStack(alignment: .leading, spacing: 12) {
        Text(String(localized: "help.related.topics"))
          .font(.headline)
          .foregroundColor(.primary)
        
        VStack(spacing: 8) {
          ForEach(relatedTopics) { topic in
            HelpRelatedTopicRow(topic: topic) {
              selectedTopic = topic
            }
          }
        }
      }
      .padding()
      .background(Color(.systemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
      .sheet(item: $selectedTopic) { topic in
        HelpTopicDetailView(topic: topic)
      }
    }
  }
}

struct HelpRelatedTopicRow: View {
  let topic: HelpTopic
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(topic.title)
          .font(.subheadline)
          .foregroundColor(.primary)
          .lineLimit(2)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Color(.systemGray6))
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
  }
}

struct HelpFeedbackView: View {
  let topic: HelpTopic
  @State private var isHelpful: Bool?
  @State private var showingFeedbackForm = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "help.was.helpful"))
        .font(.headline)
        .foregroundColor(.primary)
      
      HStack(spacing: 16) {
        Button {
          isHelpful = true
        } label: {
          HStack(spacing: 6) {
            Image(systemName: isHelpful == true ? "hand.thumbsup.fill" : "hand.thumbsup")
              .foregroundColor(isHelpful == true ? .green : .secondary)
            
            Text(String(localized: "help.helpful.yes"))
              .foregroundColor(isHelpful == true ? .green : .primary)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(isHelpful == true ? Color.green.opacity(0.1) : Color(.systemGray6))
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        
        Button {
          isHelpful = false
          showingFeedbackForm = true
        } label: {
          HStack(spacing: 6) {
            Image(systemName: isHelpful == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
              .foregroundColor(isHelpful == false ? .red : .secondary)
            
            Text(String(localized: "help.helpful.no"))
              .foregroundColor(isHelpful == false ? .red : .primary)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(isHelpful == false ? Color.red.opacity(0.1) : Color(.systemGray6))
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        
        Spacer()
      }
      
      if isHelpful == true {
        Text(String(localized: "help.feedback.thanks"))
          .font(.caption)
          .foregroundColor(.green)
          .padding(.top, 4)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .sheet(isPresented: $showingFeedbackForm) {
      HelpFeedbackForm(topic: topic)
    }
  }
}

struct HelpFeedbackForm: View {
  let topic: HelpTopic
  @Environment(\.dismiss) private var dismiss
  @State private var feedbackText = ""
  
  var body: some View {
    NavigationView {
      VStack(alignment: .leading, spacing: 16) {
        Text(String(localized: "help.feedback.improve"))
          .font(.headline)
          .foregroundColor(.primary)
        
        Text(String(localized: "help.feedback.description"))
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        TextEditor(text: $feedbackText)
          .frame(minHeight: 120)
          .padding(8)
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 8))
        
        Spacer()
      }
      .padding()
      .navigationTitle(String(localized: "help.feedback.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.send")) {
            // Send feedback
            dismiss()
          }
          .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}

struct HelpShareSheet: View {
  let topic: HelpTopic
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(spacing: 20) {
      Text(String(localized: "help.share.topic"))
        .font(.headline)
        .foregroundColor(.primary)
      
      Text(topic.title)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      // Share options would go here
      
      Button(String(localized: "common.cancel")) {
        dismiss()
      }
      .padding()
    }
    .padding()
  }
}

#Preview {
  HelpTopicDetailView(
    topic: HelpTopic(
      id: "sample",
      title: "Como adicionar uma transação",
      content: "Para adicionar uma nova transação, siga os passos abaixo...",
      category: .transactions,
      keywords: ["transação", "adicionar"],
      steps: [
        HelpStep(id: "1", stepNumber: 1, title: "Abra o app", description: "Abra o aplicativo FinPessoal"),
        HelpStep(id: "2", stepNumber: 2, title: "Toque em +", description: "Toque no botão de adicionar")
      ],
      hasVideo: true,
      isFrequentlyAsked: true
    )
  )
}