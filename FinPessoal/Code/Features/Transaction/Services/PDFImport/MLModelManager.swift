import Foundation
import CoreML

@MainActor
class MLModelManager {
  static let shared = MLModelManager()

  // MARK: - Configuration

  private let modelName = "statement-parser-v1"
  private let modelURL = "https://example.com/models/statement-parser-v1.mlpackage.zip"  // TODO: Replace with actual URL
  private let expectedModelSize: Int64 = 400 * 1024 * 1024  // ~400MB

  var modelStoragePath: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("MLModels")
      .appendingPathComponent("\(modelName).mlpackage")
  }

  // MARK: - Public Methods

  func isModelAvailable() -> Bool {
    FileManager.default.fileExists(atPath: modelStoragePath.path)
  }

  func downloadModel(progress: @escaping (Double) -> Void) async throws {
    // Create directory if needed
    let modelsDir = modelStoragePath.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true)

    // Download model
    let (downloadURL, response) = try await URLSession.shared.download(from: URL(string: modelURL)!) { downloaded, total in
      let progressValue = Double(downloaded) / Double(total)
      Task { @MainActor in
        progress(progressValue)
      }
    }

    // Verify download
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw PDFImportError.modelDownloadFailed("HTTP error")
    }

    // Unzip and move to storage
    try await unzipModel(from: downloadURL, to: modelStoragePath)
  }

  func loadModel() async throws -> MLModel {
    guard isModelAvailable() else {
      throw PDFImportError.modelNotDownloaded
    }

    do {
      let modelConfig = MLModelConfiguration()
      modelConfig.computeUnits = .all  // Use Neural Engine if available

      return try await MLModel.load(contentsOf: modelStoragePath, configuration: modelConfig)
    } catch {
      throw PDFImportError.modelLoadFailed(error.localizedDescription)
    }
  }

  func clearCache() throws {
    guard isModelAvailable() else { return }
    try FileManager.default.removeItem(at: modelStoragePath)
  }

  // MARK: - Private Methods

  private func unzipModel(from source: URL, to destination: URL) async throws {
    // TODO: Implement unzip logic or use third-party library
    // For now, assume model is already in .mlpackage format
    try FileManager.default.moveItem(at: source, to: destination)
  }
}

// MARK: - URLSession Download Extension

extension URLSession {
  func download(from url: URL, progress: @escaping (Int64, Int64) -> Void) async throws -> (URL, URLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let task = self.downloadTask(with: url) { url, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let url = url, let response = response else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }

        continuation.resume(returning: (url, response))
      }

      // Note: Progress tracking would need custom delegate
      task.resume()
    }
  }
}
