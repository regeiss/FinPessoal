import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class PDFImportViewModel: ObservableObject {
  // MARK: - Published Properties

  @Published var isImporting = false
  @Published var showFilePicker = false
  @Published var showReviewSheet = false
  @Published var selectedTransactions: Set<String> = []
  @Published var importResult: PDFImportResult?
  @Published var errorMessage: String?

  // MARK: - Dependencies

  private let importService: PDFStatementImportService
  private let repository: TransactionRepositoryProtocol
  private var currentAccountId: String?
  private var currentUserId: String?

  // MARK: - Computed Properties

  var allSelected: Bool {
    guard let result = importResult else { return false }
    return selectedTransactions.count == result.extracted.count
  }

  var selectedCount: Int {
    selectedTransactions.count
  }

  // MARK: - Initialization

  init(repository: TransactionRepositoryProtocol) {
    self.repository = repository
    self.importService = PDFStatementImportService(repository: repository)
  }

  // MARK: - Public Methods

  func importPDF(from url: URL, accountId: String, userId: String) async {
    currentAccountId = accountId
    currentUserId = userId
    isImporting = true
    errorMessage = nil

    do {
      let result = try await importService.importPDFStatement(from: url, toAccountId: accountId)
      importResult = result

      // Pre-select all non-duplicate transactions
      selectedTransactions = Set(result.extracted.map { $0.id })

      showReviewSheet = true
    } catch {
      if let pdfError = error as? PDFImportError {
        errorMessage = pdfError.localizedDescription
      } else {
        errorMessage = error.localizedDescription
      }
    }

    isImporting = false
  }

  func toggleSelection(_ transactionId: String) {
    if selectedTransactions.contains(transactionId) {
      selectedTransactions.remove(transactionId)
    } else {
      selectedTransactions.insert(transactionId)
    }
  }

  func selectAll() {
    guard let result = importResult else { return }
    selectedTransactions = Set(result.extracted.map { $0.id })
  }

  func deselectAll() {
    selectedTransactions.removeAll()
  }

  func saveSelectedTransactions() async throws {
    guard let result = importResult,
          let accountId = currentAccountId,
          let userId = currentUserId else {
      throw PDFImportError.saveFailed("Missing required data")
    }

    let transactionsToSave = result.extracted.filter { selectedTransactions.contains($0.id) }

    try await importService.saveTransactions(transactionsToSave, accountId: accountId, userId: userId)

    // Reset state
    importResult = nil
    selectedTransactions.removeAll()
    showReviewSheet = false
  }

  func cancelImport() {
    importResult = nil
    selectedTransactions.removeAll()
    showReviewSheet = false
  }
}
