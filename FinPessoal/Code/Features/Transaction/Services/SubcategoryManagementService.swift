//
//  SubcategoryManagementService.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Foundation
import Combine

class SubcategoryManagementService: ObservableObject {
    @Published var categorySubcategories: [TransactionCategory: [String]] = [:]
    @Published var customSubcategories: [TransactionCategory: [String]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let transactionRepository: TransactionRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(transactionRepository: TransactionRepositoryProtocol) {
        self.transactionRepository = transactionRepository
        loadSubcategories()
    }
    
    // MARK: - Loading
    
    func loadSubcategories() {
        isLoading = true
        defer { isLoading = false }
        
        // Load default subcategories
        for category in TransactionCategory.allCases {
            let defaultSubcategories = category.subcategories.map { $0.displayName }
            categorySubcategories[category] = defaultSubcategories
        }
        
        // Load custom subcategories from UserDefaults (would be Firebase in production)
        loadCustomSubcategories()
    }
    
    private func loadCustomSubcategories() {
        for category in TransactionCategory.allCases {
            let key = "custom_subcategories_\(category.rawValue)"
            let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
            customSubcategories[category] = stored
        }
    }
    
    // MARK: - Subcategory Management
    
    func getAllSubcategories(for category: TransactionCategory) -> [String] {
        let defaults = categorySubcategories[category] ?? []
        let customs = customSubcategories[category] ?? []
        return defaults + customs
    }
    
    func getCustomSubcategories(for category: TransactionCategory) -> [String] {
        return customSubcategories[category] ?? []
    }
    
    func addCustomSubcategory(_ name: String, to category: TransactionCategory) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if subcategory already exists
        let existing = getAllSubcategories(for: category)
        guard !existing.contains(where: { $0.lowercased() == trimmedName.lowercased() }) else {
            errorMessage = String(localized: "subcategory.error.duplicate")
            return
        }
        
        // Add to custom subcategories
        var customs = customSubcategories[category] ?? []
        customs.append(trimmedName)
        customSubcategories[category] = customs
        
        // Save to UserDefaults
        let key = "custom_subcategories_\(category.rawValue)"
        UserDefaults.standard.set(customs, forKey: key)
        
        objectWillChange.send()
    }
    
    func removeCustomSubcategory(_ name: String, from category: TransactionCategory) async {
        // Check if subcategory is in use
        let isInUse = await isSubcategoryInUse(name, in: category)
        if isInUse {
            errorMessage = String(localized: "subcategory.error.inUse")
            return
        }
        
        // Remove from custom subcategories
        var customs = customSubcategories[category] ?? []
        customs.removeAll { $0 == name }
        customSubcategories[category] = customs
        
        // Save to UserDefaults
        let key = "custom_subcategories_\(category.rawValue)"
        UserDefaults.standard.set(customs, forKey: key)
        
        objectWillChange.send()
    }
    
    func canRemoveSubcategory(_ name: String, from category: TransactionCategory) async -> Bool {
        // Can only remove custom subcategories
        let customs = customSubcategories[category] ?? []
        guard customs.contains(name) else { return false }
        
        // Check if in use
        return !(await isSubcategoryInUse(name, in: category))
    }
    
    private func isSubcategoryInUse(_ subcategoryName: String, in category: TransactionCategory) async -> Bool {
        do {
            let transactions = try await transactionRepository.getTransactions(by: category)
            return transactions.contains { transaction in
                transaction.subcategory?.displayName == subcategoryName
            }
        } catch {
            return true // Assume in use if we can't check
        }
    }
    
    // MARK: - Statistics
    
    func getSubcategoryUsage(for category: TransactionCategory) async -> [String: Int] {
        do {
            let transactions = try await transactionRepository.getTransactions(by: category)
            var usage: [String: Int] = [:]
            
            for transaction in transactions {
                if let subcategory = transaction.subcategory {
                    usage[subcategory.displayName, default: 0] += 1
                }
            }
            
            return usage
        } catch {
            return [:]
        }
    }
}