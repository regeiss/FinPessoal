//
//  CategorySubcategoryPicker.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import SwiftUI

struct CategorySubcategoryPicker: View {
    @Binding var selectedCategory: TransactionCategory
    @Binding var selectedSubcategory: TransactionSubcategory?
    @EnvironmentObject var themeManager: ThemeManager

    @State private var showingCategoryPicker = false
    @State private var showingSubcategoryPicker = false

    var body: some View {
        VStack(spacing: 12) {
            // Category Selection
            Button(action: {
                showingCategoryPicker = true
            }) {
                HStack {
                    Image(systemName: selectedCategory.icon)
                        .foregroundColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "transactions.category"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(selectedCategory.displayName)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Subcategory Selection (only if category has subcategories)
            if !selectedCategory.subcategories.isEmpty {
                Button(action: {
                    showingSubcategoryPicker = true
                }) {
                    HStack {
                        Image(systemName: selectedSubcategory?.icon ?? "tag")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "transactions.subcategory"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(selectedSubcategory?.displayName ?? String(localized: "transactions.subcategory.select"))
                                .font(.body)
                                .foregroundColor(selectedSubcategory != nil ? .primary : .secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory, selectedSubcategory: $selectedSubcategory)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingSubcategoryPicker) {
            SubcategoryPickerView(category: selectedCategory, selectedSubcategory: $selectedSubcategory)
                .environmentObject(themeManager)
        }
    }
}

struct CategoryPickerView: View {
    @Binding var selectedCategory: TransactionCategory
    @Binding var selectedSubcategory: TransactionSubcategory?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            List {
                ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        // Reset subcategory when changing category
                        selectedSubcategory = nil
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
                                .frame(width: 24)

                            Text(category.displayName)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "transactions.select.category"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SubcategoryPickerView: View {
    let category: TransactionCategory
    @Binding var selectedSubcategory: TransactionSubcategory?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            List {
                // Option to clear subcategory
                Button(action: {
                    selectedSubcategory = nil
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        Text(String(localized: "transactions.subcategory.none"))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedSubcategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                Divider()
                
                // Subcategory options
                ForEach(category.subcategories.sorted(), id: \.self) { subcategory in
                    Button(action: {
                        selectedSubcategory = subcategory
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: subcategory.icon)
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text(subcategory.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedSubcategory == subcategory {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "transactions.select.subcategory"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCategory: TransactionCategory = .food
        @State private var selectedSubcategory: TransactionSubcategory? = .restaurants

        var body: some View {
            Form {
                CategorySubcategoryPicker(
                    selectedCategory: $selectedCategory,
                    selectedSubcategory: $selectedSubcategory
                )
            }
            .environmentObject(ThemeManager())
        }
    }

    return PreviewWrapper()
}