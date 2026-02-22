import Foundation

// MARK: - Extracted PDF Text Models

struct ExtractedPDFText {
  let pages: [PageText]
  let totalPages: Int

  var allText: String {
    pages.map { $0.text }.joined(separator: "\n\n")
  }
}

struct PageText {
  let pageNumber: Int
  let text: String
  let confidence: Float  // Vision recognition confidence (0.0-1.0)
}

// MARK: - Parsed Transaction Model

struct ParsedTransaction: Identifiable, Equatable {
  let id: String
  let date: Date
  let description: String
  let amount: Double
  let type: TransactionType
  let suggestedCategory: TransactionCategory?
  let confidence: Float  // ML model confidence (0.0-1.0)

  init(
    id: String = UUID().uuidString,
    date: Date,
    description: String,
    amount: Double,
    type: TransactionType,
    suggestedCategory: TransactionCategory? = nil,
    confidence: Float
  ) {
    self.id = id
    self.date = date
    self.description = description
    self.amount = amount
    self.type = type
    self.suggestedCategory = suggestedCategory
    self.confidence = confidence
  }
}

// MARK: - Import Result

struct PDFImportResult {
  let extracted: [ParsedTransaction]
  let duplicates: [ParsedTransaction]
  let errors: [PDFImportError]

  var successCount: Int { extracted.count }
  var duplicateCount: Int { duplicates.count }
  var errorCount: Int { errors.count }
}

// MARK: - Import Status

enum PDFImportStatus: Equatable {
  case idle
  case extracting(progress: Double)
  case parsing(progress: Double)
  case checkingDuplicates
  case reviewing
  case saving
  case completed(PDFImportResult)
  case failed(PDFImportError)
}

// MARK: - Errors

enum PDFImportError: LocalizedError, Equatable {
  case fileNotReadable
  case fileTooLarge(size: Int64, maxSize: Int64)
  case invalidPDFFormat
  case encryptedPDF
  case corruptedFile
  case noTextFound
  case lowConfidence(Float)
  case partialExtraction(pagesSucceeded: Int, pagesFailed: Int)
  case modelNotDownloaded
  case modelDownloadFailed(String)
  case modelLoadFailed(String)
  case modelInferenceFailed(String)
  case invalidModelOutput
  case noTransactionsFound
  case saveFailed(String)

  var errorDescription: String? {
    switch self {
    case .fileNotReadable:
      return String(localized: "pdf.error.not.readable", defaultValue: "Não foi possível ler o arquivo PDF")
    case .fileTooLarge(let size, let maxSize):
      return String(localized: "pdf.error.too.large", defaultValue: "Arquivo muito grande: \(size)MB (máximo: \(maxSize)MB)")
    case .invalidPDFFormat:
      return String(localized: "pdf.error.invalid.format", defaultValue: "Formato de PDF inválido")
    case .encryptedPDF:
      return String(localized: "pdf.error.encrypted", defaultValue: "PDF criptografado. Use um PDF sem senha")
    case .noTextFound:
      return String(localized: "pdf.error.no.text", defaultValue: "PDF parece ser uma imagem digitalizada. Use o extrato digital do banco")
    case .lowConfidence(let conf):
      return String(localized: "pdf.error.low.confidence", defaultValue: "Baixa confiança na extração (\(Int(conf * 100))%)")
    case .modelNotDownloaded:
      return String(localized: "pdf.error.model.not.downloaded", defaultValue: "Modelo ML não está baixado")
    case .noTransactionsFound:
      return String(localized: "pdf.error.no.transactions", defaultValue: "Nenhuma transação encontrada no PDF")
    default:
      return "Erro ao importar PDF"
    }
  }
}
