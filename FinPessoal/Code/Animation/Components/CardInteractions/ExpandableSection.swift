//
//  ExpandableSection.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Accordion-style expandable section with single-expansion support
public struct ExpandableSection<Header: View, Content: View>: View {

  // MARK: - Configuration

  /// Whether section starts expanded
  private let initiallyExpanded: Bool

  /// Whether to show chevron indicator
  private let showChevron: Bool

  /// Callback when section expands
  private let onExpand: (() -> Void)?

  /// Callback when section collapses
  private let onCollapse: (() -> Void)?

  /// Header view builder
  private let header: Header

  /// Content view builder
  private let content: Content

  /// Unique section ID for coordination
  private let sectionID: String

  // MARK: - State

  /// Local expansion state (when no coordinator)
  @State private var isLocallyExpanded: Bool

  /// Optional coordinator for single-expansion behavior
  private var coordinator: ExpansionCoordinator?

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates an expandable section
  /// - Parameters:
  ///   - id: Unique section identifier (auto-generated if not provided)
  ///   - coordinator: Optional coordinator for single-expansion (nil = independent)
  ///   - initiallyExpanded: Whether section starts expanded, default false
  ///   - showChevron: Whether to show chevron indicator, default true
  ///   - onExpand: Optional callback when section expands
  ///   - onCollapse: Optional callback when section collapses
  ///   - header: Header view builder
  ///   - content: Content view builder
  public init(
    id: String? = nil,
    coordinator: ExpansionCoordinator? = nil,
    initiallyExpanded: Bool = false,
    showChevron: Bool = true,
    onExpand: (() -> Void)? = nil,
    onCollapse: (() -> Void)? = nil,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content
  ) {
    self.sectionID = id ?? UUID().uuidString
    self.coordinator = coordinator
    self.initiallyExpanded = initiallyExpanded
    self.showChevron = showChevron
    self.onExpand = onExpand
    self.onCollapse = onCollapse
    self.header = header()
    self.content = content()

    // Initialize local state
    _isLocallyExpanded = State(initialValue: initiallyExpanded)
  }

  // MARK: - Body

  public var body: some View {
    VStack(spacing: 0) {
      // Header (always visible, tappable)
      Button {
        toggleExpansion()
      } label: {
        HStack {
          header

          Spacer()

          if showChevron {
            chevronView
          }
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isButton)
      .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
      .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")

      // Divider
      if isExpanded {
        Divider()
          .padding(.vertical, 8)
      }

      // Content (revealed when expanded)
      if isExpanded {
        content
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .animation(expansionAnimation, value: isExpanded)
  }

  // MARK: - Views

  /// Chevron indicator
  private var chevronView: some View {
    Image(systemName: "chevron.right")
      .font(.caption)
      .fontWeight(.semibold)
      .foregroundStyle(.secondary)
      .rotationEffect(.degrees(isExpanded ? 90 : 0))
      .animation(chevronAnimation, value: isExpanded)
  }

  // MARK: - Computed Properties

  /// Whether section is currently expanded
  private var isExpanded: Bool {
    if let coordinator = coordinator {
      return coordinator.isExpanded(sectionID)
    } else {
      return isLocallyExpanded
    }
  }

  /// Expansion animation respecting animation mode
  private var expansionAnimation: Animation? {
    if reduceMotion {
      return .linear(duration: 0.15)
    }
    return AnimationEngine.adaptiveExpand()
  }

  /// Chevron rotation animation
  private var chevronAnimation: Animation? {
    if reduceMotion {
      return .linear(duration: 0.15)
    }
    return .easeInOut(duration: 0.25)
  }

  // MARK: - Actions

  /// Toggles section expansion
  private func toggleExpansion() {
    let wasExpanded = isExpanded

    // Update state via coordinator or local state
    if let coordinator = coordinator {
      coordinator.toggle(sectionID)
    } else {
      isLocallyExpanded.toggle()
    }

    // Trigger callbacks
    if wasExpanded {
      onCollapse?()
    } else {
      onExpand?()
    }

    // Light haptic feedback
    HapticEngine.shared.light()
  }
}
