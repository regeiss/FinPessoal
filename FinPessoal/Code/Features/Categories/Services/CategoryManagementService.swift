//
//  CategoryManagementService.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Combine
import FirebaseAuth
import Foundation

class CategoryManagementService: ObservableObject {
  @Published var customCategories: [BuiltInCategory] = []
  @Published var categoryUsage: [String: CategoryUsage] = [:]
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let transactionRepository: TransactionRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()

  init(transactionRepository: TransactionRepositoryProtocol) {
    self.transactionRepository = transactionRepository
  }

  // MARK: - Category Management

  func loadCategories() async {
    isLoading = true
    defer { isLoading = false }

    let userId = Auth.auth().currentUser?.uid ?? "mock-user"

    // Load default categories
    await MainActor.run {
      customCategories = TransactionCategory.allCases.map { category in
        BuiltInCategory(transactionCategory: category)
      }
      print("✅ Loaded \(customCategories.count) categories")
    }

    // TODO: Load custom categories from Firebase
    // TODO: Load usage statistics
    await loadCategoryUsage()
  }

  private func loadCategoryUsage() async {
    do {
      let transactions = try await transactionRepository.getTransactions()
      let usage = calculateCategoryUsage(from: transactions)

      await MainActor.run {
        categoryUsage = usage
      }
    } catch {
      print("Failed to load category usage: \(error)")
    }
  }

  private func calculateCategoryUsage(from transactions: [Transaction])
    -> [String: CategoryUsage]
  {
    var usage: [String: CategoryUsage] = [:]

    // Group transactions by category
    let groupedByCategory = Dictionary(grouping: transactions) { transaction in
      transaction.category.rawValue
    }

    for (categoryId, categoryTransactions) in groupedByCategory {
      let lastUsed = categoryTransactions.map(\.date).max()
      usage[categoryId] = CategoryUsage(
        categoryId: categoryId,
        transactionCount: categoryTransactions.count,
        lastUsed: lastUsed
      )
    }

    // Add unused categories
    for category in TransactionCategory.allCases {
      if usage[category.rawValue] == nil {
        usage[category.rawValue] = CategoryUsage(
          categoryId: category.rawValue,
          transactionCount: 0,
          lastUsed: nil
        )
      }
    }

    return usage
  }

  // MARK: - Category Editing

  func canEditCategory(_ category: BuiltInCategory) -> Bool {
    guard let usage = categoryUsage[category.id] else { return true }
    return !usage.isInUse || category.isCustom
  }

  func canDeleteCategory(_ category: BuiltInCategory) -> Bool {
    guard category.isCustom else { return false }
    guard let usage = categoryUsage[category.id] else { return true }
    return !usage.isInUse
  }

  func updateCategory(
    _ category: BuiltInCategory,
    name: String,
    icon: String,
    color: String
  ) async throws {
    // Since we're only working with built-in categories, we can't actually update them
    // This would be where custom category updates would happen
    throw CategoryError.categoryInUse
  }

  func createCustomCategory(
    name: String,
    icon: String,
    color: String,
    baseCategory: TransactionCategory
  ) async throws -> BuiltInCategory {
    // For now, we're not implementing custom categories
    // This would create a new custom category
    throw CategoryError.unauthorized
  }

  func deleteCategory(_ category: BuiltInCategory) async throws {
    guard canDeleteCategory(category) else {
      throw CategoryError.categoryInUse
    }

    // Built-in categories cannot be deleted
    throw CategoryError.categoryInUse
  }

  // MARK: - Validation

  func validateCategoryName(_ name: String, excludingId: String? = nil) -> Bool
  {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return false }

    // Check for duplicates
    let existingNames =
      customCategories
      .filter { $0.id != excludingId }
      .map { $0.displayName.lowercased() }

    return !existingNames.contains(trimmedName.lowercased())
  }

  // MARK: - Category Usage Info

  func getCategoryUsageInfo(_ category: BuiltInCategory) -> CategoryUsage? {
    return categoryUsage[category.id]
  }

  func getEditableCategories() -> [BuiltInCategory] {
    return customCategories.filter { canEditCategory($0) }
  }

  func getUnusedCategories() -> [BuiltInCategory] {
    var result: [BuiltInCategory] = []
    for category in customCategories {
      guard let usage = categoryUsage[category.id] else {
        result.append(category)
        continue
      }
      if !usage.isInUse {
        result.append(category)
      }
    }
    return result
  }
}

// MARK: - Errors

enum CategoryError: Error, LocalizedError {
  case categoryInUse
  case invalidName
  case duplicateName
  case unauthorized

  var errorDescription: String? {
    switch self {
    case .categoryInUse:
      return String(localized: "category.error.inUse")
    case .invalidName:
      return String(localized: "category.error.invalidName")
    case .duplicateName:
      return String(localized: "category.error.duplicateName")
    case .unauthorized:
      return String(localized: "category.error.unauthorized")
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .categoryInUse:
      return String(localized: "category.error.inUse.suggestion")
    case .invalidName:
      return String(localized: "category.error.invalidName.suggestion")
    case .duplicateName:
      return String(localized: "category.error.duplicateName.suggestion")
    case .unauthorized:
      return String(localized: "category.error.unauthorized.suggestion")
    }
  }
}

