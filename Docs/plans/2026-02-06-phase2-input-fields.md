# Phase 2: Inner Shadows on All Input Fields - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace all TextField, SecureField, and TextEditor instances with StyledTextField, StyledSecureField, and StyledTextEditor components featuring inner shadows, focus animations, and error states.

**Architecture:** Create three reusable styled input components that wrap native SwiftUI inputs with layered backgrounds, inner shadows, focus state animations (300ms spring), and comprehensive accessibility. Components integrate with existing AnimationSettings.effectiveMode and OldMoney color palette.

**Tech Stack:** SwiftUI, @FocusState, InnerShadowModifier, LayeredBackgroundModifier, AnimationEngine, HapticEngine, AccessibilityTraits

---

## Phase 2 Component Inventory

**TextField instances (24 files):**
- Auth: AuthScreen.swift (email)
- Account: AddAccountView.swift (name, balance), EditAccountView.swift (name)
- Transaction: AddTransactionView.swift (amount, description), TransactionDetailView.swift (description)
- Budget: AddBudgetScreen.swift (name, amount), AddEditCategorySheet.swift (name)
- Bills: AddBillScreen.swift (name, amount), BillsScreen.swift (search)
- Goals: AddGoalScreen.swift (name, target amount, current amount), GoalCard.swift (contribution)
- Categories: CategoriesManagementScreen.swift (search), CategoryFormView.swift (name)
- CreditCard: AddCreditCardView.swift (name, limit, balance), AddCreditCardTransactionView.swift (amount, description), PayCreditCardView.swift (amount)
- Loan: AddLoanView.swift (name, amount, interest rate), MakeLoanPaymentView.swift (amount)
- Profile: ProfileEditView.swift (name, email)
- Help: HelpTopicDetailView.swift (search), HelpFAQScreen.swift (search), HelpScreen.swift (search)

**SecureField instances (2 files):**
- Auth: AuthScreen.swift (password), LoginView.swift (password)

**TextEditor instances (2 files):**
- Bills: AddBillScreen.swift (notes)
- Help: HelpTopicDetailView.swift (notes)

**Search bars (.searchable, 4 files):**
- Transaction: TransactionsScreen.swift, TransactionsContentView.swift
- Help: HelpScreen.swift, HelpFAQScreen.swift

**Total:** 24 TextField files, 2 SecureField files, 2 TextEditor files, 4 search bar files = **32 files to modify**

---

## Task 1: Create StyledTextField Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/StyledTextField.swift`
- Read: `FinPessoal/Code/Animation/Components/DepthModifier.swift` (reference InnerShadowModifier)
- Read: `FinPessoal/Code/Animation/AnimationEngine.swift` (spring presets)
- Read: `FinPessoal/Code/Theme/Color+OldMoney.swift` (color palette)

**Step 1: Write the component structure**

Create `FinPessoal/Code/Animation/Components/StyledTextField.swift`:

```swift
//
//  StyledTextField.swift
//  FinPessoal
//
//  Created by Claude Code on 06/02/26.
//

import SwiftUI

/// Styled text field with inner shadow, focus animation, and error states
struct StyledTextField: View {
  // MARK: - Properties

  let title: String
  @Binding var text: String
  let placeholder: String
  let keyboardType: UIKeyboardType
  let autocapitalization: TextInputAutocapitalization
  let error: String?

  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  // MARK: - Initialization

  init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    keyboardType: UIKeyboardType = .default,
    autocapitalization: TextInputAutocapitalization = .sentences,
    error: String? = nil
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.keyboardType = keyboardType
    self.autocapitalization = autocapitalization
    self.error = error
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      // Label
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      // Text field with styled background
      TextField(placeholder, text: $text)
        .keyboardType(keyboardType)
        .textInputAutocapitalization(autocapitalization)
        .padding(12)
        .background(
          ZStack {
            // Layered background
            RoundedRectangle(cornerRadius: 8)
              .fill(backgroundColor)

            // Inner shadow overlay
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(
                LinearGradient(
                  colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                    Color.clear
                  ],
                  startPoint: .top,
                  endPoint: .bottom
                ),
                lineWidth: 1
              )

            RoundedRectangle(cornerRadius: 8)
              .fill(
                LinearGradient(
                  colors: [
                    Color.black.opacity(innerShadowIntensity),
                    Color.clear
                  ],
                  startPoint: .top,
                  endPoint: .center
                )
              )
              .allowsHitTesting(false)
          }
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(borderColor, lineWidth: borderWidth)
        )
        .focused($isFocused)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "Empty" : text)
        .accessibilityHint(error != nil ? "Error: \(error!)" : "")
        .onChange(of: isFocused) { _, newValue in
          if newValue && animationMode == .full {
            HapticEngine.shared.light()
          }
        }

      // Error message
      if let error = error {
        Text(error)
          .font(.caption)
          .foregroundColor(Color.oldMoney.error)
          .accessibilityHidden(true)
      }
    }
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
    .animation(focusAnimation, value: isFocused)
  }

  // MARK: - Computed Properties

  private var backgroundColor: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : Color.oldMoney.surface
  }

  private var borderColor: Color {
    if error != nil {
      return Color.oldMoney.error
    } else if isFocused {
      return Color.oldMoney.accent
    } else {
      return Color.clear
    }
  }

  private var borderWidth: CGFloat {
    (isFocused || error != nil) ? 2 : 0
  }

  private var innerShadowIntensity: Double {
    if error != nil {
      return 0.08
    } else if isFocused {
      return 0.04
    } else {
      return 0.06
    }
  }

  private var focusAnimation: Animation? {
    switch animationMode {
    case .full:
      return AnimationEngine.Spring.snappy
    case .reduced:
      return AnimationEngine.Timing.quickFade
    case .minimal:
      return nil
    }
  }
}

// MARK: - Preview

#Preview("StyledTextField - Light") {
  VStack(spacing: 20) {
    StyledTextField(
      title: "Email",
      text: .constant(""),
      placeholder: "Enter your email",
      keyboardType: .emailAddress,
      autocapitalization: .never
    )

    StyledTextField(
      title: "Amount",
      text: .constant("1234.56"),
      placeholder: "0.00",
      keyboardType: .decimalPad
    )

    StyledTextField(
      title: "Description",
      text: .constant(""),
      placeholder: "Enter description",
      error: "Description is required"
    )
  }
  .padding()
}

#Preview("StyledTextField - Dark") {
  VStack(spacing: 20) {
    StyledTextField(
      title: "Email",
      text: .constant(""),
      placeholder: "Enter your email",
      keyboardType: .emailAddress,
      autocapitalization: .never
    )

    StyledTextField(
      title: "Amount",
      text: .constant("1234.56"),
      placeholder: "0.00",
      keyboardType: .decimalPad
    )

    StyledTextField(
      title: "Description",
      text: .constant(""),
      placeholder: "Enter description",
      error: "Description is required"
    )
  }
  .padding()
  .preferredColorScheme(.dark)
}
```

**Step 2: Add the file to Xcode project**

Run in Xcode:
1. Right-click on `FinPessoal/Code/Animation/Components` folder
2. Select "Add Files to FinPessoal"
3. Choose `StyledTextField.swift`
4. Ensure "FinPessoal" target is checked

**Step 3: Build and verify compilation**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15' build`

Expected: Build succeeds with no errors

**Step 4: Test in preview**

1. Open `StyledTextField.swift` in Xcode
2. Click "Resume" on canvas preview
3. Verify:
   - Light mode: Recessed appearance with subtle inner shadow
   - Dark mode: Darker background with visible inner glow
   - Error state: Red border with error message below
   - Focus state: Accent color border animation

**Step 5: Commit**

```bash
git add FinPessoal/Code/Animation/Components/StyledTextField.swift
git commit -m "feat(phase2): add StyledTextField component with inner shadows

- Inner shadow effect with recessed appearance
- Focus state animation (300ms spring)
- Error state with red border and message
- Layered background adapts to light/dark mode
- Integration with AnimationSettings.effectiveMode
- Full accessibility with VoiceOver labels and hints
- Keyboard type and autocapitalization support"
```

---

## Task 2: Create StyledSecureField Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/StyledSecureField.swift`
- Reference: `FinPessoal/Code/Animation/Components/StyledTextField.swift`

**Step 1: Write the component**

Create `FinPessoal/Code/Animation/Components/StyledSecureField.swift`:

```swift
//
//  StyledSecureField.swift
//  FinPessoal
//
//  Created by Claude Code on 06/02/26.
//

import SwiftUI

/// Styled secure field with inner shadow, focus animation, and error states
struct StyledSecureField: View {
  // MARK: - Properties

  let title: String
  @Binding var text: String
  let placeholder: String
  let error: String?

  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  // MARK: - Initialization

  init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    error: String? = nil
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.error = error
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      // Label
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      // Secure field with styled background
      SecureField(placeholder, text: $text)
        .padding(12)
        .background(
          ZStack {
            // Layered background
            RoundedRectangle(cornerRadius: 8)
              .fill(backgroundColor)

            // Inner shadow overlay
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(
                LinearGradient(
                  colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                    Color.clear
                  ],
                  startPoint: .top,
                  endPoint: .bottom
                ),
                lineWidth: 1
              )

            RoundedRectangle(cornerRadius: 8)
              .fill(
                LinearGradient(
                  colors: [
                    Color.black.opacity(innerShadowIntensity),
                    Color.clear
                  ],
                  startPoint: .top,
                  endPoint: .center
                )
              )
              .allowsHitTesting(false)
          }
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(borderColor, lineWidth: borderWidth)
        )
        .focused($isFocused)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "Empty" : "Entered")
        .accessibilityHint(error != nil ? "Error: \(error!). Input is secured and hidden" : "Input is secured and hidden")
        .onChange(of: isFocused) { _, newValue in
          if newValue && animationMode == .full {
            HapticEngine.shared.light()
          }
        }

      // Error message
      if let error = error {
        Text(error)
          .font(.caption)
          .foregroundColor(Color.oldMoney.error)
          .accessibilityHidden(true)
      }
    }
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
    .animation(focusAnimation, value: isFocused)
  }

  // MARK: - Computed Properties

  private var backgroundColor: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : Color.oldMoney.surface
  }

  private var borderColor: Color {
    if error != nil {
      return Color.oldMoney.error
    } else if isFocused {
      return Color.oldMoney.accent
    } else {
      return Color.clear
    }
  }

  private var borderWidth: CGFloat {
    (isFocused || error != nil) ? 2 : 0
  }

  private var innerShadowIntensity: Double {
    if error != nil {
      return 0.08
    } else if isFocused {
      return 0.04
    } else {
      return 0.06
    }
  }

  private var focusAnimation: Animation? {
    switch animationMode {
    case .full:
      return AnimationEngine.Spring.snappy
    case .reduced:
      return AnimationEngine.Timing.quickFade
    case .minimal:
      return nil
    }
  }
}

// MARK: - Preview

#Preview("StyledSecureField - Light") {
  VStack(spacing: 20) {
    StyledSecureField(
      title: "Password",
      text: .constant(""),
      placeholder: "Enter your password"
    )

    StyledSecureField(
      title: "Confirm Password",
      text: .constant("password123"),
      placeholder: "Confirm password"
    )

    StyledSecureField(
      title: "Current Password",
      text: .constant(""),
      placeholder: "Enter current password",
      error: "Password is required"
    )
  }
  .padding()
}

#Preview("StyledSecureField - Dark") {
  VStack(spacing: 20) {
    StyledSecureField(
      title: "Password",
      text: .constant(""),
      placeholder: "Enter your password"
    )

    StyledSecureField(
      title: "Confirm Password",
      text: .constant("password123"),
      placeholder: "Confirm password"
    )

    StyledSecureField(
      title: "Current Password",
      text: .constant(""),
      placeholder: "Enter current password",
      error: "Password is required"
    )
  }
  .padding()
  .preferredColorScheme(.dark)
}
```

**Step 2: Add to Xcode project and build**

Same process as Task 1.

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Components/StyledSecureField.swift
git commit -m "feat(phase2): add StyledSecureField component

- SecureField wrapper with inner shadow effect
- Focus state animation matching StyledTextField
- Error state with validation feedback
- Full accessibility with 'Entered' value for privacy
- Maintains security while providing visual feedback"
```

---

## Task 3: Create StyledTextEditor Component

**Files:**
- Create: `FinPessoal/Code/Animation/Components/StyledTextEditor.swift`
- Reference: `FinPessoal/Code/Animation/Components/StyledTextField.swift`

**Step 1: Write the component**

Create `FinPessoal/Code/Animation/Components/StyledTextEditor.swift`:

```swift
//
//  StyledTextEditor.swift
//  FinPessoal
//
//  Created by Claude Code on 06/02/26.
//

import SwiftUI

/// Styled text editor with inner shadow, focus animation, and error states
struct StyledTextEditor: View {
  // MARK: - Properties

  let title: String
  @Binding var text: String
  let placeholder: String
  let minHeight: CGFloat
  let error: String?

  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  @State private var animationMode: AnimationMode = .full

  // MARK: - Initialization

  init(
    title: String,
    text: Binding<String>,
    placeholder: String = "",
    minHeight: CGFloat = 100,
    error: String? = nil
  ) {
    self.title = title
    self._text = text
    self.placeholder = placeholder
    self.minHeight = minHeight
    self.error = error
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      // Label
      Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(Color.oldMoney.textSecondary)
        .accessibilityHidden(true)

      // Text editor with styled background
      ZStack(alignment: .topLeading) {
        // Placeholder
        if text.isEmpty {
          Text(placeholder)
            .foregroundColor(Color.oldMoney.textSecondary.opacity(0.5))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .accessibilityHidden(true)
        }

        TextEditor(text: $text)
          .padding(8)
          .frame(minHeight: minHeight)
          .scrollContentBackground(.hidden)
          .focused($isFocused)
      }
      .background(
        ZStack {
          // Layered background
          RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)

          // Inner shadow overlay
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(
              LinearGradient(
                colors: [
                  Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                  Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
              ),
              lineWidth: 1
            )

          RoundedRectangle(cornerRadius: 8)
            .fill(
              LinearGradient(
                colors: [
                  Color.black.opacity(innerShadowIntensity),
                  Color.clear
                ],
                startPoint: .top,
                endPoint: .center
              )
            )
            .allowsHitTesting(false)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(borderColor, lineWidth: borderWidth)
      )
      .accessibilityLabel(title)
      .accessibilityValue(text.isEmpty ? "Empty" : text)
      .accessibilityHint(error != nil ? "Error: \(error!)" : "Multi-line text input")
      .onChange(of: isFocused) { _, newValue in
        if newValue && animationMode == .full {
          HapticEngine.shared.light()
        }
      }

      // Error message
      if let error = error {
        Text(error)
          .font(.caption)
          .foregroundColor(Color.oldMoney.error)
          .accessibilityHidden(true)
      }
    }
    .onAppear {
      animationMode = AnimationSettings.shared.effectiveMode
    }
    .animation(focusAnimation, value: isFocused)
  }

  // MARK: - Computed Properties

  private var backgroundColor: Color {
    colorScheme == .dark
      ? Color(white: 0.15)
      : Color.oldMoney.surface
  }

  private var borderColor: Color {
    if error != nil {
      return Color.oldMoney.error
    } else if isFocused {
      return Color.oldMoney.accent
    } else {
      return Color.clear
    }
  }

  private var borderWidth: CGFloat {
    (isFocused || error != nil) ? 2 : 0
  }

  private var innerShadowIntensity: Double {
    if error != nil {
      return 0.08
    } else if isFocused {
      return 0.04
    } else {
      return 0.06
    }
  }

  private var focusAnimation: Animation? {
    switch animationMode {
    case .full:
      return AnimationEngine.Spring.snappy
    case .reduced:
      return AnimationEngine.Timing.quickFade
    case .minimal:
      return nil
    }
  }
}

// MARK: - Preview

#Preview("StyledTextEditor - Light") {
  VStack(spacing: 20) {
    StyledTextEditor(
      title: "Notes",
      text: .constant(""),
      placeholder: "Enter your notes here...",
      minHeight: 120
    )

    StyledTextEditor(
      title: "Description",
      text: .constant("This is a sample description with multiple lines of text."),
      placeholder: "Enter description",
      minHeight: 100
    )

    StyledTextEditor(
      title: "Comments",
      text: .constant(""),
      placeholder: "Add comments",
      minHeight: 80,
      error: "Comments are required"
    )
  }
  .padding()
}

#Preview("StyledTextEditor - Dark") {
  VStack(spacing: 20) {
    StyledTextEditor(
      title: "Notes",
      text: .constant(""),
      placeholder: "Enter your notes here...",
      minHeight: 120
    )

    StyledTextEditor(
      title: "Description",
      text: .constant("This is a sample description with multiple lines of text."),
      placeholder: "Enter description",
      minHeight: 100
    )

    StyledTextEditor(
      title: "Comments",
      text: .constant(""),
      placeholder: "Add comments",
      minHeight: 80,
      error: "Comments are required"
    )
  }
  .padding()
  .preferredColorScheme(.dark)
}
```

**Step 2: Add to Xcode project and build**

Same process as Task 1.

**Step 3: Commit**

```bash
git add FinPessoal/Code/Animation/Components/StyledTextEditor.swift
git commit -m "feat(phase2): add StyledTextEditor component

- Multi-line text editor with inner shadow effect
- Placeholder text support (TextEditor doesn't have native placeholder)
- Focus state animation with border glow
- Configurable minimum height
- Full accessibility with multi-line hint"
```

---

## Task 4: Migrate Auth Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Auth/Screen/AuthScreen.swift`
- Modify: `FinPessoal/Code/Features/Main/View/LoginView.swift`

**Step 1: Migrate AuthScreen.swift**

Replace lines 34-46 (email and password fields):

```swift
// BEFORE:
TextField("auth.email.placeholder", text: $email)
  .textFieldStyle(RoundedBorderTextFieldStyle())
  .keyboardType(.emailAddress)
  .autocapitalization(.none)
  .accessibilityLabel("auth.email.label")
  .accessibilityHint("Enter your email address to sign in")
  .accessibilityValue(email.isEmpty ? "Empty" : email)

SecureField("auth.password.placeholder", text: $password)
  .textFieldStyle(RoundedBorderTextFieldStyle())
  .accessibilityLabel("auth.password.label")
  .accessibilityHint("Enter your password. Input is secured and hidden")
  .accessibilityValue(password.isEmpty ? "Empty" : "Entered")

// AFTER:
StyledTextField(
  title: String(localized: "auth.email.label"),
  text: $email,
  placeholder: String(localized: "auth.email.placeholder"),
  keyboardType: .emailAddress,
  autocapitalization: .never
)

StyledSecureField(
  title: String(localized: "auth.password.label"),
  text: $password,
  placeholder: String(localized: "auth.password.placeholder")
)
```

**Step 2: Migrate LoginView.swift**

Find and replace TextField/SecureField instances with styled components.

**Step 3: Build and test**

Run: `xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build`

Expected: Build succeeds

**Step 4: Manual QA**

1. Run app in simulator
2. Navigate to Auth screen
3. Tap email field → verify focus border animation
4. Type email → verify inner shadow visible
5. Tap password field → verify same behavior
6. Test VoiceOver accessibility

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Auth/Screen/AuthScreen.swift FinPessoal/Code/Features/Main/View/LoginView.swift
git commit -m "feat(phase2): migrate auth screens to styled inputs

- Replace TextField with StyledTextField for email
- Replace SecureField with StyledSecureField for password
- Maintain all accessibility labels and hints
- Focus animations now work on auth inputs"
```

---

## Task 5: Migrate Account Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Account/View/AddAccountView.swift`
- Modify: `FinPessoal/Code/Features/Account/View/EditAccountView.swift`

**Step 1: Migrate AddAccountView.swift**

Find TextField instances for:
- Account name
- Initial balance

Replace with:
```swift
StyledTextField(
  title: String(localized: "account.name"),
  text: $accountName,
  placeholder: String(localized: "account.name.placeholder")
)

StyledTextField(
  title: String(localized: "account.balance"),
  text: $initialBalance,
  placeholder: "0.00",
  keyboardType: .decimalPad
)
```

**Step 2: Migrate EditAccountView.swift**

Similar replacements for account name field.

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Account/View/AddAccountView.swift FinPessoal/Code/Features/Account/View/EditAccountView.swift
git commit -m "feat(phase2): migrate account screens to styled inputs

- AddAccountView: name and balance fields
- EditAccountView: name field
- Inner shadow effect on all account inputs"
```

---

## Task 6: Migrate Transaction Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Transaction/Screen/AddTransactionView.swift`
- Modify: `FinPessoal/Code/Features/Transaction/Screen/TransactionDetailView.swift`

**Step 1: Migrate AddTransactionView.swift**

Replace lines 50-59 (amount and description):

```swift
StyledTextField(
  title: String(localized: "transactions.amount"),
  text: $amount,
  placeholder: String(localized: "transactions.amount.placeholder"),
  keyboardType: .decimalPad
)

StyledTextField(
  title: String(localized: "transactions.description"),
  text: $description,
  placeholder: String(localized: "transactions.description.placeholder")
)
```

**Step 2: Migrate TransactionDetailView.swift**

Replace description field with StyledTextField.

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Transaction/Screen/AddTransactionView.swift FinPessoal/Code/Features/Transaction/Screen/TransactionDetailView.swift
git commit -m "feat(phase2): migrate transaction screens to styled inputs

- Amount field with decimal keyboard
- Description field with styled appearance
- Focus states on transaction inputs"
```

---

## Task 7: Migrate Budget Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Budget/Screen/AddBudgetScreen.swift`
- Modify: `FinPessoal/Code/Features/Budget/View/AddEditCategorySheet.swift`

**Step 1: Migrate AddBudgetScreen.swift**

Replace budget name and amount fields:

```swift
StyledTextField(
  title: String(localized: "budget.name"),
  text: $budgetName,
  placeholder: String(localized: "budget.name.placeholder")
)

StyledTextField(
  title: String(localized: "budget.amount"),
  text: $budgetAmount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)
```

**Step 2: Migrate AddEditCategorySheet.swift**

Replace category name field.

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Budget/Screen/AddBudgetScreen.swift FinPessoal/Code/Features/Budget/View/AddEditCategorySheet.swift
git commit -m "feat(phase2): migrate budget screens to styled inputs

- Budget name and amount fields
- Category name field with inner shadows"
```

---

## Task 8: Migrate Bills Screen (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Bills/Screen/AddBillScreen.swift`
- Modify: `FinPessoal/Code/Features/Bills/Screen/BillsScreen.swift`

**Step 1: Migrate AddBillScreen.swift**

Replace bill name, amount, and notes fields:

```swift
StyledTextField(
  title: String(localized: "bills.name"),
  text: $billName,
  placeholder: String(localized: "bills.name.placeholder")
)

StyledTextField(
  title: String(localized: "bills.amount"),
  text: $billAmount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)

StyledTextEditor(
  title: String(localized: "bills.notes"),
  text: $notes,
  placeholder: String(localized: "bills.notes.placeholder"),
  minHeight: 100
)
```

**Step 2: Update BillsScreen.swift search bar**

Note: `.searchable()` is a native SwiftUI modifier and doesn't need replacement.
Keep as-is: `.searchable(text: $searchText, prompt: "Search bills")`

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Bills/Screen/AddBillScreen.swift
git commit -m "feat(phase2): migrate bills screens to styled inputs

- Bill name and amount fields with StyledTextField
- Notes field with StyledTextEditor (multi-line)
- Search bar kept as native .searchable modifier"
```

---

## Task 9: Migrate Goals Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Goals/Screen/AddGoalScreen.swift`
- Modify: `FinPessoal/Code/Features/Goals/View/GoalCard.swift`

**Step 1: Migrate AddGoalScreen.swift**

Replace goal name, target amount, and current amount fields:

```swift
StyledTextField(
  title: String(localized: "goals.name"),
  text: $goalName,
  placeholder: String(localized: "goals.name.placeholder")
)

StyledTextField(
  title: String(localized: "goals.target.amount"),
  text: $targetAmount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)

StyledTextField(
  title: String(localized: "goals.current.amount"),
  text: $currentAmount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)
```

**Step 2: Migrate GoalCard.swift contribution field**

Replace contribution input TextField.

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Goals/Screen/AddGoalScreen.swift FinPessoal/Code/Features/Goals/View/GoalCard.swift
git commit -m "feat(phase2): migrate goals screens to styled inputs

- Goal name, target, and current amount fields
- Contribution input on goal cards
- Decimal pad keyboard for all amounts"
```

---

## Task 10: Migrate Categories Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Categories/View/CategoriesManagementScreen.swift`
- Modify: `FinPessoal/Code/Features/Categories/View/CategoryFormView.swift`

**Step 1: Migrate CategoriesManagementScreen.swift**

Search bar: Keep `.searchable()` as-is.

**Step 2: Migrate CategoryFormView.swift**

Replace category name field:

```swift
StyledTextField(
  title: String(localized: "category.name"),
  text: $categoryName,
  placeholder: String(localized: "category.name.placeholder")
)
```

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Categories/View/CategoryFormView.swift
git commit -m "feat(phase2): migrate categories screens to styled inputs

- Category name field with inner shadow
- Search kept as native .searchable modifier"
```

---

## Task 11: Migrate CreditCard Screens (3 files)

**Files:**
- Modify: `FinPessoal/Code/Features/CreditCard/View/AddCreditCardView.swift`
- Modify: `FinPessoal/Code/Features/CreditCard/View/AddCreditCardTransactionView.swift`
- Modify: `FinPessoal/Code/Features/CreditCard/View/PayCreditCardView.swift`

**Step 1: Migrate AddCreditCardView.swift**

Replace card name, limit, and balance fields:

```swift
StyledTextField(
  title: String(localized: "creditcard.name"),
  text: $cardName,
  placeholder: String(localized: "creditcard.name.placeholder")
)

StyledTextField(
  title: String(localized: "creditcard.limit"),
  text: $cardLimit,
  placeholder: "0.00",
  keyboardType: .decimalPad
)

StyledTextField(
  title: String(localized: "creditcard.balance"),
  text: $cardBalance,
  placeholder: "0.00",
  keyboardType: .decimalPad
)
```

**Step 2: Migrate AddCreditCardTransactionView.swift**

Replace amount and description fields.

**Step 3: Migrate PayCreditCardView.swift**

Replace payment amount field.

**Step 4: Build and commit**

```bash
git add FinPessoal/Code/Features/CreditCard/View/AddCreditCardView.swift FinPessoal/Code/Features/CreditCard/View/AddCreditCardTransactionView.swift FinPessoal/Code/Features/CreditCard/View/PayCreditCardView.swift
git commit -m "feat(phase2): migrate credit card screens to styled inputs

- Add card: name, limit, balance fields
- Add transaction: amount, description fields
- Pay card: payment amount field"
```

---

## Task 12: Migrate Loan Screens (2 files)

**Files:**
- Modify: `FinPessoal/Code/Features/Loan/View/AddLoanView.swift`
- Modify: `FinPessoal/Code/Features/Loan/View/MakeLoanPaymentView.swift`

**Step 1: Migrate AddLoanView.swift**

Replace loan name, amount, and interest rate fields:

```swift
StyledTextField(
  title: String(localized: "loan.name"),
  text: $loanName,
  placeholder: String(localized: "loan.name.placeholder")
)

StyledTextField(
  title: String(localized: "loan.amount"),
  text: $loanAmount,
  placeholder: "0.00",
  keyboardType: .decimalPad
)

StyledTextField(
  title: String(localized: "loan.interest.rate"),
  text: $interestRate,
  placeholder: "0.0",
  keyboardType: .decimalPad
)
```

**Step 2: Migrate MakeLoanPaymentView.swift**

Replace payment amount field.

**Step 3: Build and commit**

```bash
git add FinPessoal/Code/Features/Loan/View/AddLoanView.swift FinPessoal/Code/Features/Loan/View/MakeLoanPaymentView.swift
git commit -m "feat(phase2): migrate loan screens to styled inputs

- Add loan: name, amount, interest rate fields
- Make payment: payment amount field
- All fields with decimal pad where appropriate"
```

---

## Task 13: Migrate Profile Screen (1 file)

**Files:**
- Modify: `FinPessoal/Code/Features/Profile/ProfileEditView.swift`

**Step 1: Migrate ProfileEditView.swift**

Replace name and email fields:

```swift
StyledTextField(
  title: String(localized: "profile.name"),
  text: $userName,
  placeholder: String(localized: "profile.name.placeholder")
)

StyledTextField(
  title: String(localized: "profile.email"),
  text: $userEmail,
  placeholder: String(localized: "profile.email.placeholder"),
  keyboardType: .emailAddress,
  autocapitalization: .never
)
```

**Step 2: Build and commit**

```bash
git add FinPessoal/Code/Features/Profile/ProfileEditView.swift
git commit -m "feat(phase2): migrate profile screen to styled inputs

- Name field with default keyboard
- Email field with email keyboard and no autocapitalization"
```

---

## Task 14: Update CHANGELOG.md

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add Phase 2 entry**

Insert at line 10 (under "### Changed - February 2026"):

```markdown
- **Phase 2: Styled Input Fields Complete** (2026-02-06)
  - Created StyledTextField component with inner shadows and focus animations
  - Created StyledSecureField component for password inputs
  - Created StyledTextEditor component for multi-line text
  - Migrated all 24 TextField instances across the app
  - Migrated all 2 SecureField instances (auth screens)
  - Migrated all 2 TextEditor instances (notes fields)
  - Features:
    - Inner shadow effect for recessed appearance
    - Focus state animation (300ms spring, accent border glow)
    - Error state with red border and message below field
    - Layered background adapts to light/dark mode
    - Integration with AnimationSettings.effectiveMode
    - Haptic feedback on focus (light haptic)
    - Full accessibility with VoiceOver labels, values, hints
    - Keyboard type and autocapitalization support
  - Screens updated:
    - Auth: AuthScreen, LoginView
    - Account: AddAccountView, EditAccountView
    - Transaction: AddTransactionView, TransactionDetailView
    - Budget: AddBudgetScreen, AddEditCategorySheet
    - Bills: AddBillScreen (with StyledTextEditor for notes)
    - Goals: AddGoalScreen, GoalCard
    - Categories: CategoryFormView
    - CreditCard: AddCreditCardView, AddCreditCardTransactionView, PayCreditCardView
    - Loan: AddLoanView, MakeLoanPaymentView
    - Profile: ProfileEditView
  - Search bars kept as native .searchable() modifiers (4 files)
  - 32 files total modified with styled input components
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update changelog for Phase 2 completion

- Documented all styled input components
- Listed all migrated screens (32 files)
- Detailed features and accessibility improvements"
```

---

## Task 15: Run Full Test Suite

**Files:**
- Test all modified files

**Step 1: Run unit tests**

Run: `xcodebuild test -project FinPessoal.xcodeproj -scheme FinPessoal -destination 'platform=iOS Simulator,name=iPhone 15'`

Expected: All tests pass

**Step 2: Manual QA checklist**

Test each migrated screen:

1. **Auth screens** (AuthScreen, LoginView)
   - [ ] Email field shows inner shadow
   - [ ] Focus animation works (border glow)
   - [ ] Password field shows "Entered" for accessibility
   - [ ] VoiceOver reads labels and hints

2. **Account screens** (AddAccountView, EditAccountView)
   - [ ] Name field focus animation
   - [ ] Balance field with decimal keyboard
   - [ ] Inner shadows visible in light/dark mode

3. **Transaction screens** (AddTransactionView, TransactionDetailView)
   - [ ] Amount field decimal keyboard
   - [ ] Description field focus state
   - [ ] All fields accessible with VoiceOver

4. **Budget screens** (AddBudgetScreen, AddEditCategorySheet)
   - [ ] Budget name and amount fields styled
   - [ ] Category name field focus animation

5. **Bills screens** (AddBillScreen)
   - [ ] Name and amount fields styled
   - [ ] Notes field uses StyledTextEditor (multi-line)
   - [ ] Notes placeholder visible when empty

6. **Goals screens** (AddGoalScreen, GoalCard)
   - [ ] All amount fields decimal keyboard
   - [ ] Goal name field styled
   - [ ] Contribution field on cards works

7. **Categories screens** (CategoryFormView)
   - [ ] Category name field styled

8. **CreditCard screens** (AddCreditCardView, etc.)
   - [ ] Card name, limit, balance fields styled
   - [ ] Transaction amount/description styled
   - [ ] Payment amount styled

9. **Loan screens** (AddLoanView, MakeLoanPaymentView)
   - [ ] Loan name, amount, rate fields styled
   - [ ] Payment amount styled

10. **Profile screen** (ProfileEditView)
    - [ ] Name field styled
    - [ ] Email field keyboard type correct

**Step 3: Accessibility testing**

Run VoiceOver on device/simulator:
- [ ] All input labels read correctly
- [ ] Empty/filled values announced
- [ ] Error messages read with "Error:" prefix
- [ ] Focus states provide feedback

**Step 4: Animation mode testing**

Test all three animation modes:
- [ ] Full mode: 300ms spring focus animation
- [ ] Reduced mode: Quick fade transition
- [ ] Minimal mode: Instant border change

**Step 5: Performance check**

Monitor frame rate during input focus:
- [ ] No dropped frames during animation
- [ ] Haptic feedback fires correctly on focus
- [ ] Memory usage normal (no leaks)

---

## Success Criteria

Phase 2 complete when:

1. ✅ StyledTextField component created and tested
2. ✅ StyledSecureField component created and tested
3. ✅ StyledTextEditor component created and tested
4. ✅ All 24 TextField instances migrated
5. ✅ All 2 SecureField instances migrated
6. ✅ All 2 TextEditor instances migrated
7. ✅ Search bars kept as native .searchable()
8. ✅ All accessibility labels maintained
9. ✅ Focus animations work in all modes
10. ✅ Error states display correctly
11. ✅ Inner shadows visible in light/dark mode
12. ✅ VoiceOver reads all inputs correctly
13. ✅ CHANGELOG.md updated
14. ✅ All tests pass
15. ✅ Build succeeds with zero warnings

---

## Rollback Plan

If issues arise:
- Phase 2 is in separate branch
- Can revert individual screen migrations
- Styled components are additive (don't break existing code)
- Original TextField/SecureField still work if needed

---

## Next Phase

After Phase 2 completion:
- **Phase 3**: Pressed depth on interactive elements (list rows, buttons, cards)
- **Phase 4**: Frosted glass on sheets and navigation bars
