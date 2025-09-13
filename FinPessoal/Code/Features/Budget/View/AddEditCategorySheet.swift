//
//  AddEditCategorySheet.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct AddEditCategorySheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var categoryViewModel: CategoryViewModel
  
  let categoryToEdit: CustomCategory?
  let isEditing: Bool
  
  @State private var showingDeleteAlert = false
  @State private var showingNameExistsAlert = false
  
  init(categoryViewModel: CategoryViewModel, categoryToEdit: CustomCategory? = nil) {
    self.categoryViewModel = categoryViewModel
    self.categoryToEdit = categoryToEdit
    self.isEditing = categoryToEdit != nil
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField(String(localized: "category.name.placeholder"), text: $categoryViewModel.name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          
          TextField(String(localized: "category.description.placeholder"), text: $categoryViewModel.description, axis: .vertical)
            .lineLimit(2...4)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } header: {
          Text(String(localized: "category.basic.info"))
        } footer: {
          Text(String(localized: "category.basic.info.footer"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Section {
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(CategoryIcon.allCases, id: \.self) { icon in
              Button {
                categoryViewModel.selectedIcon = icon
              } label: {
                let isSelected = categoryViewModel.selectedIcon == icon
                let iconColor = isSelected ? Color.white : categoryViewModel.selectedColor.color
                let backgroundColor = isSelected ? categoryViewModel.selectedColor.color : categoryViewModel.selectedColor.color.opacity(0.1)
                
                Image(systemName: icon.rawValue)
                  .font(.system(size: 20))
                  .foregroundColor(iconColor)
                  .frame(width: 44, height: 44)
                  .background(backgroundColor)
                  .clipShape(Circle())
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding(.vertical, 8)
        } header: {
          Text(String(localized: "category.icon.selection"))
        }
        
        Section {
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(CategoryColor.allCases, id: \.self) { color in
              Button {
                categoryViewModel.selectedColor = color
              } label: {
                let isSelected = categoryViewModel.selectedColor == color
                let strokeColor = isSelected ? Color.primary : Color.clear
                let scale = isSelected ? 1.1 : 1.0
                
                Circle()
                  .fill(color.color)
                  .frame(width: 36, height: 36)
                  .overlay(
                    Circle()
                      .stroke(strokeColor, lineWidth: 3)
                  )
                  .scaleEffect(scale)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding(.vertical, 8)
        } header: {
          Text(String(localized: "category.color.selection"))
        }
        
        Section {
          HStack {
            Image(systemName: categoryViewModel.selectedIcon.rawValue)
              .font(.system(size: 24))
              .foregroundColor(.white)
              .frame(width: 48, height: 48)
              .background(categoryViewModel.selectedColor.color)
              .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
              let displayName = categoryViewModel.name.isEmpty ? String(localized: "category.preview.name") : categoryViewModel.name
              let displayDescription = categoryViewModel.description.isEmpty ? String(localized: "category.preview.description") : categoryViewModel.description
              
              Text(displayName)
                .font(.headline)
                .foregroundColor(.primary)
              
              Text(displayDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            }
            
            Spacer()
          }
          .padding(.vertical, 8)
        } header: {
          Text(String(localized: "category.preview"))
        }
        
        if isEditing {
          Section {
            Button {
              showingDeleteAlert = true
            } label: {
              HStack {
                Image(systemName: "trash")
                  .foregroundColor(.red)
                Text(String(localized: "category.delete"))
                  .foregroundColor(.red)
              }
            }
          }
        }
      }
      .navigationTitle(isEditing ? String(localized: "category.edit.title") : String(localized: "category.add.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            categoryViewModel.resetForm()
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(isEditing ? String(localized: "common.save") : String(localized: "category.create")) {
            saveCategory()
          }
          .disabled(!categoryViewModel.isValidCategory)
        }
      }
      .alert(String(localized: "category.delete.confirm"), isPresented: $showingDeleteAlert) {
        Button(String(localized: "common.cancel"), role: .cancel) { }
        Button(String(localized: "category.delete"), role: .destructive) {
          deleteCategory()
        }
      } message: {
        Text(String(localized: "category.delete.message"))
      }
      .alert(String(localized: "category.name.exists.title"), isPresented: $showingNameExistsAlert) {
        Button("OK") { }
      } message: {
        Text(String(localized: "category.name.exists.message"))
      }
    }
    .onAppear {
      if let category = categoryToEdit {
        categoryViewModel.populateForm(with: category)
      }
    }
  }
  
  private func saveCategory() {
    // Check if name already exists
    if categoryViewModel.categoryNameExists(categoryViewModel.name, excluding: categoryToEdit?.id) {
      showingNameExistsAlert = true
      return
    }
    
    let success: Bool
    if let category = categoryToEdit {
      success = categoryViewModel.updateCategory(category)
    } else {
      success = categoryViewModel.createCategory()
    }
    
    if success {
      dismiss()
    }
  }
  
  private func deleteCategory() {
    if let category = categoryToEdit {
      categoryViewModel.deleteCategory(category)
      dismiss()
    }
  }
}