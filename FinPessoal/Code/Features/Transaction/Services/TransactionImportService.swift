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
            let (category, subcategory) = categorizeTransaction(ofxTransaction)
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
                updatedAt: Date(),
                subcategory: subcategory
            )
        }
    }
    
    private func categorizeTransaction(_ ofxTransaction: OFXTransaction) -> (TransactionCategory, TransactionSubcategory?) {
        let description = (ofxTransaction.name + " " + (ofxTransaction.memo ?? "")).lowercased()
        
        // Salary/Income
        if description.contains("salary") || description.contains("payroll") || description.contains("salario") {
            return (.salary, .primaryJob)
        } else if description.contains("bonus") {
            return (.salary, .bonus)
        } else if description.contains("freelance") || description.contains("autonomo") {
            return (.salary, .freelance)
        }
        
        // Food
        else if description.contains("grocery") || description.contains("supermarket") || description.contains("mercado") {
            return (.food, .groceries)
        } else if description.contains("restaurant") || description.contains("restaurante") {
            return (.food, .restaurants)
        } else if description.contains("delivery") || description.contains("entrega") {
            return (.food, .delivery)
        } else if description.contains("coffee") || description.contains("cafe") {
            return (.food, .coffee)
        } else if description.contains("fastfood") || description.contains("fast food") || description.contains("mcdonalds") || description.contains("burger") {
            return (.food, .fastFood)
        } else if description.contains("food") {
            return (.food, nil)
        }
        
        // Transport
        else if description.contains("gas") || description.contains("fuel") || description.contains("posto") || description.contains("combustivel") {
            return (.transport, .fuel)
        } else if description.contains("uber") || description.contains("taxi") {
            return (.transport, .taxi)
        } else if description.contains("metro") || description.contains("bus") || description.contains("onibus") || description.contains("public transport") {
            return (.transport, .publicTransport)
        } else if description.contains("parking") || description.contains("estacionamento") {
            return (.transport, .parking)
        } else if description.contains("insurance") || description.contains("seguro") && description.contains("car") {
            return (.transport, .insurance)
        } else if description.contains("transport") {
            return (.transport, nil)
        }
        
        // Bills
        else if description.contains("electric") || description.contains("energia") || description.contains("light") {
            return (.bills, .electricity)
        } else if description.contains("water") || description.contains("agua") {
            return (.bills, .water)
        } else if description.contains("internet") || description.contains("wifi") {
            return (.bills, .internet)
        } else if description.contains("phone") || description.contains("telefone") || description.contains("celular") {
            return (.bills, .phone)
        } else if description.contains("subscription") || description.contains("assinatura") || description.contains("netflix") || description.contains("spotify") {
            return (.bills, .subscription)
        } else if description.contains("tax") || description.contains("imposto") {
            return (.bills, .taxes)
        } else if description.contains("bill") || description.contains("conta") {
            return (.bills, nil)
        }
        
        // Housing
        else if description.contains("rent") || description.contains("aluguel") {
            return (.housing, .rent)
        } else if description.contains("mortgage") || description.contains("financiamento") {
            return (.housing, .mortgage)
        } else if description.contains("repair") || description.contains("reparo") || description.contains("manutencao") {
            return (.housing, .repairs)
        } else if description.contains("furniture") || description.contains("movel") {
            return (.housing, .furniture)
        } else if description.contains("cleaning") || description.contains("limpeza") {
            return (.housing, .cleaning)
        }
        
        // Healthcare
        else if description.contains("doctor") || description.contains("medico") || description.contains("hospital") {
            return (.healthcare, .doctor)
        } else if description.contains("pharmacy") || description.contains("farmacia") || description.contains("remedio") {
            return (.healthcare, .pharmacy)
        } else if description.contains("dental") || description.contains("dentista") {
            return (.healthcare, .dental)
        } else if description.contains("therapy") || description.contains("terapia") {
            return (.healthcare, .therapy)
        } else if description.contains("medical") {
            return (.healthcare, nil)
        }
        
        // Entertainment
        else if description.contains("movie") || description.contains("cinema") {
            return (.entertainment, .movies)
        } else if description.contains("game") || description.contains("jogo") {
            return (.entertainment, .games)
        } else if description.contains("concert") || description.contains("show") {
            return (.entertainment, .concerts)
        } else if description.contains("sport") || description.contains("esporte") {
            return (.entertainment, .sports)
        } else if description.contains("book") || description.contains("livro") {
            return (.entertainment, .books)
        } else if description.contains("entertainment") {
            return (.entertainment, nil)
        }
        
        // Shopping
        else if description.contains("clothing") || description.contains("roupa") || description.contains("fashion") {
            return (.shopping, .clothing)
        } else if description.contains("electronics") || description.contains("eletronicos") {
            return (.shopping, .electronics)
        } else if description.contains("gift") || description.contains("presente") {
            return (.shopping, .gifts)
        } else if description.contains("beauty") || description.contains("beleza") || description.contains("cosmetic") {
            return (.shopping, .beauty)
        } else if description.contains("shopping") || description.contains("store") || description.contains("loja") {
            return (.shopping, nil)
        }
        
        // Investment
        else if description.contains("stock") || description.contains("acao") {
            return (.investment, .stocks)
        } else if description.contains("cryptocurrency") || description.contains("bitcoin") || description.contains("crypto") {
            return (.investment, .cryptocurrency)
        } else if description.contains("savings") || description.contains("poupanca") {
            return (.investment, .savings)
        } else if description.contains("investment") || description.contains("investimento") {
            return (.investment, nil)
        }
        
        // Default to other
        else {
            return (.other, .miscellaneous)
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