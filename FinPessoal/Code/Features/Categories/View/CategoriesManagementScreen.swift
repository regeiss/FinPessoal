//
//  CategoriesManagementScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import SwiftUI
import FirebaseAuth

struct CategoriesManagementScreen: View {
    @StateObject private var subcategoryService: SubcategoryManagementService
    @State private var selectedCategory: TransactionCategory = .food
    @State private var showingAddSubcategory = false
    @State private var newSubcategoryName = ""
    @State private var subcategoryUsage: [String: Int] = [:]
    @State private var showingAddCategory = false
    @State private var categories: [Category] = []
    @State private var selectedCategoryForEdit: Category?
    @State private var isLoadingCategories = false
    @State private var selectedTab = 0 // 0 = Categories, 1 = Subcategories

    let transactionRepository: TransactionRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let forcePhoneLayout: Bool

    init(
        transactionRepository: TransactionRepositoryProtocol,
        categoryRepository: CategoryRepositoryProtocol,
        forcePhoneLayout: Bool = false
    ) {
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
        self._subcategoryService = StateObject(wrappedValue: SubcategoryManagementService(transactionRepository: transactionRepository))
        self.forcePhoneLayout = forcePhoneLayout
    }
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? "mock-user"
    }

    var body: some View {
        Group {
            if selectedTab == 0 {
                categoriesView
            } else {
                subcategoriesView
            }
        }
        .task {
            await loadCategories()
        }
    }

    @ViewBuilder
    private var subcategoriesView: some View {
        if UIDevice.current.userInterfaceIdiom == .pad && !forcePhoneLayout {
            iPadCategoriesView
        } else {
            iPhoneCategoriesView
        }
    }

    @ViewBuilder
    private var categoriesView: some View {
        if UIDevice.current.userInterfaceIdiom == .pad && !forcePhoneLayout {
            iPadCategoryManagementView
        } else {
            iPhoneCategoryManagementView
        }
    }
    
    private var iPhoneCategoriesView: some View {
        VStack(spacing: 0) {
                // Segmented control for tabs
                Picker("", selection: $selectedTab) {
                    Text(String(localized: "categories.categories.tab")).tag(0)
                    Text(String(localized: "categories.subcategories.tab")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

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
        .background(.clear)
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
    
    private var iPadCategoriesView: some View {
        NavigationSplitView {
            // Category picker in sidebar
            VStack(spacing: 0) {
                // Segmented control for tabs
                Picker("", selection: $selectedTab) {
                    Text(String(localized: "categories.categories.tab")).tag(0)
                    Text(String(localized: "categories.subcategories.tab")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

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
                                .foregroundColor(selectedCategory == category ? .white : (.blue))
                                .frame(width: 32, height: 32)
                                .background(selectedCategory == category ? (.blue) : Color.blue.opacity(0.1))
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

    // MARK: - Category Management Views

    private var iPhoneCategoryManagementView: some View {
        VStack(spacing: 0) {
                // Segmented control for tabs
                Picker("", selection: $selectedTab) {
                    Text(String(localized: "categories.categories.tab")).tag(0)
                    Text(String(localized: "categories.subcategories.tab")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                if isLoadingCategories {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Section(header: Text(type.displayName)) {
                            ForEach(categories.filter { $0.transactionType == type }, id: \.id) { category in
                                CategoryManagementRow(
                                    category: category,
                                    onEdit: {
                                        selectedCategoryForEdit = category
                                    },
                                    onDelete: {
                                        deleteCategory(category)
                                    }
                                )
                            }
                        }
                    }
                }
                }
                .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            await loadCategories()
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(
                categoryRepository: categoryRepository,
                userId: currentUserId,
                onSave: {
                    Task {
                        await loadCategories()
                    }
                }
            )
        }
        .sheet(item: $selectedCategoryForEdit) { category in
            CategoryFormView(
                categoryRepository: categoryRepository,
                userId: currentUserId,
                category: category,
                onSave: {
                    Task {
                        await loadCategories()
                    }
                    selectedCategoryForEdit = nil
                }
            )
        }
    }

    private var iPadCategoryManagementView: some View {
            VStack(spacing: 0) {
                // Segmented control for tabs
                Picker("", selection: $selectedTab) {
                    Text(String(localized: "categories.categories.tab")).tag(0)
                    Text(String(localized: "categories.subcategories.tab")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                if isLoadingCategories {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Section(header: Text(type.displayName)) {
                            ForEach(categories.filter { $0.transactionType == type }, id: \.id) { category in
                                CategoryManagementRow(
                                    category: category,
                                    onEdit: {
                                        selectedCategoryForEdit = category
                                    },
                                    onDelete: {
                                        deleteCategory(category)
                                    }
                                )
                            }
                        }
                    }
                }
                }
                .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddCategory = true
                } label: {
                    Label(String(localized: "category.add"), systemImage: "plus")
                }
            }
        }
        .refreshable {
            await loadCategories()
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(
                categoryRepository: categoryRepository,
                userId: currentUserId,
                onSave: {
                    Task {
                        await loadCategories()
                    }
                }
            )
        }
        .sheet(item: $selectedCategoryForEdit) { category in
            CategoryFormView(
                categoryRepository: categoryRepository,
                userId: currentUserId,
                category: category,
                onSave: {
                    Task {
                        await loadCategories()
                    }
                    selectedCategoryForEdit = nil
                }
            )
        }
    }

    // MARK: - Helper Functions

    private func loadCategories() async {
        isLoadingCategories = true
        defer { isLoadingCategories = false }

        do {
            let loadedCategories = try await categoryRepository.getCategories()
            await MainActor.run {
                categories = loadedCategories.sorted { $0.sortOrder < $1.sortOrder }
            }
        } catch {
            print("Error loading categories: \(error)")
        }
    }

    private func deleteCategory(_ category: Category) {
        Task {
            do {
                try await categoryRepository.deleteCategory(id: category.id)
                await loadCategories()
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
}

// MARK: - Category Management Row
struct CategoryManagementRow: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: category.icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(category.displayColor)
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)

                if let description = category.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack {
                    Text(category.transactionType.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(category.displayColor.opacity(0.2))
                        .foregroundColor(category.displayColor)
                        .cornerRadius(4)

                    if category.isActive {
                        Text(String(localized: "category.active"))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog(
            String(localized: "category.delete.confirmation.title"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "common.delete"), role: .destructive) {
                onDelete()
            }
            Button(String(localized: "common.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "category.delete.confirmation.message"))
        }
    }
}

struct CategoryScrollPickerView: View {
    @Binding var selectedCategory: TransactionCategory

    var body: some View {
        FlowLayout(spacing: 12) {
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
        .onAppear {
            print("CategoryScrollPickerView: Total categories available: \(TransactionCategory.allCases.count)")
            for category in TransactionCategory.allCases.sorted() {
                print("Category: \(category.rawValue) - \(category.displayName)")
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
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
    CategoriesManagementScreen(
        transactionRepository: MockTransactionRepository(),
        categoryRepository: MockCategoryRepository()
    )
}