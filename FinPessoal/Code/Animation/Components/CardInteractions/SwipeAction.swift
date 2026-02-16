//
//  SwipeAction.swift
//  FinPessoal
//
//  Created by Claude Code on 15/02/26.
//

import SwiftUI

/// A swipe action that can be performed on a SwipeableRow
public struct SwipeAction: Identifiable {

  // MARK: - Properties

  /// Unique identifier
  public let id = UUID()

  /// Action title displayed to user
  public let title: String

  /// SF Symbol icon name
  public let icon: String

  /// Action color tint
  public let tint: Color

  /// Button role (e.g., .destructive)
  public let role: ButtonRole?

  /// Action to execute when triggered
  public let action: () async -> Void

  // MARK: - Initialization

  /// Creates a new swipe action
  /// - Parameters:
  ///   - title: Action title
  ///   - icon: SF Symbol name
  ///   - tint: Action color
  ///   - role: Button role (optional)
  ///   - action: Action to execute
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

// MARK: - Preset Factory Methods

public extension SwipeAction {

  /// Delete action preset (red, destructive, trash icon)
  /// - Parameter action: Action to execute when triggered
  /// - Returns: Configured delete action
  static func delete(action: @escaping () async -> Void) -> SwipeAction {
    SwipeAction(
      title: String(localized: "common.delete"),
      icon: "trash",
      tint: .red,
      role: .destructive,
      action: action
    )
  }

  /// Edit action preset (blue, pencil icon)
  /// - Parameter action: Action to execute when triggered
  /// - Returns: Configured edit action
  static func edit(action: @escaping () async -> Void) -> SwipeAction {
    SwipeAction(
      title: String(localized: "common.edit"),
      icon: "pencil",
      tint: .blue,
      action: action
    )
  }

  /// Archive action preset (orange, archivebox icon)
  /// - Parameter action: Action to execute when triggered
  /// - Returns: Configured archive action
  static func archive(action: @escaping () async -> Void) -> SwipeAction {
    SwipeAction(
      title: String(localized: "common.archive"),
      icon: "archivebox",
      tint: .orange,
      action: action
    )
  }

  /// Complete action preset (green/income color, checkmark icon)
  /// - Parameter action: Action to execute when triggered
  /// - Returns: Configured complete action
  static func complete(action: @escaping () async -> Void) -> SwipeAction {
    SwipeAction(
      title: String(localized: "common.complete"),
      icon: "checkmark.circle.fill",
      tint: Color.oldMoney.income,
      action: action
    )
  }
}
