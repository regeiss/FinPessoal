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
            .foregroundStyle(Color.oldMoney.textSecondary)
          TextField(String(localized: "categories.search.placeholder"), text: $searchText)
            .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.oldMoney.surface)
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
                .foregroundStyle(Color.oldMoney.textSecondary)
            }
          } footer: {
            Text(String(localized: "categories.available.footer"))
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }
          
          Section {
            Button {
              showingAddCategory = true
            } label: {
              HStack {
                Image(systemName: "plus.circle")
                  .foregroundStyle(Color.oldMoney.income)
                Text(String(localized: "category.add.new"))
                  .foregroundStyle(Color.oldMoney.income)
              }
            }
            
            Button {
              categoryViewModel.resetToDefaults()
            } label: {
              HStack {
                Image(systemName: "arrow.clockwise")
                  .foregroundStyle(Color.oldMoney.accent)
                Text(String(localized: "categories.reset.defaults"))
                  .foregroundStyle(Color.oldMoney.accent)
              }
            }
            
            Button {
              categoryViewModel.selectAllCategories()
            } label: {
              HStack {
                Image(systemName: "checkmark.circle")
                  .foregroundStyle(Color.oldMoney.income)
                Text(String(localized: "categories.select.all"))
                  .foregroundStyle(Color.oldMoney.income)
              }
            }
            
            Button {
              categoryViewModel.deselectAllCategories()
            } label: {
              HStack {
                Image(systemName: "xmark.circle")
                  .foregroundStyle(Color.oldMoney.expense)
                Text(String(localized: "categories.deselect.all"))
                  .foregroundStyle(Color.oldMoney.expense)
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
            .foregroundStyle(Color.oldMoney.text)
          
          if category.isCustom {
            Text(String(localized: "category.custom.badge"))
              .font(.caption2)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.orange.opacity(0.2))
              .foregroundStyle(Color.oldMoney.warning)
              .clipShape(Capsule())
          }
          
          Spacer()
        }
        
        Text(category.description)
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
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
              .foregroundStyle(Color.oldMoney.accent)
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