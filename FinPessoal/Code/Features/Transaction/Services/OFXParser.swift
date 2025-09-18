//
//  OFXParser.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Foundation

class OFXParser {
    private let dateFormatter: DateFormatter
    private let ofxDateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone.current
        
        ofxDateFormatter = DateFormatter()
        ofxDateFormatter.dateFormat = "yyyyMMdd"
        ofxDateFormatter.timeZone = TimeZone.current
    }
    
    func parseOFX(from data: Data) throws -> OFXStatement {
        guard let content = String(data: data, encoding: .utf8) ??
                            String(data: data, encoding: .windowsCP1252) ??
                            String(data: data, encoding: .ascii) else {
            throw OFXParseError.encodingError
        }
        
        let cleanContent = preprocessOFXContent(content)
        
        if cleanContent.contains("<?xml") {
            return try parseXMLOFX(cleanContent)
        } else {
            return try parseSGMLOFX(cleanContent)
        }
    }
    
    private func preprocessOFXContent(_ content: String) -> String {
        var cleanContent = content
        
        cleanContent = cleanContent.replacingOccurrences(of: "\r\n", with: "\n")
        cleanContent = cleanContent.replacingOccurrences(of: "\r", with: "\n")
        
        let lines = cleanContent.components(separatedBy: "\n")
        var processedLines: [String] = []
        var inHeader = true
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                continue
            }
            
            if trimmedLine.hasPrefix("<OFX>") || trimmedLine.hasPrefix("<?xml") {
                inHeader = false
            }
            
            if !inHeader {
                processedLines.append(trimmedLine)
            }
        }
        
        return processedLines.joined(separator: "\n")
    }
    
    private func parseXMLOFX(_ content: String) throws -> OFXStatement {
        guard let data = content.data(using: .utf8) else {
            throw OFXParseError.encodingError
        }
        
        let parser = XMLParser(data: data)
        let delegate = OFXXMLParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            throw OFXParseError.invalidFormat
        }
        
        return delegate.statement ?? OFXStatement(account: OFXAccount(acctid: "", accttype: ""), transactions: [])
    }
    
    private func parseSGMLOFX(_ content: String) throws -> OFXStatement {
        let tags = extractSGMLTags(from: content)
        
        let account = parseAccount(from: tags)
        let transactions = parseTransactions(from: tags)
        
        let dtstart = parseOFXDate(tags["DTSTART"])
        let dtend = parseOFXDate(tags["DTEND"])
        
        return OFXStatement(account: account, transactions: transactions, dtstart: dtstart, dtend: dtend)
    }
    
    private func extractSGMLTags(from content: String) -> [String: String] {
        var tags: [String: String] = [:]
        let pattern = "<([^>]+)>([^<]*)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in matches {
                if let tagRange = Range(match.range(at: 1), in: content),
                   let valueRange = Range(match.range(at: 2), in: content) {
                    let tag = String(content[tagRange])
                    let value = String(content[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    tags[tag] = value
                }
            }
        } catch {
            print("Regex error: \(error)")
        }
        
        return tags
    }
    
    private func parseAccount(from tags: [String: String]) -> OFXAccount {
        let bankid = tags["BANKID"]
        let acctid = tags["ACCTID"] ?? ""
        let accttype = tags["ACCTTYPE"] ?? "CHECKING"
        
        return OFXAccount(bankid: bankid, acctid: acctid, accttype: accttype)
    }
    
    private func parseTransactions(from tags: [String: String]) -> [OFXTransaction] {
        var transactions: [OFXTransaction] = []
        
        let transactionPattern = "<STMTTRN>(.*?)</STMTTRN>"
        do {
            let regex = try NSRegularExpression(pattern: transactionPattern, options: [.dotMatchesLineSeparators])
            let content = tags.map { "\($0.key)>\($0.value)" }.joined(separator: "\n")
            let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: content) {
                    let transactionContent = String(content[range])
                    if let transaction = parseTransaction(from: transactionContent) {
                        transactions.append(transaction)
                    }
                }
            }
        } catch {
            print("Transaction parsing error: \(error)")
        }
        
        return transactions
    }
    
    private func parseTransaction(from content: String) -> OFXTransaction? {
        let tags = extractSGMLTags(from: content)
        
        guard let fitid = tags["FITID"],
              let trntype = tags["TRNTYPE"],
              let dtposted = tags["DTPOSTED"],
              let trnamt = tags["TRNAMT"],
              let name = tags["NAME"] else {
            return nil
        }
        
        guard let date = parseOFXDate(dtposted),
              let amount = Double(trnamt) else {
            return nil
        }
        
        let memo = tags["MEMO"]
        let checknum = tags["CHECKNUM"]
        
        return OFXTransaction(
            fitid: fitid,
            type: trntype,
            dtposted: date,
            trnamt: amount,
            name: name,
            memo: memo,
            checknum: checknum
        )
    }
    
    private func parseOFXDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let cleanDateString = dateString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleanDateString.count >= 14 {
            return dateFormatter.date(from: String(cleanDateString.prefix(14)))
        } else if cleanDateString.count >= 8 {
            return ofxDateFormatter.date(from: String(cleanDateString.prefix(8)))
        }
        
        return nil
    }
}

class OFXXMLParserDelegate: NSObject, XMLParserDelegate {
    var statement: OFXStatement?
    private var currentElement = ""
    private var currentValue = ""
    private var account: OFXAccount?
    private var transactions: [OFXTransaction] = []
    private var currentTransaction: [String: String] = [:]
    private var dtstart: Date?
    private var dtend: Date?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName.uppercased()
        currentValue = ""
        
        if currentElement == "STMTTRN" {
            currentTransaction = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.uppercased()
        
        switch element {
        case "BANKID", "ACCTID", "ACCTTYPE":
            if account == nil {
                if element == "ACCTID" {
                    account = OFXAccount(acctid: currentValue, accttype: "CHECKING")
                }
            }
            
        case "FITID", "TRNTYPE", "DTPOSTED", "TRNAMT", "NAME", "MEMO", "CHECKNUM":
            currentTransaction[element] = currentValue
            
        case "STMTTRN":
            if let transaction = createTransactionFromDict(currentTransaction) {
                transactions.append(transaction)
            }
            
        case "DTSTART":
            dtstart = parseOFXDate(currentValue)
            
        case "DTEND":
            dtend = parseOFXDate(currentValue)
            
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        guard let account = account else { return }
        statement = OFXStatement(account: account, transactions: transactions, dtstart: dtstart, dtend: dtend)
    }
    
    private func createTransactionFromDict(_ dict: [String: String]) -> OFXTransaction? {
        guard let fitid = dict["FITID"],
              let trntype = dict["TRNTYPE"],
              let dtposted = dict["DTPOSTED"],
              let trnamt = dict["TRNAMT"],
              let name = dict["NAME"] else {
            return nil
        }
        
        guard let date = parseOFXDate(dtposted),
              let amount = Double(trnamt) else {
            return nil
        }
        
        return OFXTransaction(
            fitid: fitid,
            type: trntype,
            dtposted: date,
            trnamt: amount,
            name: name,
            memo: dict["MEMO"],
            checknum: dict["CHECKNUM"]
        )
    }
    
    private func parseOFXDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        let cleanDateString = dateString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleanDateString.count >= 14 {
            return dateFormatter.date(from: String(cleanDateString.prefix(14)))
        } else if cleanDateString.count >= 8 {
            dateFormatter.dateFormat = "yyyyMMdd"
            return dateFormatter.date(from: String(cleanDateString.prefix(8)))
        }
        
        return nil
    }
}
