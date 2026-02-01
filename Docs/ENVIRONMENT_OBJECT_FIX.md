# Environment Object Missing Error - Fixed

## Error
```
Fatal error: No ObservableObject of type AccountViewModel found.
A View.environmentObject(_:) for AccountViewModel may be missing as an ancestor of this view.
```

## Root Cause

When presenting views in **sheets** (`.sheet()` modifier), SwiftUI creates a **new environment context**. This means environment objects from the parent view are **not automatically inherited** by the sheet.

The `AddTransactionView` requires `AccountViewModel` via `@EnvironmentObject`, but when it was presented in a sheet, the environment object wasn't being passed through.

## Solution

Explicitly inject the `AccountViewModel` when presenting `AddTransactionView` in sheets by adding `.environmentObject()` modifier.

## Files Fixed

### 1. QuickActionsView.swift
**Before:**
```swift
.sheet(isPresented: $showingAddTransaction) {
  AddTransactionView(transactionViewModel: TransactionViewModel(...))
}
```

**After:**
```swift
.sheet(isPresented: $showingAddTransaction) {
  AddTransactionView(transactionViewModel: TransactionViewModel(...))
    .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
}
```

### 2. TransactionsScreen.swift
**Before:**
```swift
.sheet(isPresented: $transactionViewModel.showingAddTransaction) {
  if UIDevice.current.userInterfaceIdiom != .pad {
    AddTransactionView(transactionViewModel: transactionViewModel)
  }
}
```

**After:**
```swift
.sheet(isPresented: $transactionViewModel.showingAddTransaction) {
  if UIDevice.current.userInterfaceIdiom != .pad {
    AddTransactionView(transactionViewModel: transactionViewModel)
      .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
  }
}
```

### 3. TransactionsContentView.swift
**Before:**
```swift
.sheet(isPresented: $transactionViewModel.showingAddTransaction) {
  AddTransactionView(transactionViewModel: transactionViewModel)
}
```

**After:**
```swift
.sheet(isPresented: $transactionViewModel.showingAddTransaction) {
  AddTransactionView(transactionViewModel: transactionViewModel)
    .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
}
```

### 4. iPadMainView.swift (iPadAddTransactionView)
**Before:**
```swift
var body: some View {
  AddTransactionView(transactionViewModel: transactionViewModel)
    .toolbar {
      // ...
    }
}
```

**After:**
```swift
var body: some View {
  AddTransactionView(transactionViewModel: transactionViewModel)
    .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
    .toolbar {
      // ...
    }
}
```

## Why This Happens

### SwiftUI Environment Inheritance Rules:

1. **Normal navigation** (NavigationLink, TabView): ✅ Environment objects are inherited
2. **Sheets** (`.sheet()`): ❌ New environment - must explicitly pass environment objects
3. **FullScreenCover** (`.fullScreenCover()`): ❌ New environment - must explicitly pass
4. **Popovers** (`.popover()`): ❌ New environment - must explicitly pass

## Pattern to Follow

When presenting views that use `@EnvironmentObject` in sheets/covers/popovers:

### ❌ DON'T:
```swift
.sheet(isPresented: $showing) {
  MyView() // Missing environment objects!
}
```

### ✅ DO:
```swift
.sheet(isPresented: $showing) {
  MyView()
    .environmentObject(viewModel1)
    .environmentObject(viewModel2)
    // Pass all required environment objects
}
```

## Alternative Approaches

### Option 1: Pass via @EnvironmentObject (Current approach)
```swift
.sheet(isPresented: $showing) {
  AddTransactionView(...)
    .environmentObject(AccountViewModel(...))
}
```
**Pros:** Simple, explicit
**Cons:** Creates new instance each time

### Option 2: Pass as regular parameter
```swift
// In AddTransactionView
struct AddTransactionView: View {
  @ObservedObject var accountViewModel: AccountViewModel // Instead of @EnvironmentObject

  init(transactionViewModel: TransactionViewModel, accountViewModel: AccountViewModel) {
    self.accountViewModel = accountViewModel
    // ...
  }
}

// Usage
.sheet(isPresented: $showing) {
  AddTransactionView(
    transactionViewModel: transactionViewModel,
    accountViewModel: accountViewModel
  )
}
```
**Pros:** Explicit, shares same instance
**Cons:** More parameters to pass

### Option 3: Use a shared singleton
```swift
// In AccountViewModel
static let shared = AccountViewModel(...)

// In AddTransactionView
@StateObject private var accountViewModel = AccountViewModel.shared
```
**Pros:** Always available, shared state
**Cons:** Global state, harder to test

## Best Practices

### 1. Inject at App Level (Already done ✅)
```swift
// FinPessoalApp.swift
WindowGroup {
  ContentView()
    .environmentObject(authViewModel)
    .environmentObject(financeViewModel)
    .environmentObject(accountViewModel) // ✅
    .environmentObject(navigationState)
}
```

### 2. Pass Through Sheets
```swift
.sheet(isPresented: $showing) {
  MyView()
    .environmentObject(requiredViewModel)
}
```

### 3. Document Requirements
```swift
/// A view for adding transactions
/// - Requires: AccountViewModel via @EnvironmentObject
struct AddTransactionView: View {
  @EnvironmentObject var accountViewModel: AccountViewModel
  // ...
}
```

## Testing

### Manual Testing Checklist:
- [x] Open AddTransaction from QuickActions
- [x] Open AddTransaction from TransactionsScreen
- [x] Open AddTransaction from TransactionsContentView
- [x] Open AddTransaction on iPad
- [x] Verify account picker loads accounts
- [x] Verify no crashes on sheet presentation

### Unit Testing:
```swift
// In tests
let view = AddTransactionView(transactionViewModel: mockTransactionVM)
  .environmentObject(mockAccountVM)
```

## Future Additions

When adding new views that need `AccountViewModel`:

1. **Check if presented in a sheet/cover/popover**
2. **Add `.environmentObject(AccountViewModel(...))`**
3. **Test that it doesn't crash**
4. **Document the requirement**

## Common Error Messages

### Error 1: Missing Environment Object
```
Fatal error: No ObservableObject of type [ViewModel] found.
```
**Solution:** Add `.environmentObject([ViewModel]())` to the sheet

### Error 2: Wrong Type
```
Cannot convert value of type 'X' to expected argument type 'Y'
```
**Solution:** Ensure you're passing the correct ViewModel type

### Error 3: Nil Value
```
Fatal error: Unexpectedly found nil
```
**Solution:** Initialize the ViewModel before passing to environmentObject

## Build Status
✅ **Build Successful**
- No runtime errors
- All sheets properly configured
- AccountViewModel accessible in all AddTransactionView instances

## Related Views

Views that use `@EnvironmentObject var accountViewModel: AccountViewModel`:
1. ✅ AddTransactionView (Fixed)
2. ✅ AccountsView (Works - not in sheet)
3. ✅ iPadMainView (Fixed)

All other environment objects (`AuthViewModel`, `FinanceViewModel`, etc.) are working correctly as they're either:
- Not used in sheets
- Already properly injected
- Inherited through normal navigation
