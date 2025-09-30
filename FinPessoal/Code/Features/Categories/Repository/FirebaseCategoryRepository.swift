//
//  FirebaseCategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseCategoryRepository: CategoryRepositoryProtocol {
    private let db = Firestore.firestore()
    private let categoriesCollection = "categories"
    
    // MARK: - Category Operations
    
    func getCategories() async throws -> [Category] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(categoriesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .order(by: "sortOrder")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Category.self)
        }
    }
    
    func getCategories(for transactionType: TransactionType) async throws -> [Category] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(categoriesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("transactionType", isEqualTo: transactionType.rawValue)
            .whereField("isActive", isEqualTo: true)
            .order(by: "sortOrder")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Category.self)
        }
    }
    
    func getCategory(by id: String) async throws -> Category? {
        let document = try await db.collection(categoriesCollection).document(id)
            .getDocument()
        return try document.data(as: Category.self)
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
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
            userId: userId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection(categoriesCollection)
            .document(updatedCategory.id)
            .setData(from: updatedCategory)
        
        return updatedCategory
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
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
        
        try await db.collection(categoriesCollection)
            .document(updatedCategory.id)
            .setData(from: updatedCategory, merge: true)
        
        return updatedCategory
    }
    
    func deleteCategory(id: String) async throws {
        try await db.collection(categoriesCollection).document(id).delete()
    }
    
    func initializeDefaultCategories() async throws -> [Category] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        // Check if user already has categories
        let existingCategories = try await getCategories()
        if !existingCategories.isEmpty {
            return existingCategories // User already has categories
        }
        
        // Create default categories
        let defaultCategories = DefaultCategoriesData.getDefaultCategories(for: userId)
        var createdCategories: [Category] = []
        
        for category in defaultCategories {
            let createdCategory = try await createCategory(category)
            createdCategories.append(createdCategory)
        }
        
        return createdCategories
    }
}

enum CategoryError: LocalizedError {
    case userNotAuthenticated
    case categoryNotFound
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return String(localized: "category.error.not_authenticated")
        case .categoryNotFound:
            return String(localized: "category.error.category_not_found")
        case .invalidData:
            return String(localized: "category.error.invalid_data")
        case .networkError(let error):
            return String(localized: "category.error.network") + ": \(error.localizedDescription)"
        }
    }
}