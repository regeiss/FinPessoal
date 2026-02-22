import Foundation
import PDFKit
import Vision
import UIKit

@MainActor
class PDFExtractor {
  // MARK: - Configuration

  private let maxFileSize: Int64 = 50 * 1024 * 1024  // 50MB
  private let recognitionLevel: VNRequestTextRecognitionLevel = .accurate
  private let supportedLanguages = ["pt-BR", "en-US"]

  // MARK: - Public Methods

  func extractText(from url: URL) async throws -> ExtractedPDFText {
    // Validate file
    try validatePDF(at: url)

    // Load PDF document
    guard let pdfDocument = PDFDocument(url: url) else {
      throw PDFImportError.invalidPDFFormat
    }

    // Check if encrypted
    if pdfDocument.isEncrypted {
      throw PDFImportError.encryptedPDF
    }

    let pageCount = pdfDocument.pageCount
    guard pageCount > 0 else {
      throw PDFImportError.invalidPDFFormat
    }

    // Extract text from each page
    var pages: [PageText] = []

    for pageIndex in 0..<pageCount {
      guard let page = pdfDocument.page(at: pageIndex) else {
        continue
      }

      let pageText = try await extractTextFromPage(page, pageNumber: pageIndex + 1)
      pages.append(pageText)
    }

    // Validate we got some text
    if pages.allSatisfy({ $0.text.isEmpty }) {
      throw PDFImportError.noTextFound
    }

    return ExtractedPDFText(pages: pages, totalPages: pageCount)
  }

  // MARK: - Private Methods

  private func validatePDF(at url: URL) throws {
    // Check file exists
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw PDFImportError.fileNotReadable
    }

    // Check file size
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    if let fileSize = attributes[.size] as? Int64, fileSize > maxFileSize {
      throw PDFImportError.fileTooLarge(size: fileSize / (1024 * 1024), maxSize: maxFileSize / (1024 * 1024))
    }
  }

  private func extractTextFromPage(_ page: PDFPage, pageNumber: Int) async throws -> PageText {
    // Render page as image
    let pageRect = page.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)

    let image = renderer.image { context in
      UIColor.white.set()
      context.fill(pageRect)
      context.cgContext.translateBy(x: 0, y: pageRect.size.height)
      context.cgContext.scaleBy(x: 1.0, y: -1.0)
      page.draw(with: .mediaBox, to: context.cgContext)
    }

    // Perform Vision text recognition
    return try await withCheckedThrowingContinuation { continuation in
      guard let cgImage = image.cgImage else {
        continuation.resume(throwing: PDFImportError.invalidPDFFormat)
        return
      }

      let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

      let request = VNRecognizeTextRequest { request, error in
        if let error = error {
          continuation.resume(throwing: PDFImportError.invalidPDFFormat)
          return
        }

        guard let observations = request.results as? [VNRecognizedTextObservation] else {
          continuation.resume(throwing: PDFImportError.noTextFound)
          return
        }

        var text = ""
        var totalConfidence: Float = 0.0
        var observationCount = 0

        for observation in observations {
          guard let candidate = observation.topCandidates(1).first else { continue }

          text += candidate.string + "\n"
          totalConfidence += candidate.confidence
          observationCount += 1
        }

        let avgConfidence = observationCount > 0 ? totalConfidence / Float(observationCount) : 0.0

        let pageText = PageText(
          pageNumber: pageNumber,
          text: text.trimmingCharacters(in: .whitespacesAndNewlines),
          confidence: avgConfidence
        )

        continuation.resume(returning: pageText)
      }

      request.recognitionLevel = self.recognitionLevel
      request.recognitionLanguages = self.supportedLanguages
      request.usesLanguageCorrection = true

      DispatchQueue.global(qos: .userInitiated).async {
        try? requestHandler.perform([request])
      }
    }
  }
}
