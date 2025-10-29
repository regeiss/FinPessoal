//
//  BillDetailView.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import SwiftUI

struct BillDetailView: View {
  let bill: Bill
  @ObservedObject var viewModel: BillsViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var showingDeleteConfirmation = false
  @State private var showingPaymentConfirmation = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header with icon
          headerView

          // Status badge
          statusView

          // Amount display
          amountView

          // Bill details
          detailsView

          // Due date information
          dueDateView

          // Actions
          if !bill.isPaid {
            actionsView
          }

          // Notes
          if let notes = bill.notes, !notes.isEmpty {
            notesView(notes: notes)
          }

          Spacer(minLength: 20)
        }
        .padding()
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle(String(localized: "bill.details"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.done")) {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(role: .destructive) {
            showingDeleteConfirmation = true
          } label: {
            Image(systemName: "trash")
              .foregroundColor(.red)
          }
        }
      }
      .alert(String(localized: "bill.delete.confirmation"), isPresented: $showingDeleteConfirmation) {
        Button(String(localized: "common.cancel"), role: .cancel) {}
        Button(String(localized: "common.delete"), role: .destructive) {
          deleteBill()
        }
      } message: {
        Text(String(localized: "bill.delete.message"))
      }
      .alert(String(localized: "bill.mark.paid.confirmation"), isPresented: $showingPaymentConfirmation) {
        Button(String(localized: "common.cancel"), role: .cancel) {}
        Button(String(localized: "bill.mark.paid"), role: .none) {
          markAsPaid()
        }
      } message: {
        Text(String(localized: "bill.mark.paid.message", defaultValue: "Mark '\(bill.name)' as paid?"))
      }
    }
  }

  // MARK: - Header View

  private var headerView: some View {
    VStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(bill.category.swiftUIColor.opacity(0.15))
          .frame(width: 80, height: 80)

        Image(systemName: bill.subcategory?.icon ?? bill.category.icon)
          .font(.system(size: 36))
          .foregroundColor(bill.category.swiftUIColor)
      }

      VStack(spacing: 4) {
        Text(bill.name)
          .font(.title2)
          .fontWeight(.bold)

        Text(bill.category.displayName)
          .font(.subheadline)
          .foregroundColor(.secondary)

        if let subcategory = bill.subcategory {
          Text(subcategory.displayName)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }

  // MARK: - Status View

  private var statusView: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(statusColor)
        .frame(width: 12, height: 12)

      Text(bill.statusText)
        .font(.headline)
        .foregroundColor(statusColor)

      if bill.isOverdue {
        Text("•")
          .foregroundColor(.secondary)

        Text(String(localized: "bill.overdue.days", defaultValue: "\(-bill.daysUntilDue) days overdue"))
          .font(.subheadline)
          .foregroundColor(.red)
      } else if bill.isDueSoon {
        Text("•")
          .foregroundColor(.secondary)

        Text(String(localized: "bill.due.in", defaultValue: "Due in \(bill.daysUntilDue) days"))
          .font(.subheadline)
          .foregroundColor(.orange)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(statusColor.opacity(0.1))
    .cornerRadius(20)
  }

  // MARK: - Amount View

  private var amountView: some View {
    VStack(spacing: 4) {
      Text(String(localized: "bill.field.amount"))
        .font(.caption)
        .foregroundColor(.secondary)

      Text(bill.formattedAmount)
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(.primary)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
  }

  // MARK: - Details View

  private var detailsView: some View {
    VStack(spacing: 12) {
      DetailRow(
        label: String(localized: "bill.field.due.day"),
        value: String(localized: "bill.day.of.month", defaultValue: "Day \(bill.dueDay)")
      )

      Divider()

      DetailRow(
        label: String(localized: "bill.field.reminder.days"),
        value: bill.reminderDaysBefore == 0
        ? String(localized: "bill.reminder.same.day")
        : String(localized: "bill.reminder.days.value", defaultValue: "\(bill.reminderDaysBefore) days before")
      )

      Divider()

      DetailRow(
        label: String(localized: "bill.field.active"),
        value: bill.isActive
        ? String(localized: "common.yes")
        : String(localized: "common.no")
      )
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
  }

  // MARK: - Due Date View

  private var dueDateView: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "bill.next.due.date"))
            .font(.caption)
            .foregroundColor(.secondary)

          Text(bill.nextDueDate.formatted(date: .long, time: .omitted))
            .font(.subheadline)
            .fontWeight(.medium)
        }

        Spacer()

        if !bill.isPaid {
          VStack(alignment: .trailing, spacing: 4) {
            Text(String(localized: "bill.days.until"))
              .font(.caption)
              .foregroundColor(.secondary)

            Text("\(bill.daysUntilDue)")
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(bill.isOverdue ? .red : .primary)
          }
        }
      }

      if let lastPaidDate = bill.lastPaidDate {
        Divider()

        HStack {
          Text(String(localized: "bill.last.paid"))
            .font(.caption)
            .foregroundColor(.secondary)

          Spacer()

          Text(lastPaidDate.formatted(date: .long, time: .omitted))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
  }

  // MARK: - Actions View

  private var actionsView: some View {
    Button(action: {
      showingPaymentConfirmation = true
    }) {
      HStack {
        Image(systemName: "checkmark.circle.fill")
          .font(.title3)

        Text(String(localized: "bill.mark.paid"))
          .font(.headline)
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.green)
      .cornerRadius(12)
    }
  }

  // MARK: - Notes View

  private func notesView(notes: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(String(localized: "bill.section.notes"))
        .font(.caption)
        .foregroundColor(.secondary)

      Text(notes)
        .font(.body)
        .foregroundColor(.primary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
  }

  // MARK: - Helpers

  private var statusColor: Color {
    switch bill.status {
    case .paid:
      return .green
    case .overdue:
      return .red
    case .dueSoon:
      return .orange
    case .upcoming:
      return .blue
    }
  }

  // MARK: - Actions

  private func markAsPaid() {
    Task {
      _ = await viewModel.markBillAsPaid(bill.id)
      dismiss()
    }
  }

  private func deleteBill() {
    Task {
      _ = await viewModel.deleteBill(bill.id)
      dismiss()
    }
  }
}

// MARK: - Detail Row Component

struct DetailRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundColor(.secondary)

      Spacer()

      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.primary)
    }
  }
}

#Preview {
  let sampleBill = Bill(
    id: "1",
    name: "Internet Bill",
    amount: 99.90,
    dueDay: 15,
    category: .bills,
    subcategory: .internet,
    accountId: "account-1",
    isPaid: false,
    isActive: true,
    notes: "Vivo Fibra 300MB",
    reminderDaysBefore: 3,
    lastPaidDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
    nextDueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
    userId: "user-1",
    createdAt: Date(),
    updatedAt: Date()
  )

  return BillDetailView(
    bill: sampleBill,
    viewModel: BillsViewModel(repository: MockBillRepository())
  )
}
