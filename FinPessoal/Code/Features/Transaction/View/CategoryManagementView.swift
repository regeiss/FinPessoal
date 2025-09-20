//
//  CategoryManagementView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import SwiftUI

struct CategoryManagementView: View {
    @StateObject private var categoryService: CategoryManagementService
    @Environment(\.dismiss) private var dismiss
    
    
    init(transactionRepository: TransactionRepositoryProtocol) {
        self._categoryService = StateObject(wrappedValue: CategoryManagementService(transactionRepository: transactionRepository))
        print("🏗️ CategoryManagementView initialized")
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(categoryService.customCategories) { category in
                        CategoryManagementRow(
                            category: category,
                            usage: categoryService.getCategoryUsageInfo(category)
                        )
                    }
                } header: {
                    Text(String(localized: "categories.management.title"))
                } footer: {
                    Text(String(localized: "categories.management.footer"))
                        .font(.caption)
                }
            }
            .navigationTitle(String(localized: "categories.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.close")) {
                        dismiss()
                    }
                }
                
            }
            .task {
                await categoryService.loadCategories()
            }
            .refreshable {
                await categoryService.loadCategories()
            }
        }
    }
}

struct CategoryManagementRow: View {
    let category: BuiltInCategory
    let usage: CategoryUsage?
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon and color
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.displayName)
                    .font(.headline)
                
                HStack {
                    if let usage = usage {
                        if usage.isInUse {
                            Text(String(localized: "categories.usage.count", defaultValue: "\(usage.transactionCount) transactions"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(String(localized: "categories.usage.unused"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if category.isCustom {
                        Text(String(localized: "categories.custom"))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoryManagementView(transactionRepository: MockTransactionRepository())
}