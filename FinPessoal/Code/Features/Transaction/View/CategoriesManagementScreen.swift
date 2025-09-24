//
//  CategoriesManagementScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import SwiftUI

struct CategoriesManagementScreen: View {
    @StateObject private var subcategoryService: SubcategoryManagementService
    @State private var selectedCategory: TransactionCategory = .food
    @State private var showingAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var subcategoryUsage: [String: Int] = [:]
    
    let forcePhoneLayout: Bool
    
    init(transactionRepository: TransactionRepositoryProtocol, forcePhoneLayout: Bool = false) {
        self._subcategoryService = StateObject(wrappedValue: SubcategoryManagementService(transactionRepository: transactionRepository))
        self.forcePhoneLayout = forcePhoneLayout
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad && !forcePhoneLayout {
            iPadCategoriesView
        } else {
            iPhoneCategoriesView
        }
    }
    
    private var iPhoneCategoriesView: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category picker
                CategoryScrollPickerView(selectedCategory: $selectedCategory)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Subcategories list
                List {
                    Section {
                        let allSubcategories = subcategoryService.getAllSubcategories(for: selectedCategory)
                        let customSubcategories = subcategoryService.getCustomSubcategories(for: selectedCategory)
                        
                        ForEach(allSubcategories, id: \.self) { subcategory in
                            SubcategoryRow(
                                name: subcategory,
                                usage: subcategoryUsage[subcategory] ?? 0,
                                isCustom: customSubcategories.contains(subcategory),
                                canDelete: customSubcategories.contains(subcategory),
                                onDelete: {
                                    Task {
                                        await subcategoryService.removeCustomSubcategory(subcategory, from: selectedCategory)
                                        await loadUsageData()
                                    }
                                }
                            )
                        }
                    } header: {
                        HStack {
                            Text(String(localized: "categories.subcategories.title"))
                            Spacer()
                            Button {
                                showingAddSubcategory = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                        }
                    } footer: {
                        Text(String(localized: "categories.subcategories.footer"))
                            .font(.caption)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle(String(localized: "categories.management.title"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadUsageData()
            }
            .onChange(of: selectedCategory) { _, _ in
                Task {
                    await loadUsageData()
                }
            }
            .alert(String(localized: "categories.subcategory.add"), isPresented: $showingAddSubcategory) {
                TextField(String(localized: "categories.subcategory.name.placeholder"), text: $newSubcategoryName)
                Button(String(localized: "common.cancel"), role: .cancel) {
                    newSubcategoryName = ""
                }
                Button(String(localized: "common.add")) {
                    subcategoryService.addCustomSubcategory(newSubcategoryName, to: selectedCategory)
                    newSubcategoryName = ""
                    Task {
                        await loadUsageData()
                    }
                }
                .disabled(newSubcategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text(String(localized: "categories.subcategory.add.message"))
            }
            .alert(String(localized: "common.error"), isPresented: .constant(subcategoryService.errorMessage != nil)) {
                Button(String(localized: "common.ok")) {
                    subcategoryService.errorMessage = nil
                }
            } message: {
                if let error = subcategoryService.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var iPadCategoriesView: some View {
        NavigationSplitView {
            // Category picker in sidebar
            VStack(spacing: 0) {
                Text("Categorias")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                Text("Selecione uma categoria para gerenciar suas subcategorias")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                List(TransactionCategory.allCases.sorted(), id: \.self) { category in
                    Button {
                        selectedCategory = category
                        Task {
                            await loadUsageData()
                        }
                    } label: {
                        HStack {
                            Image(systemName: category.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedCategory == category ? .white : .blue)
                                .frame(width: 32, height: 32)
                                .background(selectedCategory == category ? .blue : .blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(subcategoryService.getAllSubcategories(for: category).count) subcategorias")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(selectedCategory == category ? Color.blue.opacity(0.1) : Color.clear)
                }
                .listStyle(SidebarListStyle())
            }
            .navigationTitle("Categorias")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadUsageData()
            }
        } detail: {
            // Subcategories management in detail view
            VStack(spacing: 0) {
                // Header with selected category
                HStack {
                    Image(systemName: selectedCategory.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(.blue)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedCategory.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(subcategoryService.getAllSubcategories(for: selectedCategory).count) subcategorias")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingAddSubcategory = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text(String(localized: "categories.subcategory.add"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Subcategories list
                List {
                    let allSubcategories = subcategoryService.getAllSubcategories(for: selectedCategory)
                    let customSubcategories = subcategoryService.getCustomSubcategories(for: selectedCategory)
                    
                    ForEach(allSubcategories, id: \.self) { subcategory in
                        SubcategoryRow(
                            name: subcategory,
                            usage: subcategoryUsage[subcategory] ?? 0,
                            isCustom: customSubcategories.contains(subcategory),
                            canDelete: customSubcategories.contains(subcategory),
                            onDelete: {
                                Task {
                                    await subcategoryService.removeCustomSubcategory(subcategory, from: selectedCategory)
                                    await loadUsageData()
                                }
                            }
                        )
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle(selectedCategory.displayName)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadUsageData()
            }
            .alert(String(localized: "categories.subcategory.add"), isPresented: $showingAddSubcategory) {
                TextField(String(localized: "categories.subcategory.name.placeholder"), text: $newSubcategoryName)
                Button(String(localized: "common.cancel"), role: .cancel) {
                    newSubcategoryName = ""
                }
                Button(String(localized: "common.add")) {
                    subcategoryService.addCustomSubcategory(newSubcategoryName, to: selectedCategory)
                    newSubcategoryName = ""
                    Task {
                        await loadUsageData()
                    }
                }
                .disabled(newSubcategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text(String(localized: "categories.subcategory.add.message"))
            }
            .alert(String(localized: "common.error"), isPresented: .constant(subcategoryService.errorMessage != nil)) {
                Button(String(localized: "common.ok")) {
                    subcategoryService.errorMessage = nil
                }
            } message: {
                if let error = subcategoryService.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private func loadUsageData() async {
        let usage = await subcategoryService.getSubcategoryUsage(for: selectedCategory)
        await MainActor.run {
            subcategoryUsage = usage
        }
    }
}

struct CategoryScrollPickerView: View {
    @Binding var selectedCategory: TransactionCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let category: TransactionCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubcategoryRow: View {
    let name: String
    let usage: Int
    let isCustom: Bool
    let canDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                    
                    if isCustom {
                        Text(String(localized: "categories.custom"))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                if usage > 0 {
                    Text(String(localized: "categories.usage.count", defaultValue: "\(usage) transactions"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(String(localized: "categories.usage.unused"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if canDelete && usage == 0 {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            } else if usage > 0 {
                Image(systemName: "lock")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoriesManagementScreen(transactionRepository: MockTransactionRepository())
}