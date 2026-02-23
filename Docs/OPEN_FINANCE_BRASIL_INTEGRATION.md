# Open Finance Brasil Integration Guide

## Overview

Open Finance Brasil (formerly Open Banking Brasil) allows your app to securely access financial data from Brazilian banks with user consent. This guide explains how to integrate it into FinPessoal.

## What is Open Finance Brasil?

**Official System:** Central Bank of Brazil's standardized API framework
**Purpose:** Allow secure financial data sharing between institutions
**User Benefit:** Automatic transaction sync instead of manual PDF imports
**Coverage:** All major Brazilian banks (Nubank, Itaú, Bradesco, Santander, etc.)

### Comparison with PDF Import

| Feature | PDF Import | Open Finance |
|---------|-----------|--------------|
| Setup | None | Registration required |
| Real-time | No | Yes |
| Accuracy | 70-80% | 100% |
| Coverage | All banks | Participating banks only |
| User Action | Upload monthly | One-time consent |
| Cost | Free | May have API costs |
| Maintenance | Low | Medium (API updates) |

**Recommendation:** Offer both! PDF import for quick start, Open Finance for ongoing sync.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      FinPessoal App                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   PDF Import │  │ Open Finance │  │  Manual Entry│     │
│  │   (Current)  │  │    (New)     │  │   (Current)  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                       │
│                   │ Transaction     │                       │
│                   │ Repository      │                       │
│                   └────────┬────────┘                       │
│                            │                                 │
│                   ┌────────▼────────┐                       │
│                   │    Firebase     │                       │
│                   │   Firestore     │                       │
│                   └─────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ OAuth 2.0 + mTLS
                            │
┌───────────────────────────▼─────────────────────────────────┐
│              Open Finance Brasil Directory                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Nubank     │  │     Itaú     │  │   Bradesco   │     │
│  │     API      │  │     API      │  │     API      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Registration & Certification

### 1.1 Register Organization

**Portal:** https://web.directory.openbankingbrasil.org.br

**Requirements:**
- Valid CNPJ (Brazilian company registration)
- Technical contact email
- Legal representative information
- Company website

**Process:**
1. Create account on Open Finance Brasil Directory
2. Submit organization details
3. Wait for approval (~5-10 business days)
4. Receive Organization ID

### 1.2 Obtain Certificates

**Required Certificates:**
1. **Transport Certificate (mTLS)** - For API authentication
2. **Signing Certificate** - For request signing

**How to Get:**

**Option A: Use Approved Certificate Authority**
- Serpro (government CA)
- ICP-Brasil certified CAs
- Cost: R$ 500-2000/year

**Option B: Sandbox Certificates (Testing)**
```bash
# For development only
openssl req -x509 -newkey rsa:2048 \
  -keyout transport-key.pem \
  -out transport-cert.pem \
  -days 365 -nodes

openssl req -x509 -newkey rsa:2048 \
  -keyout signing-key.pem \
  -out signing-cert.pem \
  -days 365 -nodes
```

### 1.3 Register as Third Party Provider (TPP)

**Software Statement:**
```json
{
  "software_name": "FinPessoal",
  "software_version": "1.0",
  "software_description": "Personal Finance Manager",
  "software_redirect_uris": [
    "finpessoal://oauth-callback"
  ],
  "software_roles": [
    "DADOS" // Data access role
  ],
  "software_logo_uri": "https://yourapp.com/logo.png"
}
```

**Submit for approval and receive:**
- Software Statement ID (SSA)
- Client credentials
- API access keys

---

## Phase 2: Technical Implementation

### 2.1 Project Structure

```
FinPessoal/Code/Features/OpenFinance/
├── Model/
│   ├── OFAccount.swift
│   ├── OFTransaction.swift
│   ├── OFConsent.swift
│   └── OFInstitution.swift
├── Services/
│   ├── OpenFinanceAuthService.swift
│   ├── OpenFinanceAPIService.swift
│   ├── OpenFinanceSyncService.swift
│   └── CertificateManager.swift
├── Repository/
│   └── OpenFinanceRepository.swift
├── ViewModel/
│   └── BankConnectionViewModel.swift
└── Screen/
    ├── BankSelectionScreen.swift
    ├── ConsentScreen.swift
    └── AccountLinkingScreen.swift
```

### 2.2 Core Models

**OFAccount.swift:**
```swift
import Foundation

struct OFAccount: Codable, Identifiable {
  let id: String
  let institutionId: String
  let institutionName: String
  let accountType: String // CONTA_DEPOSITO_A_VISTA, CONTA_POUPANCA
  let accountNumber: String
  let branch: String
  let balance: Double
  let currency: String // BRL
  let lastSyncDate: Date

  // Consent information
  let consentId: String
  let consentExpirationDate: Date
  let permissions: [String]
}

struct OFTransaction: Codable {
  let transactionId: String
  let type: String // DEBITO, CREDITO, PIX
  let creditDebitType: String // CREDITO, DEBITO
  let transactionName: String
  let amount: Double
  let transactionDate: Date
  let partyPersonType: String?
  let partyName: String?
  let partyCpfCnpj: String?
}

struct OFConsent: Codable {
  let consentId: String
  let status: String // AUTHORISED, REJECTED, CONSUMED
  let creationDateTime: Date
  let expirationDateTime: Date
  let permissions: [String]
  let institutionId: String
}

struct OFInstitution: Codable, Identifiable {
  let id: String // Organisation ID
  let name: String
  let logoUrl: String
  let apiDiscoveryUrl: String
  let authorizationEndpoint: String
  let tokenEndpoint: String
}
```

### 2.3 Authentication Service

**OpenFinanceAuthService.swift:**
```swift
import Foundation
import AuthenticationServices

@MainActor
class OpenFinanceAuthService: NSObject, ObservableObject {
  @Published var isAuthenticated = false
  @Published var currentConsent: OFConsent?

  private let certManager = CertificateManager()
  private var authSession: ASWebAuthenticationSession?

  // MARK: - OAuth 2.0 Flow

  func initiateConsentFlow(
    institution: OFInstitution,
    permissions: [String],
    expirationDays: Int = 90
  ) async throws -> OFConsent {

    // Step 1: Create consent request
    let consentRequest = [
      "data": [
        "permissions": permissions,
        "expirationDateTime": calculateExpirationDate(days: expirationDays),
        "loggedUser": [
          "document": [
            "identification": getUserCPF(),
            "rel": "CPF"
          ]
        ]
      ]
    ]

    // Step 2: Send consent request to institution
    let consentResponse = try await sendConsentRequest(
      to: institution,
      request: consentRequest
    )

    let consentId = consentResponse.consentId

    // Step 3: Build authorization URL
    let authURL = buildAuthorizationURL(
      institution: institution,
      consentId: consentId
    )

    // Step 4: Open web authentication session
    let callbackURL = try await openAuthSession(url: authURL)

    // Step 5: Extract authorization code
    guard let code = extractAuthCode(from: callbackURL) else {
      throw OpenFinanceError.authorizationFailed
    }

    // Step 6: Exchange code for tokens
    let tokens = try await exchangeCodeForTokens(
      institution: institution,
      code: code
    )

    // Step 7: Store tokens securely
    try await storeTokens(tokens, consentId: consentId)

    // Step 8: Get updated consent status
    let consent = try await getConsentStatus(
      institution: institution,
      consentId: consentId,
      accessToken: tokens.accessToken
    )

    currentConsent = consent
    isAuthenticated = true

    return consent
  }

  // MARK: - Helper Methods

  private func buildAuthorizationURL(
    institution: OFInstitution,
    consentId: String
  ) -> URL {
    var components = URLComponents(string: institution.authorizationEndpoint)!

    components.queryItems = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: getClientId()),
      URLQueryItem(name: "redirect_uri", value: "finpessoal://oauth-callback"),
      URLQueryItem(name: "scope", value: "openid consent:\(consentId)"),
      URLQueryItem(name: "state", value: generateState()),
      URLQueryItem(name: "nonce", value: generateNonce()),
      URLQueryItem(name: "code_challenge", value: generatePKCEChallenge()),
      URLQueryItem(name: "code_challenge_method", value: "S256")
    ]

    return components.url!
  }

  private func openAuthSession(url: URL) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      authSession = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: "finpessoal"
      ) { callbackURL, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let callbackURL = callbackURL {
          continuation.resume(returning: callbackURL)
        }
      }

      authSession?.presentationContextProvider = self
      authSession?.prefersEphemeralWebBrowserSession = true
      authSession?.start()
    }
  }

  private func exchangeCodeForTokens(
    institution: OFInstitution,
    code: String
  ) async throws -> OFTokenResponse {

    var request = URLRequest(url: URL(string: institution.tokenEndpoint)!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    // Attach mTLS certificate
    request = try certManager.attachClientCertificate(to: request)

    let body = [
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": "finpessoal://oauth-callback",
      "code_verifier": getPKCEVerifier()
    ]

    request.httpBody = body.percentEncoded()

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
      throw OpenFinanceError.tokenExchangeFailed
    }

    return try JSONDecoder().decode(OFTokenResponse.self, from: data)
  }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension OpenFinanceAuthService: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}

struct OFTokenResponse: Codable {
  let accessToken: String
  let tokenType: String
  let expiresIn: Int
  let refreshToken: String?
  let scope: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case scope
  }
}

enum OpenFinanceError: LocalizedError {
  case authorizationFailed
  case tokenExchangeFailed
  case consentExpired
  case apiError(String)

  var errorDescription: String? {
    switch self {
    case .authorizationFailed:
      return "Falha na autorização"
    case .tokenExchangeFailed:
      return "Erro ao obter token de acesso"
    case .consentExpired:
      return "Consentimento expirado"
    case .apiError(let message):
      return "Erro na API: \(message)"
    }
  }
}
```

### 2.4 API Service

**OpenFinanceAPIService.swift:**
```swift
import Foundation

@MainActor
class OpenFinanceAPIService {
  private let certManager = CertificateManager()

  // MARK: - Accounts API

  func getAccounts(
    institution: OFInstitution,
    accessToken: String
  ) async throws -> [OFAccount] {

    let url = URL(string: "\(institution.apiDiscoveryUrl)/accounts/v2/accounts")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    // Attach mTLS certificate
    request = try certManager.attachClientCertificate(to: request)

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(AccountsResponse.self, from: data)

    return response.data.map { accountData in
      OFAccount(
        id: accountData.accountId,
        institutionId: institution.id,
        institutionName: institution.name,
        accountType: accountData.type,
        accountNumber: accountData.number,
        branch: accountData.branchCode,
        balance: 0, // Get from balances endpoint
        currency: "BRL",
        lastSyncDate: Date(),
        consentId: "", // Pass from caller
        consentExpirationDate: Date(), // Pass from caller
        permissions: []
      )
    }
  }

  // MARK: - Transactions API

  func getTransactions(
    institution: OFInstitution,
    accountId: String,
    accessToken: String,
    fromDate: Date,
    toDate: Date
  ) async throws -> [OFTransaction] {

    let dateFormatter = ISO8601DateFormatter()
    let fromDateStr = dateFormatter.string(from: fromDate)
    let toDateStr = dateFormatter.string(from: toDate)

    var components = URLComponents(
      string: "\(institution.apiDiscoveryUrl)/accounts/v2/accounts/\(accountId)/transactions"
    )!
    components.queryItems = [
      URLQueryItem(name: "fromBookingDate", value: fromDateStr),
      URLQueryItem(name: "toBookingDate", value: toDateStr)
    ]

    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    // Attach mTLS certificate
    request = try certManager.attachClientCertificate(to: request)

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(TransactionsResponse.self, from: data)

    return response.data.map { txData in
      OFTransaction(
        transactionId: txData.transactionId,
        type: txData.type,
        creditDebitType: txData.creditDebitType,
        transactionName: txData.transactionName,
        amount: txData.amount,
        transactionDate: ISO8601DateFormatter().date(from: txData.bookingDate) ?? Date(),
        partyPersonType: txData.creditorPersonType ?? txData.debtorPersonType,
        partyName: txData.creditorName ?? txData.debtorName,
        partyCpfCnpj: txData.creditorCpfCnpj ?? txData.debtorCpfCnpj
      )
    }
  }

  // MARK: - Balance API

  func getBalance(
    institution: OFInstitution,
    accountId: String,
    accessToken: String
  ) async throws -> Double {

    let url = URL(string: "\(institution.apiDiscoveryUrl)/accounts/v2/accounts/\(accountId)/balances")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    request = try certManager.attachClientCertificate(to: request)

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(BalanceResponse.self, from: data)

    return response.data.availableAmount
  }
}

// MARK: - Response Models

struct AccountsResponse: Codable {
  let data: [AccountData]
}

struct AccountData: Codable {
  let accountId: String
  let type: String
  let number: String
  let branchCode: String
}

struct TransactionsResponse: Codable {
  let data: [TransactionData]
}

struct TransactionData: Codable {
  let transactionId: String
  let type: String
  let creditDebitType: String
  let transactionName: String
  let amount: Double
  let bookingDate: String
  let creditorPersonType: String?
  let creditorName: String?
  let creditorCpfCnpj: String?
  let debtorPersonType: String?
  let debtorName: String?
  let debtorCpfCnpj: String?
}

struct BalanceResponse: Codable {
  let data: BalanceData
}

struct BalanceData: Codable {
  let availableAmount: Double
}
```

### 2.5 Sync Service

**OpenFinanceSyncService.swift:**
```swift
import Foundation

@MainActor
class OpenFinanceSyncService: ObservableObject {
  @Published var isSyncing = false
  @Published var lastSyncDate: Date?
  @Published var syncProgress: Double = 0.0

  private let apiService = OpenFinanceAPIService()
  private let repository: TransactionRepositoryProtocol

  init(repository: TransactionRepositoryProtocol) {
    self.repository = repository
  }

  func syncAll(connectedAccounts: [OFAccount]) async throws {
    isSyncing = true
    syncProgress = 0.0

    let total = Double(connectedAccounts.count)
    var current = 0.0

    for ofAccount in connectedAccounts {
      // Get institution details
      guard let institution = await getInstitution(id: ofAccount.institutionId),
            let accessToken = await getAccessToken(consentId: ofAccount.consentId) else {
        current += 1.0
        syncProgress = current / total
        continue
      }

      do {
        // Sync transactions from last 30 days
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let toDate = Date()

        let ofTransactions = try await apiService.getTransactions(
          institution: institution,
          accountId: ofAccount.id,
          accessToken: accessToken,
          fromDate: fromDate,
          toDate: toDate
        )

        // Convert to app transactions
        let appTransactions = ofTransactions.map { ofTx in
          convertToAppTransaction(ofTx, accountId: ofAccount.id)
        }

        // Check for duplicates
        let existing = try await repository.getTransactions(from: fromDate, to: toDate)
        let newTransactions = appTransactions.filter { newTx in
          !existing.contains { existing in
            isSameTransaction(existing, newTx)
          }
        }

        // Save new transactions
        for transaction in newTransactions {
          try await repository.addTransaction(transaction)
        }

        print("✅ Synced \(newTransactions.count) transactions from \(ofAccount.institutionName)")

      } catch {
        print("❌ Error syncing \(ofAccount.institutionName): \(error)")
      }

      current += 1.0
      syncProgress = current / total
    }

    lastSyncDate = Date()
    isSyncing = false
  }

  private func convertToAppTransaction(_ ofTx: OFTransaction, accountId: String) -> Transaction {
    return Transaction(
      id: ofTx.transactionId,
      accountId: accountId,
      amount: ofTx.amount,
      description: ofTx.transactionName,
      category: categorize(ofTx.transactionName),
      type: ofTx.creditDebitType == "CREDITO" ? .income : .expense,
      date: ofTx.transactionDate,
      isRecurring: false,
      userId: "", // Set from auth
      createdAt: Date(),
      updatedAt: Date()
    )
  }

  private func categorize(_ description: String) -> TransactionCategory {
    // Reuse categorization logic from PDF parser
    let lowercased = description.lowercased()

    if lowercased.contains("restaurante") || lowercased.contains("mercado") {
      return .food
    } else if lowercased.contains("uber") || lowercased.contains("posto") {
      return .transport
    }
    // ... etc

    return .other
  }

  private func isSameTransaction(_ t1: Transaction, _ t2: Transaction) -> Bool {
    // Same logic as PDF import duplicate detection
    return abs(t1.amount - t2.amount) < 0.01 &&
           abs(Calendar.current.dateComponents([.day], from: t1.date, to: t2.date).day ?? 999) <= 1 &&
           t1.description.lowercased().contains(t2.description.lowercased().prefix(10))
  }
}
```

---

## Phase 3: UI Integration

### 3.1 Bank Selection Screen

**BankSelectionScreen.swift:**
```swift
import SwiftUI

struct BankSelectionScreen: View {
  @StateObject private var viewModel = BankConnectionViewModel()
  @State private var searchText = ""

  var filteredBanks: [OFInstitution] {
    if searchText.isEmpty {
      return viewModel.availableBanks
    }
    return viewModel.availableBanks.filter {
      $0.name.localizedCaseInsensitiveContains(searchText)
    }
  }

  var body: some View {
    NavigationView {
      List {
        Section {
          ForEach(filteredBanks) { bank in
            Button {
              viewModel.selectBank(bank)
            } label: {
              HStack(spacing: 16) {
                AsyncImage(url: URL(string: bank.logoUrl)) { image in
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                } placeholder: {
                  ProgressView()
                }
                .frame(width: 48, height: 48)
                .cornerRadius(8)

                Text(bank.name)
                  .font(.body)

                Spacer()

                Image(systemName: "chevron.right")
                  .foregroundColor(.gray)
              }
              .padding(.vertical, 4)
            }
          }
        } header: {
          Text("Selecione seu banco")
        } footer: {
          Text("Seus dados são protegidos e você pode revogar o acesso a qualquer momento.")
            .font(.caption)
        }
      }
      .searchable(text: $searchText, prompt: "Buscar banco")
      .navigationTitle("Conectar Conta")
      .navigationBarTitleDisplayMode(.large)
      .sheet(item: $viewModel.selectedBank) { bank in
        ConsentScreen(bank: bank, viewModel: viewModel)
      }
    }
  }
}
```

### 3.2 Add to TransactionsScreen

**Update TransactionsScreen.swift toolbar:**
```swift
Menu {
  Button {
    transactionViewModel.showImportPicker()
  } label: {
    Label("Import OFX", systemImage: "doc.text")
  }

  Button {
    showingPDFFilePicker = true
  } label: {
    Label("Import PDF", systemImage: "doc.text.viewfinder")
  }

  Button {
    showingBankConnection = true
  } label: {
    Label("Connect Bank", systemImage: "building.columns")
  }
} label: {
  Image(systemName: "square.and.arrow.down")
}

// Add sheet
.sheet(isPresented: $showingBankConnection) {
  BankSelectionScreen()
}
```

---

## Phase 4: Security & Compliance

### 4.1 Certificate Management

**CertificateManager.swift:**
```swift
import Foundation
import Security

class CertificateManager {

  func attachClientCertificate(to request: URLRequest) throws -> URLRequest {
    // Load certificates from keychain
    let identity = try loadIdentity()

    var mutableRequest = request
    // Configure URLSession with client certificate
    // Implementation depends on your certificate storage

    return mutableRequest
  }

  private func loadIdentity() throws -> SecIdentity {
    // Load from keychain or bundle
    // This is production code - secure storage required
    throw NSError(domain: "Not implemented", code: -1)
  }
}
```

### 4.2 Data Privacy

**Best Practices:**
```swift
// 1. Encrypt sensitive data at rest
let encryptedToken = try encrypt(accessToken, with: userKey)

// 2. Never log sensitive information
// ❌ BAD: print("Access token: \(accessToken)")
// ✅ GOOD: print("Access token received")

// 3. Implement certificate pinning
let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

// 4. Use secure storage
KeychainManager.store(token, forKey: "of_access_token")

// 5. Clear data on logout
func logout() {
  KeychainManager.deleteAll()
  UserDefaults.standard.removeObject(forKey: "consent_id")
}
```

---

## Phase 5: Testing

### 5.1 Sandbox Environment

**Sandbox URLs:**
```swift
struct OpenFinanceEnvironment {
  static let production = "https://data.directory.openbankingbrasil.org.br"
  static let sandbox = "https://data.sandbox.directory.openbankingbrasil.org.br"

  static var current: String {
    #if DEBUG
    return sandbox
    #else
    return production
    #endif
  }
}
```

### 5.2 Test Banks

Most banks provide sandbox environments:
- **Banco Central Sandbox:** Test all APIs
- **Nubank Sandbox:** https://developer.nubank.com.br
- **Itaú Sandbox:** Developer portal
- **Bradesco Sandbox:** Developer portal

---

## Phase 6: Deployment Checklist

- [ ] Production certificates obtained
- [ ] Software Statement approved
- [ ] Privacy policy updated
- [ ] Terms of service include Open Finance
- [ ] Security audit completed
- [ ] API error handling implemented
- [ ] Token refresh logic implemented
- [ ] Consent expiration handling
- [ ] Rate limiting handled
- [ ] Monitoring/analytics setup
- [ ] User education materials created
- [ ] Support team trained

---

## Cost Estimation

**Setup Costs:**
- Certificate authority: R$ 500-2,000/year
- Legal review: R$ 2,000-5,000 (one-time)
- Security audit: R$ 5,000-15,000 (one-time)

**Operational Costs:**
- API calls: Usually free for data access
- Hosting/infrastructure: Minimal (client-side mostly)
- Maintenance: Developer time for API updates

**Total First Year:** ~R$ 10,000-25,000

---

## Resources

**Official Documentation:**
- [Open Finance Brasil Portal](https://openbankingbrasil.org.br/)
- [Technical Standards](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/overview)
- [Developer Portal](https://web.directory.openbankingbrasil.org.br/)

**SDKs & Libraries:**
- [open-banking-brasil-sdk (unofficial)](https://github.com/OpenBanking-Brasil/applications-exemplo)
- Apple's ASWebAuthenticationSession documentation

**Community:**
- Slack: Open Finance Brasil workspace
- GitHub: OpenBanking-Brasil organization

---

## Comparison: Integration Complexity

| Approach | Setup Time | Ongoing Effort | User Experience |
|----------|------------|----------------|-----------------|
| PDF Import | 1 day ✅ | Low | Manual upload monthly |
| Open Finance | 2-3 months | Medium | One-time consent, auto-sync |
| Both | 2-3 months | Medium | Best of both worlds ⭐ |

**Recommendation:** Implement PDF import first (already done ✅), then add Open Finance for power users.

---

## Next Steps

1. **Week 1-2:** Register organization, obtain sandbox certificates
2. **Week 3-4:** Implement authentication flow
3. **Week 5-6:** Implement API integration
4. **Week 7-8:** Build UI components
5. **Week 9-10:** Security audit and testing
6. **Week 11-12:** Production deployment

**Need Help?** Consider hiring a consultant familiar with Open Finance Brasil APIs for faster implementation.
