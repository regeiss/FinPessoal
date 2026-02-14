// FinPessoal/Code/Animation/Components/Charts/PieDonutChart.swift
import SwiftUI

/// Canvas-based pie/donut chart with animations
struct PieDonutChart: View {

  // MARK: - Style

  enum PieChartStyle: Equatable {
    case pie
    case donut(innerRadius: CGFloat)
  }

  // MARK: - Models

  struct SegmentAngles {
    let start: Double
    let end: Double
  }

  // MARK: - Properties

  let segments: [ChartSegment]
  let style: PieChartStyle

  @StateObject private var gestureHandler = ChartGestureHandler()
  @State private var animatedSegments: [ChartSegment] = []
  @State private var animationMode: AnimationMode = AnimationSettings.shared.effectiveMode

  // MARK: - Init

  init(segments: [ChartSegment], style: PieChartStyle = .donut(innerRadius: 0.5)) {
    self.segments = segments
    self.style = style
    _animatedSegments = State(initialValue: segments.map { seg in
      var s = seg
      s.trimEnd = 0
      s.scale = 1.0
      s.opacity = 1.0
      return s
    })
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
      let radius = size / 2
      let angles = Self.calculateAngles(for: animatedSegments)

      ZStack {
        // Canvas for pie/donut chart
        Canvas { context, canvasSize in
          for (index, segment) in animatedSegments.enumerated() {
            guard index < angles.count else { continue }

            let angle = angles[index]
            let isSelected = gestureHandler.selectedID == segment.id
            let segmentScale = isSelected ? AnimationEngine.selectionScale : segment.scale

            // Calculate paths
            let outerRadius = radius * segmentScale
            let innerRadius: CGFloat = {
              switch style {
              case .pie:
                return 0
              case .donut(let ratio):
                return radius * ratio
              }
            }()

            // Draw segment
            var path = Path()

            // Start at center (for pie) or inner radius (for donut)
            if case .pie = style {
              path.move(to: center)
            } else {
              let innerStartX = center.x + innerRadius * cos(angle.start * .pi / 180)
              let innerStartY = center.y + innerRadius * sin(angle.start * .pi / 180)
              path.move(to: CGPoint(x: innerStartX, y: innerStartY))
            }

            // Outer arc with trim
            let trimmedEnd = angle.start + ((angle.end - angle.start) * segment.trimEnd)
            path.addArc(
              center: center,
              radius: outerRadius,
              startAngle: .degrees(angle.start),
              endAngle: .degrees(trimmedEnd),
              clockwise: false
            )

            // Close path
            if case .donut = style {
              // Inner arc (reverse direction)
              path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: .degrees(trimmedEnd),
                endAngle: .degrees(angle.start),
                clockwise: true
              )
            }

            path.closeSubpath()

            // Fill segment with opacity
            context.fill(
              path,
              with: .color(segment.color.opacity(segment.opacity))
            )
          }
        }

        // Callout for selected segment
        if let selectedID = gestureHandler.selectedID,
           let selectedSegment = animatedSegments.first(where: { $0.id == selectedID }) {
          VStack {
            ChartCalloutView(segment: selectedSegment)
              .padding(.top, 16)
            Spacer()
          }
        }
      }
      .contentShape(Rectangle())
      .onTapGesture { location in
        handleTap(at: location, in: geometry, center: center, radius: radius, angles: angles)
      }
    }
    .onAppear {
      animateReveal()
    }
    .onChange(of: segments) { oldValue, newValue in
      animateDataChange()
    }
    .onChange(of: gestureHandler.selectedID) { oldValue, newValue in
      animateSelection(oldID: oldValue, newID: newValue)
    }
  }

  // MARK: - Hit Testing

  private func handleTap(
    at location: CGPoint,
    in geometry: GeometryProxy,
    center: CGPoint,
    radius: CGFloat,
    angles: [SegmentAngles]
  ) {
    // Calculate distance from center
    let dx = location.x - center.x
    let dy = location.y - center.y
    let distance = sqrt(dx * dx + dy * dy)

    // Check if within chart bounds
    let innerRadius: CGFloat = {
      switch style {
      case .pie:
        return 0
      case .donut(let ratio):
        return radius * ratio
      }
    }()

    guard distance >= innerRadius && distance <= radius else {
      gestureHandler.handleTap(segmentID: "")
      return
    }

    // Calculate angle (adjust for -90° start)
    var angle = atan2(dy, dx) * 180 / .pi
    if angle < -90 {
      angle += 360
    }

    // Find tapped segment
    for (index, segmentAngle) in angles.enumerated() {
      guard index < animatedSegments.count else { continue }

      let normalizedStart = segmentAngle.start
      var normalizedEnd = segmentAngle.end

      // Handle wrap-around
      if normalizedEnd < normalizedStart {
        normalizedEnd += 360
      }

      if angle >= normalizedStart && angle <= normalizedEnd {
        gestureHandler.handleTap(segmentID: animatedSegments[index].id)
        return
      }
    }

    // No segment found, deselect
    gestureHandler.handleTap(segmentID: "")
  }

  // MARK: - Angle Calculation

  static func calculateAngles(for segments: [ChartSegment]) -> [SegmentAngles] {
    var angles: [SegmentAngles] = []
    var currentAngle: Double = -90 // Start at top

    for segment in segments {
      let sweepAngle = (segment.percentage / 100.0) * 360.0
      let startAngle = currentAngle
      let endAngle = currentAngle + sweepAngle

      angles.append(SegmentAngles(start: startAngle, end: endAngle))
      currentAngle = endAngle
    }

    return angles
  }

  // MARK: - Animations

  private func animateReveal() {
    for (index, _) in segments.enumerated() {
      let delay = 0.3 + (Double(index) * AnimationEngine.standardStagger)

      withAnimation(AnimationEngine.chartReveal(delay: delay)) {
        animatedSegments[index].trimEnd = 1.0
      }
    }
  }

  private func animateDataChange() {
    // Fade out
    withAnimation(.easeOut(duration: 0.15)) {
      for index in animatedSegments.indices {
        animatedSegments[index].opacity = 0
      }
    }

    // Update segments after fade
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      animatedSegments = segments.map { seg in
        var s = seg
        s.trimEnd = 1.0
        s.scale = 1.0
        s.opacity = 0
        return s
      }

      // Fade in with morph animation
      withAnimation(AnimationEngine.chartMorph) {
        for index in animatedSegments.indices {
          animatedSegments[index].opacity = 1.0
        }
      }
    }
  }

  private func animateSelection(oldID: String?, newID: String?) {
    // Reset old selection
    if let oldID = oldID,
       let oldIndex = animatedSegments.firstIndex(where: { $0.id == oldID }) {
      withAnimation(AnimationEngine.chartSelection) {
        animatedSegments[oldIndex].scale = 1.0
      }
    }

    // Animate new selection
    if let newID = newID,
       let newIndex = animatedSegments.firstIndex(where: { $0.id == newID }) {
      withAnimation(AnimationEngine.chartSelection) {
        animatedSegments[newIndex].scale = 1.0 // Scale is applied in rendering
      }
    }
  }
}

// MARK: - Previews

#Preview("Donut Chart - 4 Segments") {
  PieDonutChart(
    segments: [
      ChartSegment(
        id: "food",
        value: 800,
        percentage: 40,
        label: "Food & Dining",
        color: .blue,
        category: nil
      ),
      ChartSegment(
        id: "transport",
        value: 600,
        percentage: 30,
        label: "Transportation",
        color: .green,
        category: nil
      ),
      ChartSegment(
        id: "entertainment",
        value: 400,
        percentage: 20,
        label: "Entertainment",
        color: .orange,
        category: nil
      ),
      ChartSegment(
        id: "other",
        value: 200,
        percentage: 10,
        label: "Other",
        color: .purple,
        category: nil
      )
    ],
    style: .donut(innerRadius: 0.5)
  )
  .frame(width: 300, height: 300)
  .padding()
}

#Preview("Pie Chart - 2 Segments") {
  PieDonutChart(
    segments: [
      ChartSegment(
        id: "income",
        value: 5000,
        percentage: 50,
        label: "Income",
        color: .green,
        category: nil
      ),
      ChartSegment(
        id: "expenses",
        value: 5000,
        percentage: 50,
        label: "Expenses",
        color: .red,
        category: nil
      )
    ],
    style: .pie
  )
  .frame(width: 300, height: 300)
  .padding()
}
