//
//  OFXModels.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Foundation

struct OFXTransaction {
    let fitid: String
    let type: String
    let dtposted: Date
    let trnamt: Double
    let name: String
    let memo: String?
    let checknum: String?
    
    init(fitid: String, type: String, dtposted: Date, trnamt: Double, name: String, memo: String? = nil, checknum: String? = nil) {
        self.fitid = fitid
        self.type = type
        self.dtposted = dtposted
        self.trnamt = trnamt
        self.name = name
        self.memo = memo
        self.checknum = checknum
    }
}

struct OFXAccount {
    let bankid: String?
    let acctid: String
    let accttype: String
    
    init(bankid: String? = nil, acctid: String, accttype: String) {
        self.bankid = bankid
        self.acctid = acctid
        self.accttype = accttype
    }
}

struct OFXStatement {
    let account: OFXAccount
    let transactions: [OFXTransaction]
    let dtstart: Date?
    let dtend: Date?
    
    init(account: OFXAccount, transactions: [OFXTransaction], dtstart: Date? = nil, dtend: Date? = nil) {
        self.account = account
        self.transactions = transactions
        self.dtstart = dtstart
        self.dtend = dtend
    }
}

enum OFXTransactionType: String, CaseIterable {
    case credit = "CREDIT"
    case debit = "DEBIT"
    case int = "INT"
    case div = "DIV"
    case fee = "FEE"
    case srvchg = "SRVCHG"
    case dep = "DEP"
    case atm = "ATM"
    case pos = "POS"
    case xfer = "XFER"
    case check = "CHECK"
    case payment = "PAYMENT"
    case cash = "CASH"
    case directdep = "DIRECTDEP"
    case directdebit = "DIRECTDEBIT"
    case repeatpmt = "REPEATPMT"
    case other = "OTHER"
    
    var transactionType: TransactionType {
        switch self {
        case .credit, .int, .div, .dep, .directdep:
            return .income
        case .debit, .fee, .srvchg, .atm, .pos, .check, .payment, .cash, .directdebit, .repeatpmt:
            return .expense
        case .xfer, .other:
            return .transfer
        }
    }
}

enum OFXParseError: Error, LocalizedError {
    case invalidFormat
    case missingRequiredField(String)
    case invalidDate(String)
    case invalidAmount(String)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid OFX file format"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidDate(let date):
            return "Invalid date format: \(date)"
        case .invalidAmount(let amount):
            return "Invalid amount format: \(amount)"
        case .encodingError:
            return "File encoding error"
        }
    }
}