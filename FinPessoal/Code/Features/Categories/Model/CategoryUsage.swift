//
//  CategoryUsage.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import Foundation

struct CategoryUsage {
    let categoryId: String
    let transactionCount: Int
    let lastUsed: Date?
    
    var isInUse: Bool {
        return transactionCount > 0
    }
}