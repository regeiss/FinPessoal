//
//  MockSubcategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

class MockSubcategoryRepository: SubcategoryRepositoryProtocol {
    private var subcategories: [Subcategory] = []
    
    init() {
        setupMockData()
    }
    
    // MARK: - Subcategory Operations
    
    func getSubcategories() async throws -> [Subcategory] {
        return subcategories.filter { $0.isActive }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getSubcategories(for categoryId: String) async throws -> [Subcategory] {
        return subcategories
            .filter { $0.categoryId == categoryId && $0.isActive }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getSubcategory(by id: String) async throws -> Subcategory? {
        return subcategories.first { $0.id == id }
    }
    
    func createSubcategory(_ subcategory: Subcategory) async throws -> Subcategory {
        let updatedSubcategory = Subcategory(
            id: subcategory.id,
            categoryId: subcategory.categoryId,
            name: subcategory.name,
            description: subcategory.description,
            icon: subcategory.icon,
            isActive: subcategory.isActive,
            sortOrder: subcategory.sortOrder,
            userId: "mock-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        subcategories.append(updatedSubcategory)
        return updatedSubcategory
    }
    
    func updateSubcategory(_ subcategory: Subcategory) async throws -> Subcategory {
        guard let index = subcategories.firstIndex(where: { $0.id == subcategory.id }) else {
            throw SubcategoryError.subcategoryNotFound
        }
        
        let updatedSubcategory = Subcategory(
            id: subcategory.id,
            categoryId: subcategory.categoryId,
            name: subcategory.name,
            description: subcategory.description,
            icon: subcategory.icon,
            isActive: subcategory.isActive,
            sortOrder: subcategory.sortOrder,
            userId: subcategory.userId,
            createdAt: subcategory.createdAt,
            updatedAt: Date()
        )
        
        subcategories[index] = updatedSubcategory
        return updatedSubcategory
    }
    
    func deleteSubcategory(id: String) async throws {
        subcategories.removeAll { $0.id == id }
    }
    
    func deleteSubcategories(for categoryId: String) async throws {
        subcategories.removeAll { $0.categoryId == categoryId }
    }
    
    func initializeDefaultSubcategories(for categories: [Category]) async throws -> [Subcategory] {
        if !subcategories.isEmpty {
            return subcategories
        }
        
        let defaultSubcategories = DefaultCategoriesData.getDefaultSubcategories(for: categories)
        subcategories = defaultSubcategories
        return subcategories
    }
    
    // MARK: - Helper Methods
    
    private func setupMockData() {
        subcategories = [
            Subcategory(
                id: "sub-restaurant",
                categoryId: "cat-food",
                name: "Restaurantes",
                description: "Gastos em restaurantes",
                icon: "fork.knife.circle",
                userId: "mock-user-id"
            ),
            Subcategory(
                id: "sub-groceries",
                categoryId: "cat-food",
                name: "Supermercado",
                description: "Compras no supermercado",
                icon: "cart",
                userId: "mock-user-id"
            ),
            Subcategory(
                id: "sub-fuel",
                categoryId: "cat-transport",
                name: "Combustível",
                description: "Gastos com combustível",
                icon: "fuelpump",
                userId: "mock-user-id"
            ),
            Subcategory(
                id: "sub-public-transport",
                categoryId: "cat-transport",
                name: "Transporte Público",
                description: "Ônibus, metrô, etc.",
                icon: "bus",
                userId: "mock-user-id"
            ),
            Subcategory(
                id: "sub-movies",
                categoryId: "cat-entertainment",
                name: "Cinema",
                description: "Filmes e cinema",
                icon: "popcorn",
                userId: "mock-user-id"
            )
        ]
    }
}