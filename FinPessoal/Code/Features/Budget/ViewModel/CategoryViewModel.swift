//
//  CategoryViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import Foundation
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
  @Published var customCategories: [CustomCategory] = []
  @Published var selectedCategories: Set<String> = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  // For add/edit operations
  @Published var name = ""
  @Published var description = ""
  @Published var selectedIcon: CategoryIcon = .star
  @Published var selectedColor: CategoryColor = .blue
  
  private let userDefaults = UserDefaults.standard
  private let customCategoriesKey = "customCategories"
  private let selectedCategoriesKey = "selectedBudgetCategories"
  
  init() {
    loadCustomCategories()
    loadSelectedCategories()
  }
  
  // MARK: - Data Loading
  
  func loadCustomCategories() {
    if let data = userDefaults.data(forKey: customCategoriesKey),
       let categories = try? JSONDecoder().decode([CustomCategory].self, from: data) {
      customCategories = categories.filter { $0.isActive }
    }
  }
  
  func loadSelectedCategories() {
    let savedIds = userDefaults.stringArray(forKey: selectedCategoriesKey) ?? []
    selectedCategories = Set(savedIds)
    
    // If no saved preferences, select default categories
    if selectedCategories.isEmpty {
      selectedCategories = Set(TransactionCategory.allCases.map { $0.rawValue })
    }
  }
  
  // MARK: - CRUD Operations
  
  func createCategory() -> Bool {
    guard isValidCategory else { return false }
    
    let newCategory = CustomCategory(
      name: name,
      description: description,
      iconName: selectedIcon.rawValue,
      colorName: selectedColor.rawValue
    )
    
    customCategories.append(newCategory)
    selectedCategories.insert(newCategory.id)
    saveCustomCategories()
    saveSelectedCategories()
    resetForm()
    return true
  }
  
  func updateCategory(_ category: CustomCategory) -> Bool {
    guard isValidCategory else { return false }
    
    if let index = customCategories.firstIndex(where: { $0.id == category.id }) {
      var updatedCategory = category
      updatedCategory.update(
        name: name,
        description: description,
        iconName: selectedIcon.rawValue,
        colorName: selectedColor.rawValue
      )
      customCategories[index] = updatedCategory
      saveCustomCategories()
      resetForm()
      return true
    }
    return false
  }
  
  func deleteCategory(_ category: CustomCategory) {
    customCategories.removeAll { $0.id == category.id }
    selectedCategories.remove(category.id)
    saveCustomCategories()
    saveSelectedCategories()
  }
  
  func toggleCategorySelection(_ categoryId: String) {
    if selectedCategories.contains(categoryId) {
      selectedCategories.remove(categoryId)
    } else {
      selectedCategories.insert(categoryId)
    }
    saveSelectedCategories()
  }
  
  // MARK: - Bulk Operations
  
  func selectAllCategories() {
    selectedCategories = Set(TransactionCategory.allCases.map { $0.rawValue })
    selectedCategories.formUnion(Set(customCategories.map { $0.id }))
    saveSelectedCategories()
  }
  
  func deselectAllCategories() {
    selectedCategories.removeAll()
    saveSelectedCategories()
  }
  
  func resetToDefaults() {
    selectedCategories = Set([
      TransactionCategory.food.rawValue,
      TransactionCategory.transport.rawValue,
      TransactionCategory.healthcare.rawValue,
      TransactionCategory.shopping.rawValue,
      TransactionCategory.bills.rawValue,
      TransactionCategory.entertainment.rawValue,
      TransactionCategory.salary.rawValue,
      TransactionCategory.other.rawValue
    ])
    saveSelectedCategories()
  }
  
  // MARK: - Form Management
  
  func populateForm(with category: CustomCategory) {
    name = category.name
    description = category.description
    selectedIcon = CategoryIcon(rawValue: category.iconName) ?? .star
    selectedColor = CategoryColor(rawValue: category.colorName) ?? .blue
  }
  
  func resetForm() {
    name = ""
    description = ""
    selectedIcon = .star
    selectedColor = .blue
  }
  
  var isValidCategory: Bool {
    return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
           !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  // MARK: - Helper Methods
  
  func getAllCategories() -> [CategoryProtocol] {
    let builtInCategories = TransactionCategory.allCases.map { BuiltInCategory(transactionCategory: $0) }
    let customCats = customCategories.filter { $0.isActive }
    return builtInCategories + customCats
  }
  
  func getFilteredCategories(searchText: String) -> [CategoryProtocol] {
    let allCategories = getAllCategories()
    
    if searchText.isEmpty {
      return allCategories
    } else {
      return allCategories.filter {
        $0.displayName.localizedCaseInsensitiveContains(searchText) ||
        $0.description.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  func isCategorySelected(_ categoryId: String) -> Bool {
    return selectedCategories.contains(categoryId)
  }
  
  // MARK: - Persistence
  
  private func saveCustomCategories() {
    if let data = try? JSONEncoder().encode(customCategories) {
      userDefaults.set(data, forKey: customCategoriesKey)
    }
  }
  
  private func saveSelectedCategories() {
    userDefaults.set(Array(selectedCategories), forKey: selectedCategoriesKey)
  }
  
  // MARK: - Validation
  
  func categoryNameExists(_ name: String, excluding categoryId: String? = nil) -> Bool {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    
    // Check built-in categories
    let builtInExists = TransactionCategory.allCases.contains {
      $0.displayName.lowercased() == trimmedName
    }
    
    if builtInExists { return true }
    
    // Check custom categories
    return customCategories.contains {
      $0.name.lowercased() == trimmedName && $0.id != categoryId
    }
  }
}