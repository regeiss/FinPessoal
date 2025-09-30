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
    private let subcategoriesCollection = "subcategories"
    
    // MARK: - Categories
    
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
        // First, delete all subcategories
        let subcategoriesSnapshot = try await db.collection(subcategoriesCollection)
            .whereField("categoryId", isEqualTo: id)
            .getDocuments()
        
        let batch = db.batch()
        for document in subcategoriesSnapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        // Delete the category
        batch.deleteDocument(db.collection(categoriesCollection).document(id))
        
        try await batch.commit()
    }
    
    // MARK: - Subcategories
    
    func getSubcategories() async throws -> [Subcategory] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(subcategoriesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .order(by: "sortOrder")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Subcategory.self)
        }
    }
    
    func getSubcategories(for categoryId: String) async throws -> [Subcategory] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(subcategoriesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("isActive", isEqualTo: true)
            .order(by: "sortOrder")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Subcategory.self)
        }
    }
    
    func getSubcategory(by id: String) async throws -> Subcategory? {
        let document = try await db.collection(subcategoriesCollection).document(id)
            .getDocument()
        return try document.data(as: Subcategory.self)
    }
    
    func createSubcategory(_ subcategory: Subcategory) async throws -> Subcategory {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        let updatedSubcategory = Subcategory(
            id: subcategory.id,
            categoryId: subcategory.categoryId,
            name: subcategory.name,
            description: subcategory.description,
            icon: subcategory.icon,
            isActive: subcategory.isActive,
            sortOrder: subcategory.sortOrder,
            userId: userId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection(subcategoriesCollection)
            .document(updatedSubcategory.id)
            .setData(from: updatedSubcategory)
        
        return updatedSubcategory
    }
    
    func updateSubcategory(_ subcategory: Subcategory) async throws -> Subcategory {
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
        
        try await db.collection(subcategoriesCollection)
            .document(updatedSubcategory.id)
            .setData(from: updatedSubcategory, merge: true)
        
        return updatedSubcategory
    }
    
    func deleteSubcategory(id: String) async throws {
        try await db.collection(subcategoriesCollection).document(id).delete()
    }
    
    // MARK: - Default data
    
    func initializeDefaultCategories() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw CategoryError.userNotAuthenticated
        }
        
        // Check if user already has categories
        let existingCategories = try await getCategories()
        if !existingCategories.isEmpty {
            return // User already has categories
        }
        
        // Create default categories
        let defaultCategories = DefaultCategoriesData.getDefaultCategories(for: userId)
        var createdCategories: [Category] = []
        
        for category in defaultCategories {
            let createdCategory = try await createCategory(category)
            createdCategories.append(createdCategory)
        }
        
        // Create default subcategories
        let defaultSubcategories = DefaultCategoriesData.getDefaultSubcategories(for: createdCategories)
        for subcategory in defaultSubcategories {
            try await createSubcategory(subcategory)
        }
    }
}

enum CategoryError: LocalizedError {
    case userNotAuthenticated
    case categoryNotFound
    case subcategoryNotFound
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return String(localized: "category.error.not_authenticated")
        case .categoryNotFound:
            return String(localized: "category.error.category_not_found")
        case .subcategoryNotFound:
            return String(localized: "category.error.subcategory_not_found")
        case .invalidData:
            return String(localized: "category.error.invalid_data")
        case .networkError(let error):
            return String(localized: "category.error.network") + ": \(error.localizedDescription)"
        }
    }
}