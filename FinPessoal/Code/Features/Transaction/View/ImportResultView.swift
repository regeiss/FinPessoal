//
//  ImportResultView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/09/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportResultView: View {
    let result: ImportResult?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let result = result {
                    successView(result)
                } else {
                    EmptyView()
                }
            }
            .navigationTitle(String(localized: "import.result.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func successView(_ result: ImportResult) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Card
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text(String(localized: "import.result.success"))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    statisticsGrid(result)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Details
                if !result.successful.isEmpty {
                    importedTransactionsSection(result.successful)
                }
                
                if !result.duplicates.isEmpty {
                    duplicatesSection(result.duplicates)
                }
                
                if !result.failed.isEmpty {
                    failedSection(result.failed)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func statisticsGrid(_ result: ImportResult) -> some View {
        HStack(spacing: 20) {
            statCard(
                title: String(localized: "import.result.imported"),
                value: "\(result.successful.count)",
                color: .green
            )
            
            statCard(
                title: String(localized: "import.result.duplicates"),
                value: "\(result.duplicates.count)",
                color: .orange
            )
            
            if !result.failed.isEmpty {
                statCard(
                    title: String(localized: "import.result.failed"),
                    value: "\(result.failed.count)",
                    color: .red
                )
            }
        }
    }
    
    @ViewBuilder
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func importedTransactionsSection(_ transactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "import.result.imported.transactions"))
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(transactions.prefix(5)) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.description)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(transaction.formattedAmount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(transaction.type == .expense ? .red : .green)
                    }
                    .padding(.vertical, 4)
                }
                
                if transactions.count > 5 {
                    Text(String(localized: "import.result.and.more", 
                               defaultValue: "and \(transactions.count - 5) more..."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func duplicatesSection(_ duplicates: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "import.result.duplicates.section"))
                .font(.headline)
            
            Text(String(localized: "import.result.duplicates.description"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVStack(spacing: 8) {
                ForEach(duplicates.prefix(3)) { transaction in
                    HStack {
                        Text(transaction.description)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(transaction.formattedAmount)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                
                if duplicates.count > 3 {
                    Text(String(localized: "import.result.and.more",
                               defaultValue: "and \(duplicates.count - 3) more..."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func failedSection(_ failed: [ImportError]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "import.result.failed.section"))
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(failed.indices.prefix(3), id: \.self) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(failed[index].transaction.description)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Text(failed[index].error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if failed.count > 3 {
                    Text(String(localized: "import.result.and.more",
                               defaultValue: "and \(failed.count - 3) more..."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red, lineWidth: 1)
        )
    }
}