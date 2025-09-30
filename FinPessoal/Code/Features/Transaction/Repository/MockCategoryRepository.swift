//
//  MockCategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

class MockCategoryRepository: CategoryRepositoryProtocol {
    private var categories: [Category] = []
    private var subcategories: [Subcategory] = []
    private let mockUserId = "mock-user-id"
    
    init() {
        initializeMockData()
    }
    
    private func initializeMockData() {
        categories = DefaultCategoriesData.getDefaultCategories(for: mockUserId)
        subcategories = DefaultCategoriesData.getDefaultSubcategories(for: categories)
    }
    
    // MARK: - Categories
    
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
        let newCategory = Category(
            id: category.id,
            name: category.name,
            description: category.description,
            icon: category.icon,
            color: category.color,
            transactionType: category.transactionType,
            isActive: category.isActive,
            sortOrder: category.sortOrder,
            userId: mockUserId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        categories.append(newCategory)
        return newCategory
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
        // Remove subcategories first
        subcategories.removeAll { $0.categoryId == id }
        
        // Remove category
        categories.removeAll { $0.id == id }
    }
    
    // MARK: - Subcategories
    
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
        let newSubcategory = Subcategory(
            id: subcategory.id,
            categoryId: subcategory.categoryId,
            name: subcategory.name,
            description: subcategory.description,
            icon: subcategory.icon,
            isActive: subcategory.isActive,
            sortOrder: subcategory.sortOrder,
            userId: mockUserId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        subcategories.append(newSubcategory)
        return newSubcategory
    }
    
    func updateSubcategory(_ subcategory: Subcategory) async throws -> Subcategory {
        guard let index = subcategories.firstIndex(where: { $0.id == subcategory.id }) else {
            throw CategoryError.subcategoryNotFound
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
    
    // MARK: - Default data
    
    func initializeDefaultCategories() async throws {
        // Mock repository already initializes with default data
        // This method is a no-op for the mock
    }
}