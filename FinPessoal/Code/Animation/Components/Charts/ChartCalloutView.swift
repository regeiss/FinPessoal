// FinPessoal/Code/Animation/Components/Charts/ChartCalloutView.swift
import SwiftUI

/// Floating callout displayed when chart element is selected
struct ChartCalloutView: View {
  let segment: ChartSegment?
  let bar: ChartBar?

  @State private var animationMode: AnimationMode = AnimationSettings.shared.effectiveMode

  init(segment: ChartSegment) {
    self.segment = segment
    self.bar = nil
  }

  init(bar: ChartBar) {
    self.segment = nil
    self.bar = bar
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let segment = segment {
        Text(segment.label)
          .font(.caption)
          .fontWeight(.semibold)
          .minimumScaleFactor(0.8)

        HStack(spacing: 8) {
          Text("\(segment.percentage, specifier: "%.1f")%")
            .font(.caption2)
            .minimumScaleFactor(0.8)

          Text(segment.value.formatted(.currency(code: "USD")))
            .font(.caption2)
            .foregroundStyle(.secondary)
            .minimumScaleFactor(0.8)
        }
      } else if let bar = bar {
        Text(bar.label)
          .font(.caption)
          .fontWeight(.semibold)
          .minimumScaleFactor(0.8)

        Text(bar.value.formatted(.currency(code: "USD")))
          .font(.caption2)
          .foregroundStyle(.secondary)
          .minimumScaleFactor(0.8)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.oldMoney.accent, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8)
    )
    .transition(.asymmetric(
      insertion: .opacity.combined(with: .offset(y: -10)),
      removal: .opacity
    ))
    .animation(
      animationMode == .full ? AnimationEngine.quickFade : .linear(duration: 0.1),
      value: segment != nil || bar != nil
    )
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    .accessibilityHidden(true)
  }
}

#Preview("Segment Callout") {
  ChartCalloutView(
    segment: ChartSegment(
      id: "food",
      value: 500,
      percentage: 25,
      label: "Food & Dining",
      color: .blue,
      category: nil
    )
  )
  .padding()
}

#Preview("Bar Callout") {
  ChartCalloutView(
    bar: ChartBar(
      id: "jan",
      value: 1500,
      maxValue: 2000,
      label: "January",
      color: .green,
      date: nil
    )
  )
  .padding()
}
