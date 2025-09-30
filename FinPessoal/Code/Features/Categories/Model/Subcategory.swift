//
//  Subcategory.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

struct Subcategory: Identifiable, Codable, Hashable {
    let id: String
    let categoryId: String
    let name: String
    let description: String?
    let icon: String
    let isActive: Bool
    let sortOrder: Int
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Convenience initializer
    init(
        id: String = UUID().uuidString,
        categoryId: String,
        name: String,
        description: String? = nil,
        icon: String,
        isActive: Bool = true,
        sortOrder: Int = 0,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.description = description
        self.icon = icon
        self.isActive = isActive
        self.sortOrder = sortOrder
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Sample Data
extension Subcategory {
    static var sampleData: [Subcategory] {
        return [
            Subcategory(
                categoryId: "cat-food",
                name: "Restaurantes",
                description: "Gastos em restaurantes",
                icon: "fork.knife.circle",
                userId: "sample-user"
            ),
            Subcategory(
                categoryId: "cat-food",
                name: "Supermercado",
                description: "Compras no supermercado",
                icon: "cart",
                userId: "sample-user"
            ),
            Subcategory(
                categoryId: "cat-transport",
                name: "Combustível",
                description: "Gastos com combustível",
                icon: "fuelpump",
                userId: "sample-user"
            )
        ]
    }
}