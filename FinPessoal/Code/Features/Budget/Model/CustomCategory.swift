//
//  CustomCategory.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import Foundation
import SwiftUI

struct CustomCategory: Codable, Identifiable, Hashable {
  let id: String
  var name: String
  var description: String
  var iconName: String
  var colorName: String
  var isActive: Bool
  let createdAt: Date
  var updatedAt: Date
  
  init(name: String, description: String, iconName: String, colorName: String) {
    self.id = UUID().uuidString
    self.name = name
    self.description = description
    self.iconName = iconName
    self.colorName = colorName
    self.isActive = true
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  var icon: String {
    return iconName
  }
  
  var color: Color {
    switch colorName {
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "pink": return .pink
    case "yellow": return .yellow
    case "mint": return .mint
    case "teal": return .teal
    case "indigo": return .indigo
    case "brown": return .brown
    case "gray": return .gray
    default: return .blue
    }
  }
  
  mutating func update(name: String, description: String, iconName: String, colorName: String) {
    self.name = name
    self.description = description
    self.iconName = iconName
    self.colorName = colorName
    self.updatedAt = Date()
  }
}

// Combined category protocol to handle both built-in and custom categories
protocol CategoryProtocol {
  var id: String { get }
  var displayName: String { get }
  var description: String { get }
  var icon: String { get }
  var isCustom: Bool { get }
}

// Wrapper for TransactionCategory to conform to CategoryProtocol
struct BuiltInCategory: CategoryProtocol {
  let transactionCategory: TransactionCategory
  
  var id: String { transactionCategory.rawValue }
  var displayName: String { transactionCategory.displayName }
  var description: String {
    switch transactionCategory {
    case .food: return String(localized: "category.food.description")
    case .transport: return String(localized: "category.transport.description")
    case .entertainment: return String(localized: "category.entertainment.description")
    case .healthcare: return String(localized: "category.healthcare.description")
    case .shopping: return String(localized: "category.shopping.description")
    case .bills: return String(localized: "category.bills.description")
    case .salary: return String(localized: "category.salary.description")
    case .investment: return String(localized: "category.investment.description")
    case .housing: return String(localized: "category.housing.description")
    case .other: return String(localized: "category.other.description")
    }
  }
  var icon: String { transactionCategory.icon }
  var isCustom: Bool { false }
}

// Wrapper for CustomCategory to conform to CategoryProtocol
extension CustomCategory: CategoryProtocol {
  var displayName: String { name }
  var isCustom: Bool { true }
}

// Available icons for custom categories
enum CategoryIcon: String, CaseIterable {
  case car = "car"
  case house = "house"
  case cart = "cart"
  case heart = "heart"
  case star = "star"
  case book = "book"
  case camera = "camera"
  case music = "music.note"
  case phone = "phone"
  case laptop = "laptopcomputer"
  case gameController = "gamecontroller"
  case airplane = "airplane"
  case bicycle = "bicycle"
  case tshirt = "tshirt"
  case bag = "bag"
  case creditCard = "creditcard"
  case banknote = "banknote"
  case chart = "chart.bar"
  case gift = "gift"
  case paintbrush = "paintbrush"
  case wrench = "wrench"
  case leaf = "leaf"
  case flame = "flame"
  case drop = "drop"
  case bolt = "bolt"
  case cloud = "cloud"
  case sun = "sun.max"
  case moon = "moon"
  case sparkles = "sparkles"
  
  var displayName: String {
    switch self {
    case .car: return String(localized: "icon.car")
    case .house: return String(localized: "icon.house")
    case .cart: return String(localized: "icon.cart")
    case .heart: return String(localized: "icon.heart")
    case .star: return String(localized: "icon.star")
    case .book: return String(localized: "icon.book")
    case .camera: return String(localized: "icon.camera")
    case .music: return String(localized: "icon.music")
    case .phone: return String(localized: "icon.phone")
    case .laptop: return String(localized: "icon.laptop")
    case .gameController: return String(localized: "icon.game")
    case .airplane: return String(localized: "icon.airplane")
    case .bicycle: return String(localized: "icon.bicycle")
    case .tshirt: return String(localized: "icon.tshirt")
    case .bag: return String(localized: "icon.bag")
    case .creditCard: return String(localized: "icon.creditcard")
    case .banknote: return String(localized: "icon.banknote")
    case .chart: return String(localized: "icon.chart")
    case .gift: return String(localized: "icon.gift")
    case .paintbrush: return String(localized: "icon.paintbrush")
    case .wrench: return String(localized: "icon.wrench")
    case .leaf: return String(localized: "icon.leaf")
    case .flame: return String(localized: "icon.flame")
    case .drop: return String(localized: "icon.drop")
    case .bolt: return String(localized: "icon.bolt")
    case .cloud: return String(localized: "icon.cloud")
    case .sun: return String(localized: "icon.sun")
    case .moon: return String(localized: "icon.moon")
    case .sparkles: return String(localized: "icon.sparkles")
    }
  }
}

// Available colors for custom categories
enum CategoryColor: String, CaseIterable {
  case red = "red"
  case blue = "blue"
  case green = "green"
  case orange = "orange"
  case purple = "purple"
  case pink = "pink"
  case yellow = "yellow"
  case mint = "mint"
  case teal = "teal"
  case indigo = "indigo"
  case brown = "brown"
  case gray = "gray"
  
  var color: Color {
    switch self {
    case .red: return .red
    case .blue: return .blue
    case .green: return .green
    case .orange: return .orange
    case .purple: return .purple
    case .pink: return .pink
    case .yellow: return .yellow
    case .mint: return .mint
    case .teal: return .teal
    case .indigo: return .indigo
    case .brown: return .brown
    case .gray: return .gray
    }
  }
  
  var displayName: String {
    switch self {
    case .red: return String(localized: "color.red")
    case .blue: return String(localized: "color.blue")
    case .green: return String(localized: "color.green")
    case .orange: return String(localized: "color.orange")
    case .purple: return String(localized: "color.purple")
    case .pink: return String(localized: "color.pink")
    case .yellow: return String(localized: "color.yellow")
    case .mint: return String(localized: "color.mint")
    case .teal: return String(localized: "color.teal")
    case .indigo: return String(localized: "color.indigo")
    case .brown: return String(localized: "color.brown")
    case .gray: return String(localized: "color.gray")
    }
  }
}