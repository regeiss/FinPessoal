//
//  FirebaseCategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//  Converted to Realtime Database on 24/12/25
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class FirebaseCategoryRepository: CategoryRepositoryProtocol {
  private let database = Database.database().reference()
  private let categoriesPath = "categories"

  // MARK: - Category Operations

  func getCategories() async throws -> [Category] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CategoryError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(categoriesPath)
      .child(userId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let categories = try data.compactMap { (categoryId, categoryData) -> Category? in
      var mutableData = categoryData
      mutableData["id"] = categoryId
      return try Category.fromDictionary(mutableData)
    }

    return categories
      .filter { $0.isActive }
      .sorted { $0.sortOrder < $1.sortOrder }
  }

  func getCategories(for transactionType: TransactionType) async throws -> [Category] {
    let allCategories = try await getCategories()
    return allCategories
      .filter { $0.transactionType == transactionType }
      .sorted { $0.sortOrder < $1.sortOrder }
  }

  func getCategory(by id: String) async throws -> Category? {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CategoryError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(categoriesPath)
      .child(userId)
      .child(id)
      .getData()

    guard let data = snapshot.value as? [String: Any] else {
      return nil
    }

    var mutableData = data
    mutableData["id"] = id
    return try Category.fromDictionary(mutableData)
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

    let categoryData = try updatedCategory.toDictionary()

    try await database
      .child(categoriesPath)
      .child(userId)
      .child(updatedCategory.id)
      .setValue(categoryData)

    return updatedCategory
  }

  func updateCategory(_ category: Category) async throws -> Category {
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
      userId: category.userId,
      createdAt: category.createdAt,
      updatedAt: Date()
    )

    let categoryData = try updatedCategory.toDictionary()

    try await database
      .child(categoriesPath)
      .child(userId)
      .child(updatedCategory.id)
      .updateChildValues(categoryData)

    return updatedCategory
  }

  func deleteCategory(id: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CategoryError.userNotAuthenticated
    }

    try await database
      .child(categoriesPath)
      .child(userId)
      .child(id)
      .removeValue()
  }

  func initializeDefaultCategories() async throws -> [Category] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CategoryError.userNotAuthenticated
    }

    // Check if user already has categories
    let existingCategories = try await getCategories()
    if !existingCategories.isEmpty {
      return existingCategories  // User already has categories
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
