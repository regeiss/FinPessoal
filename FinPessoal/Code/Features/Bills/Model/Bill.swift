//
//  Bill.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation

/// Represents a recurring bill or payment obligation
struct Bill: Identifiable, Codable, Equatable {
  let id: String
  var name: String
  var amount: Double
  var dueDay: Int // Day of month (1-31)
  var category: TransactionCategory
  var subcategory: TransactionSubcategory?
  var accountId: String
  var isPaid: Bool
  var isActive: Bool
  var notes: String?
  var reminderDaysBefore: Int // Days before due date to send reminder
  var lastPaidDate: Date?
  var nextDueDate: Date
  var userId: String
  var createdAt: Date
  var updatedAt: Date

  // MARK: - Computed Properties

  /// Formatted amount in BRL currency
  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }

  /// Days until next due date
  var daysUntilDue: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let dueDate = calendar.startOfDay(for: nextDueDate)
    let components = calendar.dateComponents([.day], from: today, to: dueDate)
    return components.day ?? 0
  }

  /// Is the bill overdue?
  var isOverdue: Bool {
    return !isPaid && nextDueDate < Date()
  }

  /// Is the bill due soon (within reminder days)?
  var isDueSoon: Bool {
    return !isPaid && daysUntilDue <= reminderDaysBefore && daysUntilDue > 0
  }

  /// Status of the bill
  var status: BillStatus {
    if isPaid {
      return .paid
    } else if isOverdue {
      return .overdue
    } else if isDueSoon {
      return .dueSoon
    } else {
      return .upcoming
    }
  }

  /// Color for status indicator
  var statusColor: String {
    switch status {
    case .paid:
      return "green"
    case .overdue:
      return "red"
    case .dueSoon:
      return "orange"
    case .upcoming:
      return "blue"
    }
  }

  /// Status display text
  var statusText: String {
    switch status {
    case .paid:
      return String(localized: "bill.status.paid")
    case .overdue:
      return String(localized: "bill.status.overdue")
    case .dueSoon:
      return String(localized: "bill.status.due.soon")
    case .upcoming:
      return String(localized: "bill.status.upcoming")
    }
  }

  /// Calculate next due date based on current due date
  func calculateNextDueDate(after date: Date = Date()) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month], from: date)
    components.day = dueDay

    // Start with current month
    if let nextDate = calendar.date(from: components) {
      if nextDate > date {
        return nextDate
      }
    }

    // Try next month
    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) {
      components = calendar.dateComponents([.year, .month], from: nextMonth)
      components.day = dueDay

      if let nextDate = calendar.date(from: components) {
        return nextDate
      }
    }

    // Fallback: add 30 days
    return calendar.date(byAdding: .day, value: 30, to: date) ?? date
  }

  // MARK: - Mark as Paid

  /// Mark bill as paid and calculate next due date
  mutating func markAsPaid() {
    isPaid = true
    lastPaidDate = Date()
    nextDueDate = calculateNextDueDate(after: Date())
    updatedAt = Date()
  }

  /// Reset bill to unpaid status
  mutating func markAsUnpaid() {
    isPaid = false
    lastPaidDate = nil
    updatedAt = Date()
  }

  // MARK: - Firestore Conversion

  func toDictionary() throws -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "name": name,
      "amount": amount,
      "dueDay": dueDay,
      "category": category.rawValue,
      "accountId": accountId,
      "isPaid": isPaid,
      "isActive": isActive,
      "reminderDaysBefore": reminderDaysBefore,
      "nextDueDate": nextDueDate.timeIntervalSince1970,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]

    if let subcategory = subcategory {
      dict["subcategory"] = subcategory.rawValue
    }

    if let notes = notes {
      dict["notes"] = notes
    }

    if let lastPaidDate = lastPaidDate {
      dict["lastPaidDate"] = lastPaidDate.timeIntervalSince1970
    }

    return dict
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> Bill {
    guard let id = dict["id"] as? String,
          let name = dict["name"] as? String,
          let amount = dict["amount"] as? Double,
          let dueDay = dict["dueDay"] as? Int,
          let categoryRaw = dict["category"] as? String,
          let category = TransactionCategory(rawValue: categoryRaw),
          let accountId = dict["accountId"] as? String,
          let isPaid = dict["isPaid"] as? Bool,
          let isActive = dict["isActive"] as? Bool,
          let reminderDaysBefore = dict["reminderDaysBefore"] as? Int,
          let nextDueDateTimestamp = dict["nextDueDate"] as? TimeInterval,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
          let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required Bill fields")
    }

    let subcategory: TransactionSubcategory?
    if let subcategoryRaw = dict["subcategory"] as? String {
      subcategory = TransactionSubcategory(rawValue: subcategoryRaw)
    } else {
      subcategory = nil
    }

    let notes = dict["notes"] as? String

    let lastPaidDate: Date?
    if let lastPaidTimestamp = dict["lastPaidDate"] as? TimeInterval {
      lastPaidDate = Date(timeIntervalSince1970: lastPaidTimestamp)
    } else {
      lastPaidDate = nil
    }

    return Bill(
      id: id,
      name: name,
      amount: amount,
      dueDay: dueDay,
      category: category,
      subcategory: subcategory,
      accountId: accountId,
      isPaid: isPaid,
      isActive: isActive,
      notes: notes,
      reminderDaysBefore: reminderDaysBefore,
      lastPaidDate: lastPaidDate,
      nextDueDate: Date(timeIntervalSince1970: nextDueDateTimestamp),
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
      updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
    )
  }
}

// MARK: - Bill Status

enum BillStatus: String, Codable {
  case paid = "paid"
  case overdue = "overdue"
  case dueSoon = "dueSoon"
  case upcoming = "upcoming"
}

// MARK: - Bill Filter

enum BillFilter: String, CaseIterable {
  case all = "all"
  case active = "active"
  case paid = "paid"
  case unpaid = "unpaid"
  case overdue = "overdue"
  case dueSoon = "dueSoon"

  var displayName: String {
    switch self {
    case .all:
      return String(localized: "bill.filter.all")
    case .active:
      return String(localized: "bill.filter.active")
    case .paid:
      return String(localized: "bill.filter.paid")
    case .unpaid:
      return String(localized: "bill.filter.unpaid")
    case .overdue:
      return String(localized: "bill.filter.overdue")
    case .dueSoon:
      return String(localized: "bill.filter.due.soon")
    }
  }
}
