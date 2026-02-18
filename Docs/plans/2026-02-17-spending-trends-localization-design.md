# Spending Trends Graph Localization — Design

**Date:** 2026-02-17
**Scope:** `DashboardScreen.swift`, `SpendingTrendsChart.swift`, `ChartCalloutView.swift`
**Approach:** Locale.current everywhere — no new types, no new files

---

## Problem

The Spending Trends graph has three localization issues:

1. **UI strings** in `DashboardScreen` are literal Swift strings instead of using the existing xcstrings keys ("Spending Trends", "Range", "7 Days", "30 Days").
2. **Currency formatting** is hardcoded to BRL (`"BRL"`) in `SpendingTrendsChart` and to USD (`"USD"`) in `ChartCalloutView`.
3. **Date formatting** is hardcoded to `Locale(identifier: "pt_BR")` in `SpendingTrendsChart.formatDate()`.

---

## Design

### Approach: `Locale.current` everywhere

Replace all hardcoded locale/currency identifiers with `Locale.current`. The device locale drives all formatting automatically. No injectable dependency, no user setting — YAGNI.

---

### Section 1 — UI Strings (DashboardScreen.swift)

Wrap all literal chart-related strings with the existing xcstrings keys:

| Line | Before | After |
|------|--------|-------|
| 48 | `Text("Spending Trends")` | `Text("Spending Trends", bundle: .main)` |
| 171 | `Picker("Range", ...)` | `Picker(String(localized: "Range"), ...)` |
| 172 | `Text("7 Days")` | `Text("7 Days", bundle: .main)` |
| 173 | `Text("30 Days")` | `Text("30 Days", bundle: .main)` |

All four keys already exist in `Localizable.xcstrings` — no new strings needed.

---

### Section 2 — Currency Formatting (SpendingTrendsChart.swift)

**`formatCurrency(_:)`** — replace hardcoded locale with `Locale.current`:

```swift
// Before
formatter.currencyCode = "BRL"
return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"

// After
formatter.locale = .current
let fallback = 0.formatted(.currency(code: Locale.current.currency?.identifier ?? "BRL"))
return formatter.string(from: NSNumber(value: value)) ?? fallback
```

**Callout `PhysicsNumberCounter`** — replace hardcoded `"BRL"`:

```swift
// Before
format: .currency(code: "BRL")

// After
format: .currency(code: Locale.current.currency?.identifier ?? "BRL")
```

---

### Section 3 — Date Formatting (SpendingTrendsChart.swift)

**`formatDate(_:)`** — replace hardcoded pt-BR locale:

```swift
// Before
formatter.locale = Locale(identifier: "pt_BR")

// After
formatter.locale = .current
```

---

### Section 4 — ChartCalloutView.swift

Replace both hardcoded `"USD"` currency codes:

```swift
// Before
segment.value.formatted(.currency(code: "USD"))
bar.value.formatted(.currency(code: "USD"))

// After
let currencyCode = Locale.current.currency?.identifier ?? "BRL"
segment.value.formatted(.currency(code: currencyCode))
bar.value.formatted(.currency(code: currencyCode))
```

---

## Files Changed

| File | Changes |
|------|---------|
| `FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift` | 4 string literals → localized |
| `FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift` | formatCurrency + formatDate + callout currency |
| `FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift` | 2 × hardcoded USD → Locale.current |

---

## No New xcstrings Keys Needed

All UI strings ("Spending Trends", "Range", "7 Days", "30 Days") already exist in `Localizable.xcstrings`. This change is purely a code fix — no translation work required.

---

## Success Criteria

- Build succeeds with zero errors
- Y-axis labels, callout amounts, and date labels all reflect device locale
- "Spending Trends" title and range picker labels use xcstrings
- No hardcoded `"BRL"`, `"USD"`, or `"pt_BR"` remain in chart files
