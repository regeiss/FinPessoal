import SwiftUI

/// Animated refresh indicator for pull-to-refresh
struct RefreshIndicator: View {
  // MARK: - Properties

  let state: PullToRefreshState
  let pullProgress: Double // 0.0 to 1.0

  @State private var spinRotation: Double = 0
  @State private var pulseScale: Double = 1.0
  @State private var showParticles: Bool = false

  private let animationSettings = AnimationSettings.shared

  // MARK: - Initialization

  init(state: PullToRefreshState, pullProgress: Double = 0.0) {
    self.state = state
    self.pullProgress = pullProgress
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      switch state {
      case .idle:
        EmptyView()

      case .pulling:
        pullingIndicator

      case .ready:
        readyIndicator

      case .loading:
        loadingIndicator

      case .complete:
        completeIndicator
      }

      // Particle effect overlay (full mode only)
      if showParticles && animationSettings.effectiveMode == .full {
        particleEffect
      }
    }
    .frame(height: 60)
  }

  // MARK: - Pulling State

  private var pullingIndicator: some View {
    HStack(spacing: 12) {
      // Rotating arrow icon
      Image(systemName: "arrow.down")
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(iconColor)
        .rotationEffect(.degrees(180 * pullProgress))
        .scaleEffect(iconScale)

      // Progress text
      if pullProgress > 0.3 {
        Text(pullProgressText)
          .font(.caption)
          .foregroundColor(.oldMoney.text.opacity(0.6))
          .transition(.opacity.combined(with: .scale))
      }
    }
    .animation(AnimationEngine.quickFade, value: pullProgress)
  }

  private var pullProgressText: String {
    if pullProgress >= 1.0 {
      return "Release to refresh"
    } else if pullProgress >= 0.7 {
      return "Almost there..."
    } else if pullProgress >= 0.5 {
      return "Keep pulling"
    } else {
      return "Pull to refresh"
    }
  }

  // MARK: - Ready State

  private var readyIndicator: some View {
    HStack(spacing: 12) {
      // Pulsing arrow
      Image(systemName: "arrow.down.circle.fill")
        .font(.system(size: 24, weight: .semibold))
        .foregroundColor(.oldMoney.accent)
        .scaleEffect(pulseScale)
        .rotationEffect(.degrees(180))

      Text("Release to refresh")
        .font(.callout)
        .fontWeight(.medium)
        .foregroundColor(.oldMoney.accent)
    }
    .onAppear {
      startPulseAnimation()
    }
  }

  private func startPulseAnimation() {
    guard animationSettings.effectiveMode != .minimal else { return }

    withAnimation(
      .easeInOut(duration: 0.6)
      .repeatForever(autoreverses: true)
    ) {
      pulseScale = 1.1
    }
  }

  // MARK: - Loading State

  private var loadingIndicator: some View {
    HStack(spacing: 12) {
      // Spinning icon
      Image(systemName: "arrow.triangle.2.circlepath")
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.oldMoney.accent)
        .rotationEffect(.degrees(spinRotation))

      Text("Refreshing...")
        .font(.callout)
        .foregroundColor(.oldMoney.text.opacity(0.8))
    }
    .onAppear {
      startSpinAnimation()
    }
  }

  private func startSpinAnimation() {
    guard animationSettings.effectiveMode != .minimal else { return }

    withAnimation(
      .linear(duration: 1.0)
      .repeatForever(autoreverses: false)
    ) {
      spinRotation = 360
    }
  }

  // MARK: - Complete State

  private var completeIndicator: some View {
    HStack(spacing: 12) {
      // Success checkmark
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 24, weight: .semibold))
        .foregroundColor(successColor)
        .scaleEffect(pulseScale)

      Text("Updated")
        .font(.callout)
        .fontWeight(.medium)
        .foregroundColor(successColor)
    }
    .onAppear {
      animateSuccess()
    }
  }

  private func animateSuccess() {
    guard animationSettings.effectiveMode != .minimal else { return }

    // Pop scale animation
    withAnimation(AnimationEngine.bouncySpring) {
      pulseScale = 1.2
    }

    // Trigger particles in full mode
    if animationSettings.effectiveMode == .full {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        showParticles = true
      }

      // Hide particles after brief display
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        showParticles = false
      }
    }

    // Scale back down
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      withAnimation(AnimationEngine.gentleSpring) {
        pulseScale = 1.0
      }
    }
  }

  // MARK: - Particle Effect

  private var particleEffect: some View {
    ZStack {
      ForEach(0..<8, id: \.self) { index in
        particleDot(index: index)
      }
    }
  }

  private func particleDot(index: Int) -> some View {
    let angle = Double(index) * (360.0 / 8.0)
    let offsetX = cos(angle * .pi / 180.0) * 30
    let offsetY = sin(angle * .pi / 180.0) * 30

    return Circle()
      .fill(Color.oldMoney.accent.opacity(0.6))
      .frame(width: 4, height: 4)
      .offset(x: showParticles ? offsetX : 0, y: showParticles ? offsetY : 0)
      .opacity(showParticles ? 0 : 1)
      .animation(
        .easeOut(duration: 0.4).delay(Double(index) * 0.02),
        value: showParticles
      )
  }

  // MARK: - Styling

  private var iconColor: Color {
    let baseOpacity = 0.6 + (pullProgress * 0.4)

    if pullProgress >= 1.0 {
      return .oldMoney.accent
    } else {
      return .oldMoney.text.opacity(baseOpacity)
    }
  }

  private var iconScale: Double {
    return 0.5 + (pullProgress * 0.5)
  }

  private var successColor: Color {
    return Color.oldMoney.success ?? .green
  }
}

// MARK: - Refresh Indicator Container

/// Container that manages refresh indicator positioning and visibility
struct RefreshIndicatorContainer<Content: View>: View {
  @ObservedObject var coordinator: RefreshCoordinator
  let content: Content

  @State private var pullOffset: CGFloat = 0

  init(
    coordinator: RefreshCoordinator,
    @ViewBuilder content: () -> Content
  ) {
    self.coordinator = coordinator
    self.content = content()
  }

  var body: some View {
    VStack(spacing: 0) {
      // Refresh indicator
      RefreshIndicator(
        state: coordinator.refreshState,
        pullProgress: calculatePullProgress()
      )
      .frame(height: indicatorHeight)
      .opacity(indicatorOpacity)
      .offset(y: indicatorOffset)

      // Content
      content
    }
  }

  private func calculatePullProgress() -> Double {
    switch coordinator.refreshState {
    case .pulling(let offset):
      return min(offset / 60.0, 1.0)
    case .ready, .loading, .complete:
      return 1.0
    case .idle:
      return 0.0
    }
  }

  private var indicatorHeight: CGFloat {
    switch coordinator.refreshState {
    case .idle:
      return 0
    case .pulling(let offset):
      return min(offset, 60)
    case .ready, .loading, .complete:
      return 60
    }
  }

  private var indicatorOpacity: Double {
    switch coordinator.refreshState {
    case .idle:
      return 0.0
    case .pulling(let offset):
      return min(offset / 30.0, 1.0)
    case .ready, .loading, .complete:
      return 1.0
    }
  }

  private var indicatorOffset: CGFloat {
    switch coordinator.refreshState {
    case .idle:
      return -60
    default:
      return 0
    }
  }
}

// MARK: - View Extension

extension View {
  /// Adds refresh indicator managed by coordinator
  func refreshIndicator(coordinator: RefreshCoordinator) -> some View {
    RefreshIndicatorContainer(coordinator: coordinator) {
      self
    }
  }
}

// MARK: - Preview

#if DEBUG
struct RefreshIndicator_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 40) {
      // Pulling state
      VStack {
        Text("Pulling (30%)")
          .font(.caption)
        RefreshIndicator(
          state: .pulling(offset: 18),
          pullProgress: 0.3
        )
      }

      // Pulling state (70%)
      VStack {
        Text("Pulling (70%)")
          .font(.caption)
        RefreshIndicator(
          state: .pulling(offset: 42),
          pullProgress: 0.7
        )
      }

      // Ready state
      VStack {
        Text("Ready")
          .font(.caption)
        RefreshIndicator(
          state: .ready,
          pullProgress: 1.0
        )
      }

      // Loading state
      VStack {
        Text("Loading")
          .font(.caption)
        RefreshIndicator(
          state: .loading,
          pullProgress: 1.0
        )
      }

      // Complete state
      VStack {
        Text("Complete")
          .font(.caption)
        RefreshIndicator(
          state: .complete,
          pullProgress: 1.0
        )
      }
    }
    .padding()
    .background(Color.oldMoney.background)
    .previewDisplayName("All States")

    // Dark mode
    VStack(spacing: 30) {
      RefreshIndicator(state: .ready, pullProgress: 1.0)
      RefreshIndicator(state: .loading, pullProgress: 1.0)
      RefreshIndicator(state: .complete, pullProgress: 1.0)
    }
    .padding()
    .background(Color.oldMoney.background)
    .preferredColorScheme(.dark)
    .previewDisplayName("Dark Mode")
  }
}
#endif
