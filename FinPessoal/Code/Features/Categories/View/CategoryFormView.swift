//
//  CategoryFormView.swift
//  FinPessoal
//
//  Created by Claude on 05/10/25.
//

import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) var dismiss

    let categoryRepository: CategoryRepositoryProtocol
    let userId: String
    let category: Category?
    let onSave: () -> Void

    @State private var name: String
    @State private var description: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var selectedTransactionType: TransactionType
    @State private var sortOrder: Int

    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Available icons for categories
    private let availableIcons = [
        "fork.knife", "car", "house", "cross", "gamecontroller", "bag",
        "doc.text", "dollarsign.circle", "chart.line.uptrend.xyaxis",
        "questionmark.circle", "creditcard", "gift", "airplane", "cart",
        "book", "graduationcap", "heart", "tshirt", "phone", "wrench",
        "leaf", "lightbulb", "music.note", "tv", "cup.and.saucer",
        "briefcase", "building.2", "star", "flag", "calendar"
    ]

    // Available colors for categories
    private let availableColors: [(name: String, color: Color)] = [
        ("red", .red), ("blue", .blue), ("green", .green), ("orange", .orange),
        ("purple", .purple), ("yellow", .yellow), ("pink", .pink), ("cyan", .cyan),
        ("indigo", .indigo), ("teal", .teal), ("mint", .mint), ("brown", .brown),
        ("gray", .gray)
    ]

    init(
        categoryRepository: CategoryRepositoryProtocol,
        userId: String,
        category: Category? = nil,
        onSave: @escaping () -> Void
    ) {
        self.categoryRepository = categoryRepository
        self.userId = userId
        self.category = category
        self.onSave = onSave

        // Initialize state based on whether we're editing or creating
        _name = State(initialValue: category?.name ?? "")
        _description = State(initialValue: category?.description ?? "")
        _selectedIcon = State(initialValue: category?.icon ?? "questionmark.circle")
        _selectedColor = State(initialValue: category?.color ?? "blue")
        _selectedTransactionType = State(initialValue: category?.transactionType ?? .expense)
        _sortOrder = State(initialValue: category?.sortOrder ?? 0)
    }

    var isEditing: Bool {
        category != nil
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                // Basic Information
                Section {
                    StyledTextField(
                      text: $name,
                      placeholder: String(localized: "category.name.placeholder")
                    )

                    StyledTextField(
                      text: $description,
                      placeholder: String(localized: "category.description.placeholder")
                    )
                } header: {
                    Text(String(localized: "category.basic.info"))
                }

                // Transaction Type
                Section {
                    Picker(String(localized: "category.transaction.type"), selection: $selectedTransactionType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(isEditing) // Can't change type when editing
                } header: {
                    Text(String(localized: "category.type.section"))
                } footer: {
                    if isEditing {
                        Text(String(localized: "category.type.cannot.change"))
                            .font(.caption)
                    }
                }

                // Appearance
                Section {
                    // Icon Selection
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            Text(String(localized: "category.icon"))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: selectedIcon)
                                .foregroundColor(getColor(selectedColor))
                                .font(.system(size: 24))
                                .frame(width: 32, height: 32)
                        }
                    }

                    // Color Selection
                    Button {
                        showingColorPicker = true
                    } label: {
                        HStack {
                            Text(String(localized: "category.color"))
                                .foregroundColor(.primary)
                            Spacer()
                            Circle()
                                .fill(getColor(selectedColor))
                                .frame(width: 32, height: 32)
                        }
                    }
                } header: {
                    Text(String(localized: "category.appearance"))
                }

                // Preview
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(getColor(selectedColor))
                                .clipShape(Circle())

                            Text(name.isEmpty ? String(localized: "category.name.placeholder") : name)
                                .font(.headline)

                            if !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                } header: {
                    Text(String(localized: "category.preview"))
                }
            }
            .navigationTitle(isEditing ? String(localized: "category.edit") : String(localized: "category.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveCategory()
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
            .alert(String(localized: "common.error"), isPresented: $showError) {
                Button(String(localized: "common.ok")) {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .disabled(isSaving)
            .overlay {
                if isSaving {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }

    private func getColor(_ colorName: String) -> Color {
        availableColors.first(where: { $0.name == colorName })?.color ?? .gray
    }

    private func saveCategory() {
        guard isValid else { return }

        isSaving = true

        Task {
            do {
                let categoryToSave: Category

                if let existingCategory = category {
                    // Update existing category
                    categoryToSave = Category(
                        id: existingCategory.id,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        icon: selectedIcon,
                        color: selectedColor,
                        transactionType: existingCategory.transactionType,
                        isActive: existingCategory.isActive,
                        sortOrder: sortOrder,
                        userId: userId,
                        createdAt: existingCategory.createdAt,
                        updatedAt: Date()
                    )
                    _ = try await categoryRepository.updateCategory(categoryToSave)
                } else {
                    // Create new category
                    categoryToSave = Category(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                        icon: selectedIcon,
                        color: selectedColor,
                        transactionType: selectedTransactionType,
                        sortOrder: sortOrder,
                        userId: userId
                    )
                    _ = try await categoryRepository.createCategory(categoryToSave)
                }

                await MainActor.run {
                    isSaving = false
                    onSave()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Icon Picker View
struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String

    private let icons = [
        "fork.knife", "car", "house", "cross", "gamecontroller", "bag",
        "doc.text", "dollarsign.circle", "chart.line.uptrend.xyaxis",
        "questionmark.circle", "creditcard", "gift", "airplane", "cart",
        "book", "graduationcap", "heart", "tshirt", "phone", "wrench",
        "leaf", "lightbulb", "music.note", "tv", "cup.and.saucer",
        "briefcase", "building.2", "star", "flag", "calendar",
        "fuelpump", "bus", "shippingbox", "pills", "stethoscope",
        "drop", "bolt", "wifi", "banknote", "key"
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 60))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack {
                                Image(systemName: icon)
                                    .font(.system(size: 28))
                                    .foregroundColor(selectedIcon == icon ? .white : (.blue))
                                    .frame(width: 60, height: 60)
                                    .background(selectedIcon == icon ? (.blue) : Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "category.select.icon"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Picker View
struct ColorPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedColor: String

    private let colors: [(name: String, color: Color)] = [
        ("red", .red), ("blue", .blue), ("green", .green), ("orange", .orange),
        ("purple", .purple), ("yellow", .yellow), ("pink", .pink), ("cyan", .cyan),
        ("indigo", .indigo), ("teal", .teal), ("mint", .mint), ("brown", .brown),
        ("gray", .gray)
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 60))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(colors, id: \.name) { colorItem in
                        Button {
                            selectedColor = colorItem.name
                            dismiss()
                        } label: {
                            VStack {
                                Circle()
                                    .fill(colorItem.color)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == colorItem.name ? (.blue) : Color.clear, lineWidth: 3)
                                    )

                                if selectedColor == colorItem.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "category.select.color"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryFormView(
        categoryRepository: MockCategoryRepository(),
        userId: "preview-user",
        onSave: {}
    )
}
