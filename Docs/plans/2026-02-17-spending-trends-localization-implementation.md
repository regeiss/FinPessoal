# Spending Trends Localization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace all hardcoded currency codes, locale identifiers, and literal UI strings in the Spending Trends graph with `Locale.current` so the chart adapts to the device locale automatically.

**Architecture:** Three files, ~10 line changes total. No new types, no new xcstrings keys, no new files. `Locale.current.currency?.identifier` drives currency formatting everywhere; `Locale.current` drives date formatting; existing xcstrings keys drive UI labels.

**Tech Stack:** SwiftUI, `NumberFormatter`, `DateFormatter`, Swift `FormatStyle.currency`

---

## Prerequisites

- Design doc: `Docs/plans/2026-02-17-spending-trends-localization-design.md`
- Working on `main` branch
- Xcode 15+, iOS 15+ deployment target

---

## Task 1: Fix UI String Literals in DashboardScreen

**Files:**
- Modify: `FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift`

**Step 1: Read the current file**

```bash
# Locate the spending trends card and chartRangePicker
grep -n "Spending Trends\|7 Days\|30 Days\|Range" FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
```

Expected output — four literal strings:
```
48:                  Text("Spending Trends")
171:    Picker("Range", selection: $viewModel.chartDateRange) {
172:      Text("7 Days").tag(ChartDateRange.sevenDays)
173:      Text("30 Days").tag(ChartDateRange.thirtyDays)
```

**Step 2: Replace the four literals**

In `DashboardScreen.swift`, make these four edits:

Replace:
```swift
Text("Spending Trends")
```
With:
```swift
Text("Spending Trends", bundle: .main)
```

Replace:
```swift
Picker("Range", selection: $viewModel.chartDateRange) {
```
With:
```swift
Picker(String(localized: "Range"), selection: $viewModel.chartDateRange) {
```

Replace:
```swift
Text("7 Days").tag(ChartDateRange.sevenDays)
Text("30 Days").tag(ChartDateRange.thirtyDays)
```
With:
```swift
Text("7 Days", bundle: .main).tag(ChartDateRange.sevenDays)
Text("30 Days", bundle: .main).tag(ChartDateRange.thirtyDays)
```

**Step 3: Verify no more literal chart strings**

```bash
grep -n '"Spending Trends"\|"7 Days"\|"30 Days"\|Picker(\"Range\"' FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
```

Expected: no output (zero matches).

**Step 4: Build**

```bash
xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

**Step 5: Commit**

```bash
git add FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
git commit -m "$(cat <<'EOF'
feat(l10n): localize Spending Trends UI strings

- Text("Spending Trends") → Text("Spending Trends", bundle: .main)
- Picker("Range") → String(localized: "Range")
- Text("7 Days") / Text("30 Days") → bundle: .main variants
- All four keys already exist in Localizable.xcstrings

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Fix Currency and Date Formatting in SpendingTrendsChart

**Files:**
- Modify: `FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift`

**Step 1: Read the three hardcoded spots**

```bash
grep -n '"BRL"\|"pt_BR"\|currencyCode' FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift
```

Expected:
```
408:        format: .currency(code: "BRL")
455:    formatter.currencyCode = "BRL"
457:    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0"
463:    formatter.locale = Locale(identifier: "pt_BR")
```

**Step 2: Fix `formatCurrency(_:)`**

Locate the `formatCurrency` function (around line 452). Replace it entirely:

```swift
private func formatCurrency(_ value: Double) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .currency
  formatter.locale = .current
  formatter.maximumFractionDigits = 0
  let fallback = value.formatted(.currency(
    code: Locale.current.currency?.identifier ?? "BRL"
  ))
  return formatter.string(from: NSNumber(value: value)) ?? fallback
}
```

**Step 3: Fix `formatDate(_:)`**

Locate the `formatDate` function (around line 460). Replace it:

```swift
private func formatDate(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM d"
  formatter.locale = .current
  return formatter.string(from: date)
}
```

**Step 4: Fix the callout `PhysicsNumberCounter`**

Locate the `calloutView(for:in:)` function (around line 400). Replace the hardcoded currency:

```swift
PhysicsNumberCounter(
  value: point.value,
  format: .currency(code: Locale.current.currency?.identifier ?? "BRL")
)
```

**Step 5: Verify no hardcoded locales remain**

```bash
grep -n '"BRL"\|"pt_BR"\|currencyCode\s*=' FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift
```

Expected: no output.

**Step 6: Build**

```bash
xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

**Step 7: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/SpendingTrendsChart.swift
git commit -m "$(cat <<'EOF'
feat(l10n): localize SpendingTrendsChart currency and date formatting

- formatCurrency: formatter.locale = .current (was hardcoded "BRL")
- formatDate: formatter.locale = .current (was hardcoded "pt_BR")
- Callout PhysicsNumberCounter: Locale.current.currency (was "BRL")
- Fallback uses Locale.current.currency?.identifier ?? "BRL"

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Fix Hardcoded USD in ChartCalloutView

**Files:**
- Modify: `FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift`

**Step 1: Read the two hardcoded spots**

```bash
grep -n '"USD"' FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
```

Expected:
```
34:          Text(segment.value.formatted(.currency(code: "USD")))
45:        Text(bar.value.formatted(.currency(code: "USD")))
```

**Step 2: Fix both instances**

In the `body`, replace both hardcoded `"USD"` occurrences:

```swift
Text(segment.value.formatted(.currency(
  code: Locale.current.currency?.identifier ?? "BRL"
)))
```

```swift
Text(bar.value.formatted(.currency(
  code: Locale.current.currency?.identifier ?? "BRL"
)))
```

**Step 3: Verify no hardcoded USD remains**

```bash
grep -n '"USD"' FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
```

Expected: no output.

**Step 4: Build**

```bash
xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

**Step 5: Commit**

```bash
git add FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
git commit -m "$(cat <<'EOF'
feat(l10n): localize ChartCalloutView currency formatting

- Segment value: .currency(code: "USD") → Locale.current.currency
- Bar value: .currency(code: "USD") → Locale.current.currency
- Fallback to "BRL" if locale has no currency identifier

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Final Verification and CHANGELOG

**Files:**
- None (verification only) + `CHANGELOG.md`

**Step 1: Confirm zero hardcoded locales across all chart files**

```bash
grep -rn '"BRL"\|"USD"\|"pt_BR"\|currencyCode\s*=' \
  FinPessoal/Code/Animation/Components/Charts/ \
  FinPessoal/Code/Features/Dashboard/Screen/DashboardScreen.swift
```

Expected: no output.

**Step 2: Clean build**

```bash
xcodebuild clean -project FinPessoal.xcodeproj -scheme FinPessoal 2>&1 | tail -1
xcodebuild -project FinPessoal.xcodeproj -scheme FinPessoal build \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **` with zero errors.

**Step 3: Update CHANGELOG.md**

Add to the top of `### Added - February 2026`:

```markdown
- **Spending Trends Localization** (2026-02-17)
  - **Summary**: Chart currency, dates, and UI labels now follow device locale
  - **Build Status**: ✅ BUILD SUCCEEDED

  **Fixed**:
  - `DashboardScreen`: "Spending Trends", "Range", "7 Days", "30 Days" use xcstrings
  - `SpendingTrendsChart`: `formatCurrency` and `formatDate` use `Locale.current`
  - `SpendingTrendsChart`: Callout `PhysicsNumberCounter` uses `Locale.current.currency`
  - `ChartCalloutView`: Segment and bar values use `Locale.current.currency` (was hardcoded USD)
```

**Step 4: Commit CHANGELOG**

```bash
git add CHANGELOG.md
git commit -m "$(cat <<'EOF'
docs(l10n): update CHANGELOG with spending trends localization

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## Success Criteria

- ✅ Build succeeds with zero errors
- ✅ No `"BRL"`, `"USD"`, or `"pt_BR"` remain in chart or dashboard files
- ✅ Y-axis labels use device locale currency symbol and format
- ✅ Callout date uses device locale (e.g. "Feb 17" in en-US, "17 de fev." in pt-BR)
- ✅ "Spending Trends" title and range picker use xcstrings
- ✅ CHANGELOG updated

---

**End of Implementation Plan**

**Next Step:** Use `superpowers:executing-plans` to implement this plan task-by-task.
