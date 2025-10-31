# Accessibility Guidelines - FinPessoal

## Overview
This document outlines the accessibility standards and implementation patterns for the FinPessoal iOS app to ensure compliance with WCAG 2.1 Level AA standards and iOS accessibility best practices.

## Core Principles

### 1. Perceivable
- All UI elements must have meaningful labels
- Visual information must have alternative text descriptions
- Color is not the only means of conveying information
- Support Dynamic Type for all text

### 2. Operable
- All functionality available via keyboard/switch control
- Sufficient time for users to read and use content
- Clear navigation structure
- Avoid content that causes seizures

### 3. Understandable
- Text is readable and understandable
- UI appears and operates in predictable ways
- Users are helped to avoid and correct mistakes

### 4. Robust
- Content works with current and future assistive technologies
- Proper use of SwiftUI accessibility APIs

## Implementation Standards

### Buttons and Interactive Elements

```swift
// Icon buttons
Button {
    // action
} label: {
    Image(systemName: "plus")
}
.accessibilityLabel("Add Transaction")
.accessibilityHint("Opens form to add a new transaction")

// Buttons with text and icon
Button {
    // action
} label: {
    Label("Settings", systemImage: "gear")
}
.accessibilityLabel("Settings")
.accessibilityHint("Opens application settings")
```

### Form Fields

```swift
// TextField
TextField("", text: $amount, prompt: Text("0.00"))
    .accessibilityLabel("Transaction Amount")
    .accessibilityHint("Enter the transaction amount")
    .accessibilityValue(amount.isEmpty ? "Empty" : amount)

// Picker
Picker("Category", selection: $selectedCategory) {
    // options
}
.accessibilityLabel("Transaction Category")
.accessibilityHint("Select the category for this transaction")
.accessibilityValue(selectedCategory.name)

// Toggle
Toggle("Enable Notifications", isOn: $isEnabled)
    .accessibilityLabel("Enable Notifications")
    .accessibilityHint("Toggle to enable or disable push notifications")
    .accessibilityValue(isEnabled ? "Enabled" : "Disabled")

// DatePicker
DatePicker("Date", selection: $date)
    .accessibilityLabel("Transaction Date")
    .accessibilityHint("Select the date for this transaction")
```

### Lists and Cards

```swift
// List row - combine elements for better VoiceOver experience
HStack {
    VStack(alignment: .leading) {
        Text(transaction.description)
        Text(transaction.date, style: .date)
    }
    Spacer()
    Text(transaction.amount, format: .currency(code: "USD"))
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(transaction.description), \(transaction.date.formatted()), \(transaction.amount.formatted(.currency(code: "USD")))")
.accessibilityHint("Double tap to view transaction details")
.accessibilityAddTraits(.isButton)

// Card with progress
VStack {
    Text("Budget Name")
    ProgressView(value: spent, total: total)
    Text("$\(spent) of $\(total)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Budget: \(name)")
.accessibilityValue("\(spent) spent of \(total) total, \(percentage)% used")
.accessibilityHint("Double tap to view budget details")
```

### Charts and Data Visualizations

```swift
// Pie chart
PieChartView(data: categoryData)
    .accessibilityLabel("Category Spending Chart")
    .accessibilityValue(chartDescription)
    .accessibilityHint("Shows spending breakdown by category")

// Where chartDescription would be something like:
// "Food: 30%, Transport: 20%, Entertainment: 15%, Others: 35%"

// Bar chart
BarChartView(data: monthlyData)
    .accessibilityLabel("Monthly Spending Trend")
    .accessibilityValue("January: $1,200, February: $1,450, March: $1,100")
    .accessibilityHint("Shows spending trends over the last three months")
```

### Progress Indicators

```swift
ProgressView(value: current, total: target)
    .accessibilityLabel("Goal Progress")
    .accessibilityValue("\(percentage)% complete, \(current) of \(target)")
```

### Navigation

```swift
// Tab bar items
TabView {
    DashboardView()
        .tabItem {
            Label("Dashboard", systemImage: "house")
        }
        .accessibilityLabel("Dashboard Tab")
        .accessibilityHint("View your financial dashboard")
}

// Navigation links
NavigationLink(destination: TransactionDetailView()) {
    TransactionRow(transaction: transaction)
}
.accessibilityLabel(transaction.description)
.accessibilityHint("Navigate to transaction details")
```

### Empty States

```swift
VStack {
    Image(systemName: "tray")
        .accessibilityHidden(true)
    Text("No transactions yet")
    Text("Tap the + button to add your first transaction")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("No Transactions")
.accessibilityHint("You haven't added any transactions yet. Tap the add button in the toolbar to create your first transaction")
```

### Sensitive Information

```swift
// Credit card number
SecureField("Card Number", text: $cardNumber)
    .accessibilityLabel("Credit Card Number")
    .accessibilityHint("Enter your 16-digit card number. Input is secured")
    .textContentType(.creditCardNumber)

// Password
SecureField("Password", text: $password)
    .accessibilityLabel("Password")
    .accessibilityHint("Enter your password. Input is secured and hidden")
```

### Financial Data

```swift
// Balance display
Text(balance, format: .currency(code: currencyCode))
    .accessibilityLabel("Current Balance")
    .accessibilityValue("\(balance.formatted(.currency(code: currencyCode)))")

// Amount with sign
HStack {
    Image(systemName: isIncome ? "arrow.down" : "arrow.up")
        .foregroundColor(isIncome ? .green : .red)
    Text(amount, format: .currency(code: "USD"))
}
.accessibilityElement(children: .combine)
.accessibilityLabel(isIncome ? "Income" : "Expense")
.accessibilityValue(amount.formatted(.currency(code: "USD")))
```

## Dynamic Type Support

All text in the app should support Dynamic Type:

```swift
// Use built-in text styles
Text("Title")
    .font(.headline)  // Automatically supports Dynamic Type

Text("Body text")
    .font(.body)  // Automatically supports Dynamic Type

// For custom sizes, use relative sizing
Text("Custom")
    .font(.system(size: 20, weight: .bold, design: .default))
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Cap maximum size if needed
```

## Color Contrast

- Text must meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- Use semantic colors that adapt to light/dark mode
- Don't rely solely on color to convey information

```swift
// Use semantic colors
.foregroundColor(.primary)
.foregroundColor(.secondary)

// For status indicators, use both color and icon
HStack {
    Image(systemName: "checkmark.circle.fill")
    Text("Complete")
}
.foregroundColor(.green)
```

## Accessibility Traits

Use appropriate traits to communicate element types:

```swift
// Button traits
.accessibilityAddTraits(.isButton)

// Header traits
.accessibilityAddTraits(.isHeader)

// Selected state
.accessibilityAddTraits(.isSelected)

// Static text (not interactive)
.accessibilityAddTraits(.isStaticText)

// Remove button traits if not a button
.accessibilityRemoveTraits(.isButton)
```

## Reduce Motion

Respect user's reduce motion preference:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Conditionally apply animations
.animation(reduceMotion ? nil : .default, value: someValue)

// Or use simpler animations
withAnimation(reduceMotion ? nil : .spring()) {
    // changes
}
```

## Testing Checklist

For each screen/component, verify:

- [ ] All buttons have meaningful labels
- [ ] All form fields have labels and hints
- [ ] All images that convey information have labels
- [ ] Decorative images are hidden from VoiceOver
- [ ] Tab order is logical
- [ ] All interactive elements are reachable via VoiceOver
- [ ] Charts and visualizations have text alternatives
- [ ] Color is not the only means of conveying information
- [ ] Text supports Dynamic Type
- [ ] Animations respect reduce motion preference
- [ ] Test with VoiceOver enabled
- [ ] Test with large text sizes
- [ ] Test in dark mode

## Priority Levels

### Critical (Implement First)
- Dashboard screen
- Transaction management
- Budget screens
- All form screens (add/edit)

### High (Implement Second)
- Charts and reports
- Goal tracking
- Settings
- Navigation components

### Medium (Implement Third)
- Bills management
- Credit cards
- Loans
- Help screens

## Resources

- [Apple Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [SwiftUI Accessibility API](https://developer.apple.com/documentation/swiftui/view-accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

## Notes

- Always test with real assistive technologies (VoiceOver, Switch Control)
- Consider users with various disabilities (visual, motor, cognitive)
- Accessibility is not a one-time task - maintain it with new features
- Get feedback from users who rely on assistive technologies
