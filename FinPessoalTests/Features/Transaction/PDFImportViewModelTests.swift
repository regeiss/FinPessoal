import XCTest
@testable import FinPessoal

@MainActor
class PDFImportViewModelTests: XCTestCase {
  var viewModel: PDFImportViewModel!
  var mockRepository: MockTransactionRepository!

  override func setUpWithError() throws {
    mockRepository = MockTransactionRepository()
    viewModel = PDFImportViewModel(repository: mockRepository)
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isImporting)
    XCTAssertFalse(viewModel.showFilePicker)
    XCTAssertFalse(viewModel.showReviewSheet)
    XCTAssertTrue(viewModel.selectedTransactions.isEmpty)
    XCTAssertNil(viewModel.importResult)
  }

  func testToggleSelection() {
    let transactionId = "test-123"

    // Initially not selected
    XCTAssertFalse(viewModel.selectedTransactions.contains(transactionId))

    // Select
    viewModel.toggleSelection(transactionId)
    XCTAssertTrue(viewModel.selectedTransactions.contains(transactionId))

    // Deselect
    viewModel.toggleSelection(transactionId)
    XCTAssertFalse(viewModel.selectedTransactions.contains(transactionId))
  }

  func testSelectAll() {
    // Create mock result
    let mockResult = PDFImportResult(
      extracted: [
        ParsedTransaction(date: Date(), description: "Test 1", amount: 10, type: .expense, confidence: 0.9),
        ParsedTransaction(date: Date(), description: "Test 2", amount: 20, type: .expense, confidence: 0.9)
      ],
      duplicates: [],
      errors: []
    )

    viewModel.importResult = mockResult
    viewModel.selectAll()

    XCTAssertEqual(viewModel.selectedTransactions.count, 2)
    XCTAssertTrue(viewModel.allSelected)
  }

  func testDeselectAll() {
    viewModel.selectedTransactions = ["1", "2", "3"]
    viewModel.deselectAll()

    XCTAssertTrue(viewModel.selectedTransactions.isEmpty)
    XCTAssertEqual(viewModel.selectedCount, 0)
  }
}
