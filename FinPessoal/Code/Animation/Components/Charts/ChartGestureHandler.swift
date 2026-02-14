// FinPessoal/Code/Animation/Components/Charts/ChartGestureHandler.swift
import SwiftUI
import Combine

/// Centralized gesture coordination for charts
@MainActor
final class ChartGestureHandler: ObservableObject {
  @Published var selectedID: String?
  @Published var isDragging: Bool = false
  @Published var zoomScale: CGFloat = 1.0

  init() {}

  /// Handle tap gesture on chart element
  func handleTap(segmentID: String) {
    HapticEngine.shared.selection()

    if selectedID == segmentID {
      selectedID = nil // Deselect
    } else {
      selectedID = segmentID // Select
    }
  }

  /// Handle drag gesture (for scrubbing)
  func handleDragChanged(segmentID: String?) {
    isDragging = true

    if let newID = segmentID, newID != selectedID {
      HapticEngine.shared.selection()
      selectedID = newID
    }
  }

  /// Handle drag gesture end
  func handleDragEnded() {
    isDragging = false
  }

  /// Handle long press gesture
  func handleLongPress() {
    HapticEngine.shared.medium()
    // Future: trigger detail sheet
  }

  /// Reset all gesture state
  func reset() {
    selectedID = nil
    isDragging = false
    zoomScale = 1.0
  }
}
