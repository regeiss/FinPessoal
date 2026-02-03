import SwiftUI
import Combine

/// Coordinates chart animations, timing, and interactive gestures
@MainActor
class ChartAnimationCoordinator: ObservableObject {
  // MARK: - Published Properties

  @Published var animationProgress: Double = 0.0
  @Published var interactionState: ChartInteractionState = .idle
  @Published var isAnimating: Bool = false

  // MARK: - Private Properties

  private var cancellables = Set<AnyCancellable>()
  private var entryAnimationCompleted: Bool = false

  // MARK: - Configuration

  // AnimationEngine is accessed via static members
  private let hapticEngine = HapticEngine.shared
  private let animationSettings = AnimationSettings.shared

  // MARK: - Animation Timing

  private enum AnimationTiming {
    static let containerFadeIn: Double = 0.2
    static let axesDrawDelay: Double = 0.2
    static let axesDrawDuration: Double = 0.2
    static let gridLineStagger: Double = 0.05
    static let lineDrawDelay: Double = 0.3
    static let lineDrawDuration: Double = 0.6
    static let dataPointDelay: Double = 0.1
  }

  // MARK: - Initialization

  init() {
    setupSubscriptions()
  }

  private func setupSubscriptions() {
    // Animation mode is checked dynamically when needed
    // (effectiveMode is a computed property, not @Published)
  }

  // MARK: - Entry Animation

  /// Starts the staggered entry animation for the chart
  func startEntryAnimation() {
    guard !entryAnimationCompleted else { return }
    guard animationSettings.effectiveMode != .minimal else {
      completeEntryImmediately()
      return
    }

    isAnimating = true

    // Phase 1: Container fade-in (handled by parent view)
    // Phase 2: Axes draw
    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.axesDrawDelay) { [weak self] in
      self?.animateAxes()
    }

    // Phase 3: Line drawing
    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.lineDrawDelay) { [weak self] in
      self?.animateLineDraw()
    }
  }

  private func animateAxes() {
    // Axes animation is handled by the chart view itself
    // This coordinator just manages timing
  }

  private func animateLineDraw() {
    let duration = animationSettings.effectiveMode == .full
      ? AnimationTiming.lineDrawDuration
      : AnimationTiming.lineDrawDuration / 2

    withAnimation(AnimationEngine.gentleSpring) {
      animationProgress = 1.0
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
      self?.completeEntry()
    }
  }

  private func completeEntryImmediately() {
    animationProgress = 1.0
    entryAnimationCompleted = true
    isAnimating = false
  }

  private func completeEntry() {
    entryAnimationCompleted = true
    isAnimating = false
  }

  // MARK: - Data Update Animation

  /// Animates transition when chart data changes
  func animateDataUpdate(completion: (() -> Void)? = nil) {
    guard animationSettings.effectiveMode != .minimal else {
      completion?()
      return
    }

    isAnimating = true

    // Fade out current data
    withAnimation(AnimationEngine.quickFade) {
      animationProgress = 0.0
    }

    // Delay then animate new data
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self = self else { return }

      withAnimation(AnimationEngine.gentleSpring) {
        self.animationProgress = 1.0
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        self.isAnimating = false
        completion?()
      }
    }
  }

  // MARK: - Gesture Coordination

  /// Handles start of gesture interaction
  func beginInteraction(at point: ChartDataPoint) {
    interactionState = .hovering(point: point)
    hapticEngine.light()
  }

  /// Handles drag gesture movement
  func updateInteraction(to point: ChartDataPoint) {
    switch interactionState {
    case .hovering(let currentPoint), .dragging(let currentPoint):
      // Only trigger haptic if moving to a different point
      if currentPoint.id != point.id {
        interactionState = .dragging(point: point)
        hapticEngine.light()
      }
    default:
      interactionState = .dragging(point: point)
    }
  }

  /// Handles tap gesture on data point
  func tapDataPoint(_ point: ChartDataPoint) {
    interactionState = .tapped(point: point)
    hapticEngine.medium()

    // Trigger particle burst effect in full mode
    if animationSettings.effectiveMode == .full {
      triggerParticleBurst(at: point)
    }

    // Reset state after brief delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.endInteraction()
    }
  }

  /// Handles end of gesture interaction
  func endInteraction() {
    interactionState = .idle
  }

  // MARK: - Visual Effects

  private func triggerParticleBurst(at point: ChartDataPoint) {
    // Particle burst would be handled by the parent view
    // This coordinator just signals the event
    NotificationCenter.default.post(
      name: NSNotification.Name("ChartDataPointTapped"),
      object: nil,
      userInfo: ["point": point]
    )
  }

  // MARK: - Animation Mode Handling

  private func handleAnimationModeChange(_ mode: AnimationMode) {
    switch mode {
    case .minimal:
      // Immediately complete any ongoing animations
      completeEntryImmediately()
    case .reduced, .full:
      // Animations continue normally
      break
    }
  }

  // MARK: - Sequencing

  /// Coordinates staggered reveal for multiple chart elements
  func sequenceAnimations(
    elements: Int,
    delay: Double = 0.05,
    action: @escaping (Int) -> Void
  ) {
    for i in 0..<elements {
      let elementDelay = Double(i) * delay
      DispatchQueue.main.asyncAfter(deadline: .now() + elementDelay) {
        action(i)
      }
    }
  }

  /// Coordinates timing with dashboard-level animations
  func coordinateWithDashboard(delay: Double = 0.0) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      self?.startEntryAnimation()
    }
  }
}

// MARK: - Gesture State

extension ChartAnimationCoordinator {
  var currentDataPoint: ChartDataPoint? {
    switch interactionState {
    case .hovering(let point), .dragging(let point), .tapped(let point):
      return point
    case .idle:
      return nil
    }
  }

  var isInteracting: Bool {
    switch interactionState {
    case .idle:
      return false
    default:
      return true
    }
  }
}

// MARK: - Preview Support

#if DEBUG
extension ChartAnimationCoordinator {
  static var preview: ChartAnimationCoordinator {
    let coordinator = ChartAnimationCoordinator()
    coordinator.animationProgress = 1.0
    coordinator.entryAnimationCompleted = true
    return coordinator
  }
}
#endif
