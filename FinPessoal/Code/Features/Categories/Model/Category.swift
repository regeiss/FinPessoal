//
//  Category.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
  let id: String
  let name: String
  let description: String?
  let icon: String
  let color: String
  let transactionType: TransactionType  // income, expense, or transfer
  let isActive: Bool
  let sortOrder: Int
  let userId: String
  let createdAt: Date
  let updatedAt: Date

  // Computed properties
  var displayColor: Color {
    switch color.lowercased() {
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "yellow": return .yellow
    case "pink": return .pink
    case "cyan": return .cyan
    case "indigo": return .indigo
    case "teal": return .teal
    case "mint": return .mint
    case "brown": return .brown
    default: return .gray
    }
  }

  // Convenience initializer
  init(
    id: String = UUID().uuidString,
    name: String,
    description: String? = nil,
    icon: String,
    color: String,
    transactionType: TransactionType,
    isActive: Bool = true,
    sortOrder: Int = 0,
    userId: String,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.icon = icon
    self.color = color
    self.transactionType = transactionType
    self.isActive = isActive
    self.sortOrder = sortOrder
    self.userId = userId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - Default Categories Data

struct DefaultCategoriesData {
  static func getDefaultCategories(for userId: String) -> [Category] {
    return [
      // Income Categories
      Category(
        name: "Salário",
        description: "Receitas de trabalho e salário",
        icon: "dollarsign.circle",
        color: "green",
        transactionType: .income,
        sortOrder: 1,
        userId: userId
      ),
      Category(
        name: "Investimentos",
        description: "Retornos de investimentos",
        icon: "chart.line.uptrend.xyaxis",
        color: "blue",
        transactionType: .income,
        sortOrder: 2,
        userId: userId
      ),
      Category(
        name: "Freelance",
        description: "Trabalhos autônomos",
        icon: "laptopcomputer",
        color: "purple",
        transactionType: .income,
        sortOrder: 3,
        userId: userId
      ),
      Category(
        name: "Outros Rendimentos",
        description: "Outras receitas",
        icon: "plus.circle",
        color: "cyan",
        transactionType: .income,
        sortOrder: 4,
        userId: userId
      ),

      // Expense Categories
      Category(
        name: "Alimentação",
        description: "Gastos com comida e bebida",
        icon: "fork.knife",
        color: "orange",
        transactionType: .expense,
        sortOrder: 1,
        userId: userId
      ),
      Category(
        name: "Transporte",
        description: "Gastos com transporte",
        icon: "car",
        color: "blue",
        transactionType: .expense,
        sortOrder: 2,
        userId: userId
      ),
      Category(
        name: "Moradia",
        description: "Gastos com habitação",
        icon: "house",
        color: "brown",
        transactionType: .expense,
        sortOrder: 3,
        userId: userId
      ),
      Category(
        name: "Saúde",
        description: "Gastos com saúde e bem-estar",
        icon: "cross",
        color: "red",
        transactionType: .expense,
        sortOrder: 4,
        userId: userId
      ),
      Category(
        name: "Entretenimento",
        description: "Gastos com lazer e diversão",
        icon: "gamecontroller",
        color: "purple",
        transactionType: .expense,
        sortOrder: 5,
        userId: userId
      ),
      Category(
        name: "Compras",
        description: "Compras gerais",
        icon: "bag",
        color: "pink",
        transactionType: .expense,
        sortOrder: 6,
        userId: userId
      ),
      Category(
        name: "Contas",
        description: "Contas fixas e utilitários",
        icon: "doc.text",
        color: "gray",
        transactionType: .expense,
        sortOrder: 7,
        userId: userId
      ),
      Category(
        name: "Outros Gastos",
        description: "Outras despesas",
        icon: "questionmark.circle",
        color: "gray",
        transactionType: .expense,
        sortOrder: 8,
        userId: userId
      ),
    ]
  }

  static func getDefaultSubcategories(for categories: [Category])
    -> [Subcategory]
  {
    var subcategories: [Subcategory] = []

    for category in categories {
      let categorySubcategories = getSubcategoriesForCategory(category)
      subcategories.append(contentsOf: categorySubcategories)
    }

    return subcategories
  }

  private static func getSubcategoriesForCategory(_ category: Category)
    -> [Subcategory]
  {
    switch category.name {
    case "Salário":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Salário Principal",
          icon: "briefcase",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Salário Secundário",
          icon: "briefcase.circle",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Bônus",
          icon: "star.circle",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Comissão",
          icon: "percent",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Benefícios",
          icon: "heart.circle",
          userId: category.userId
        ),
      ]
    case "Investimentos":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Ações",
          icon: "chart.line.uptrend.xyaxis",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Renda Fixa",
          icon: "doc.richtext",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Imóveis",
          icon: "building.2",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Criptomoedas",
          icon: "bitcoinsign.circle",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Poupança",
          icon: "banknote",
          userId: category.userId
        ),
      ]
    case "Alimentação":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Restaurantes",
          icon: "fork.knife.circle",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Supermercado",
          icon: "cart",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Fast Food",
          icon: "takeoutbag.and.cup.and.straw",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Delivery",
          icon: "shippingbox",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Café",
          icon: "cup.and.saucer",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Bebidas",
          icon: "wineglass",
          userId: category.userId
        ),
      ]
    case "Transporte":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Combustível",
          icon: "fuelpump",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Transporte Público",
          icon: "bus",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Taxi/Uber",
          icon: "car.circle",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Estacionamento",
          icon: "parkingsign",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Manutenção",
          icon: "wrench.and.screwdriver",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Seguro",
          icon: "shield.checkered",
          userId: category.userId
        ),
      ]
    case "Moradia":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Aluguel",
          icon: "key",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Financiamento",
          icon: "house.lodge",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Reparos",
          icon: "hammer",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Móveis",
          icon: "chair.lounge",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Utilitários",
          icon: "lightbulb",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Limpeza",
          icon: "paintbrush",
          userId: category.userId
        ),
      ]
    case "Saúde":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Médico",
          icon: "stethoscope",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Farmácia",
          icon: "pills",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Dentista",
          icon: "mouth",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Hospital",
          icon: "cross.case",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Terapia",
          icon: "brain.head.profile",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Suplementos",
          icon: "leaf",
          userId: category.userId
        ),
      ]
    case "Entretenimento":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Cinema",
          icon: "popcorn",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Jogos",
          icon: "gamecontroller",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Shows",
          icon: "music.note",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Esportes",
          icon: "sportscourt",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Livros",
          icon: "book",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Streaming",
          icon: "tv",
          userId: category.userId
        ),
      ]
    case "Compras":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Roupas",
          icon: "tshirt",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Eletrônicos",
          icon: "desktopcomputer",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Casa",
          icon: "house.and.flag",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Beleza",
          icon: "comb",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Presentes",
          icon: "gift",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Acessórios",
          icon: "eyeglasses",
          userId: category.userId
        ),
      ]
    case "Contas":
      return [
        Subcategory(
          categoryId: category.id,
          name: "Energia",
          icon: "bolt",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Água",
          icon: "drop",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Internet",
          icon: "wifi",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Telefone",
          icon: "phone",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Assinaturas",
          icon: "rectangle.stack",
          userId: category.userId
        ),
        Subcategory(
          categoryId: category.id,
          name: "Impostos",
          icon: "doc.text",
          userId: category.userId
        ),
      ]
    default:
      return [
        Subcategory(
          categoryId: category.id,
          name: "Diversos",
          icon: "questionmark.circle",
          userId: category.userId
        )
      ]
    }
  }
}
