//
//  HelpModels.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import Foundation

struct HelpTopic: Identifiable, Hashable {
  let id: String
  let title: String
  let content: String
  let category: HelpCategory
  let keywords: [String]
  let steps: [HelpStep]?
  let hasVideo: Bool
  let videoURL: String?
  let isFrequentlyAsked: Bool
  
  init(id: String, title: String, content: String, category: HelpCategory, keywords: [String] = [], steps: [HelpStep]? = nil, hasVideo: Bool = false, videoURL: String? = nil, isFrequentlyAsked: Bool = false) {
    self.id = id
    self.title = title
    self.content = content
    self.category = category
    self.keywords = keywords
    self.steps = steps
    self.hasVideo = hasVideo
    self.videoURL = videoURL
    self.isFrequentlyAsked = isFrequentlyAsked
  }
}

struct HelpStep: Identifiable, Hashable {
  let id: String
  let stepNumber: Int
  let title: String
  let description: String
  let imageName: String?
  let tip: String?
  
  init(id: String, stepNumber: Int, title: String, description: String, imageName: String? = nil, tip: String? = nil) {
    self.id = id
    self.stepNumber = stepNumber
    self.title = title
    self.description = description
    self.imageName = imageName
    self.tip = tip
  }
}

enum HelpCategory: String, CaseIterable, Identifiable {
  case gettingStarted = "getting_started"
  case transactions = "transactions"
  case categories = "categories"
  case creditCards = "credit_cards"
  case loans = "loans"
  case budgets = "budgets"
  case goals = "goals"
  case reports = "reports"
  case accounts = "accounts"
  case troubleshooting = "troubleshooting"
  case security = "security"

  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .gettingStarted:
      return String(localized: "help.category.getting.started")
    case .transactions:
      return String(localized: "help.category.transactions")
    case .categories:
      return String(localized: "help.category.categories")
    case .creditCards:
      return String(localized: "help.category.credit.cards")
    case .loans:
      return String(localized: "help.category.loans")
    case .budgets:
      return String(localized: "help.category.budgets")
    case .goals:
      return String(localized: "help.category.goals")
    case .reports:
      return String(localized: "help.category.reports")
    case .accounts:
      return String(localized: "help.category.accounts")
    case .troubleshooting:
      return String(localized: "help.category.troubleshooting")
    case .security:
      return String(localized: "help.category.security")
    }
  }
  
  var icon: String {
    switch self {
    case .gettingStarted:
      return "star.circle"
    case .transactions:
      return "list.bullet.rectangle"
    case .categories:
      return "tag.circle"
    case .creditCards:
      return "creditcard"
    case .loans:
      return "building.columns"
    case .budgets:
      return "chart.pie"
    case .goals:
      return "target"
    case .reports:
      return "chart.bar"
    case .accounts:
      return "person.circle"
    case .troubleshooting:
      return "wrench"
    case .security:
      return "lock.shield"
    }
  }
  
  var color: String {
    switch self {
    case .gettingStarted:
      return "blue"
    case .transactions:
      return "green"
    case .categories:
      return "pink"
    case .creditCards:
      return "indigo"
    case .loans:
      return "teal"
    case .budgets:
      return "orange"
    case .goals:
      return "purple"
    case .reports:
      return "red"
    case .accounts:
      return "cyan"
    case .troubleshooting:
      return "yellow"
    case .security:
      return "gray"
    }
  }
}

struct HelpSection: Identifiable {
  let id: String
  let title: String
  let topics: [HelpTopic]
  let category: HelpCategory?
  
  init(id: String, title: String, topics: [HelpTopic], category: HelpCategory? = nil) {
    self.id = id
    self.title = title
    self.topics = topics
    self.category = category
  }
}