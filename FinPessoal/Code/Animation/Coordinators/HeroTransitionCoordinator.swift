//
//  HeroTransitionCoordinator.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI
import Observation

/// Coordinator for managing hero transition state and preventing conflicts
@Observable
public class HeroTransitionCoordinator {

  // MARK: - State

  /// ID of currently active transition (nil if none)
  public var activeTransition: String?

  /// Whether a transition is currently in progress
  public var isTransitioning: Bool = false

  // MARK: - Initialization

  /// Creates a hero transition coordinator
  public init() {}

  // MARK: - Methods

  /// Begins a hero transition
  /// - Parameter id: Unique identifier for the transition
  public func beginTransition(id: String) {
    activeTransition = id
    isTransitioning = true
    HapticEngine.shared.light()
  }

  /// Ends the current hero transition
  public func endTransition() {
    isTransitioning = false
    activeTransition = nil
  }

  /// Checks if a specific transition is active
  /// - Parameter id: Transition identifier to check
  /// - Returns: True if this transition is active
  public func isActive(_ id: String) -> Bool {
    activeTransition == id
  }
}
