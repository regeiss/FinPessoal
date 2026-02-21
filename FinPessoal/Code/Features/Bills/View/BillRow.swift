//
//  BillRow.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import SwiftUI

struct BillRow: View {
  let bill: Bill
  let onMarkAsPaid: (() -> Void)?

  init(bill: Bill, onMarkAsPaid: (() -> Void)? = nil) {
    self.bill = bill
    self.onMarkAsPaid = onMarkAsPaid
  }

  var body: some View {
    HStack(spacing: 16) {
      // Category icon
      ZStack {
        Circle()
          .fill(bill.category.swiftUIColor.opacity(0.15))
          .frame(width: 56, height: 56)

        Image(systemName: bill.subcategory?.icon ?? bill.category.icon)
          .font(.system(size: 24))
          .foregroundColor(bill.category.swiftUIColor)
      }
      .accessibilityHidden(true)

      // Bill info
      VStack(alignment: .leading, spacing: 6) {
        Text(bill.name)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(Color.oldMoney.text)

        HStack(spacing: 8) {
          // Status badge
          HStack(spacing: 4) {
            Circle()
              .fill(statusColor)
              .frame(width: 10, height: 10)
              .accessibilityHidden(true)

            Text(bill.statusText)
              .font(.subheadline)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }

          // Due date info
          if !bill.isPaid {
            Text("•")
              .font(.subheadline)
              .foregroundStyle(Color.oldMoney.textSecondary)
              .accessibilityHidden(true)

            if bill.isOverdue {
              Text(String(localized: "bill.overdue.days", defaultValue: "\(-bill.daysUntilDue) days overdue"))
                .font(.subheadline)
                .foregroundStyle(Color.oldMoney.expense)
            } else {
              Text(String(localized: "bill.due.in", defaultValue: "Due in \(bill.daysUntilDue) days"))
                .font(.subheadline)
                .foregroundStyle(Color.oldMoney.textSecondary)
            }
          } else {
            Text("•")
              .font(.subheadline)
              .foregroundStyle(Color.oldMoney.textSecondary)
              .accessibilityHidden(true)

            Text(String(localized: "bill.next.due"))
              .font(.subheadline)
              .foregroundStyle(Color.oldMoney.textSecondary)

            Text(bill.nextDueDate.formatted(date: .abbreviated, time: .omitted))
              .font(.subheadline)
              .foregroundStyle(Color.oldMoney.textSecondary)
          }
        }
      }

      Spacer()

      // Amount and action
      VStack(alignment: .trailing, spacing: 6) {
        Text(bill.formattedAmount)
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundStyle(Color.oldMoney.text)

        if !bill.isPaid && onMarkAsPaid != nil {
          Button(action: {
            onMarkAsPaid?()
          }) {
            HStack(spacing: 4) {
              Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
              Text(String(localized: "bill.mark.paid"))
                .font(.subheadline)
            }
            .foregroundStyle(Color.oldMoney.income)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Mark as Paid")
          .accessibilityHint("Marks \(bill.name) as paid for the current period")
        }
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 16)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
    .accessibilityAddTraits(.isButton)
  }

  private var accessibilityDescription: String {
    var description = "\(bill.name), \(bill.formattedAmount), "

    if bill.isPaid {
      description += "Paid, Next due \(bill.nextDueDate.formatted(date: .abbreviated, time: .omitted))"
    } else {
      description += "\(bill.statusText), "

      if bill.isOverdue {
        description += "\(-bill.daysUntilDue) days overdue"
      } else {
        description += "Due in \(bill.daysUntilDue) days"
      }
    }

    return description
  }

  private var statusColor: Color {
    switch bill.status {
    case .paid:
      return Color.oldMoney.income
    case .overdue:
      return Color.oldMoney.expense
    case .dueSoon:
      return Color.oldMoney.warning
    case .upcoming:
      return Color.oldMoney.accent
    }
  }
}

#Preview {
  let calendar = Calendar.current
  let now = Date()

  let sampleBills = [
    Bill(
      id: "1",
      name: "Electricity Bill",
      amount: 250.00,
      dueDay: 15,
      category: .bills,
      subcategory: .electricity,
      accountId: "account-1",
      isPaid: false,
      isActive: true,
      notes: nil,
      reminderDaysBefore: 3,
      lastPaidDate: nil,
      nextDueDate: calendar.date(byAdding: .day, value: 2, to: now)!,
      userId: "user-1",
      createdAt: now,
      updatedAt: now
    ),
    Bill(
      id: "2",
      name: "Internet",
      amount: 99.90,
      dueDay: 10,
      category: .bills,
      subcategory: .internet,
      accountId: "account-1",
      isPaid: true,
      isActive: true,
      notes: nil,
      reminderDaysBefore: 3,
      lastPaidDate: now,
      nextDueDate: calendar.date(byAdding: .month, value: 1, to: now)!,
      userId: "user-1",
      createdAt: now,
      updatedAt: now
    ),
    Bill(
      id: "3",
      name: "Water Bill",
      amount: 85.50,
      dueDay: 5,
      category: .bills,
      subcategory: .water,
      accountId: "account-1",
      isPaid: false,
      isActive: true,
      notes: nil,
      reminderDaysBefore: 3,
      lastPaidDate: nil,
      nextDueDate: calendar.date(byAdding: .day, value: -2, to: now)!,
      userId: "user-1",
      createdAt: now,
      updatedAt: now
    )
  ]

  return List {
    ForEach(sampleBills) { bill in
      BillRow(bill: bill) {
        print("Mark \(bill.name) as paid")
      }
    }
  }
}
