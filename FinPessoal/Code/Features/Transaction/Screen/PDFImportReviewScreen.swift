import SwiftUI

struct PDFImportReviewScreen: View {
  @ObservedObject var viewModel: PDFImportViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingSaveConfirmation = false
  @State private var isSaving = false

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        if let result = viewModel.importResult {
          // Summary Header
          summaryHeader(result: result)

          // Transactions List
          ScrollView {
            LazyVStack(spacing: 12) {
              ForEach(result.extracted) { transaction in
                ParsedTransactionRow(
                  transaction: transaction,
                  isSelected: viewModel.selectedTransactions.contains(transaction.id),
                  onToggle: {
                    viewModel.toggleSelection(transaction.id)
                  }
                )
              }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
          }

          // Bottom Actions
          bottomActionBar(result: result)
        } else {
          ProgressView()
        }
      }
      .background(Color.oldMoney.background)
      .navigationTitle(String(localized: "pdf.import.review.title", defaultValue: "Review Import"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "Cancel", defaultValue: "Cancel")) {
            viewModel.cancelImport()
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if viewModel.allSelected {
              viewModel.deselectAll()
            } else {
              viewModel.selectAll()
            }
          }) {
            Text(viewModel.allSelected ?
                 String(localized: "Deselect All", defaultValue: "Deselect All") :
                 String(localized: "Select All", defaultValue: "Select All"))
          }
        }
      }
      .alert(String(localized: "pdf.import.save.confirmation.title", defaultValue: "Save Transactions?"),
             isPresented: $showingSaveConfirmation) {
        Button(String(localized: "Cancel", defaultValue: "Cancel"), role: .cancel) { }
        Button(String(localized: "Save", defaultValue: "Save")) {
          Task {
            await saveTransactions()
          }
        }
      } message: {
        Text(String(localized: "pdf.import.save.confirmation.message",
                    defaultValue: "Save \(viewModel.selectedCount) selected transactions?"))
      }
    }
  }

  // MARK: - Subviews

  private func summaryHeader(result: PDFImportResult) -> some View {
    VStack(spacing: 12) {
      HStack(spacing: 20) {
        summaryCard(
          title: String(localized: "pdf.import.summary.extracted", defaultValue: "Extracted"),
          count: result.extracted.count,
          color: .green
        )

        summaryCard(
          title: String(localized: "pdf.import.summary.duplicates", defaultValue: "Duplicates"),
          count: result.duplicates.count,
          color: .orange
        )

        summaryCard(
          title: String(localized: "pdf.import.summary.selected", defaultValue: "Selected"),
          count: viewModel.selectedCount,
          color: .blue
        )
      }
      .padding(.horizontal)
      .padding(.vertical, 16)

      if result.duplicates.count > 0 {
        Text(String(localized: "pdf.import.duplicates.info",
                    defaultValue: "\(result.duplicates.count) duplicate transactions were found and excluded"))
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal)
          .padding(.bottom, 8)
      }
    }
    .background(Color.oldMoney.surface)
  }

  private func summaryCard(title: String, count: Int, color: Color) -> some View {
    VStack(spacing: 4) {
      Text("\(count)")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(color)

      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
  }

  private func bottomActionBar(result: PDFImportResult) -> some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 16) {
        Button(action: {
          viewModel.cancelImport()
          dismiss()
        }) {
          Text(String(localized: "Cancel", defaultValue: "Cancel"))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }

        Button(action: {
          showingSaveConfirmation = true
        }) {
          HStack {
            if isSaving {
              ProgressView()
                .tint(.white)
            }
            Text(String(localized: "pdf.import.save.button",
                        defaultValue: "Save \(viewModel.selectedCount)"))
              .font(.headline)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(viewModel.selectedCount > 0 ? Color.blue : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(12)
        }
        .disabled(viewModel.selectedCount == 0 || isSaving)
      }
      .padding()
      .background(Color.oldMoney.surface)
    }
  }

  // MARK: - Actions

  private func saveTransactions() async {
    isSaving = true

    do {
      try await viewModel.saveSelectedTransactions()
      dismiss()
    } catch {
      viewModel.errorMessage = error.localizedDescription
    }

    isSaving = false
  }
}

// MARK: - ParsedTransactionRow

struct ParsedTransactionRow: View {
  let transaction: ParsedTransaction
  let isSelected: Bool
  let onToggle: () -> Void

  var body: some View {
    Button(action: onToggle) {
      HStack(spacing: 12) {
        // Selection Checkbox
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.title3)
          .foregroundColor(isSelected ? .blue : .gray)
          .accessibilityLabel(isSelected ? "Selected" : "Not selected")

        // Transaction Info
        VStack(alignment: .leading, spacing: 4) {
          Text(transaction.description)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .lineLimit(2)

          HStack(spacing: 8) {
            Text(transaction.date, style: .date)
              .font(.caption)
              .foregroundColor(.secondary)

            if let category = transaction.suggestedCategory {
              Label(category.displayName, systemImage: category.icon)
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Confidence Badge
            confidenceBadge
          }
        }

        Spacer()

        // Amount
        VStack(alignment: .trailing, spacing: 2) {
          Text(transaction.amount, format: .currency(code: "BRL"))
            .font(.headline)
            .foregroundColor(transaction.type == .expense ? .red : .green)

          Text(transaction.type.displayName)
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(isSelected ? Color.blue.opacity(0.1) : Color.oldMoney.surface)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }

  private var confidenceBadge: some View {
    HStack(spacing: 4) {
      Image(systemName: confidenceIcon)
        .font(.caption2)
      Text("\(Int(transaction.confidence * 100))%")
        .font(.caption2)
    }
    .foregroundColor(confidenceColor)
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(confidenceColor.opacity(0.1))
    .cornerRadius(4)
  }

  private var confidenceIcon: String {
    if transaction.confidence >= 0.8 {
      return "checkmark.circle.fill"
    } else if transaction.confidence >= 0.6 {
      return "exclamationmark.circle.fill"
    } else {
      return "xmark.circle.fill"
    }
  }

  private var confidenceColor: Color {
    if transaction.confidence >= 0.8 {
      return .green
    } else if transaction.confidence >= 0.6 {
      return .orange
    } else {
      return .red
    }
  }
}

// MARK: - Preview

#Preview {
  let repository = MockTransactionRepository()
  let viewModel = PDFImportViewModel(repository: repository)

  // Mock data
  viewModel.importResult = PDFImportResult(
    extracted: [
      ParsedTransaction(
        date: Date(),
        description: "Restaurante ABC",
        amount: 45.50,
        type: .expense,
        suggestedCategory: .food,
        confidence: 0.92
      ),
      ParsedTransaction(
        date: Date(),
        description: "Salário",
        amount: 5000.00,
        type: .income,
        suggestedCategory: .salary,
        confidence: 0.95
      )
    ],
    duplicates: [],
    errors: []
  )
  viewModel.selectedTransactions = Set(viewModel.importResult?.extracted.map { $0.id } ?? [])

  return PDFImportReviewScreen(viewModel: viewModel)
}
