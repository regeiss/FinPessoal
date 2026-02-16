//
//  HeroTransitionLink.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// A component that provides hero transition animations between views using matched geometry
public struct HeroTransitionLink<Item: Identifiable, Content: View, Destination: View>: View {

  // MARK: - Configuration

  /// Item to transition
  private let item: Item

  /// Namespace for matched geometry effect
  private let namespace: Namespace.ID

  /// Source content view
  private let content: Content

  /// Destination view builder
  private let destination: (Item) -> Destination

  // MARK: - State

  /// Whether destination is presented
  @State private var isPresented: Bool = false

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a hero transition link
  /// - Parameters:
  ///   - item: Item to transition
  ///   - namespace: Namespace for matched geometry
  ///   - content: Source content builder
  ///   - destination: Destination view builder
  public init(
    item: Item,
    namespace: Namespace.ID,
    @ViewBuilder content: () -> Content,
    @ViewBuilder destination: @escaping (Item) -> Destination
  ) {
    self.item = item
    self.namespace = namespace
    self.content = content()
    self.destination = destination
  }

  // MARK: - Body

  public var body: some View {
    Button {
      presentDestination()
    } label: {
      if reduceMotion {
        // Reduce Motion: No matched geometry effect
        content
      } else {
        // Full animation: Matched geometry effect
        content
          .matchedGeometryEffect(
            id: item.id,
            in: namespace
          )
      }
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $isPresented) {
      destinationView
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isButton)
  }

  // MARK: - Views

  /// Destination view with matched geometry
  private var destinationView: some View {
    Group {
      if reduceMotion {
        // Reduce Motion: Simple transition
        destination(item)
          .transition(.opacity)
      } else {
        // Full animation: Matched geometry
        destination(item)
          .matchedGeometryEffect(
            id: item.id,
            in: namespace
          )
      }
    }
  }

  // MARK: - Actions

  /// Presents the destination view with hero transition
  private func presentDestination() {
    HapticEngine.shared.light()

    withAnimation(AnimationEngine.adaptiveHeroTransition()) {
      isPresented = true
    }
  }
}
