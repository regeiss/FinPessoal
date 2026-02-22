import XCTest
@testable import FinPessoal

class StatementMLProcessorTests: XCTestCase {
  var processor: StatementMLProcessor!

  override func setUpWithError() throws {
    processor = StatementMLProcessor()
  }

  func testBuildPrompt() {
    let extractedText = ExtractedPDFText(
      pages: [PageText(pageNumber: 1, text: "Nubank\n10/01/2026 Restaurante R$ 50,00", confidence: 0.9)],
      totalPages: 1
    )

    let prompt = processor.buildPrompt(from: extractedText)

    XCTAssertTrue(prompt.contains("transaction"))
    XCTAssertTrue(prompt.contains("Restaurante"))
  }

  func testParseValidJSON() throws {
    let json = """
    {
      "transactions": [
        {
          "date": "2026-01-10",
          "description": "Restaurante",
          "amount": 50.0,
          "type": "expense",
          "suggested_category": "food"
        }
      ]
    }
    """

    let parsed = try processor.parseMLResponse(json)
    XCTAssertEqual(parsed.count, 1)
    XCTAssertEqual(parsed[0].description, "Restaurante")
  }
}
