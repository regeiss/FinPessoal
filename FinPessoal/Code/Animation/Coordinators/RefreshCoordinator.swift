import SwiftUI
import Combine

/// State machine for managing pull-to-refresh lifecycle
@MainActor
class RefreshCoordinator: ObservableObject {
  // MARK: - Published Properties

  @Published var refreshState: PullToRefreshState = .idle
  @Published var isRefreshing: Bool = false
  @Published var lastRefreshDate: Date?
  @Published var refreshError: Error?

  // MARK: - Private Properties

  private var cancellables = Set<AnyCancellable>()
  private let hapticEngine = HapticEngine.shared
  private let animationSettings = AnimationSettings.shared

  // Timing configuration
  private enum Timing {
    static let completeDisplayDuration: Double = 0.8
    static let errorDisplayDuration: Double = 2.0
    static let minimumRefreshDuration: Double = 0.5
  }

  // MARK: - Initialization

  init() {
    setupSubscriptions()
  }

  private func setupSubscriptions() {
    // Monitor state changes for haptic feedback
    $refreshState
      .removeDuplicates { lhs, rhs in
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.ready, .ready),
             (.loading, .loading),
             (.complete, .complete):
          return true
        case (.pulling(let offset1), .pulling(let offset2)):
          return abs(offset1 - offset2) < 1.0
        default:
          return false
        }
      }
      .sink { [weak self] state in
        self?.handleStateChange(state)
      }
      .store(in: &cancellables)
  }

  // MARK: - State Transitions

  /// Updates the pull offset and state
  func updatePullOffset(_ offset: CGFloat) {
    guard !isRefreshing else { return }

    if offset >= 60.0 {
      transitionTo(.ready)
    } else if offset > 0 {
      transitionTo(.pulling(offset: offset))
    } else {
      transitionTo(.idle)
    }
  }

  /// Triggers the refresh action
  func triggerRefresh() {
    guard !isRefreshing else { return }

    transitionTo(.loading)
    isRefreshing = true
    refreshError = nil
  }

  /// Completes the refresh successfully
  func completeRefresh() {
    guard isRefreshing else { return }

    isRefreshing = false
    lastRefreshDate = Date()
    transitionTo(.complete)

    // Success haptic
    hapticEngine.success()

    // Auto-reset to idle after display duration
    DispatchQueue.main.asyncAfter(deadline: .now() + Timing.completeDisplayDuration) {
      self.transitionTo(.idle)
    }
  }

  /// Completes the refresh with an error
  func failRefresh(error: Error) {
    guard isRefreshing else { return }

    isRefreshing = false
    refreshError = error
    transitionTo(.idle)

    // Error haptic
    hapticEngine.error()
  }

  /// Cancels an ongoing refresh
  func cancelRefresh() {
    guard isRefreshing else { return }

    isRefreshing = false
    refreshError = nil
    transitionTo(.idle)

    // Warning haptic
    hapticEngine.warning()
  }

  /// Resets to idle state
  func reset() {
    isRefreshing = false
    refreshError = nil
    transitionTo(.idle)
  }

  private func transitionTo(_ newState: PullToRefreshState) {
    guard animationSettings.effectiveMode != .minimal else {
      refreshState = newState
      return
    }

    withAnimation(AnimationEngine.gentleSpring) {
      refreshState = newState
    }
  }

  // MARK: - State Change Handling

  private func handleStateChange(_ state: PullToRefreshState) {
    switch state {
    case .ready:
      // Trigger medium haptic when ready threshold is crossed
      hapticEngine.medium()

    case .pulling(let offset) where offset >= 30.0:
      // Light haptic at halfway point (only once)
      if case .pulling(let previousOffset) = refreshState,
         previousOffset < 30.0 {
        hapticEngine.light()
      }

    default:
      break
    }
  }

  // MARK: - Integration with ViewModel

  /// Executes a refresh action and manages state
  func executeRefresh(_ action: @escaping () async throws -> Void) async {
    let startTime = Date()

    do {
      try await action()

      // Ensure minimum refresh duration for better UX
      let elapsed = Date().timeIntervalSince(startTime)
      if elapsed < Timing.minimumRefreshDuration {
        try? await Task.sleep(nanoseconds: UInt64((Timing.minimumRefreshDuration - elapsed) * 1_000_000_000))
      }

      await MainActor.run {
        completeRefresh()
      }
    } catch {
      await MainActor.run {
        failRefresh(error: error)
      }
    }
  }

  /// Convenience method for ViewModel integration
  func refresh(with viewModel: DashboardViewModel) async {
    await executeRefresh {
      try await viewModel.loadDashboardData()
    }
  }
}

// MARK: - Equatable for PullToRefreshState

extension PullToRefreshState: Equatable {
  static func == (lhs: PullToRefreshState, rhs: PullToRefreshState) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (.pulling(let offset1), .pulling(let offset2)):
      return abs(offset1 - offset2) < 1.0
    case (.ready, .ready):
      return true
    case (.loading, .loading):
      return true
    case (.complete, .complete):
      return true
    default:
      return false
    }
  }
}

// MARK: - Refresh Status

extension RefreshCoordinator {
  /// Human-readable status message
  var statusMessage: String {
    if let error = refreshError {
      return "Error: \(error.localizedDescription)"
    }

    switch refreshState {
    case .idle:
      if let lastRefresh = lastRefreshDate {
        return "Last updated \(timeAgo(lastRefresh))"
      }
      return "Pull to refresh"

    case .pulling:
      return "Pull down to refresh"

    case .ready:
      return "Release to refresh"

    case .loading:
      return "Refreshing..."

    case .complete:
      return "Updated successfully"
    }
  }

  private func timeAgo(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)

    if seconds < 60 {
      return "just now"
    } else if seconds < 3600 {
      let minutes = Int(seconds / 60)
      return "\(minutes)m ago"
    } else if seconds < 86400 {
      let hours = Int(seconds / 3600)
      return "\(hours)h ago"
    } else {
      let days = Int(seconds / 86400)
      return "\(days)d ago"
    }
  }
}

// MARK: - Refresh Metrics

extension RefreshCoordinator {
  /// Tracks refresh statistics for analytics
  struct RefreshMetrics {
    var totalRefreshes: Int = 0
    var successfulRefreshes: Int = 0
    var failedRefreshes: Int = 0
    var averageRefreshDuration: Double = 0.0
    var lastRefreshDuration: Double = 0.0

    mutating func recordSuccess(duration: Double) {
      totalRefreshes += 1
      successfulRefreshes += 1
      lastRefreshDuration = duration
      updateAverageDuration(duration)
    }

    mutating func recordFailure(duration: Double) {
      totalRefreshes += 1
      failedRefreshes += 1
      lastRefreshDuration = duration
      updateAverageDuration(duration)
    }

    private mutating func updateAverageDuration(_ duration: Double) {
      averageRefreshDuration = ((averageRefreshDuration * Double(totalRefreshes - 1)) + duration) / Double(totalRefreshes)
    }

    var successRate: Double {
      guard totalRefreshes > 0 else { return 0.0 }
      return Double(successfulRefreshes) / Double(totalRefreshes)
    }
  }

  private static var metrics = RefreshMetrics()

  static func recordRefreshSuccess(duration: Double) {
    metrics.recordSuccess(duration: duration)
  }

  static func recordRefreshFailure(duration: Double) {
    metrics.recordFailure(duration: duration)
  }

  static func getMetrics() -> RefreshMetrics {
    return metrics
  }

  static func resetMetrics() {
    metrics = RefreshMetrics()
  }
}

// MARK: - Preview Support

#if DEBUG
extension RefreshCoordinator {
  static var preview: RefreshCoordinator {
    let coordinator = RefreshCoordinator()
    coordinator.lastRefreshDate = Date().addingTimeInterval(-300) // 5 minutes ago
    return coordinator
  }

  static var previewLoading: RefreshCoordinator {
    let coordinator = RefreshCoordinator()
    coordinator.refreshState = .loading
    coordinator.isRefreshing = true
    return coordinator
  }

  static var previewComplete: RefreshCoordinator {
    let coordinator = RefreshCoordinator()
    coordinator.refreshState = .complete
    coordinator.lastRefreshDate = Date()
    return coordinator
  }
}
#endif
