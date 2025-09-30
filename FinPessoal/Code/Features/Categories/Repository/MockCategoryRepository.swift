//
//  MockCategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

class MockCategoryRepository: CategoryRepositoryProtocol {
    private var categories: [Category] = []
    
    init() {
        setupMockData()
    }
    
    // MARK: - Category Operations
    
    func getCategories() async throws -> [Category] {
        return categories.filter { $0.isActive }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getCategories(for transactionType: TransactionType) async throws -> [Category] {
        return categories
            .filter { $0.transactionType == transactionType && $0.isActive }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getCategory(by id: String) async throws -> Category? {
        return categories.first { $0.id == id }
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        let updatedCategory = Category(
            id: category.id,
            name: category.name,
            description: category.description,
            icon: category.icon,
            color: category.color,
            transactionType: category.transactionType,
            isActive: category.isActive,
            sortOrder: category.sortOrder,
            userId: "mock-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        categories.append(updatedCategory)
        return updatedCategory
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else {
            throw CategoryError.categoryNotFound
        }
        
        let updatedCategory = Category(
            id: category.id,
            name: category.name,
            description: category.description,
            icon: category.icon,
            color: category.color,
            transactionType: category.transactionType,
            isActive: category.isActive,
            sortOrder: category.sortOrder,
            userId: category.userId,
            createdAt: category.createdAt,
            updatedAt: Date()
        )
        
        categories[index] = updatedCategory
        return updatedCategory
    }
    
    func deleteCategory(id: String) async throws {
        categories.removeAll { $0.id == id }
    }
    
    func initializeDefaultCategories() async throws -> [Category] {
        if !categories.isEmpty {
            return categories
        }
        
        let defaultCategories = DefaultCategoriesData.getDefaultCategories(for: "mock-user-id")
        for category in defaultCategories {
            categories.append(category)
        }
        
        return categories
    }
    
    // MARK: - Helper Methods
    
    private func setupMockData() {
        categories = [
            Category(
                id: "cat-food",
                name: "Alimentação",
                description: "Gastos com comida e bebida",
                icon: "fork.knife",
                color: "orange",
                transactionType: .expense,
                sortOrder: 1,
                userId: "mock-user-id"
            ),
            Category(
                id: "cat-transport",
                name: "Transporte",
                description: "Gastos com transporte",
                icon: "car",
                color: "blue",
                transactionType: .expense,
                sortOrder: 2,
                userId: "mock-user-id"
            ),
            Category(
                id: "cat-entertainment",
                name: "Entretenimento",
                description: "Gastos com lazer e diversão",
                icon: "gamecontroller",
                color: "purple",
                transactionType: .expense,
                sortOrder: 3,
                userId: "mock-user-id"
            ),
            Category(
                id: "cat-salary",
                name: "Salário",
                description: "Receitas de trabalho e salário",
                icon: "dollarsign.circle",
                color: "green",
                transactionType: .income,
                sortOrder: 1,
                userId: "mock-user-id"
            )
        ]
    }
}