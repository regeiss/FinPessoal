import SwiftUI

// MARK: - Pull-to-Refresh State

enum PullToRefreshState {
  case idle
  case pulling(offset: CGFloat)
  case ready
  case loading
  case complete

  var offset: CGFloat {
    switch self {
    case .pulling(let offset):
      return offset
    default:
      return 0
    }
  }
}

// MARK: - ScrollView Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

// MARK: - Pull-to-Refresh View

struct PullToRefreshView<Content: View>: View {
  // MARK: - Properties

  @Binding var isRefreshing: Bool
  let onRefresh: () async -> Void
  let content: Content

  @State private var scrollOffset: CGFloat = 0
  @State private var refreshState: PullToRefreshState = .idle
  @State private var previousState: PullToRefreshState = .idle
  @State private var isDragging: Bool = false

  private let refreshThreshold: CGFloat = 60.0
  private let halfwayThreshold: CGFloat = 30.0

  private let hapticEngine = HapticEngine.shared
  private let animationSettings = AnimationSettings.shared

  // MARK: - Initialization

  init(
    isRefreshing: Binding<Bool>,
    onRefresh: @escaping () async -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self._isRefreshing = isRefreshing
    self.onRefresh = onRefresh
    self.content = content()
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: 0) {
          // Refresh indicator at top
          refreshIndicatorView
            .frame(height: indicatorHeight)
            .offset(y: indicatorOffset)

          // Main content
          content
            .background(
              GeometryReader { contentGeometry in
                Color.clear
                  .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: contentGeometry.frame(in: .named("scrollView")).minY
                  )
              }
            )
        }
      }
      .coordinateSpace(name: "scrollView")
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
        handleScrollOffsetChange(offset)
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            isDragging = true
          }
          .onEnded { _ in
            handleDragEnd()
          }
      )
    }
    .onChange(of: isRefreshing) { _, newValue in
      if !newValue && refreshState == .loading {
        completeRefresh()
      }
    }
  }

  // MARK: - Refresh Indicator

  @ViewBuilder
  private var refreshIndicatorView: some View {
    ZStack {
      switch refreshState {
      case .idle:
        EmptyView()

      case .pulling(let offset):
        pullingIndicator(progress: min(offset / refreshThreshold, 1.0))

      case .ready:
        readyIndicator

      case .loading:
        loadingIndicator

      case .complete:
        completeIndicator
      }
    }
    .frame(height: indicatorHeight)
  }

  private func pullingIndicator(progress: Double) -> some View {
    HStack(spacing: 8) {
      Image(systemName: "arrow.down")
        .rotationEffect(.degrees(180 * progress))
        .scaleEffect(0.5 + (0.5 * progress))
        .foregroundColor(.oldMoney.text.opacity(0.6))

      if progress > 0.5 {
        Text("Pull to refresh")
          .font(.caption)
          .foregroundColor(.oldMoney.text.opacity(0.6))
      }
    }
  }

  private var readyIndicator: some View {
    HStack(spacing: 8) {
      Image(systemName: "arrow.down")
        .rotationEffect(.degrees(180))
        .foregroundColor(.oldMoney.accent)
        .scaleEffect(1.1)
        .animation(
          .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
          value: refreshState
        )

      Text("Release to refresh")
        .font(.caption)
        .foregroundColor(.oldMoney.accent)
    }
  }

  private var loadingIndicator: some View {
    HStack(spacing: 8) {
      ProgressView()
        .tint(.oldMoney.accent)

      Text("Refreshing...")
        .font(.caption)
        .foregroundColor(.oldMoney.text.opacity(0.8))
    }
  }

  private var completeIndicator: some View {
    HStack(spacing: 8) {
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.oldMoney.success ?? .green)
        .scaleEffect(1.2)

      Text("Updated")
        .font(.caption)
        .foregroundColor(.oldMoney.success ?? .green)
    }
  }

  // MARK: - Computed Properties

  private var indicatorHeight: CGFloat {
    switch refreshState {
    case .idle:
      return 0
    case .pulling(let offset):
      return min(offset, refreshThreshold)
    case .ready:
      return refreshThreshold
    case .loading, .complete:
      return 60
    }
  }

  private var indicatorOffset: CGFloat {
    switch refreshState {
    case .idle:
      return -60
    case .pulling:
      return 0
    case .ready, .loading:
      return 0
    case .complete:
      return 0
    }
  }

  // MARK: - Scroll Handling

  private func handleScrollOffsetChange(_ offset: CGFloat) {
    guard !isRefreshing else { return }

    // Only track pulling when at the top and dragging
    guard isDragging && offset >= 0 else {
      if refreshState != .idle && !isDragging {
        refreshState = .idle
      }
      return
    }

    // Apply elastic resistance
    let elasticOffset = applyElasticResistance(offset)

    // Update state based on offset
    updateRefreshState(for: elasticOffset)

    scrollOffset = elasticOffset
  }

  private func applyElasticResistance(_ offset: CGFloat) -> CGFloat {
    // Resistance increases as you pull further
    let resistance: CGFloat = 0.5
    return offset * resistance
  }

  private func updateRefreshState(for offset: CGFloat) {
    let newState: PullToRefreshState

    if offset >= refreshThreshold {
      newState = .ready
    } else if offset > 0 {
      newState = .pulling(offset: offset)
    } else {
      newState = .idle
    }

    // Trigger haptics on state transitions
    if shouldTriggerHaptic(from: previousState, to: newState) {
      triggerHapticForState(newState)
    }

    previousState = refreshState
    refreshState = newState
  }

  private func shouldTriggerHaptic(
    from oldState: PullToRefreshState,
    to newState: PullToRefreshState
  ) -> Bool {
    switch (oldState, newState) {
    case (.pulling, .ready):
      return true // Crossed threshold
    case (.pulling(let oldOffset), .pulling(let newOffset)):
      // Halfway threshold
      return oldOffset < halfwayThreshold && newOffset >= halfwayThreshold
    default:
      return false
    }
  }

  private func triggerHapticForState(_ state: PullToRefreshState) {
    switch state {
    case .ready:
      hapticEngine.medium()
    case .pulling(let offset) where offset >= halfwayThreshold:
      hapticEngine.light()
    default:
      break
    }
  }

  // MARK: - Drag Handling

  private func handleDragEnd() {
    isDragging = false

    // Trigger refresh if ready
    if case .ready = refreshState {
      startRefresh()
    } else {
      // Spring back to idle
      withAnimation(AnimationEngine.gentleSpring) {
        refreshState = .idle
        scrollOffset = 0
      }
    }
  }

  private func startRefresh() {
    refreshState = .loading
    isRefreshing = true

    Task {
      await onRefresh()

      await MainActor.run {
        isRefreshing = false
      }
    }
  }

  private func completeRefresh() {
    // Show success state briefly
    refreshState = .complete
    hapticEngine.success()

    // Then reset to idle
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      withAnimation(.easeOut(duration: 0.3)) {
        refreshState = .idle
        scrollOffset = 0
      }
    }
  }
}

// MARK: - View Extension

extension View {
  /// Adds pull-to-refresh functionality to any scrollable content
  func pullToRefresh(
    isRefreshing: Binding<Bool>,
    onRefresh: @escaping () async -> Void
  ) -> some View {
    PullToRefreshView(
      isRefreshing: isRefreshing,
      onRefresh: onRefresh
    ) {
      self
    }
  }
}

// MARK: - Preview

#if DEBUG
struct PullToRefreshView_Previews: PreviewProvider {
  static var previews: some View {
    PullToRefreshPreview()
  }

  struct PullToRefreshPreview: View {
    @State private var isRefreshing = false
    @State private var items = Array(1...20)

    var body: some View {
      PullToRefreshView(
        isRefreshing: $isRefreshing,
        onRefresh: refreshData
      ) {
        LazyVStack(spacing: 12) {
          ForEach(items, id: \.self) { item in
            HStack {
              Circle()
                .fill(Color.oldMoney.accent)
                .frame(width: 40, height: 40)

              VStack(alignment: .leading, spacing: 4) {
                Text("Item \(item)")
                  .font(.headline)
                Text("Updated just now")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }

              Spacer()
            }
            .padding()
            .background(Color.oldMoney.surface)
            .cornerRadius(12)
          }
        }
        .padding()
      }
      .background(Color.oldMoney.background)
    }

    private func refreshData() async {
      try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
      items = Array(1...20).shuffled()
    }
  }
}
#endif
