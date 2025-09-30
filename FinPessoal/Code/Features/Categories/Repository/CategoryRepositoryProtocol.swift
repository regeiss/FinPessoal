//
//  CategoryRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

protocol CategoryRepositoryProtocol {
    // MARK: - Category Operations
    func getCategories() async throws -> [Category]
    func getCategories(for transactionType: TransactionType) async throws -> [Category]
    func getCategory(by id: String) async throws -> Category?
    func createCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(id: String) async throws
    func initializeDefaultCategories() async throws -> [Category]
}

protocol SubcategoryRepositoryProtocol {
    // MARK: - Subcategory Operations
    func getSubcategories() async throws -> [Subcategory]
    func getSubcategories(for categoryId: String) async throws -> [Subcategory]
    func getSubcategory(by id: String) async throws -> Subcategory?
    func createSubcategory(_ subcategory: Subcategory) async throws -> Subcategory
    func updateSubcategory(_ subcategory: Subcategory) async throws -> Subcategory
    func deleteSubcategory(id: String) async throws
    func deleteSubcategories(for categoryId: String) async throws
    func initializeDefaultSubcategories(for categories: [Category]) async throws -> [Subcategory]
}