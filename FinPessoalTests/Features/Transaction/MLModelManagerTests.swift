import XCTest
@testable import FinPessoal

class MLModelManagerTests: XCTestCase {
  var modelManager: MLModelManager!

  override func setUpWithError() throws {
    modelManager = MLModelManager.shared
  }

  func testModelStoragePath() {
    let path = modelManager.modelStoragePath
    XCTAssertTrue(path.path.contains("MLModels"))
  }

  func testIsModelAvailable() {
    // Initially false (not downloaded)
    let available = modelManager.isModelAvailable()
    XCTAssertFalse(available)
  }

  // Note: Actual download test would be integration test
  // Unit test just verifies path and status checks
}
