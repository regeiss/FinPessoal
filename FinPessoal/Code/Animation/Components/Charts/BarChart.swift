// FinPessoal/Code/Animation/Components/Charts/BarChart.swift
import SwiftUI

/// Vertical bar chart with animated heights and selection support
struct BarChart: View {
  let bars: [ChartBar]
  let maxHeight: CGFloat

  @StateObject private var gestureHandler = ChartGestureHandler()
  @State private var animatedBars: [ChartBar]
  @State private var animationTask: Task<Void, Never>?
  @ObservedObject private var animationSettings = AnimationSettings.shared
  @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

  init(bars: [ChartBar], maxHeight: CGFloat = 200) {
    self.bars = bars
    self.maxHeight = maxHeight
    _animatedBars = State(initialValue: bars)
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 12) {
      ForEach(animatedBars) { bar in
        barView(for: bar)
      }
    }
    .onAppear {
      animateReveal()
    }
    .onChange(of: bars) { _, newBars in
      animateDataChange(to: newBars)
    }
    .onDisappear {
      animationTask?.cancel()
    }
  }

  // MARK: - Bar View

  private func barView(for bar: ChartBar) -> some View {
    let isSelected = gestureHandler.selectedID == bar.id
    let calculatedHeight = Self.calculateHeight(for: bar, maxHeight: maxHeight)

    return VStack(spacing: 4) {
      // Callout
      if isSelected {
        ChartCalloutView(bar: bar)
          .transition(.asymmetric(
            insertion: .opacity.combined(with: .offset(y: -10)),
            removal: .opacity
          ))
      }

      // Bar
      RoundedRectangle(cornerRadius: 8)
        .fill(bar.color)
        .frame(width: 40, height: bar.height)
        .opacity(bar.opacity)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(.primary, lineWidth: differentiateWithoutColor ? 3.0 : 0)
        )
        .scaleEffect(
          x: 1.0,
          y: isSelected ? AnimationEngine.selectionScale : 1.0,
          anchor: .bottom
        )
        .animation(AnimationEngine.chartSelection, value: isSelected)
        .onTapGesture {
          gestureHandler.handleTap(segmentID: bar.id)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bar.label)
        .accessibilityValue(bar.value.formatted(.currency(code: "USD")))
        .accessibilityHint("Double tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])

      // Label
      Text(bar.label)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(width: 40)
    }
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
  }

  // MARK: - Animations

  private func animateReveal() {
    animationTask?.cancel()
    animationTask = Task { @MainActor in
      // Initial delay
      try? await Task.sleep(nanoseconds: UInt64(AnimationEngine.chartInitialDelay * 1_000_000_000))

      if Task.isCancelled { return }

      // Animate each bar with stagger
      for (index, var bar) in animatedBars.enumerated() {
        if Task.isCancelled { return }

        let delay = Double(index) * AnimationEngine.standardStagger
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if Task.isCancelled { return }

        // Calculate target height
        let targetHeight = Self.calculateHeight(for: bar, maxHeight: maxHeight)

        // Animate height and opacity
        withAnimation(AnimationEngine.chartReveal(delay: 0)) {
          if let idx = animatedBars.firstIndex(where: { $0.id == bar.id }) {
            animatedBars[idx].height = targetHeight
            animatedBars[idx].opacity = 1.0
          }
        }
      }
    }
  }

  private func animateDataChange(to newBars: [ChartBar]) {
    animationTask?.cancel()
    animationTask = Task { @MainActor in
      // Fade out
      withAnimation(.linear(duration: AnimationEngine.chartFadeDuration)) {
        for index in animatedBars.indices {
          animatedBars[index].opacity = 0
        }
      }

      try? await Task.sleep(nanoseconds: UInt64(AnimationEngine.chartFadeDuration * 1_000_000_000))

      if Task.isCancelled { return }

      // Update bars
      animatedBars = newBars

      // Fade in with new heights
      for (index, var bar) in animatedBars.enumerated() {
        if Task.isCancelled { return }

        let targetHeight = Self.calculateHeight(for: bar, maxHeight: maxHeight)

        withAnimation(AnimationEngine.chartMorph) {
          if let idx = animatedBars.firstIndex(where: { $0.id == bar.id }) {
            animatedBars[idx].height = targetHeight
            animatedBars[idx].opacity = 1.0
          }
        }
      }
    }
  }

  // MARK: - Height Calculation

  static func calculateHeight(for bar: ChartBar, maxHeight: CGFloat) -> CGFloat {
    guard bar.maxValue > 0 else { return 0 }
    let ratio = bar.value / bar.maxValue
    return CGFloat(ratio) * maxHeight
  }
}

// MARK: - Preview

#Preview("Bar Chart") {
  VStack {
    BarChart(
      bars: [
        ChartBar(
          id: "jan",
          value: 1500,
          maxValue: 2000,
          label: "Jan",
          color: .blue,
          date: nil
        ),
        ChartBar(
          id: "feb",
          value: 1800,
          maxValue: 2000,
          label: "Feb",
          color: .blue,
          date: nil
        ),
        ChartBar(
          id: "mar",
          value: 1200,
          maxValue: 2000,
          label: "Mar",
          color: .blue,
          date: nil
        ),
        ChartBar(
          id: "apr",
          value: 2000,
          maxValue: 2000,
          label: "Apr",
          color: .blue,
          date: nil
        ),
        ChartBar(
          id: "may",
          value: 900,
          maxValue: 2000,
          label: "May",
          color: .blue,
          date: nil
        ),
        ChartBar(
          id: "jun",
          value: 1600,
          maxValue: 2000,
          label: "Jun",
          color: .blue,
          date: nil
        )
      ],
      maxHeight: 200
    )
    .padding()
  }
}
