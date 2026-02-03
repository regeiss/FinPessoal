import SwiftUI
import Combine

/// Coordinates smooth transitions from skeleton loading states to real content
@MainActor
class LoadingTransitionCoordinator: ObservableObject {
  // MARK: - Published Properties

  @Published var isLoading: Bool = true
  @Published var showSkeleton: Bool = true
  @Published var contentOpacity: Double = 0.0
  @Published var contentOffset: CGFloat = 20.0

  // MARK: - Private Properties

  private var cancellables = Set<AnyCancellable>()
  private let animationSettings = AnimationSettings.shared

  // MARK: - Configuration

  private enum TransitionTiming {
    static let skeletonFadeOut: Double = 0.2
    static let staggerDelay: Double = 0.1
    static let contentSlideIn: Double = 0.4
    static let contentFadeIn: Double = 0.3
  }

  // MARK: - Initialization

  init(isLoading: Bool = true) {
    self.isLoading = isLoading
    self.showSkeleton = isLoading

    if !isLoading {
      setupImmediateContent()
    }
  }

  // MARK: - Transition Management

  /// Triggers transition from skeleton to content
  func transitionToContent(staggerIndex: Int = 0) {
    guard isLoading else { return }

    // Immediately mark as not loading to prevent duplicate transitions
    isLoading = false

    // Handle different animation modes
    switch animationSettings.effectiveMode {
    case .minimal:
      transitionImmediately()
    case .reduced:
      transitionReduced(staggerIndex: staggerIndex)
    case .full:
      transitionFull(staggerIndex: staggerIndex)
    }
  }

  private func transitionImmediately() {
    showSkeleton = false
    contentOpacity = 1.0
    contentOffset = 0.0
  }

  private func transitionReduced(staggerIndex: Int) {
    let staggerDelay = Double(staggerIndex) * TransitionTiming.staggerDelay

    // Quick fade out skeleton
    withAnimation(.easeOut(duration: TransitionTiming.skeletonFadeOut / 2)) {
      showSkeleton = false
    }

    // Quick fade in content
    DispatchQueue.main.asyncAfter(deadline: .now() + TransitionTiming.skeletonFadeOut / 2 + staggerDelay) {
      withAnimation(.easeIn(duration: TransitionTiming.contentFadeIn / 2)) {
        self.contentOpacity = 1.0
        self.contentOffset = 0.0
      }
    }
  }

  private func transitionFull(staggerIndex: Int) {
    let staggerDelay = Double(staggerIndex) * TransitionTiming.staggerDelay

    // Phase 1: Fade out skeleton
    withAnimation(.easeOut(duration: TransitionTiming.skeletonFadeOut)) {
      showSkeleton = false
    }

    // Phase 2: Slide in and fade in content with stagger
    let contentDelay = TransitionTiming.skeletonFadeOut + staggerDelay

    DispatchQueue.main.asyncAfter(deadline: .now() + contentDelay) {
      withAnimation(AnimationEngine.gentleSpring) {
        self.contentOpacity = 1.0
        self.contentOffset = 0.0
      }
    }
  }

  /// Sets up content to display immediately without transition
  private func setupImmediateContent() {
    showSkeleton = false
    contentOpacity = 1.0
    contentOffset = 0.0
  }

  // MARK: - Staggered Group Coordination

  /// Coordinates transitions for multiple elements with stagger
  func coordinateStaggeredTransition(
    elementCount: Int,
    action: @escaping (Int) -> Void
  ) {
    guard isLoading else { return }

    isLoading = false

    for index in 0..<elementCount {
      let delay = TransitionTiming.skeletonFadeOut + (Double(index) * TransitionTiming.staggerDelay)

      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        action(index)
      }
    }
  }

  // MARK: - Reset

  /// Resets to loading state
  func reset() {
    isLoading = true
    showSkeleton = true
    contentOpacity = 0.0
    contentOffset = 20.0
  }
}

// MARK: - Loading Transition View Modifier

struct LoadingTransitionModifier: ViewModifier {
  @ObservedObject var coordinator: LoadingTransitionCoordinator
  let skeleton: AnyView

  func body(content: Content) -> some View {
    ZStack {
      // Content layer with transition
      content
        .opacity(coordinator.contentOpacity)
        .offset(y: coordinator.contentOffset)

      // Skeleton layer
      if coordinator.showSkeleton {
        skeleton
          .transition(.opacity)
      }
    }
  }
}

extension View {
  /// Applies loading transition with skeleton
  func loadingTransition<Skeleton: View>(
    coordinator: LoadingTransitionCoordinator,
    @ViewBuilder skeleton: () -> Skeleton
  ) -> some View {
    modifier(
      LoadingTransitionModifier(
        coordinator: coordinator,
        skeleton: AnyView(skeleton())
      )
    )
  }
}

// MARK: - Staggered Card Container

/// Container for dashboard cards that handles staggered reveal
struct StaggeredRevealCard<Content: View, Skeleton: View>: View {
  @ObservedObject var coordinator: LoadingTransitionCoordinator
  let staggerIndex: Int
  let content: () -> Content
  let skeleton: () -> Skeleton

  @State private var contentOpacity: Double = 0.0
  @State private var contentOffset: CGFloat = 20.0
  @State private var showSkeleton: Bool = true

  var body: some View {
    ZStack {
      // Content layer
      content()
        .opacity(contentOpacity)
        .offset(y: contentOffset)

      // Skeleton layer
      if showSkeleton {
        skeleton()
          .transition(.opacity)
      }
    }
    .onChange(of: coordinator.isLoading) { _, newValue in
      if !newValue {
        triggerReveal()
      }
    }
    .onAppear {
      if !coordinator.isLoading {
        setupImmediateContent()
      }
    }
  }

  private func triggerReveal() {
    let staggerDelay = Double(staggerIndex) * 0.1

    // Fade out skeleton
    withAnimation(.easeOut(duration: 0.2)) {
      showSkeleton = false
    }

    // Reveal content with stagger
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + staggerDelay) {
      withAnimation(AnimationEngine.gentleSpring) {
        contentOpacity = 1.0
        contentOffset = 0.0
      }
    }
  }

  private func setupImmediateContent() {
    showSkeleton = false
    contentOpacity = 1.0
    contentOffset = 0.0
  }
}

// MARK: - Number Count-Up Transition

/// Wrapper that animates number values counting up when transitioning from loading
struct NumberCountUpTransition: View {
  let value: Double
  let isLoading: Bool
  let format: FloatingPointFormatStyle<Double>.Currency

  @State private var displayValue: Double = 0.0

  var body: some View {
    PhysicsNumberCounter(
      value: displayValue,
      format: format
    )
    .onChange(of: isLoading) { _, newValue in
      if !newValue {
        animateCountUp()
      }
    }
    .onAppear {
      if !isLoading {
        displayValue = value
      }
    }
  }

  private func animateCountUp() {
    // Animate from 0 to actual value
    withAnimation(AnimationEngine.gentleSpring.delay(0.3)) {
      displayValue = value
    }
  }
}

// MARK: - Dashboard Transition Helper

/// Helper for coordinating all dashboard card transitions
struct DashboardTransitionHelper {
  static func createCoordinators(cardCount: Int) -> [LoadingTransitionCoordinator] {
    return (0..<cardCount).map { _ in
      LoadingTransitionCoordinator(isLoading: true)
    }
  }

  static func transitionAll(coordinators: [LoadingTransitionCoordinator]) {
    for (index, coordinator) in coordinators.enumerated() {
      coordinator.transitionToContent(staggerIndex: index)
    }
  }

  static func resetAll(coordinators: [LoadingTransitionCoordinator]) {
    coordinators.forEach { $0.reset() }
  }
}

// MARK: - Preview

#if DEBUG
struct LoadingTransitionCoordinator_Previews: PreviewProvider {
  static var previews: some View {
    LoadingTransitionPreview()
  }

  struct LoadingTransitionPreview: View {
    @StateObject private var coordinator1 = LoadingTransitionCoordinator()
    @StateObject private var coordinator2 = LoadingTransitionCoordinator()
    @StateObject private var coordinator3 = LoadingTransitionCoordinator()

    var body: some View {
      VStack(spacing: 20) {
        // Card 1
        StaggeredRevealCard(
          coordinator: coordinator1,
          staggerIndex: 0
        ) {
          cardContent(title: "Balance", value: "$1,234.56")
        } skeleton: {
          BalanceCardSkeleton()
        }

        // Card 2
        StaggeredRevealCard(
          coordinator: coordinator2,
          staggerIndex: 1
        ) {
          cardContent(title: "Expenses", value: "$567.89")
        } skeleton: {
          BalanceCardSkeleton()
        }

        // Card 3
        StaggeredRevealCard(
          coordinator: coordinator3,
          staggerIndex: 2
        ) {
          cardContent(title: "Income", value: "$2,345.67")
        } skeleton: {
          BalanceCardSkeleton()
        }

        Button("Toggle Loading") {
          if coordinator1.isLoading {
            coordinator1.transitionToContent(staggerIndex: 0)
            coordinator2.transitionToContent(staggerIndex: 1)
            coordinator3.transitionToContent(staggerIndex: 2)
          } else {
            coordinator1.reset()
            coordinator2.reset()
            coordinator3.reset()
          }
        }
        .padding()
      }
      .padding()
      .background(Color.oldMoney.background)
    }

    private func cardContent(title: String, value: String) -> some View {
      VStack(alignment: .leading, spacing: 12) {
        Text(title)
          .font(.headline)
        Text(value)
          .font(.title)
          .fontWeight(.bold)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(20)
      .background(Color.oldMoney.surface)
      .cornerRadius(16)
    }
  }
}
#endif
