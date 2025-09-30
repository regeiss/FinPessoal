//
//  CategoriesManagementScreen.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import SwiftUI

struct CategoriesManagementScreen: View {
    @StateObject private var categoryService = CategoryManagementService(
        repository: AppConfiguration.shared.createCategoryRepository()
    )
    
    @State private var selectedTransactionType: TransactionType = .expense
    @State private var showingAddCategory = false
    @State private var showingAddSubcategory = false
    @State private var selectedCategory: Category?
    @State private var selectedCategoryForSubcategory: Category?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Transaction Type Picker
                transactionTypePicker
                
                if categoryService.isLoading {
                    ProgressView("Carregando categorias...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Categories List
                    categoriesList
                }
            }
            .navigationTitle("Gerenciar Categorias")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(
                    categoryService: categoryService,
                    transactionType: selectedTransactionType
                )
            }
            .sheet(isPresented: $showingAddSubcategory) {
                if let category = selectedCategoryForSubcategory {
                    AddSubcategorySheet(
                        categoryService: categoryService,
                        category: category
                    )
                }
            }
            .task {
                await categoryService.loadCategories()
                
                // Initialize default categories if none exist
                if categoryService.categories.isEmpty {
                    await categoryService.initializeDefaultCategories()
                }
            }
        }
    }
    
    private var transactionTypePicker: some View {
        Picker("Tipo de Transação", selection: $selectedTransactionType) {
            Text("Receitas").tag(TransactionType.income)
            Text("Despesas").tag(TransactionType.expense)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var categoriesList: some View {
        List {
            ForEach(filteredCategories) { category in
                CategoryRowView(
                    category: category,
                    subcategories: categoryService.getSubcategoriesForCategory(category.id),
                    onAddSubcategory: {
                        selectedCategoryForSubcategory = category
                        showingAddSubcategory = true
                    },
                    onEditCategory: {
                        selectedCategory = category
                        showingAddCategory = true
                    },
                    onDeleteCategory: {
                        Task {
                            await categoryService.deleteCategory(category)
                        }
                    },
                    onEditSubcategory: { subcategory in
                        // TODO: Implement edit subcategory
                    },
                    onDeleteSubcategory: { subcategory in
                        Task {
                            await categoryService.deleteSubcategory(subcategory)
                        }
                    }
                )
            }
        }
    }
    
    private var filteredCategories: [Category] {
        return categoryService.getCategoriesForType(selectedTransactionType)
    }
}

struct CategoryRowView: View {
    let category: Category
    let subcategories: [Subcategory]
    let onAddSubcategory: () -> Void
    let onEditCategory: () -> Void
    let onDeleteCategory: () -> Void
    let onEditSubcategory: (Subcategory) -> Void
    let onDeleteSubcategory: (Subcategory) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // Subcategories
            ForEach(subcategories) { subcategory in
                HStack {
                    Image(systemName: subcategory.icon)
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text(subcategory.name)
                    
                    Spacer()
                    
                    Menu {
                        Button("Editar") {
                            onEditSubcategory(subcategory)
                        }
                        
                        Button("Excluir", role: .destructive) {
                            onDeleteSubcategory(subcategory)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 20)
            }
            
            // Add Subcategory Button
            Button {
                onAddSubcategory()
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text("Adicionar Subcategoria")
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.leading, 20)
            }
        } label: {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.displayColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.headline)
                    
                    if let description = category.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(subcategories.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
                
                Menu {
                    Button("Editar") {
                        onEditCategory()
                    }
                    
                    Button("Excluir", role: .destructive) {
                        onDeleteCategory()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct AddCategorySheet: View {
    @ObservedObject var categoryService: CategoryManagementService
    let transactionType: TransactionType
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = "blue"
    
    private let availableIcons = [
        "folder", "tag", "star", "heart", "bookmark", "flag",
        "house", "car", "airplane", "bicycle", "tram",
        "cart", "bag", "briefcase", "creditcard", "banknote",
        "fork.knife", "cup.and.saucer", "gamecontroller", "tv",
        "book", "music.note", "camera", "phone"
    ]
    
    private let availableColors = [
        "red", "blue", "green", "orange", "purple", "yellow",
        "pink", "cyan", "indigo", "teal", "mint", "brown"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações da Categoria") {
                    TextField("Nome da categoria", text: $name)
                    
                    TextField("Descrição (opcional)", text: $description)
                }
                
                Section("Aparência") {
                    // Icon Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ícone")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \\.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Color Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cor")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors, id: \\.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(colorForString(color))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                        )
                                }
                            }
                        }
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(colorForString(selectedColor))
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Nome da categoria" : name)
                                .font(.headline)
                            
                            if !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nova Categoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task {
                            let success = await categoryService.createCategory(
                                name: name,
                                description: description.isEmpty ? nil : description,
                                icon: selectedIcon,
                                color: selectedColor,
                                transactionType: transactionType
                            )
                            
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func colorForString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        case "brown": return .brown
        default: return .gray
        }
    }
}

struct AddSubcategorySheet: View {
    @ObservedObject var categoryService: CategoryManagementService
    let category: Category
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "tag"
    
    private let availableIcons = [
        "tag", "bookmark", "star", "circle", "square", "triangle",
        "diamond", "heart", "leaf", "flame", "drop", "snowflake"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Categoria Principal") {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.displayColor)
                            .frame(width: 24, height: 24)
                        
                        Text(category.name)
                            .font(.headline)
                    }
                }
                
                Section("Informações da Subcategoria") {
                    TextField("Nome da subcategoria", text: $name)
                    
                    TextField("Descrição (opcional)", text: $description)
                }
                
                Section("Ícone") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableIcons, id: \\.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? category.displayColor : Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Nome da subcategoria" : name)
                                .font(.subheadline)
                            
                            if !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nova Subcategoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        Task {
                            let success = await categoryService.createSubcategory(
                                name: name,
                                description: description.isEmpty ? nil : description,
                                icon: selectedIcon,
                                categoryId: category.id
                            )
                            
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CategoriesManagementScreen()
}