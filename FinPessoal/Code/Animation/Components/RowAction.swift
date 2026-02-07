//
//  RowAction.swift
//  FinPessoal
//
//  Created by Claude Code on 07/02/26.
//

import SwiftUI

/// Model for swipe actions on InteractiveListRow
public struct RowAction: Identifiable {
  public let id = UUID()
  public let title: String
  public let icon: String
  public let tint: Color
  public let role: ButtonRole?
  public let action: () async -> Void

  public init(
    title: String,
    icon: String,
    tint: Color,
    role: ButtonRole? = nil,
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.icon = icon
    self.tint = tint
    self.role = role
    self.action = action
  }
}

// MARK: - Preset Actions

extension RowAction {
  /// Delete action (red, destructive)
  public static func delete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.delete"),
      icon: "trash",
      tint: .red,
      role: .destructive,
      action: action
    )
  }

  /// Edit action (blue)
  public static func edit(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.edit"),
      icon: "pencil",
      tint: .blue,
      action: action
    )
  }

  /// Complete action (green)
  public static func complete(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.complete"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

  /// Mark paid action (green)
  public static func markPaid(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "bill.mark.paid"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }

  /// Archive action (orange)
  public static func archive(action: @escaping () async -> Void) -> RowAction {
    RowAction(
      title: String(localized: "common.archive"),
      icon: "archivebox",
      tint: .orange,
      action: action
    )
  }
}
