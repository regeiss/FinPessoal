import SwiftUI

/// Reusable skeleton placeholder with animated shimmer effect
struct SkeletonView: View {
  // MARK: - Properties

  @Environment(\.colorScheme) private var colorScheme
  @State private var shimmerOffset: CGFloat = -1.0

  private let animationSettings = AnimationSettings.shared

  // Configuration
  let cornerRadius: CGFloat
  let height: CGFloat?

  // MARK: - Initialization

  init(
    cornerRadius: CGFloat = 8,
    height: CGFloat? = nil
  ) {
    self.cornerRadius = cornerRadius
    self.height = height
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      RoundedRectangle(cornerRadius: cornerRadius)
        .fill(baseColor)
        .overlay(
          shimmerOverlay(width: geometry.size.width)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    .frame(height: height)
    .onAppear {
      startShimmerAnimation()
    }
  }

  // MARK: - Shimmer Animation

  @ViewBuilder
  private func shimmerOverlay(width: CGFloat) -> some View {
    switch animationSettings.effectiveMode {
    case .full:
      fullShimmerEffect(width: width)
    case .reduced:
      reducedPulseEffect
    case .minimal:
      EmptyView()
    }
  }

  private func fullShimmerEffect(width: CGFloat) -> some View {
    TimelineView(.animation(minimumInterval: 1.0 / 120.0)) { timeline in
      LinearGradient(
        colors: shimmerColors,
        startPoint: .leading,
        endPoint: .trailing
      )
      .frame(width: width * 2)
      .offset(x: shimmerOffset * width)
    }
  }

  private var reducedPulseEffect: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(accentColor.opacity(0.1))
      .opacity(shimmerOffset > 0 ? 0.5 : 1.0)
  }

  private func startShimmerAnimation() {
    switch animationSettings.effectiveMode {
    case .full:
      startFullShimmer()
    case .reduced:
      startReducedPulse()
    case .minimal:
      break
    }
  }

  private func startFullShimmer() {
    withAnimation(
      .easeInOut(duration: 1.5)
      .repeatForever(autoreverses: false)
    ) {
      shimmerOffset = 1.0
    }
  }

  private func startReducedPulse() {
    withAnimation(
      .easeInOut(duration: 1.0)
      .repeatForever(autoreverses: true)
    ) {
      shimmerOffset = 1.0
    }
  }

  // MARK: - Colors

  private var baseColor: Color {
    colorScheme == .dark
      ? Color.oldMoney.surface.opacity(0.3)
      : Color.oldMoney.surface
  }

  private var accentColor: Color {
    colorScheme == .dark
      ? Color.oldMoney.divider.opacity(0.5)
      : Color.oldMoney.divider
  }

  private var shimmerColors: [Color] {
    let accent = accentColor
    return [
      baseColor,
      accent,
      baseColor
    ]
  }
}

// MARK: - Skeleton Shapes

extension SkeletonView {
  /// Creates a rectangular skeleton placeholder
  static func rectangle(
    width: CGFloat? = nil,
    height: CGFloat,
    cornerRadius: CGFloat = 8
  ) -> some View {
    SkeletonView(cornerRadius: cornerRadius, height: height)
      .frame(width: width)
  }

  /// Creates a circular skeleton placeholder
  static func circle(diameter: CGFloat) -> some View {
    SkeletonView(cornerRadius: diameter / 2, height: diameter)
      .frame(width: diameter)
  }

  /// Creates a text-line skeleton placeholder
  static func textLine(
    width: CGFloat? = nil,
    height: CGFloat = 16,
    cornerRadius: CGFloat = 4
  ) -> some View {
    SkeletonView(cornerRadius: cornerRadius, height: height)
      .frame(width: width)
  }
}

// MARK: - Staggered Skeleton Group

/// Container for multiple skeleton elements with staggered animation
struct StaggeredSkeletonGroup<Content: View>: View {
  let staggerDelay: Double
  let content: () -> Content

  @State private var isVisible: Bool = false

  init(
    staggerDelay: Double = 0.05,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.staggerDelay = staggerDelay
    self.content = content
  }

  var body: some View {
    content()
      .opacity(isVisible ? 1.0 : 0.0)
      .onAppear {
        withAnimation(.easeIn(duration: 0.2).delay(staggerDelay)) {
          isVisible = true
        }
      }
  }
}

// MARK: - Preview

#if DEBUG
struct SkeletonView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 20) {
      // Text line skeletons
      VStack(alignment: .leading, spacing: 8) {
        SkeletonView.textLine(width: 200, height: 20)
        SkeletonView.textLine(width: 150, height: 16)
        SkeletonView.textLine(width: 180, height: 16)
      }

      Divider()

      // Card skeleton
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          SkeletonView.circle(diameter: 40)
          VStack(alignment: .leading, spacing: 6) {
            SkeletonView.textLine(width: 120, height: 16)
            SkeletonView.textLine(width: 80, height: 14)
          }
        }

        SkeletonView.rectangle(height: 100, cornerRadius: 12)
      }
      .padding()
      .background(Color.oldMoney.surface)
      .cornerRadius(16)

      Divider()

      // Staggered group example
      VStack(spacing: 8) {
        ForEach(0..<3, id: \.self) { index in
          StaggeredSkeletonGroup(staggerDelay: Double(index) * 0.05) {
            HStack {
              SkeletonView.circle(diameter: 30)
              VStack(alignment: .leading, spacing: 4) {
                SkeletonView.textLine(width: 150, height: 14)
                SkeletonView.textLine(width: 100, height: 12)
              }
              Spacer()
            }
            .padding()
            .background(Color.oldMoney.surface)
            .cornerRadius(8)
          }
        }
      }
    }
    .padding()
    .background(Color.oldMoney.background)
    .preferredColorScheme(.light)
    .previewDisplayName("Light Mode")

    VStack(spacing: 20) {
      SkeletonView.textLine(width: 200, height: 20)
      SkeletonView.rectangle(height: 100, cornerRadius: 12)
      SkeletonView.circle(diameter: 60)
    }
    .padding()
    .background(Color.oldMoney.background)
    .preferredColorScheme(.dark)
    .previewDisplayName("Dark Mode")
  }
}
#endif
