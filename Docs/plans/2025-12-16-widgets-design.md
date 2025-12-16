# FinPessoal Widgets Design

**Date**: 2025-12-16
**Status**: Approved

## Overview

Comprehensive widget suite for FinPessoal personal finance app, including Home Screen widgets, Lock Screen widgets, and Live Activities.

## Goals

- Quick glance at finances without opening the app
- Actionable alerts for bills, budgets, and goals
- Quick actions to add transactions and navigate to features
- Real-time notifications for critical financial events

## Architecture

### Widget Extension Structure

```
FinPessoalWidgets/
├── Shared/
│   ├── WidgetDataProvider.swift      # Fetches data from cache/Firebase
│   ├── SharedDataManager.swift       # App Groups data sync
│   └── WidgetRefreshManager.swift    # Smart refresh logic
├── HomeScreen/
│   ├── BalanceWidget.swift           # Small/Medium/Large
│   ├── BudgetWidget.swift            # Medium/Large
│   ├── BillsWidget.swift             # Small/Medium
│   ├── GoalsWidget.swift             # Small/Medium/Large
│   ├── TransactionsWidget.swift      # Medium/Large
│   └── CreditCardWidget.swift        # Small/Medium
├── LockScreen/
│   ├── BalanceLockWidget.swift       # Circular/Rectangular
│   ├── BillsDueLockWidget.swift      # Inline/Rectangular
│   ├── BudgetLockWidget.swift        # Circular gauge
│   ├── GoalsLockWidget.swift         # Circular/Rectangular
│   └── QuickExpenseLockWidget.swift  # Circular (deep link)
└── LiveActivities/
    ├── BillReminderActivity.swift
    ├── BudgetAlertActivity.swift
    ├── GoalMilestoneActivity.swift
    └── CreditCardReminderActivity.swift
```

### Data Sharing

- **App Group**: `group.com.yourteam.finpessoal`
- **Approach**: Hybrid (cache + background Firebase refresh)
- Main app writes to shared `UserDefaults`
- Widgets read from cache for instant display
- Background tasks fetch fresh data from Firebase

## Home Screen Widgets

### 1. Balance Widget

| Size | Content |
|------|---------|
| Small | Total balance with trend arrow (↑↓), colored green/red |
| Medium | Total balance + breakdown by account type (checking, savings, investment) |
| Large | Balance + mini sparkline chart (7-day trend) + top 3 accounts |

### 2. Monthly Summary Widget

| Size | Content |
|------|---------|
| Medium | Income, Expenses, Net balance + progress bar (days remaining in month) |
| Large | Same + comparison vs. last month (percentage change) |

### 3. Budget Widget

| Size | Content |
|------|---------|
| Medium | Top 3 budgets with progress bars, color-coded (green < 75%, yellow 75-90%, red > 90%) |
| Large | All active budgets with category icons, spent/limit amounts |

### 4. Bills Widget

| Size | Content |
|------|---------|
| Small | Next bill due with countdown ("Electricity in 3 days") |
| Medium | Next 3 bills with due dates and amounts, overdue highlighted in red |

### 5. Goals Widget

| Size | Content |
|------|---------|
| Small | Top goal with circular progress indicator |
| Medium | Top 2 goals with progress bars and target dates |
| Large | All active goals with monthly contribution needed to reach target |

### 6. Credit Card Widget

| Size | Content |
|------|---------|
| Small | Total credit utilization percentage (circular gauge) |
| Medium | Per-card breakdown with available credit and next due date |

### 7. Recent Transactions Widget

| Size | Content |
|------|---------|
| Medium | Last 5 transactions with category icons, amounts, dates |
| Large | Last 10 transactions grouped by today/yesterday/earlier |

## Lock Screen Widgets

### 1. Balance Lock Widget
- **Circular**: Total balance, abbreviated (R$ 12.5k)
- **Rectangular**: Total balance + trend indicator (↑2.3% this week)

### 2. Bills Due Lock Widget
- **Inline**: "2 bills due this week" or "Electric bill tomorrow"
- **Rectangular**: Next bill name, amount, days until due, warning icon if overdue

### 3. Budget Lock Widget
- **Circular**: Gauge showing overall budget health percentage
- **Rectangular**: Most critical budget (highest utilization) with name and percentage

### 4. Goals Lock Widget
- **Circular**: Top goal progress as percentage ring
- **Rectangular**: Goal name + progress bar + "R$ 500 to go"

### 5. Quick Expense Lock Widget
- **Circular**: Tap to open "Add Transaction" screen via deep link

## Live Activities

### 1. Bill Reminder Activity

- **Trigger**: 3 days before, 1 day before, and on due date
- **Lock Screen**: Bill name, amount, countdown, "Pay Now" button
- **Dynamic Island (Compact)**: Bill icon + "2 days"
- **Dynamic Island (Expanded)**: Bill name, amount, countdown, quick pay action
- **End**: After payment confirmed or 24 hours past due

### 2. Budget Alert Activity

- **Trigger**: At 90% utilization and when exceeded (100%+)
- **Lock Screen**: Category icon, "Food budget 95% used", remaining amount
- **Dynamic Island (Compact)**: Category icon + percentage
- **Dynamic Island (Expanded)**: Budget name, spent/limit, "View Details" action
- **End**: At budget period reset or user dismisses

### 3. Goal Milestone Activity

- **Trigger**: At 25%, 50%, 75%, 100% milestones
- **Lock Screen**: Celebration message, goal name, progress ring, "Add More" button
- **Dynamic Island (Compact)**: Goal icon + milestone percentage
- **Dynamic Island (Expanded)**: Goal name, amounts, celebration animation
- **End**: After 4 hours or user dismisses

### 4. Credit Card Reminder Activity

- **Trigger**: 5 days and 1 day before payment due
- **Lock Screen**: Card name, statement balance, due date, "Pay" button
- **Dynamic Island**: Card icon + days until due
- **End**: After payment or due date passes

## Data Layer

### Shared Data Structure

```swift
struct WidgetData: Codable {
  let lastUpdated: Date
  let totalBalance: Decimal
  let accounts: [AccountSummary]
  let monthlyIncome: Decimal
  let monthlyExpenses: Decimal
  let budgets: [BudgetSummary]
  let upcomingBills: [BillSummary]
  let goals: [GoalSummary]
  let creditCards: [CardSummary]
  let recentTransactions: [TransactionSummary]
}
```

### Smart Refresh Schedule

| Widget Type | Timeline Refresh | Background Fetch |
|-------------|------------------|------------------|
| Balance | 30 minutes | On app sync |
| Budget | 1 hour | When transaction added |
| Bills | 1 hour | Daily at 8 AM |
| Goals | 2 hours | On deposit detected |
| Transactions | 15 minutes | On new transaction |
| Credit Cards | 1 hour | Daily at 9 AM |
| Live Activities | Real-time | Push notification trigger |

### Sync Triggers

Main app syncs to App Groups when:
- User opens the app (full sync)
- Transaction added/edited/deleted
- Budget updated
- Bill paid or added
- Goal progress changes
- App enters background (snapshot sync)

## Deep Links

```
finpessoal://add-transaction
finpessoal://pay-bill/{billId}
finpessoal://view-budget/{budgetId}
finpessoal://view-goal/{goalId}
finpessoal://view-card/{cardId}
```

## Accessibility

- VoiceOver labels for all elements
- Dynamic Type support
- High contrast mode support
- Reduce Motion support (disable Live Activity animations)
- Full localization (Portuguese-Brazil)

## Testing Strategy

- Unit tests for `WidgetDataProvider` and data transformations
- Widget preview tests for all size combinations
- Snapshot tests for light/dark mode and accessibility sizes
- Integration tests for App Groups data sync
- Live Activity lifecycle tests

## Required Capabilities

- App Groups (data sharing)
- Push Notifications (Live Activity triggers)
- Background App Refresh (widget updates)

## Implementation Changes

- New target: `FinPessoalWidgets`
- Update `FinPessoal.entitlements` with App Group
- Add `WidgetKit` and `ActivityKit` frameworks
- Extend existing models with `Codable` widget summaries
- Add deep link handling to main app
