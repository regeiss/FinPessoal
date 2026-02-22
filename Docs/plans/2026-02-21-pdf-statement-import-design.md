# PDF Bank Statement Import - Design Document

**Date:** 2026-02-21
**Feature:** PDF Statement Import with On-Device ML Processing
**Status:** Approved Design

## Overview

Add the ability to import transactions from PDF bank statements using Vision Framework for text extraction and a small on-device LLM for intelligent parsing. This keeps all financial data private while providing flexible parsing across different Brazilian bank formats.

## Requirements

### Functional Requirements
- Support Brazilian bank statements (Nubank, Itaú, Bradesco, etc.)
- Extract transactions from PDF files using on-device processing
- Intelligent categorization using small LLM
- Review screen for user verification before import
- Duplicate detection against existing transactions
- Fully offline capable (no cloud dependencies)

### Non-Functional Requirements
- Privacy: All processing happens on-device
- Performance: < 30 seconds for typical statement import
- App Size: Model adds ~400MB (downloadable separately)
- Accuracy: > 90% correct extraction for supported banks
- UX: Follow existing OFX import patterns

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    TransactionsScreen                    │
│  (existing - add PDF import button next to OFX button)  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              PDFStatementImportService                   │
│  • Coordinates the import process                       │
│  • Progress tracking (@Published properties)            │
│  • Similar to existing TransactionImportService         │
└─────┬───────────────────────┬───────────────────────────┘
      │                       │
      ▼                       ▼
┌──────────────┐      ┌──────────────────────────┐
│ PDFExtractor │      │ StatementMLProcessor     │
│ (Vision)     │      │ (Core ML + small LLM)    │
│              │      │                          │
│ • Extracts   │──────▶│ • Parses extracted text │
│   text from  │ Text  │ • Identifies transactions│
│   PDF pages  │       │ • Suggests categories   │
└──────────────┘      └────────────┬─────────────┘
                                   │ [Transaction]
                                   ▼
                      ┌────────────────────────────┐
                      │  PDFImportReviewScreen     │
                      │  (similar to existing      │
                      │   ImportResultView)        │
                      │  • Shows extracted txns    │
                      │  • Allow edits             │
                      │  • Confirm import          │
                      └────────────┬───────────────┘
                                   │
                                   ▼
                      ┌────────────────────────────┐
                      │  TransactionRepository     │
                      │  (existing - save to       │
                      │   Firebase)                │
                      └────────────────────────────┘
```

### Core Components

1. **PDFExtractor** - Vision Framework text extraction
2. **StatementMLProcessor** - Core ML model for transaction parsing
3. **PDFStatementImportService** - Orchestration and state management
4. **PDFImportReviewScreen** - User review interface
5. **MLModelManager** - Model download and caching

### Design Decisions

- **Reuse existing patterns**: Follow OFX import architecture
- **Modular design**: Single responsibility per component
- **Privacy-first**: All processing on-device
- **Progressive**: Can function without ML model (fallback to manual)
- **Separate model download**: Keep initial app size small

## Component Details

### 1. PDFExtractor (Vision Framework)

**Responsibilities:**
- Load PDF document using PDFKit
- Extract text from each page using Vision Framework
- Handle multi-page statements
- Return structured text with confidence scores

**Interface:**
```swift
class PDFExtractor {
    func extractText(from url: URL) async throws -> ExtractedPDFText
}

struct ExtractedPDFText {
    let pages: [PageText]
    let totalPages: Int
}

struct PageText {
    let pageNumber: Int
    let text: String
    let confidence: Float  // Vision recognition confidence
}
```

**Implementation Notes:**
- Use `VNRecognizeTextRequest` with `.accurate` recognition level
- Support languages: Portuguese (pt-BR) and English (en-US)
- Process pages in parallel for performance
- Cache results during import process

---

### 2. StatementMLProcessor (Core ML + LLM)

**Responsibilities:**
- Process extracted text to identify transactions
- Use small quantized LLM (Phi-3-mini ~400MB)
- Structure data into transaction format
- Suggest categories based on description

**Model Selection:**
- Primary: Phi-3-mini-4k (quantized to ~400MB)
- Alternative: Llama-3.2-1B (smaller, faster, less capable)
- Format: Core ML package (.mlpackage)

**Prompt Strategy:**
```
System: You are a financial transaction parser for Brazilian bank statements.
Extract transaction data and return JSON.

User: [Extracted statement text]

Output format:
{
  "transactions": [
    {
      "date": "YYYY-MM-DD",
      "description": "string",
      "amount": number,
      "type": "expense|income|transfer",
      "suggested_category": "category_name"
    }
  ]
}
```

**Interface:**
```swift
class StatementMLProcessor {
    func parseTransactions(from text: ExtractedPDFText) async throws -> [ParsedTransaction]
}

struct ParsedTransaction {
    let date: Date
    let description: String
    let amount: Double
    let type: TransactionType
    let suggestedCategory: TransactionCategory?
    let confidence: Float  // ML model confidence
}
```

---

### 3. PDFStatementImportService

**Responsibilities:**
- Orchestrate the import flow
- Track progress and status
- Handle errors and retries
- Convert ParsedTransaction → Transaction
- Manage duplicate detection

**Published Properties:**
```swift
@Published var importProgress: Double = 0.0
@Published var importStatus: ImportStatus = .idle
@Published var extractedCount: Int = 0
@Published var duplicateCount: Int = 0
@Published var errorMessage: String?

enum ImportStatus {
    case idle
    case extracting     // Vision processing
    case parsing        // ML processing
    case checkingDupes  // Duplicate detection
    case reviewing      // User review
    case completed
    case failed(Error)
}
```

**Progress Breakdown:**
- 0-30%: Text extraction (Vision)
- 30-70%: ML processing
- 70-90%: Duplicate detection
- 90-100%: User review and save

---

### 4. PDFImportReviewScreen

**Responsibilities:**
- Display extracted transactions in editable list
- Show confidence indicators
- Allow inline editing (category, amount, date, description)
- Show duplicates separately
- Confirm or cancel import

**UI Components:**
- Transaction list (grouped: New / Duplicates)
- Confidence indicators (green/yellow/red badges)
- Inline edit controls
- Summary header (extracted count, duplicates, total amount)
- Confirm/Cancel buttons

**Similar to:**
- Existing `ImportResultView` pattern
- Add inline editing capabilities

---

### 5. MLModelManager

**Responsibilities:**
- Download Core ML model on first use
- Cache model locally
- Version management
- Provide fallback when unavailable

**Model Storage:**
```
Documents/
  MLModels/
    statement-parser-v1.mlpackage  (~400MB)
```

**Interface:**
```swift
class MLModelManager {
    func downloadModel(progress: @escaping (Double) -> Void) async throws
    func loadModel() async throws -> MLModel
    func isModelAvailable() -> Bool
    func clearCache()
}
```

## Data Flow

### End-to-End Process

1. **PDF Selection & Validation**
   - User taps "Import PDF Statement" in TransactionsScreen
   - File picker shows .pdf filter
   - Validate file size (<50MB) and readability
   - Show progress indicator

2. **Text Extraction (Progress 0-30%)**
   - PDFExtractor loads PDF with PDFKit
   - Process each page with Vision Framework
   - VNRecognizeTextRequest extracts text
   - Return structured text with confidence scores

3. **ML Processing (Progress 30-70%)**
   - Check if Core ML model is downloaded
   - If not: offer download with progress indicator
   - StatementMLProcessor processes extracted text
   - LLM identifies transaction patterns
   - Parse dates, amounts, descriptions
   - Suggest categories from existing system

4. **Duplicate Detection (Progress 70-90%)**
   - Query TransactionRepository for last 90 days
   - Match by: date (±1 day) + amount (exact) + description (similarity > 0.8)
   - Flag duplicates for user review

5. **Review Screen (Progress 90-100%)**
   - Display all extracted transactions
   - Group into: New / Duplicates
   - Show confidence indicators
   - Allow inline editing
   - User confirms or cancels

6. **Import Execution**
   - Convert ParsedTransaction → Transaction objects
   - Add userId, accountId, timestamps
   - Save via TransactionRepository
   - Update account balances
   - Show success summary

## Error Handling

### Error Categories

**File-Level Errors:**
```swift
enum PDFImportError: LocalizedError {
    case fileNotReadable
    case fileTooLarge(size: Int64, maxSize: Int64)
    case invalidPDFFormat
    case encryptedPDF
    case corruptedFile
}
```

**Text Extraction Errors:**
```swift
case noTextFound           // Scanned image PDF
case lowConfidence(Float)  // Vision confidence < 0.6
case partialExtraction     // Some pages failed
```

**ML Model Errors:**
```swift
case modelNotDownloaded
case modelDownloadFailed(Error)
case modelLoadFailed(Error)
case modelInferenceFailed(Error)
case invalidModelOutput     // Malformed JSON
```

**Parsing Errors:**
```swift
case noTransactionsFound
case invalidDateFormat
case invalidAmountFormat
case ambiguousTransactions
```

**Network/Firebase Errors:**
```swift
case duplicateCheckFailed(Error)
case saveFailed(Error)
case authenticationRequired
```

### Error Recovery Strategy

**Progressive Degradation:**
1. Ideal: PDF → Vision → ML → Review → Save
2. ML unavailable: Show error, offer to download model
3. Vision fails: Show clear error, suggest manual entry

**User Communication:**
- Clear, actionable messages in Portuguese
- Never expose technical details
- Always offer next steps
- Examples:
  - "PDF appears to be scanned image. Please use digital statement."
  - "Model not available. Download now? (~400MB)"
  - "Failed to parse transactions. Try manual entry?"

**Logging:**
- Log error types (no PII/financial data)
- Track success rates per bank
- Monitor ML model performance
- Send anonymized analytics

## Testing Strategy

### Unit Tests

**PDFExtractor:**
- Extract from single/multi-page PDFs
- Handle encrypted/corrupted PDFs
- Handle scanned image PDFs
- Confidence score calculation

**StatementMLProcessor:**
- Parse valid Brazilian statements
- Parse Nubank/Itaú/Bradesco formats
- Handle malformed JSON
- Category suggestion accuracy
- Date/amount parsing

**PDFStatementImportService:**
- Full import flow
- Duplicate detection
- Progress tracking
- Error handling
- Cancellation

### Integration Tests

- Import real bank statements (Nubank, Itaú, Bradesco)
- Review and edit flow
- Save to Firebase
- Offline import
- ML model download/caching

### UI Tests

- PDF picker flow
- Progress indicator display
- Review screen interaction
- Edit transaction in review
- Confirm/cancel import
- Error alert display

### Test Data

**Sample PDFs:**
- ✅ Nubank (1 page, ~20 transactions)
- ✅ Itaú (multi-page, ~50 transactions)
- ✅ Bradesco (different format)
- ✅ Special characters (accents, symbols)
- ✅ Edge cases (zero amounts, refunds, transfers)
- ✅ Corrupted PDF
- ✅ Scanned image PDF

### Performance Benchmarks

- Vision extraction: < 2 seconds per page
- ML processing: < 10 seconds per statement (20 transactions)
- Total import: < 30 seconds for standard statement
- Memory usage: < 200MB peak
- Battery impact: < 5% per import

### Privacy & Security Testing

- [ ] Verify no PDF data sent externally
- [ ] Verify ML runs entirely on-device
- [ ] Verify temp files cleaned up
- [ ] Verify no sensitive data in logs
- [ ] Test in airplane mode (fully offline)

## Implementation Notes

### Dependencies

**New:**
- PDFKit (iOS built-in)
- Vision Framework (iOS built-in)
- Core ML (iOS built-in)
- Phi-3-mini model (download separately)

**Existing:**
- Firebase (for storage)
- TransactionRepository
- Transaction models

### File Structure

```
FinPessoal/Code/Features/Transaction/
  Services/
    PDFImport/
      PDFExtractor.swift
      StatementMLProcessor.swift
      PDFStatementImportService.swift
      MLModelManager.swift
  Screen/
    PDFImportReviewScreen.swift
  Model/
    ParsedTransaction.swift
    ExtractedPDFText.swift
```

### Phased Rollout

**Phase 1: Vision + Basic Parsing**
- PDF text extraction
- Simple pattern matching for Nubank
- Manual review screen
- No ML model yet

**Phase 2: ML Integration**
- Add Core ML model
- Download manager
- Intelligent parsing
- Multi-bank support

**Phase 3: Optimization**
- Performance improvements
- Additional bank formats
- Enhanced categorization
- User feedback integration

## Success Criteria

### MVP (Minimum Viable Product)

- [ ] Import PDF statements from Nubank
- [ ] Extract transactions with >85% accuracy
- [ ] Review screen allows editing
- [ ] Save to Firebase successfully
- [ ] Detect duplicates
- [ ] Handle errors gracefully
- [ ] Works fully offline

### Future Enhancements

- Support more Brazilian banks (Santander, Caixa, etc.)
- Multi-account statements
- Receipt OCR (not just statements)
- Category learning from user corrections
- Export transactions to PDF/Excel
- Batch import (multiple PDFs at once)

## Open Questions

None - design approved.

## Appendix

### References

- [Apple Vision Framework](https://developer.apple.com/documentation/vision)
- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [PDFKit Documentation](https://developer.apple.com/documentation/pdfkit)
- Existing OFX import implementation

### Related Files

- `FinPessoal/Code/Features/Transaction/Services/TransactionImportService.swift`
- `FinPessoal/Code/Features/Transaction/Services/OFXParser.swift`
- `FinPessoal/Code/Features/Transaction/View/ImportResultView.swift`
