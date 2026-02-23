import Foundation
import Combine

@MainActor
class PDFStatementImportService: ObservableObject {
  // MARK: - Published Properties

  @Published var importProgress: Double = 0.0
  @Published var importStatus: PDFImportStatus = .idle
  @Published var extractedCount: Int = 0
  @Published var duplicateCount: Int = 0
  @Published var errorMessage: String?

  // MARK: - Dependencies

  private let extractor = PDFExtractor()
  private let processor = StatementMLProcessor()
  private let repository: TransactionRepositoryProtocol

  // MARK: - Initialization

  init(repository: TransactionRepositoryProtocol) {
    self.repository = repository
  }

  // MARK: - Public Methods

  func importPDFStatement(from url: URL, toAccountId accountId: String) async throws -> PDFImportResult {
    resetState()

    do {
      // Phase 1: Extract text (0-30%)
      importStatus = .extracting(progress: 0.1)
      let extractedText = try await extractor.extractText(from: url)
      importProgress = 0.3

      // Phase 2: Parse with ML (30-70%)
      importStatus = .parsing(progress: 0.3)
      let parsedTransactions = try await processor.parseTransactions(from: extractedText)
      extractedCount = parsedTransactions.count
      importProgress = 0.7

      // Phase 3: Check duplicates (70-90%)
      importStatus = .checkingDuplicates
      let duplicates = try await checkForDuplicates(parsedTransactions)
      duplicateCount = duplicates.count
      importProgress = 0.9

      // Create result
      let newTransactions = parsedTransactions.filter { parsed in
        !duplicates.contains(where: { $0.id == parsed.id })
      }

      let result = PDFImportResult(
        extracted: newTransactions,
        duplicates: duplicates,
        errors: []
      )

      // Phase 4: Review (user handles this in UI)
      importStatus = .reviewing
      importProgress = 1.0

      return result

    } catch let error as PDFImportError {
      importStatus = .failed(error)
      errorMessage = error.localizedDescription
      throw error
    } catch {
      let wrappedError = PDFImportError.saveFailed(error.localizedDescription)
      importStatus = .failed(wrappedError)
      errorMessage = wrappedError.localizedDescription
      throw wrappedError
    }
  }

  func saveTransactions(_ transactions: [ParsedTransaction], accountId: String, userId: String) async throws {
    importStatus = .saving

    // Convert ParsedTransaction -> Transaction
    let transactionsToSave = transactions.map { parsed in
      Transaction(
        id: UUID().uuidString,
        accountId: accountId,
        amount: parsed.amount,
        description: parsed.description,
        category: parsed.suggestedCategory ?? .other,
        type: parsed.type,
        date: parsed.date,
        isRecurring: false,
        userId: userId,
        createdAt: Date(),
        updatedAt: Date()
      )
    }

    // Save to repository
    for transaction in transactionsToSave {
      try await repository.addTransaction(transaction)
    }

    let result = PDFImportResult(
      extracted: transactions,
      duplicates: [],
      errors: []
    )

    importStatus = .completed(result)
  }

  // MARK: - Private Methods

  private func resetState() {
    importProgress = 0.0
    importStatus = .idle
    extractedCount = 0
    duplicateCount = 0
    errorMessage = nil
  }

  private func checkForDuplicates(_ transactions: [ParsedTransaction]) async throws -> [ParsedTransaction] {
    // Get recent transactions (last 90 days)
    let startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
    let recentTransactions = try await repository.getTransactions(from: startDate, to: Date())

    // Find duplicates by matching date (±1 day), amount, and description similarity
    return transactions.filter { parsed in
      recentTransactions.contains { existing in
        isSimilarTransaction(parsed, existing)
      }
    }
  }

  private func isSimilarTransaction(_ parsed: ParsedTransaction, _ existing: Transaction) -> Bool {
    // Match amount (exact)
    guard abs(parsed.amount - existing.amount) < 0.01 else { return false }

    // Match date (±1 day)
    let dayDifference = Calendar.current.dateComponents([.day], from: parsed.date, to: existing.date).day ?? 999
    guard abs(dayDifference) <= 1 else { return false }

    // Match description (similarity > 0.8)
    let similarity = stringSimilarity(parsed.description, existing.description)
    return similarity > 0.8
  }

  private func stringSimilarity(_ str1: String, _ str2: String) -> Double {
    // Simple Levenshtein distance implementation
    let s1 = str1.lowercased()
    let s2 = str2.lowercased()

    if s1 == s2 { return 1.0 }
    if s1.isEmpty || s2.isEmpty { return 0.0 }

    // TODO: Implement proper Levenshtein distance
    // For now, simple contains check
    if s1.contains(s2) || s2.contains(s1) { return 0.85 }

    return 0.0
  }
}
