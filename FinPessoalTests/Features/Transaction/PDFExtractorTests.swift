import XCTest
import PDFKit
@testable import FinPessoal

class PDFExtractorTests: XCTestCase {
  var extractor: PDFExtractor!
  var testPDFURL: URL!

  override func setUpWithError() throws {
    extractor = PDFExtractor()
    testPDFURL = createMockPDF()
  }

  func testExtractTextFromValidPDF() async throws {
    let result = try await extractor.extractText(from: testPDFURL)

    XCTAssertGreaterThan(result.pages.count, 0)
    XCTAssertEqual(result.totalPages, 1)
    XCTAssertFalse(result.pages[0].text.isEmpty)
    XCTAssertGreaterThan(result.pages[0].confidence, 0.0)
  }

  func testExtractFromEncryptedPDF() async {
    // TODO: Create encrypted PDF for testing
  }

  // Helper
  private func createMockPDF() -> URL {
    let tempURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("test.pdf")

    let pdfData = createSimplePDF(with: "Test transaction data")
    try? pdfData.write(to: tempURL)

    return tempURL
  }

  private func createSimplePDF(with text: String) -> Data {
    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)

    return renderer.pdfData { context in
      context.beginPage()
      let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
      text.draw(at: CGPoint(x: 50, y: 50), withAttributes: attrs)
    }
  }
}
