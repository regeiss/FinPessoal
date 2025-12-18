# Accessibility Testing Checklist - FinPessoal

## Overview
This checklist helps ensure that the FinPessoal iOS app meets WCAG 2.1 Level AA accessibility standards and provides an excellent experience for users with disabilities.

## Testing Tools Required
- iOS Device or Simulator with VoiceOver enabled
- Accessibility Inspector (Xcode)
- iOS Settings > Accessibility options

## Pre-Testing Setup
- [ ] Enable VoiceOver: Settings > Accessibility > VoiceOver
- [ ] Familiarize with VoiceOver gestures:
  - Single tap: Select element
  - Double tap: Activate element
  - Three-finger swipe: Scroll
  - Two-finger swipe up: Read all from top
  - Two-finger swipe down: Read all from current position
  - Rotor: Two-finger rotation gesture

---

## 1. Authentication & Onboarding

### Login Screen (LoginView.swift)
- [ ] App logo is hidden from VoiceOver
- [ ] Email field announces "Email Address" with hint
- [ ] Password field announces "Password" with secure input hint
- [ ] Sign In button clearly labeled and announces enabled/disabled state
- [ ] Google Sign In button labeled and announces action
- [ ] Apple Sign In button labeled and announces action
- [ ] Error messages are announced with "Error:" prefix
- [ ] Loading state announces "Signing in, please wait"

### Onboarding Screens (OnBoardingScreen.swift)
- [ ] Page titles marked as headers
- [ ] Decorative images hidden from VoiceOver
- [ ] Next button announces page progress (e.g., "Go to page 2 of 3")
- [ ] Get Started button clearly labeled
- [ ] Skip button announces action

---

## 2. Main Navigation

### Tab Bar (MainTabView.swift)
- [ ] All 7 tabs have descriptive labels
- [ ] Each tab has a hint describing its purpose
- [ ] Selected tab state is announced
- [ ] Tab switching works with VoiceOver double-tap

### Sidebar (SidebarView.swift) - iPad
- [ ] Profile section announces user name and email
- [ ] All navigation items have labels and hints
- [ ] Section headers properly announced
- [ ] Sign out button clearly labeled with warning

---

## 3. Dashboard Screen

### Balance Card (BalanceCardView.swift)
- [ ] Decorative eye icon hidden from VoiceOver
- [ ] Card announces "Balance Overview"
- [ ] Total balance amount clearly stated
- [ ] Monthly expenses clearly stated
- [ ] Combined element reads naturally

### Statistics Cards (StatCard.swift)
- [ ] Decorative icons hidden
- [ ] Card title and value combined
- [ ] Marked as static text

### Dashboard Actions
- [ ] Settings button labeled with hint
- [ ] Refresh action announces "Refresh Dashboard"
- [ ] Loading indicator announces progress

---

## 4. Transactions

### Transactions Screen (TransactionsScreen.swift)
- [ ] Search field has label and hint
- [ ] Add button labeled "Add Transaction" with hint
- [ ] Import button labeled with action hint
- [ ] Filter chips announce selection state
- [ ] Clear filters button has hint
- [ ] Empty state provides guidance

### Transaction Row (TransactionRow.swift)
- [ ] Decorative category icon hidden
- [ ] Row combines all transaction info
- [ ] Announces type, description, category, amount, date
- [ ] Recurring indicator announced
- [ ] Hint says "Double tap to view details"
- [ ] Marked as button

### Add Transaction Form (AddTransactionView.swift)
- [ ] Transaction type picker announces current selection
- [ ] Amount field has label, hint, and value
- [ ] Description field has label, hint, and value
- [ ] Category picker accessible
- [ ] Account picker announces current selection
- [ ] Date picker has label and hint
- [ ] Recurring toggle announces enabled/disabled state
- [ ] Save button provides validation feedback
- [ ] Close button clearly labeled

---

## 5. Budget Management

### Budget Screen (BudgetScreen.swift)
- [ ] Add button labeled with hint
- [ ] Empty state provides guidance
- [ ] Budget summary announces total budgeted/spent
- [ ] Progress bar announces percentage and amounts
- [ ] Alert section header marked as header
- [ ] Budget cards have button trait and hints

### Budget Card (BudgetCard.swift)
- [ ] Decorative icons hidden
- [ ] Progress percentage clearly announced
- [ ] Over-budget status indicated
- [ ] Remaining amount stated
- [ ] Warning messages announced
- [ ] Hint explains double-tap action

### Add Budget Form (AddBudgetScreen.swift)
- [ ] Name field has label, hint, value
- [ ] Category picker announces selection
- [ ] Amount field has currency context
- [ ] Period picker accessible
- [ ] Date picker has label and hint
- [ ] Alert threshold slider announces percentage
- [ ] Save button provides validation feedback

---

## 6. Goals

### Goal Screen (GoalScreen.swift)
- [ ] View mode picker announces card/list mode
- [ ] Add button labeled with hint
- [ ] Section headers marked as headers
- [ ] Empty state provides guidance

### Goal Card (GoalCard.swift)
- [ ] Decorative icons hidden
- [ ] Progress percentage announced
- [ ] Current vs target amounts clear
- [ ] Remaining amount stated
- [ ] Days left announced
- [ ] Monthly contribution needed stated
- [ ] Completion status announced
- [ ] Hint explains double-tap action

### Add Goal Form (AddGoalScreen.swift)
- [ ] Name field has label, hint, value
- [ ] Target amount field accessible
- [ ] Category picker announces selection
- [ ] Target date picker has label and hint
- [ ] Calculated fields announce values
- [ ] Save button provides validation feedback

---

## 7. Accounts

### Accounts View (AccountsView.swift)
- [ ] Add button labeled with hint
- [ ] Summary cards announce title and value
- [ ] Account cards combine name, type, balance
- [ ] Active/inactive status announced
- [ ] Empty state provides guidance

### Add Account Form (AddAccountView.swift)
- [ ] Name field has label, hint, value
- [ ] Type picker announces selection
- [ ] Balance field accessible
- [ ] Currency picker announces selection
- [ ] Active toggle announces state
- [ ] Save button labeled with hint

---

## 8. Bills Management

### Bills Screen (BillsScreen.swift)
- [ ] Add button labeled with hint
- [ ] Filter button announces active/inactive state
- [ ] Search field accessible
- [ ] Bill rows announce name, amount, status, due date
- [ ] Payment status clearly indicated (paid/unpaid/overdue)
- [ ] Mark as paid button contextual
- [ ] Empty state provides guidance

### Add Bill Form (AddBillScreen.swift)
- [ ] All form fields have labels, hints, values
- [ ] Due day picker announces day of month
- [ ] Category and subcategory pickers accessible
- [ ] Reminder period picker clear
- [ ] Notes field accessible
- [ ] Active toggle announces state

---

## 9. Reports

### Reports Screen (ReportsScreen.swift)
- [ ] Period selector button labeled with hint
- [ ] View toggle announces chart/table mode
- [ ] Export button labeled with options
- [ ] Loading indicator announces progress
- [ ] Error overlay provides clear message and retry action

### Category Spending (CategorySpendingView.swift)
- [ ] Section header marked as header
- [ ] Chart view announces category breakdown
- [ ] Each category item announces name, amount, percentage
- [ ] Table view has proper header row
- [ ] Table rows announce all data clearly
- [ ] Empty state provides guidance

### Monthly Trends & Budget Performance
- [ ] Charts have text alternatives with data
- [ ] Table views accessible with headers
- [ ] All data points clearly announced

---

## 10. Settings & Profile

### Settings Screen (SettingsScreen.swift)
- [ ] Profile button announces name and email
- [ ] Currency setting announces current selection
- [ ] Language setting announces current language
- [ ] Decorative icons hidden
- [ ] Settings rows have button traits
- [ ] Sign out button clearly labeled

### Profile View (ProfileView.swift)
- [ ] Profile header announces name, email, member since
- [ ] Profile settings combine label and value
- [ ] Action buttons clearly labeled
- [ ] Navigation hints provided

---

## 11. Help System

### Help Screen (HelpScreen.swift)
- [ ] Search field has label and hint
- [ ] Contact support button labeled
- [ ] Quick action buttons announce topics
- [ ] Category cards announce category and topic count
- [ ] Topic rows announce title and features (video/steps)
- [ ] FAQ section accessible
- [ ] Empty search provides guidance

---

## 12. General Accessibility Features

### Dynamic Type Support
- [ ] Test with largest accessibility text size
- [ ] All text scales appropriately
- [ ] No text truncation at large sizes
- [ ] Layout adjusts properly
- [ ] Test: Settings > Accessibility > Display & Text Size > Larger Text

### Color & Contrast
- [ ] App works in Dark Mode
- [ ] All text meets 4.5:1 contrast ratio (normal text)
- [ ] Large text meets 3:1 contrast ratio
- [ ] Color is not the only means of conveying information
- [ ] Status indicators use icons + color

### Motion & Animation
- [ ] Test with Reduce Motion enabled
- [ ] Animations either removed or simplified
- [ ] Progress indicators still work
- [ ] Test: Settings > Accessibility > Motion > Reduce Motion

### Interactive Elements
- [ ] All buttons have minimum 44x44pt tap target
- [ ] All interactive elements reachable via VoiceOver
- [ ] Tab order is logical
- [ ] No keyboard traps
- [ ] Gestures work with VoiceOver

### Empty States
- [ ] All empty states have descriptive labels
- [ ] Provide clear guidance on next steps
- [ ] Action buttons clearly labeled

### Forms
- [ ] All fields have labels
- [ ] Error states announced
- [ ] Validation feedback provided
- [ ] Required fields indicated
- [ ] Field hints explain expected input

### Progress & Status
- [ ] Loading states announced
- [ ] Progress percentages stated
- [ ] Success/error messages announced
- [ ] Time-sensitive information accessible

---

## 13. Testing Scenarios

### Scenario 1: New User Onboarding
1. [ ] Complete onboarding with VoiceOver
2. [ ] Sign in using email/password
3. [ ] Navigate through all tabs
4. [ ] Verify all content is accessible

### Scenario 2: Add Transaction
1. [ ] Navigate to Transactions tab
2. [ ] Tap Add Transaction button
3. [ ] Fill out all form fields using VoiceOver
4. [ ] Save transaction
5. [ ] Verify transaction appears in list
6. [ ] Open transaction details

### Scenario 3: Create Budget
1. [ ] Navigate to Budgets tab
2. [ ] Tap Add Budget button
3. [ ] Complete budget form
4. [ ] Save budget
5. [ ] View budget card with progress
6. [ ] Verify all budget info accessible

### Scenario 4: Set Goal
1. [ ] Navigate to Goals tab
2. [ ] Add new goal
3. [ ] Complete goal form
4. [ ] View goal progress
5. [ ] Add contribution
6. [ ] Verify updated progress announced

### Scenario 5: View Reports
1. [ ] Navigate to Reports tab
2. [ ] Change period selection
3. [ ] Toggle between chart and table views
4. [ ] Verify all data accessible in both views
5. [ ] Export report

### Scenario 6: Search Help
1. [ ] Open Help
2. [ ] Search for a topic
3. [ ] Open topic details
4. [ ] Navigate back
5. [ ] Browse by category

---

## 14. Accessibility Inspector Testing (Xcode)

### Run Audit
- [ ] Open Accessibility Inspector in Xcode
- [ ] Run Audit on app
- [ ] Review all warnings and errors
- [ ] Fix any issues found
- [ ] Re-run audit to verify fixes

### Check Elements
- [ ] Inspect each screen for accessibility labels
- [ ] Verify all images have labels or are hidden
- [ ] Check that traits are correct
- [ ] Verify hint text is helpful
- [ ] Check that values update dynamically

---

## 15. Documentation Review

- [ ] ACCESSIBILITY_GUIDELINES.md is complete
- [ ] All examples are accurate
- [ ] Implementation patterns documented
- [ ] Testing checklist up to date
- [ ] Changelog includes all improvements

---

## Sign-Off

### Tested By:
- Name: ____________________
- Date: ____________________
- Device/iOS Version: ____________________

### Issues Found:
- [ ] No issues found
- [ ] Issues documented and assigned

### Overall Assessment:
- [ ] Meets WCAG 2.1 Level AA standards
- [ ] Ready for release
- [ ] Needs improvements (document below)

### Notes:
_____________________________________________________________________
_____________________________________________________________________
_____________________________________________________________________

---

## Continuous Testing

Remember:
- Test with real users who rely on assistive technologies
- Test on actual devices, not just simulators
- Test with different iOS versions
- Re-test after every major update
- Keep this checklist updated with new features
- Accessibility is an ongoing commitment, not a one-time task
