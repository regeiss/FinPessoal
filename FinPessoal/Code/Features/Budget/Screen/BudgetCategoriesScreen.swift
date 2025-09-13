//
//  BudgetCategoriesScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct BudgetCategoriesScreen: View {
  @StateObject private var categoryViewModel = CategoryViewModel()
  @State private var showingCustomizeAlert = false
  @State private var showingAddCategory = false
  @State private var showingEditCategory = false
  @State private var categoryToEdit: CustomCategory?
  @State private var searchText = ""
  
  var filteredCategories: [CategoryProtocol] {
    return categoryViewModel.getFilteredCategories(searchText: searchText)
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Search bar
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
          TextField(String(localized: "categories.search.placeholder"), text: $searchText)
            .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.bottom, 16)
        
        // Categories list
        List {
          Section {
            ForEach(filteredCategories, id: \.id) { category in
              EnhancedCategoryRowView(
                category: category,
                isSelected: categoryViewModel.isCategorySelected(category.id),
                onToggle: {
                  categoryViewModel.toggleCategorySelection(category.id)
                },
                onEdit: category.isCustom ? {
                  if let customCategory = category as? CustomCategory {
                    categoryToEdit = customCategory
                    showingEditCategory = true
                  }
                } : nil
              )
            }
          } header: {
            HStack {
              Text(String(localized: "categories.available.header"))
                .font(.headline)
              Spacer()
              Text("\(categoryViewModel.selectedCategories.count)/\(categoryViewModel.getAllCategories().count)")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          } footer: {
            Text(String(localized: "categories.available.footer"))
              .font(.caption)
              .foregroundColor(.secondary)
          }
          
          Section {
            Button {
              showingAddCategory = true
            } label: {
              HStack {
                Image(systemName: "plus.circle")
                  .foregroundColor(.green)
                Text(String(localized: "category.add.new"))
                  .foregroundColor(.green)
              }
            }
            
            Button {
              categoryViewModel.resetToDefaults()
            } label: {
              HStack {
                Image(systemName: "arrow.clockwise")
                  .foregroundColor(.blue)
                Text(String(localized: "categories.reset.defaults"))
                  .foregroundColor(.blue)
              }
            }
            
            Button {
              categoryViewModel.selectAllCategories()
            } label: {
              HStack {
                Image(systemName: "checkmark.circle")
                  .foregroundColor(.green)
                Text(String(localized: "categories.select.all"))
                  .foregroundColor(.green)
              }
            }
            
            Button {
              categoryViewModel.deselectAllCategories()
            } label: {
              HStack {
                Image(systemName: "xmark.circle")
                  .foregroundColor(.red)
                Text(String(localized: "categories.deselect.all"))
                  .foregroundColor(.red)
              }
            }
          } header: {
            Text(String(localized: "categories.actions.header"))
          }
        }
        .listStyle(InsetGroupedListStyle())
      }
      .navigationTitle(String(localized: "categories.management.title"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.save")) {
            showingCustomizeAlert = true
          }
          .fontWeight(.semibold)
        }
      }
      .alert(String(localized: "categories.save.success"), isPresented: $showingCustomizeAlert) {
        Button("OK") { }
      } message: {
        Text(String(localized: "categories.save.success.message"))
      }
      .sheet(isPresented: $showingAddCategory) {
        AddEditCategorySheet(categoryViewModel: categoryViewModel)
      }
      .sheet(isPresented: $showingEditCategory) {
        if let category = categoryToEdit {
          AddEditCategorySheet(categoryViewModel: categoryViewModel, categoryToEdit: category)
        }
      }
    }
  }
}

struct EnhancedCategoryRowView: View {
  let category: CategoryProtocol
  let isSelected: Bool
  let onToggle: () -> Void
  let onEdit: (() -> Void)?
  
  var body: some View {
    HStack(spacing: 12) {
      // Category icon
      if let customCategory = category as? CustomCategory {
        Image(systemName: customCategory.icon)
          .font(.system(size: 20))
          .foregroundColor(isSelected ? .white : customCategory.color)
          .frame(width: 36, height: 36)
          .background(isSelected ? customCategory.color : customCategory.color.opacity(0.1))
          .clipShape(Circle())
      } else {
        Image(systemName: category.icon)
          .font(.system(size: 20))
          .foregroundColor(isSelected ? .white : .blue)
          .frame(width: 36, height: 36)
          .background(isSelected ? .blue : .blue.opacity(0.1))
          .clipShape(Circle())
      }
      
      // Category info
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(category.displayName)
            .font(.headline)
            .foregroundColor(.primary)
          
          if category.isCustom {
            Text(String(localized: "category.custom.badge"))
              .font(.caption2)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.orange.opacity(0.2))
              .foregroundColor(.orange)
              .clipShape(Capsule())
          }
          
          Spacer()
        }
        
        Text(category.description)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(2)
      }
      
      // Actions
      HStack(spacing: 8) {
        if let onEdit = onEdit {
          Button {
            onEdit()
          } label: {
            Image(systemName: "pencil")
              .font(.system(size: 16))
              .foregroundColor(.blue)
          }
          .buttonStyle(PlainButtonStyle())
        }
        
        Button {
          onToggle()
        } label: {
          Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 20))
            .foregroundColor(isSelected ? .green : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .padding(.vertical, 4)
  }
}