import XCTest
@testable import FinPessoal

class PDFStatementImportServiceTests: XCTestCase {
  var service: PDFStatementImportService!
  var mockRepository: MockTransactionRepository!

  override func setUpWithError() throws {
    mockRepository = MockTransactionRepository()
    service = PDFStatementImportService(repository: mockRepository)
  }

  func testInitialState() {
    XCTAssertEqual(service.importProgress, 0.0)
    XCTAssertEqual(service.extractedCount, 0)
  }

  func testImportFlow() async throws {
    // This will be integration test - for now just test state
    XCTAssertEqual(service.importStatus, .idle)
  }
}
