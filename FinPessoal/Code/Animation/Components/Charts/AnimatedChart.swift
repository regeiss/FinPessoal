import SwiftUI

// Note: Requires AnimationMode, AnimationSettings from Animation/Engine
// and ChartDataPoint from this directory

/// Protocol defining the animation lifecycle for chart components
protocol AnimatedChart: View {
  associatedtype DataType

  /// The data to be displayed in the chart
  var data: DataType { get }

  /// The current animation progress (0.0 to 1.0)
  var animationProgress: Double { get set }

  /// Whether the chart is in an interactive state
  var isInteractive: Bool { get }

  /// Draw the chart with the current animation progress
  /// - Parameter context: The graphics context for drawing
  /// - Parameter size: The size of the chart area
  func draw(in context: GraphicsContext, size: CGSize)

  /// Update the chart when data changes
  /// - Parameter newData: The new data to display
  func update(with newData: DataType)

  /// Transition from previous state to new state
  /// - Parameters:
  ///   - from: The previous data state
  ///   - to: The new data state
  ///   - progress: The transition progress (0.0 to 1.0)
  func transition(from: DataType, to: DataType, progress: Double)

  /// Handle gesture interactions
  /// - Parameter location: The location of the gesture in the chart coordinate space
  /// - Returns: The data point at the location, if any
  func handleGesture(at location: CGPoint) -> Any?
}

extension AnimatedChart {
  /// Default implementation checks AnimationSettings for mode-aware rendering
  var effectiveAnimationMode: AnimationMode {
    AnimationSettings.shared.effectiveMode
  }

  /// Whether animations should be enabled based on the current mode
  var shouldAnimate: Bool {
    effectiveAnimationMode != .minimal
  }

  /// Default animation duration based on mode
  var animationDuration: Double {
    switch effectiveAnimationMode {
    case .full:
      return 0.8
    case .reduced:
      return 0.4
    case .minimal:
      return 0.0
    }
  }

  /// Default implementation for transition (can be overridden)
  func transition(from: DataType, to: DataType, progress: Double) {
    // Default: simple crossfade
    // Subclasses can override for more sophisticated transitions
  }

  /// Default implementation for gesture handling
  func handleGesture(at location: CGPoint) -> Any? {
    return nil
  }
}

/// Chart interaction state
enum ChartInteractionState {
  case idle
  case hovering(point: ChartDataPoint)
  case dragging(point: ChartDataPoint)
  case tapped(point: ChartDataPoint)
}
