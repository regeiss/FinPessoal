import XCTest
@testable import FinPessoal

class PDFImportModelsTests: XCTestCase {
  func testExtractedPDFTextCreation() {
    let page = PageText(pageNumber: 1, text: "Sample text", confidence: 0.95)
    let extracted = ExtractedPDFText(pages: [page], totalPages: 1)

    XCTAssertEqual(extracted.pages.count, 1)
    XCTAssertEqual(extracted.totalPages, 1)
    XCTAssertEqual(extracted.pages[0].text, "Sample text")
  }

  func testParsedTransactionCreation() {
    let parsed = ParsedTransaction(
      date: Date(),
      description: "Test",
      amount: 100.0,
      type: .expense,
      suggestedCategory: .food,
      confidence: 0.85
    )

    XCTAssertEqual(parsed.amount, 100.0)
    XCTAssertEqual(parsed.type, .expense)
  }
}
