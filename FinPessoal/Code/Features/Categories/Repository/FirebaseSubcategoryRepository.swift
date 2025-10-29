//
//  FirebaseSubcategoryRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseSubcategoryRepository: SubcategoryRepositoryProtocol {
  private let db = Firestore.firestore()
  private let subcategoriesCollection = "subcategories"

  // MARK: - Subcategory Operations

  func getSubcategories() async throws -> [Subcategory] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw SubcategoryError.userNotAuthenticated
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
      throw SubcategoryError.userNotAuthenticated
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

  func createSubcategory(_ subcategory: Subcategory) async throws -> Subcategory
  {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw SubcategoryError.userNotAuthenticated
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

    try db.collection(subcategoriesCollection)
      .document(updatedSubcategory.id)
      .setData(from: updatedSubcategory)

    return updatedSubcategory
  }

  func updateSubcategory(_ subcategory: Subcategory) async throws -> Subcategory
  {
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

    try db.collection(subcategoriesCollection)
      .document(updatedSubcategory.id)
      .setData(from: updatedSubcategory, merge: true)

    return updatedSubcategory
  }

  func deleteSubcategory(id: String) async throws {
    try await db.collection(subcategoriesCollection).document(id).delete()
  }

  func deleteSubcategories(for categoryId: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw SubcategoryError.userNotAuthenticated
    }

    let snapshot = try await db.collection(subcategoriesCollection)
      .whereField("userId", isEqualTo: userId)
      .whereField("categoryId", isEqualTo: categoryId)
      .getDocuments()

    let batch = db.batch()
    for document in snapshot.documents {
      batch.deleteDocument(document.reference)
    }

    try await batch.commit()
  }

  func initializeDefaultSubcategories(for categories: [Category]) async throws
    -> [Subcategory]
  {
    guard Auth.auth().currentUser != nil else {
      throw SubcategoryError.userNotAuthenticated
    }

    // Check if user already has subcategories
    let existingSubcategories = try await getSubcategories()
    if !existingSubcategories.isEmpty {
      return existingSubcategories  // User already has subcategories
    }

    // Create default subcategories
    let defaultSubcategories = DefaultCategoriesData.getDefaultSubcategories(
      for: categories
    )
    var createdSubcategories: [Subcategory] = []

    for subcategory in defaultSubcategories {
      let createdSubcategory = try await createSubcategory(subcategory)
      createdSubcategories.append(createdSubcategory)
    }

    return createdSubcategories
  }
}

enum SubcategoryError: LocalizedError {
  case userNotAuthenticated
  case subcategoryNotFound
  case invalidData
  case networkError(Error)

  var errorDescription: String? {
    switch self {
    case .userNotAuthenticated:
      return String(localized: "subcategory.error.not_authenticated")
    case .subcategoryNotFound:
      return String(localized: "subcategory.error.subcategory_not_found")
    case .invalidData:
      return String(localized: "subcategory.error.invalid_data")
    case .networkError(let error):
      return String(localized: "subcategory.error.network")
        + ": \(error.localizedDescription)"
    }
  }
}

