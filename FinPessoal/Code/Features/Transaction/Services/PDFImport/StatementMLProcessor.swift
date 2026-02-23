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
    // TEMPORARY FALLBACK: Rule-based parser
    // TODO: Replace with actual Core ML inference when Phi-3 model is available

    // Check if model is available - if yes, use ML; if no, use fallback
    if modelManager.isModelAvailable() {
      // Load model and perform inference
      let model = try await modelManager.loadModel()
      // TODO: Implement actual ML inference
      // let input = try MLDictionaryFeatureProvider(dictionary: ["input": prompt])
      // let output = try model.prediction(from: input)
      throw PDFImportError.modelInferenceFailed("ML model loaded but inference not yet implemented")
    } else {
      // Fallback to rule-based parsing
      return try parseWithRules(prompt)
    }
  }

  // MARK: - Rule-Based Fallback Parser

  private func parseWithRules(_ text: String) throws -> String {
    // Extract just the statement text (after the system prompt)
    guard let statementText = text.components(separatedBy: "Extract transactions from this statement:").last else {
      throw PDFImportError.noTextFound
    }

    var transactions: [[String: Any]] = []
    let lines = statementText.components(separatedBy: .newlines)

    // Common Brazilian date patterns: DD/MM/YYYY or DD/MM/YY
    let datePattern = #"(\d{2})[/\-](\d{2})[/\-](\d{2,4})"#
    // Amount patterns: R$ 1.234,56 or 1.234,56 or -1.234,56
    let amountPattern = #"(?:R\$\s*)?(-?)(\d{1,3}(?:\.\d{3})*),(\d{2})"#

    for line in lines {
      let trimmedLine = line.trimmingCharacters(in: .whitespaces)
      guard !trimmedLine.isEmpty else { continue }

      // Try to find date
      guard let dateRange = trimmedLine.range(of: datePattern, options: .regularExpression),
            let amountRange = trimmedLine.range(of: amountPattern, options: .regularExpression) else {
        continue
      }

      // Extract date
      let dateString = String(trimmedLine[dateRange])
      guard let date = parseDate(dateString) else { continue }

      // Extract amount
      let amountString = String(trimmedLine[amountRange])
      guard let amount = parseAmount(amountString) else { continue }

      // Extract description (text between date and amount)
      let descStartIndex = dateRange.upperBound
      let descEndIndex = amountRange.lowerBound
      var description = String(trimmedLine[descStartIndex..<descEndIndex])
        .trimmingCharacters(in: .whitespaces)

      // Clean up description
      if description.isEmpty {
        description = "Transação"
      }

      // Determine type (negative = expense, positive = income)
      let type = amount < 0 ? "expense" : "income"

      // Categorize based on keywords
      let category = categorizeByKeywords(description)

      let transaction: [String: Any] = [
        "date": ISO8601DateFormatter().string(from: date),
        "description": description,
        "amount": abs(amount),
        "type": type,
        "suggested_category": category
      ]

      transactions.append(transaction)
    }

    // Convert to JSON
    let response: [String: Any] = ["transactions": transactions]
    let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw PDFImportError.invalidModelOutput
    }

    return jsonString
  }

  private func parseDate(_ dateString: String) -> Date? {
    // Try DD/MM/YYYY
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    if let date = formatter.date(from: dateString) {
      return date
    }

    // Try DD/MM/YY
    formatter.dateFormat = "dd/MM/yy"
    return formatter.date(from: dateString)
  }

  private func parseAmount(_ amountString: String) -> Double? {
    // Remove R$ and whitespace
    var cleaned = amountString.replacingOccurrences(of: "R$", with: "")
      .trimmingCharacters(in: .whitespaces)

    // Check for negative
    let isNegative = cleaned.hasPrefix("-")
    if isNegative {
      cleaned.removeFirst()
    }

    // Remove thousand separators (.) and replace decimal separator (,) with (.)
    cleaned = cleaned.replacingOccurrences(of: ".", with: "")
      .replacingOccurrences(of: ",", with: ".")

    guard let value = Double(cleaned) else {
      return nil
    }

    return isNegative ? -value : value
  }

  private func categorizeByKeywords(_ description: String) -> String {
    let lowercased = description.lowercased()

    // Food & Dining
    if lowercased.contains("restaurante") || lowercased.contains("lanchonete") ||
       lowercased.contains("padaria") || lowercased.contains("mercado") ||
       lowercased.contains("supermercado") || lowercased.contains("ifood") ||
       lowercased.contains("uber eats") || lowercased.contains("rappi") {
      return "food"
    }

    // Transport
    if lowercased.contains("uber") || lowercased.contains("99") ||
       lowercased.contains("taxi") || lowercased.contains("posto") ||
       lowercased.contains("combustivel") || lowercased.contains("gasolina") ||
       lowercased.contains("estacionamento") {
      return "transport"
    }

    // Bills
    if lowercased.contains("energia") || lowercased.contains("luz") ||
       lowercased.contains("agua") || lowercased.contains("internet") ||
       lowercased.contains("telefone") || lowercased.contains("celular") ||
       lowercased.contains("netflix") || lowercased.contains("spotify") {
      return "bills"
    }

    // Shopping
    if lowercased.contains("loja") || lowercased.contains("magazine") ||
       lowercased.contains("americanas") || lowercased.contains("mercado livre") ||
       lowercased.contains("amazon") || lowercased.contains("shopee") {
      return "shopping"
    }

    // Healthcare
    if lowercased.contains("farmacia") || lowercased.contains("drogaria") ||
       lowercased.contains("hospital") || lowercased.contains("clinica") ||
       lowercased.contains("medico") {
      return "healthcare"
    }

    // Entertainment
    if lowercased.contains("cinema") || lowercased.contains("show") ||
       lowercased.contains("teatro") || lowercased.contains("ingresso") {
      return "entertainment"
    }

    // Salary
    if lowercased.contains("salario") || lowercased.contains("pagamento") ||
       lowercased.contains("deposito") {
      return "salary"
    }

    return "other"
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
