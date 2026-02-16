//
//  ExpansionCoordinator.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI
import Observation

/// Coordinator for managing single-expansion accordion behavior
@Observable
public class ExpansionCoordinator {

  // MARK: - State

  /// ID of currently expanded section (nil if all collapsed)
  public var expandedSectionID: String?

  // MARK: - Initialization

  /// Creates an expansion coordinator
  /// - Parameter initiallyExpandedID: Optional section ID to start expanded
  public init(initiallyExpandedID: String? = nil) {
    self.expandedSectionID = initiallyExpandedID
  }

  // MARK: - Methods

  /// Expands a section (collapses any other expanded section)
  /// - Parameter id: Section ID to expand
  public func expand(_ id: String) {
    expandedSectionID = id
  }

  /// Collapses a section if it's currently expanded
  /// - Parameter id: Section ID to collapse
  public func collapse(_ id: String) {
    if expandedSectionID == id {
      expandedSectionID = nil
    }
  }

  /// Toggles a section's expansion state
  /// - Parameter id: Section ID to toggle
  public func toggle(_ id: String) {
    if isExpanded(id) {
      collapse(id)
    } else {
      expand(id)
    }
  }

  /// Checks if a section is currently expanded
  /// - Parameter id: Section ID to check
  /// - Returns: True if section is expanded
  public func isExpanded(_ id: String) -> Bool {
    expandedSectionID == id
  }

  /// Collapses all sections
  public func collapseAll() {
    expandedSectionID = nil
  }
}
