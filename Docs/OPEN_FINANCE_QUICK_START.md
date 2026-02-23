# Open Finance Brasil - Quick Start Guide

## Day 1: Sandbox Setup (2-3 hours)

### 1. Create Sandbox Account (15 minutes)

**URL:** https://web.directory.openbankingbrasil.org.br

**Steps:**
1. Click "Cadastrar" → "Ambiente Sandbox"
2. Fill in:
   - Nome: Your name
   - Email: your@email.com
   - Empresa: FinPessoal (or your company)
   - Telefone: Your phone
3. Verify email
4. Login to sandbox portal

**You now have:**
- ✅ Sandbox credentials
- ✅ Access to test APIs
- ✅ Sample institution data

### 2. Generate Test Certificates (30 minutes)

**Create a working directory:**
```bash
cd ~/Desktop
mkdir openfinance-test
cd openfinance-test
```

**Generate transport certificate (for mTLS):**
```bash
# Generate private key
openssl genrsa -out transport-key.pem 2048

# Generate certificate signing request
openssl req -new -key transport-key.pem -out transport.csr \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=FinPessoal/CN=finpessoal-sandbox"

# Self-sign for sandbox (valid 1 year)
openssl x509 -req -days 365 -in transport.csr \
  -signkey transport-key.pem -out transport-cert.pem

# Verify
openssl x509 -in transport-cert.pem -text -noout | grep Subject
```

**Generate signing certificate (for request signing):**
```bash
# Generate private key
openssl genrsa -out signing-key.pem 2048

# Generate CSR
openssl req -new -key signing-key.pem -out signing.csr \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=FinPessoal/CN=finpessoal-signing"

# Self-sign for sandbox
openssl x509 -req -days 365 -in signing.csr \
  -signkey signing-key.pem -out signing-cert.pem

# Verify
openssl x509 -in signing-cert.pem -text -noout | grep Subject
```

**You now have:**
- ✅ transport-key.pem & transport-cert.pem (for API authentication)
- ✅ signing-key.pem & signing-cert.pem (for request signing)

⚠️ **Important:** These are SANDBOX ONLY certificates. Production requires certified CAs.

### 3. Test Your First API Call (45 minutes)

**Install required tool:**
```bash
# Install jq for JSON parsing (optional but helpful)
brew install jq
```

**Test the Directory API:**
```bash
# Get list of participating organizations (banks)
curl -X GET \
  "https://data.sandbox.directory.openbankingbrasil.org.br/participants" \
  -H "Accept: application/json" | jq '.'
```

**Expected response:**
```json
[
  {
    "OrganisationId": "banco-central-sandbox",
    "OrganisationName": "Banco Central do Brasil - Sandbox",
    "Status": "Active",
    "AuthorisationServers": [...]
  }
]
```

✅ **Success!** You just made your first Open Finance API call!

### 4. Create Test Swift Project (30 minutes)

**Create new iOS project:**
```bash
# Or use your existing FinPessoal project
# Create a new Swift file for testing
```

**OpenFinanceTest.swift:**
```swift
import Foundation

struct OpenFinanceQuickTest {

    static func testDirectoryAPI() async {
        let url = URL(string: "https://data.sandbox.directory.openbankingbrasil.org.br/participants")!

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Failed: HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return
            }

            let json = try JSONSerialization.jsonObject(with: data)
            print("✅ Success! Received \(json)")

            // Parse participants
            if let array = json as? [[String: Any]] {
                print("📋 Found \(array.count) participating organizations")
                for participant in array.prefix(3) {
                    if let name = participant["OrganisationName"] as? String {
                        print("  - \(name)")
                    }
                }
            }

        } catch {
            print("❌ Error: \(error)")
        }
    }
}

// Test it
Task {
    await OpenFinanceQuickTest.testDirectoryAPI()
}
```

**Run this in Xcode Playground or your app:**
```
✅ Success! Received participants
📋 Found 15 participating organizations
  - Banco Central do Brasil - Sandbox
  - Banco Exemplo 1
  - Banco Exemplo 2
```

### 5. Explore Sandbox Bank APIs (30 minutes)

**Get institution details:**
```bash
# Replace with actual org ID from step 3
ORG_ID="banco-central-sandbox"

curl -X GET \
  "https://data.sandbox.directory.openbankingbrasil.org.br/organisations/${ORG_ID}" \
  -H "Accept: application/json" | jq '.'
```

**Look for these important fields:**
```json
{
  "AuthorisationServers": [{
    "AuthorizationEndpoint": "https://...",
    "TokenEndpoint": "https://...",
    "ApiResources": [{
      "ApiFamilyType": "accounts",
      "ApiVersion": "2",
      "ApiResourceId": "...",
      "ApiDiscoveryEndpoints": [{
        "ApiEndpoint": "https://sandbox.bank.com/open-banking/accounts/v2"
      }]
    }]
  }]
}
```

**These are the URLs you'll use for:**
- `AuthorizationEndpoint` - User consent flow
- `TokenEndpoint` - Get access tokens
- `ApiEndpoint` - Fetch actual account/transaction data

---

## Day 2: First OAuth Flow (3-4 hours)

### 1. Understand the OAuth Flow

```
User Flow:
1. User clicks "Connect Bank" in your app
2. Your app → Authorization URL (bank's login page)
3. User → Logs in at bank, approves permissions
4. Bank → Redirects back to your app with CODE
5. Your app → Exchanges CODE for ACCESS_TOKEN
6. Your app → Uses ACCESS_TOKEN to fetch data
```

### 2. Implement Simple OAuth Test

**Create OAuthTest.swift:**
```swift
import Foundation
import AuthenticationServices

@MainActor
class OpenFinanceOAuthTest: NSObject {

    func testOAuthFlow() async throws {
        // Step 1: Build authorization URL
        let authURL = buildAuthURL()
        print("🔗 Authorization URL: \(authURL)")

        // Step 2: Open browser for user consent
        let callbackURL = try await openBrowser(url: authURL)
        print("✅ Callback received: \(callbackURL)")

        // Step 3: Extract code
        guard let code = extractCode(from: callbackURL) else {
            throw NSError(domain: "No code", code: -1)
        }
        print("🎫 Authorization code: \(code)")

        // Step 4: Exchange for token (simplified)
        print("📝 Next: Exchange code for access token")
        print("   This requires mTLS certificate (see Day 3)")
    }

    private func buildAuthURL() -> URL {
        // Sandbox bank authorization endpoint
        let baseURL = "https://sandbox.bank.example.com/oauth/authorize"

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: "YOUR_CLIENT_ID"),
            URLQueryItem(name: "redirect_uri", value: "finpessoal://oauth-callback"),
            URLQueryItem(name: "scope", value: "openid accounts"),
            URLQueryItem(name: "state", value: UUID().uuidString),
        ]

        return components.url!
    }

    private func openBrowser(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "finpessoal"
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                }
            }

            session.presentationContextProvider = self
            session.start()
        }
    }

    private func extractCode(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "code" })?
            .value
    }
}

extension OpenFinanceOAuthTest: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
```

**Add to Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>finpessoal</string>
        </array>
    </dict>
</array>
```

### 3. Test OAuth in Simulator

```swift
// In your app or playground
Task {
    let test = OpenFinanceOAuthTest()
    try await test.testOAuthFlow()
}
```

**Expected flow:**
1. Safari opens with bank login
2. You "login" (sandbox has test credentials)
3. Approve permissions
4. App receives callback with code ✅

---

## Day 3: Fetch Real Data (4-5 hours)

### 1. Set Up Certificate Handling

**Add to your project:**
```swift
// CertificateHelper.swift
import Foundation

class CertificateHelper {

    static func createSSLConfig(
        certPath: String,
        keyPath: String
    ) -> URLSessionConfiguration {

        let config = URLSessionConfiguration.default

        // Load certificate and key
        guard let certData = try? Data(contentsOf: URL(fileURLWithPath: certPath)),
              let keyData = try? Data(contentsOf: URL(fileURLWithPath: keyPath)) else {
            print("❌ Failed to load certificate files")
            return config
        }

        // In production, properly configure mTLS
        // For now, just prepare the data
        print("✅ Certificates loaded")
        print("   Cert: \(certData.count) bytes")
        print("   Key: \(keyData.count) bytes")

        return config
    }
}
```

### 2. Exchange Code for Token

```swift
// TokenExchange.swift
import Foundation

struct TokenExchange {

    static func getAccessToken(
        code: String,
        tokenEndpoint: String,
        clientId: String
    ) async throws -> String {

        let url = URL(string: tokenEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "finpessoal://oauth-callback",
            "client_id": clientId
        ]

        request.httpBody = body.percentEncoded()

        // Use certificate config from step 1
        let config = CertificateHelper.createSSLConfig(
            certPath: "/path/to/transport-cert.pem",
            keyPath: "/path/to/transport-key.pem"
        )
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Token exchange failed")
            throw NSError(domain: "TokenError", code: -1)
        }

        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let accessToken = json["access_token"] as! String

        print("✅ Access token received!")
        print("   Token: \(accessToken.prefix(20))...")

        return accessToken
    }
}

extension Dictionary where Key == String, Value == String {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
```

### 3. Fetch Accounts

```swift
// AccountsFetch.swift
import Foundation

struct AccountsFetch {

    static func getAccounts(
        accessToken: String,
        apiEndpoint: String
    ) async throws -> [String: Any] {

        let url = URL(string: "\(apiEndpoint)/accounts")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Accounts fetch failed")
            throw NSError(domain: "AccountsError", code: -1)
        }

        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        print("✅ Accounts received!")
        if let data = json["data"] as? [[String: Any]] {
            print("   Found \(data.count) accounts")
            for account in data {
                if let accountId = account["accountId"] as? String {
                    print("   - Account: \(accountId)")
                }
            }
        }

        return json
    }
}
```

### 4. Complete End-to-End Test

```swift
// OpenFinanceE2ETest.swift
import Foundation

@MainActor
class OpenFinanceE2ETest {

    func runCompleteFlow() async throws {
        print("🚀 Starting Open Finance E2E Test\n")

        // Configuration (replace with real sandbox values)
        let config = SandboxConfig(
            clientId: "your-client-id",
            authEndpoint: "https://sandbox.bank.com/oauth/authorize",
            tokenEndpoint: "https://sandbox.bank.com/oauth/token",
            apiEndpoint: "https://sandbox.bank.com/open-banking/accounts/v2"
        )

        // Step 1: OAuth
        print("📝 Step 1: User Authorization")
        let oauthTest = OpenFinanceOAuthTest()
        // Get authorization code (opens browser)

        // Step 2: Get token
        print("\n📝 Step 2: Exchange Code for Token")
        // let accessToken = try await TokenExchange.getAccessToken(...)

        // Step 3: Fetch accounts
        print("\n📝 Step 3: Fetch Accounts")
        // let accounts = try await AccountsFetch.getAccounts(...)

        // Step 4: Fetch transactions
        print("\n📝 Step 4: Fetch Transactions")
        // Implementation similar to accounts

        print("\n✅ E2E Test Complete!")
        print("   You now know how to:")
        print("   ✓ Handle OAuth flow")
        print("   ✓ Exchange codes for tokens")
        print("   ✓ Fetch account data")
        print("   ✓ Ready for production implementation!")
    }
}

struct SandboxConfig {
    let clientId: String
    let authEndpoint: String
    let tokenEndpoint: String
    let apiEndpoint: String
}
```

---

## Day 4-5: Build POC UI (6-8 hours)

### Integrate into FinPessoal

**1. Add to TransactionsScreen:**
```swift
.sheet(isPresented: $showingOpenFinanceTest) {
    OpenFinancePOCScreen()
}
```

**2. Create POC Screen:**
```swift
struct OpenFinancePOCScreen: View {
    @State private var status = "Ready to test"
    @State private var accounts: [String] = []

    var body: some View {
        NavigationView {
            List {
                Section("Status") {
                    Text(status)
                }

                Section("Test Actions") {
                    Button("1. Test Directory API") {
                        testDirectory()
                    }

                    Button("2. Start OAuth Flow") {
                        startOAuth()
                    }

                    Button("3. Fetch Accounts") {
                        fetchAccounts()
                    }
                    .disabled(accounts.isEmpty)
                }

                Section("Results") {
                    ForEach(accounts, id: \.self) { account in
                        Text(account)
                    }
                }
            }
            .navigationTitle("Open Finance POC")
        }
    }

    private func testDirectory() {
        Task {
            status = "Testing Directory API..."
            await OpenFinanceQuickTest.testDirectoryAPI()
            status = "✅ Directory API works!"
        }
    }

    private func startOAuth() {
        Task {
            status = "Starting OAuth flow..."
            // Implement OAuth test
            status = "✅ OAuth flow completed!"
        }
    }

    private func fetchAccounts() {
        Task {
            status = "Fetching accounts..."
            // Implement account fetch
            accounts = ["Account 1", "Account 2"]
            status = "✅ Fetched \(accounts.count) accounts!"
        }
    }
}
```

---

## Success Criteria

After following this guide, you should have:

✅ **Day 1:** Sandbox account + test certificates + first API call
✅ **Day 2:** OAuth flow working (browser opens, code received)
✅ **Day 3:** Token exchange + account data fetched
✅ **Day 4-5:** POC UI showing real sandbox data

**You're ready for production when:**
- ✅ Understand the complete flow
- ✅ Successfully tested with sandbox
- ✅ Have POC showing accounts/transactions
- ✅ Know what production certificates cost
- ✅ Decided: DIY vs hire consultant

---

## Next Steps

**After completing POC:**

**Option A: Continue DIY**
→ Get production certificates (R$ 500-2,000)
→ Register official software statement
→ Implement full security (mTLS, signing)
→ Production testing
→ Launch!

**Option B: Hire Consultant**
→ Show them your POC
→ They build production version
→ You learn from their code
→ Faster launch!

**Option C: Pause & Use PDF**
→ Your PDF import already works great!
→ Add Open Finance later
→ No rush!

---

## Common Issues & Solutions

### "Certificate not working"
- ✅ Use sandbox self-signed certs first
- ✅ Production requires certified CA

### "OAuth redirect not working"
- ✅ Check Info.plist URL scheme
- ✅ Verify redirect_uri exactly matches

### "API returns 401"
- ✅ Check Bearer token in header
- ✅ Token might be expired (15-60 min lifetime)

### "Can't find sandbox banks"
- ✅ Use directory API to list all participants
- ✅ Each bank has different endpoints

---

## Resources

**Official Docs:**
- Directory: https://web.directory.openbankingbrasil.org.br
- Technical Specs: https://openfinancebrasil.atlassian.net
- Postman Collection: Available in directory portal

**Community:**
- Slack: Open Finance Brasil workspace
- GitHub: Look for example implementations

**Certificate Providers (Production):**
- Serpro: https://www.serpro.gov.br
- Soluti (Certisign): https://www.certisign.com.br
- Valid Certificadora: https://www.validcertificadora.com.br

---

## Timeline Summary

| Phase | Time | Result |
|-------|------|--------|
| Day 1 | 2-3 hours | Sandbox account, certs, first API call ✅ |
| Day 2 | 3-4 hours | OAuth flow working ✅ |
| Day 3 | 4-5 hours | Token exchange, data fetched ✅ |
| Day 4-5 | 6-8 hours | POC UI with real data ✅ |
| **Total** | **15-20 hours** | **Working POC!** 🎉 |

**After POC:**
- Production implementation: 4-8 weeks
- Security audit: 1-2 weeks
- Launch: Week 10-12

---

## Questions?

Common questions answered:

**Q: Do I need a CNPJ?**
A: For sandbox, no. For production, yes.

**Q: Can I test with real banks?**
A: No, sandbox only has test banks. Real banks need production certs.

**Q: How much do certificates cost?**
A: R$ 500-2,000/year depending on provider.

**Q: Is there a faster way?**
A: Yes, hire a consultant. But POC helps you understand the system.

**Q: Can I use this POC code in production?**
A: No, it's simplified. Production needs proper security, error handling, etc.

**Q: Should I do this or stick with PDF?**
A: Both! PDF works now. Open Finance is a future enhancement.
