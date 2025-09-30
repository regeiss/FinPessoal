//
//  CategoryManagementService.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

@MainActor
class CategoryManagementService: ObservableObject {
    @Published var categories: [Category] = []
    @Published var subcategories: [Subcategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CategoryRepositoryProtocol
    
    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Category Management
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedCategories = try await repository.getCategories()
            categories = loadedCategories
            
            // Load all subcategories
            let loadedSubcategories = try await repository.getSubcategories()
            subcategories = loadedSubcategories
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getCategories(for transactionType: TransactionType) async -> [Category] {
        do {
            return try await repository.getCategories(for: transactionType)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    func getSubcategories(for categoryId: String) async -> [Subcategory] {
        do {
            return try await repository.getSubcategories(for: categoryId)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    func createCategory(name: String, description: String?, icon: String, color: String, transactionType: TransactionType) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCategory = Category(
                name: name,
                description: description,
                icon: icon,
                color: color,
                transactionType: transactionType,
                sortOrder: categories.count,
                userId: "" // Will be set by repository
            )
            
            let createdCategory = try await repository.createCategory(newCategory)
            categories.append(createdCategory)
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateCategory(_ category: Category) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedCategory = try await repository.updateCategory(category)
            
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = updatedCategory
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteCategory(_ category: Category) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteCategory(id: category.id)
            categories.removeAll { $0.id == category.id }
            subcategories.removeAll { $0.categoryId == category.id }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Subcategory Management
    
    func createSubcategory(name: String, description: String?, icon: String, categoryId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let categorySubcategories = subcategories.filter { $0.categoryId == categoryId }
            
            let newSubcategory = Subcategory(
                categoryId: categoryId,
                name: name,
                description: description,
                icon: icon,
                sortOrder: categorySubcategories.count,
                userId: "" // Will be set by repository
            )
            
            let createdSubcategory = try await repository.createSubcategory(newSubcategory)
            subcategories.append(createdSubcategory)
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateSubcategory(_ subcategory: Subcategory) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedSubcategory = try await repository.updateSubcategory(subcategory)
            
            if let index = subcategories.firstIndex(where: { $0.id == subcategory.id }) {
                subcategories[index] = updatedSubcategory
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteSubcategory(_ subcategory: Subcategory) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteSubcategory(id: subcategory.id)
            subcategories.removeAll { $0.id == subcategory.id }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Initialization
    
    func initializeDefaultCategories() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.initializeDefaultCategories()
            await loadCategories()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    func getCategory(by id: String) -> Category? {
        return categories.first { $0.id == id }
    }
    
    func getSubcategory(by id: String) -> Subcategory? {
        return subcategories.first { $0.id == id }
    }
    
    func getCategoriesForType(_ type: TransactionType) -> [Category] {
        return categories.filter { $0.transactionType == type && $0.isActive }
    }
    
    func getSubcategoriesForCategory(_ categoryId: String) -> [Subcategory] {
        return subcategories.filter { $0.categoryId == categoryId && $0.isActive }
    }
}