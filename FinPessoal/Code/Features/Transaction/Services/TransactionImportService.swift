//
//  TransactionImportService.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Foundation
import FirebaseAuth
import Combine

class TransactionImportService: ObservableObject {
    @Published var importProgress: Double = 0.0
    @Published var importStatus: ImportStatus = .idle
    @Published var importedCount: Int = 0
    @Published var duplicateCount: Int = 0
    @Published var errorCount: Int = 0
    @Published var errorMessage: String?
    
    private let parser = OFXParser()
    private let repository: TransactionRepositoryProtocol
    
    enum ImportStatus {
        case idle
        case parsing
        case processing
        case completed
        case failed(Error)
        
        var isInProgress: Bool {
            switch self {
            case .parsing, .processing:
                return true
            default:
                return false
            }
        }
    }
    
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }
    
    @MainActor
    func importOFXFile(from url: URL, toAccountId accountId: String) async throws -> ImportResult {
        importStatus = .parsing
        importProgress = 0.1
        importedCount = 0
        duplicateCount = 0
        errorCount = 0
        errorMessage = nil
        
        do {
            let data = try Data(contentsOf: url)
            let statement = try parser.parseOFX(from: data)
            
            importStatus = .processing
            importProgress = 0.3
            
            let transactions = try await convertToTransactions(statement.transactions, accountId: accountId)
            
            let duplicates = try await checkForDuplicates(transactions)
            let newTransactions = Array(Set(transactions).subtracting(Set(duplicates)))
            
            duplicateCount = duplicates.count
            importProgress = 0.7
            
            let result = try await importTransactions(newTransactions)
            
            importedCount = result.successful.count
            errorCount = result.failed.count
            importProgress = 1.0
            importStatus = .completed
            
            return ImportResult(
                successful: result.successful,
                failed: result.failed,
                duplicates: duplicates
            )
            
        } catch {
            importStatus = .failed(error)
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    private func convertToTransactions(_ ofxTransactions: [OFXTransaction], accountId: String) async throws -> [Transaction] {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        
        return ofxTransactions.compactMap { ofxTransaction in
            let category = categorizeTransaction(ofxTransaction)
            let transactionType = determineTransactionType(ofxTransaction)
            
            return Transaction(
                id: UUID().uuidString,
                accountId: accountId,
                amount: abs(ofxTransaction.trnamt),
                description: cleanDescription(ofxTransaction.name, memo: ofxTransaction.memo),
                category: category,
                type: transactionType,
                date: ofxTransaction.dtposted,
                isRecurring: false,
                userId: currentUser.uid,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
    
    private func categorizeTransaction(_ ofxTransaction: OFXTransaction) -> TransactionCategory {
        let description = (ofxTransaction.name + " " + (ofxTransaction.memo ?? "")).lowercased()
        
        if description.contains("salary") || description.contains("payroll") || description.contains("salario") {
            return .salary
        } else if description.contains("grocery") || description.contains("supermarket") || description.contains("mercado") || description.contains("restaurant") || description.contains("food") || description.contains("restaurante") {
            return .food
        } else if description.contains("gas") || description.contains("fuel") || description.contains("posto") || description.contains("combustivel") || description.contains("transport") || description.contains("uber") || description.contains("taxi") {
            return .transport
        } else if description.contains("utility") || description.contains("electric") || description.contains("energia") || description.contains("agua") || description.contains("bill") || description.contains("conta") {
            return .bills
        } else if description.contains("rent") || description.contains("mortgage") || description.contains("aluguel") {
            return .housing
        } else if description.contains("medical") || description.contains("hospital") || description.contains("pharmacy") || description.contains("medico") {
            return .healthcare
        } else if description.contains("entertainment") || description.contains("movie") || description.contains("cinema") {
            return .entertainment
        } else if description.contains("shopping") || description.contains("store") || description.contains("loja") {
            return .shopping
        } else if description.contains("investment") || description.contains("investimento") || description.contains("stock") || description.contains("fund") {
            return .investment
        } else {
            return .other
        }
    }
    
    private func determineTransactionType(_ ofxTransaction: OFXTransaction) -> TransactionType {
        if let ofxType = OFXTransactionType(rawValue: ofxTransaction.type) {
            return ofxType.transactionType
        }
        
        return ofxTransaction.trnamt >= 0 ? .income : .expense
    }
    
    private func cleanDescription(_ name: String, memo: String?) -> String {
        var description = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let memo = memo, !memo.isEmpty {
            description += " - \(memo.trimmingCharacters(in: .whitespacesAndNewlines))"
        }
        
        description = description.replacingOccurrences(of: "  ", with: " ")
        
        return description.isEmpty ? "Imported Transaction" : description
    }
    
    private func checkForDuplicates(_ transactions: [Transaction]) async throws -> [Transaction] {
        var duplicates: [Transaction] = []
        
        for transaction in transactions {
            let existingTransactions = try await repository.getTransactions(for: transaction.accountId)
            
            let isDuplicate = existingTransactions.contains { existing in
                abs(existing.amount - transaction.amount) < 0.01 &&
                Calendar.current.isDate(existing.date, inSameDayAs: transaction.date) &&
                existing.description.lowercased().contains(transaction.description.lowercased().prefix(10))
            }
            
            if isDuplicate {
                duplicates.append(transaction)
            }
        }
        
        return duplicates
    }
    
    private func importTransactions(_ transactions: [Transaction]) async throws -> (successful: [Transaction], failed: [ImportError]) {
        var successful: [Transaction] = []
        var failed: [ImportError] = []
        
        let total = transactions.count
        
        for (index, transaction) in transactions.enumerated() {
            do {
                try await repository.addTransaction(transaction)
                successful.append(transaction)
            } catch {
                failed.append(ImportError(transaction: transaction, error: error))
            }
            
            DispatchQueue.main.async {
                self.importProgress = 0.7 + (0.3 * Double(index + 1) / Double(total))
            }
        }
        
        return (successful, failed)
    }
    
    func reset() {
        importStatus = .idle
        importProgress = 0.0
        importedCount = 0
        duplicateCount = 0
        errorCount = 0
        errorMessage = nil
    }
}

struct ImportResult {
    let successful: [Transaction]
    let failed: [ImportError]
    let duplicates: [Transaction]
    
    var totalProcessed: Int {
        successful.count + failed.count + duplicates.count
    }
}

struct ImportError {
    let transaction: Transaction
    let error: Error
    
    var description: String {
        "\(transaction.description): \(error.localizedDescription)"
    }
}

enum ImportServiceError: Error, LocalizedError {
    case noAccountsAvailable
    
    var errorDescription: String? {
        switch self {
        case .noAccountsAvailable:
            return "No accounts available for import"
        }
    }
}