import Foundation
import CoreML

@MainActor
class StatementMLProcessor {
  private let modelManager = MLModelManager.shared

  // MARK: - Public Methods

  func parseTransactions(from text: ExtractedPDFText) async throws -> [ParsedTransaction] {
    // Check if model is available
    guard modelManager.isModelAvailable() else {
      throw PDFImportError.modelNotDownloaded
    }

    // Build prompt
    let prompt = buildPrompt(from: text)

    // Process with ML model
    let mlOutput = try await processWithModel(prompt)

    // Parse JSON response
    let transactions = try parseMLResponse(mlOutput)

    return transactions
  }

  // MARK: - Prompt Building

  func buildPrompt(from text: ExtractedPDFText) -> String {
    let systemPrompt = """
    You are a financial transaction parser for Brazilian bank statements.
    Extract transaction data and return JSON.

    Output format:
    {
      "transactions": [
        {
          "date": "YYYY-MM-DD",
          "description": "string",
          "amount": number,
          "type": "expense|income|transfer",
          "suggested_category": "food|transport|bills|shopping|healthcare|entertainment|salary|investment|housing|other"
        }
      ]
    }

    Rules:
    - Parse dates in Brazilian format (DD/MM/YYYY)
    - Amounts may use comma as decimal separator
    - Negative amounts are expenses
    - Categorize based on merchant/description keywords
    """

    let userPrompt = """
    Extract transactions from this statement:

    \(text.allText)
    """

    return systemPrompt + "\n\n" + userPrompt
  }

  // MARK: - ML Processing

  private func processWithModel(_ prompt: String) async throws -> String {
    // TODO: Implement actual Core ML inference
    // For now, this is a placeholder that will be implemented
    // when we have the actual Phi-3 model converted to Core ML

    // Load model
    let model = try await modelManager.loadModel()

    // Process (placeholder - actual implementation depends on model interface)
    // let input = try MLDictionaryFeatureProvider(dictionary: ["input": prompt])
    // let output = try model.prediction(from: input)

    throw PDFImportError.modelInferenceFailed("Not yet implemented")
  }

  // MARK: - JSON Parsing

  func parseMLResponse(_ json: String) throws -> [ParsedTransaction] {
    struct MLResponse: Codable {
      struct MLTransaction: Codable {
        let date: String
        let description: String
        let amount: Double
        let type: String
        let suggested_category: String?
      }
      let transactions: [MLTransaction]
    }

    guard let data = json.data(using: .utf8) else {
      throw PDFImportError.invalidModelOutput
    }

    let decoder = JSONDecoder()
    let response = try decoder.decode(MLResponse.self, from: data)

    return try response.transactions.compactMap { mlTxn in
      // Parse date
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      guard let date = formatter.date(from: mlTxn.date) else {
        return nil
      }

      // Parse type
      let type: TransactionType
      switch mlTxn.type.lowercased() {
      case "income": type = .income
      case "expense": type = .expense
      case "transfer": type = .transfer
      default: type = .expense
      }

      // Parse category
      let category: TransactionCategory? = mlTxn.suggested_category.flatMap {
        TransactionCategory.fromString($0)
      }

      return ParsedTransaction(
        date: date,
        description: mlTxn.description,
        amount: abs(mlTxn.amount),
        type: type,
        suggestedCategory: category,
        confidence: 0.85  // TODO: Get from model
      )
    }
  }
}

// MARK: - TransactionCategory Extension

extension TransactionCategory {
  static func fromString(_ str: String) -> TransactionCategory? {
    switch str.lowercased() {
    case "food": return .food
    case "transport": return .transport
    case "bills": return .bills
    case "shopping": return .shopping
    case "healthcare", "health": return .healthcare
    case "entertainment": return .entertainment
    case "salary": return .salary
    case "investment": return .investment
    case "housing": return .housing
    default: return .other
    }
  }
}
