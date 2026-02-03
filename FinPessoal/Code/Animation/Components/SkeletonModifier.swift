import SwiftUI

/// View modifier that overlays a skeleton loading state
struct SkeletonModifier: ViewModifier {
  let isLoading: Bool
  let cornerRadius: CGFloat
  let animated: Bool

  init(
    isLoading: Bool,
    cornerRadius: CGFloat = 8,
    animated: Bool = true
  ) {
    self.isLoading = isLoading
    self.cornerRadius = cornerRadius
    self.animated = animated
  }

  func body(content: Content) -> some View {
    content
      .opacity(isLoading ? 0 : 1)
      .overlay(
        Group {
          if isLoading {
            if animated {
              SkeletonView(cornerRadius: cornerRadius)
            } else {
              RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.oldMoney.surface)
            }
          }
        }
      )
  }
}

// MARK: - View Extension

extension View {
  /// Applies skeleton loading state to the view
  /// - Parameters:
  ///   - isLoading: Whether the skeleton should be shown
  ///   - cornerRadius: Corner radius for the skeleton overlay
  ///   - animated: Whether to animate the skeleton shimmer
  /// - Returns: Modified view with skeleton overlay when loading
  func skeleton(
    isLoading: Bool,
    cornerRadius: CGFloat = 8,
    animated: Bool = true
  ) -> some View {
    modifier(
      SkeletonModifier(
        isLoading: isLoading,
        cornerRadius: cornerRadius,
        animated: animated
      )
    )
  }

  /// Applies skeleton loading state with redacted content
  /// - Parameter isLoading: Whether the skeleton should be shown
  /// - Returns: Modified view with skeleton overlay when loading
  func skeletonRedacted(isLoading: Bool) -> some View {
    self
      .redacted(reason: isLoading ? .placeholder : [])
      .overlay(
        Group {
          if isLoading {
            SkeletonView()
          }
        }
      )
  }
}

// MARK: - Conditional Skeleton Content

/// Builder for showing either real content or skeleton placeholder
struct SkeletonContent<Content: View, Skeleton: View>: View {
  let isLoading: Bool
  let content: () -> Content
  let skeleton: () -> Skeleton

  init(
    isLoading: Bool,
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder skeleton: @escaping () -> Skeleton
  ) {
    self.isLoading = isLoading
    self.content = content
    self.skeleton = skeleton
  }

  var body: some View {
    if isLoading {
      skeleton()
    } else {
      content()
    }
  }
}

// MARK: - Skeleton Loading Container

/// Container that manages loading state and transitions
struct SkeletonLoadingContainer<Content: View, Skeleton: View>: View {
  @Binding var isLoading: Bool
  let fadeOutDuration: Double
  let staggerDelay: Double
  let content: () -> Content
  let skeleton: () -> Skeleton

  @State private var showSkeleton: Bool = true
  @State private var contentOpacity: Double = 0.0

  init(
    isLoading: Binding<Bool>,
    fadeOutDuration: Double = 0.2,
    staggerDelay: Double = 0.1,
    @ViewBuilder content: @escaping () -> Content,
    @ViewBuilder skeleton: @escaping () -> Skeleton
  ) {
    self._isLoading = isLoading
    self.fadeOutDuration = fadeOutDuration
    self.staggerDelay = staggerDelay
    self.content = content
    self.skeleton = skeleton
  }

  var body: some View {
    ZStack {
      // Content layer
      content()
        .opacity(contentOpacity)

      // Skeleton layer
      if showSkeleton {
        skeleton()
          .transition(.opacity)
      }
    }
    .onChange(of: isLoading) { newValue in
      if !newValue {
        animateToContent()
      }
    }
    .onAppear {
      if !isLoading {
        showSkeleton = false
        contentOpacity = 1.0
      }
    }
  }

  private func animateToContent() {
    // Fade out skeleton
    withAnimation(.easeOut(duration: fadeOutDuration)) {
      showSkeleton = false
    }

    // Fade in and slide up content with stagger
    withAnimation(
      AnimationEngine.gentleSpring
        .delay(fadeOutDuration + staggerDelay)
    ) {
      contentOpacity = 1.0
    }
  }
}

// MARK: - Preview

#if DEBUG
struct SkeletonModifier_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 30) {
      // Simple modifier example
      Text("Hello, World!")
        .font(.headline)
        .padding()
        .background(Color.oldMoney.surface)
        .cornerRadius(8)
        .skeleton(isLoading: true)

      // Skeleton content builder
      SkeletonContent(isLoading: true) {
        VStack(alignment: .leading, spacing: 8) {
          Text("User Name")
            .font(.headline)
          Text("user@example.com")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
      } skeleton: {
        VStack(alignment: .leading, spacing: 8) {
          SkeletonView.textLine(width: 120, height: 20)
          SkeletonView.textLine(width: 180, height: 16)
        }
        .padding()
      }

      // Loading container with transition
      SkeletonLoadingContainerPreview()
    }
    .padding()
    .background(Color.oldMoney.background)
  }

  struct SkeletonLoadingContainerPreview: View {
    @State private var isLoading = true

    var body: some View {
      VStack {
        SkeletonLoadingContainer(
          isLoading: $isLoading,
          fadeOutDuration: 0.2,
          staggerDelay: 0.1
        ) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Loaded Content")
              .font(.title2)
              .fontWeight(.bold)
            Text("This content appears after loading completes")
              .font(.body)
              .foregroundColor(.secondary)
          }
          .padding()
          .background(Color.oldMoney.surface)
          .cornerRadius(12)
        } skeleton: {
          VStack(alignment: .leading, spacing: 12) {
            SkeletonView.textLine(width: 180, height: 24)
            SkeletonView.textLine(width: 250, height: 16)
          }
          .padding()
          .background(Color.oldMoney.surface)
          .cornerRadius(12)
        }

        Button("Toggle Loading") {
          isLoading.toggle()
        }
        .padding(.top)
      }
    }
  }
}
#endif
