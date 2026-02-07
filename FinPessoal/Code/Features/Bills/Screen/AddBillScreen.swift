//
//  AddBillScreen.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import SwiftUI

struct AddBillScreen: View {
  @ObservedObject var viewModel: BillsViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var name: String = ""
  @State private var amount: String = ""
  @State private var dueDay: Int = 1
  @State private var category: TransactionCategory = .bills
  @State private var subcategory: TransactionSubcategory? = nil
  @State private var selectedAccountId: String = ""
  @State private var reminderDaysBefore: Int = 3
  @State private var notes: String = ""
  @State private var isActive: Bool = true

  @State private var showingError = false
  @State private var errorMessage = ""

  // Mock accounts - should be fetched from AccountViewModel in real app
  private var mockAccounts: [(String, String)] {
    [
      ("account-1", String(localized: "account.type.checking")),
      ("account-2", String(localized: "account.type.savings"))
    ]
  }

  var body: some View {
    NavigationView {
      Form {
        basicInfoSection


        categorySection


        accountSection


        reminderSection


        notesSection


        activeSection
      }
      .navigationTitle(String(localized: "bills.add.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
          .accessibilityLabel("Cancel")
          .accessibilityHint("Discards changes and closes the form")
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.save")) {
            saveBill()
          }
          .disabled(!isValidBill)
          .accessibilityLabel("Save Bill")
          .accessibilityHint(isValidBill ? "Saves the new bill" : "Complete all required fields to save")
          .accessibilityAddTraits(isValidBill ? [] : .isButton)
        }
      }
      .alert(String(localized: "common.error"), isPresented: $showingError) {
        Button(String(localized: "common.ok"), role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
    }
    .onAppear {
      if mockAccounts.isEmpty == false {
        selectedAccountId = mockAccounts[0].0
      }
    }
  }

  // MARK: - View Sections

  private var basicInfoSection: some View {
    Section(header: Text(String(localized: "bill.section.basic"))) {
      StyledTextField(
        text: $name,
        placeholder: String(localized: "bill.field.name")
      )

      HStack {
        Text(String(localized: "bill.field.amount"))
        Spacer()
        StyledTextField(
          text: $amount,
          placeholder: "0,00",
          keyboardType: .decimalPad
        )
        .multilineTextAlignment(.trailing)
      }

      Picker(String(localized: "bill.field.due.day"), selection: $dueDay) {
        ForEach(1...31, id: \.self) { day in
          Text("Dia \(day)").tag(day)
        }
      }
      .accessibilityLabel("Due Day of Month")
      .accessibilityHint("Select the day of the month when this bill is due")
      .accessibilityValue("Day \(dueDay)")
    }
  }

  private var categorySection: some View {
    Section(header: Text(String(localized: "bill.section.category"))) {
      Picker(String(localized: "common.category"), selection: $category) {
        ForEach(TransactionCategory.allCases, id: \.self) { cat in
          HStack {
            Image(systemName: cat.icon)
              .accessibilityHidden(true)
            Text(cat.displayName)
          }
          .tag(cat)
        }
      }
      .accessibilityLabel("Bill Category")
      .accessibilityHint("Select the category for this bill")
      .accessibilityValue(category.displayName)

      if !category.subcategories.isEmpty {
        Picker(String(localized: "common.subcategory"), selection: $subcategory) {
          Text(String(localized: "common.none")).tag(nil as TransactionSubcategory?)

          ForEach(category.subcategories, id: \.self) { sub in
            HStack {
              Image(systemName: sub.icon)
                .accessibilityHidden(true)
              Text(sub.displayName)
            }
            .tag(sub as TransactionSubcategory?)
          }
        }
        .accessibilityLabel("Bill Subcategory")
        .accessibilityHint("Select a subcategory for more specific classification")
        .accessibilityValue(subcategory?.displayName ?? "None")
      }
    }
  }

  private var accountSection: some View {
    Section(header: Text(String(localized: "bill.section.account"))) {
      Picker(String(localized: "bill.field.account"), selection: $selectedAccountId) {
        ForEach(mockAccounts, id: \.0) { account in
          Text(account.1).tag(account.0)
        }
      }
      .accessibilityLabel("Payment Account")
      .accessibilityHint("Select the account from which this bill will be paid")
      .accessibilityValue(mockAccounts.first(where: { $0.0 == selectedAccountId })?.1 ?? "Not selected")
    }
  }

  private var reminderSection: some View {
    Section(header: Text(String(localized: "bill.section.reminder"))) {
      Picker(String(localized: "bill.field.reminder.days"), selection: $reminderDaysBefore) {
        Text(String(localized: "bill.reminder.same.day")).tag(0)
        Text("1 dia antes").tag(1)
        Text("2 dias antes").tag(2)
        Text("3 dias antes").tag(3)
        Text("5 dias antes").tag(5)
        Text("7 dias antes").tag(7)
      }
      .accessibilityLabel("Reminder Notice Period")
      .accessibilityHint("Select how many days before the due date you want to be reminded")
      .accessibilityValue(reminderDaysBefore == 0 ? "Same day" : "\(reminderDaysBefore) days before")
    }
  }

  private var notesSection: some View {
    Section(header: Text(String(localized: "bill.section.notes"))) {
      StyledTextEditor(
        text: $notes,
        placeholder: String(localized: "bill.section.notes"),
        minHeight: 100
      )
    }
  }

  private var activeSection: some View {
    Section {
      Toggle(String(localized: "bill.field.active"), isOn: $isActive)
        .accessibilityLabel("Bill Active Status")
        .accessibilityHint("Toggle to enable or disable this bill")
        .accessibilityValue(isActive ? "Active" : "Inactive")
    }
  }

  // MARK: - Validation

  private var isValidBill: Bool {
    return !name.isEmpty &&
    !amount.isEmpty &&
    Double(amount.replacingOccurrences(of: ",", with: ".")) != nil &&
    !selectedAccountId.isEmpty
  }

  // MARK: - Save Bill

  private func saveBill() {
    guard isValidBill else {
      errorMessage = String(localized: "bill.error.invalid.data")
      showingError = true
      return
    }

    guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
      errorMessage = String(localized: "bill.error.invalid.amount")
      showingError = true
      return
    }

    let now = Date()
    let calendar = Calendar.current

    // Calculate first due date
    var components = calendar.dateComponents([.year, .month], from: now)
    components.day = dueDay

    var nextDueDate = calendar.date(from: components) ?? now

    // If the date has passed this month, use next month
    if nextDueDate < now {
      if let nextMonth = calendar.date(byAdding: .month, value: 1, to: now) {
        components = calendar.dateComponents([.year, .month], from: nextMonth)
        components.day = dueDay
        nextDueDate = calendar.date(from: components) ?? now
      }
    }

    let bill = Bill(
      id: UUID().uuidString,
      name: name,
      amount: amountValue,
      dueDay: dueDay,
      category: category,
      subcategory: subcategory,
      accountId: selectedAccountId,
      isPaid: false,
      isActive: isActive,
      notes: notes.isEmpty ? nil : notes,
      reminderDaysBefore: reminderDaysBefore,
      lastPaidDate: nil,
      nextDueDate: nextDueDate,
      userId: "current-user-id", // Should come from AuthViewModel
      createdAt: now,
      updatedAt: now
    )

    Task {
      let success = await viewModel.addBill(bill)
      if success {
        dismiss()
      } else {
        errorMessage = viewModel.errorMessage ?? String(localized: "bill.error.save.failed")
        showingError = true
      }
    }
  }
}

#Preview {
  AddBillScreen(viewModel: BillsViewModel(repository: MockBillRepository()))
}
