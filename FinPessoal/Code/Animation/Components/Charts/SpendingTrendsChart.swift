import SwiftUI

/// Line chart showing spending trends over time with animated drawing
struct SpendingTrendsChart: View, AnimatedChart {
  typealias DataType = SpendingTrendsData

  // MARK: - Properties

  let data: SpendingTrendsData
  @State var animationProgress: Double = 0.0
  @State private var interactionState: ChartInteractionState = .idle
  @State private var highlightedPoint: ChartDataPoint?

  private let chartHeight: CGFloat = 200
  private let horizontalPadding: CGFloat = 16
  private let verticalPadding: CGFloat = 20

  var isInteractive: Bool {
    switch interactionState {
    case .idle:
      return false
    default:
      return true
    }
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        // Chart canvas with drawing
        Canvas { context, size in
          draw(in: context, size: size)
        }
        .drawingGroup() // Enable Metal acceleration
        .frame(height: chartHeight)

        // Interactive overlay for gestures
        chartGestureOverlay(size: geometry.size)

        // Callout for highlighted point
        if let point = highlightedPoint {
          calloutView(for: point, in: geometry.size)
        }
      }
    }
    .frame(height: chartHeight + verticalPadding * 2)
    .onAppear {
      animateEntry()
    }
  }

  // MARK: - Chart Drawing

  func draw(in context: GraphicsContext, size: CGSize) {
    guard !data.points.isEmpty else { return }

    let chartSize = CGSize(
      width: size.width - horizontalPadding * 2,
      height: chartHeight - verticalPadding * 2
    )
    let origin = CGPoint(x: horizontalPadding, y: verticalPadding)

    // Calculate data point positions if not already set
    let points = calculatePointPositions(
      data: data.points,
      in: chartSize,
      origin: origin
    )

    // Draw grid lines
    drawGrid(in: context, size: chartSize, origin: origin)

    // Draw axes
    drawAxes(in: context, size: chartSize, origin: origin)

    // Draw gradient fill beneath line
    if animationProgress > 0 {
      drawGradientFill(
        in: context,
        points: points,
        size: chartSize,
        origin: origin
      )
    }

    // Draw line path with trim animation
    drawLinePath(
      in: context,
      points: points,
      size: chartSize,
      origin: origin
    )

    // Draw data points
    if animationProgress > 0.5 {
      drawDataPoints(in: context, points: points)
    }

    // Draw axis labels
    drawAxisLabels(in: context, size: chartSize, origin: origin)
  }

  private func calculatePointPositions(
    data points: [ChartDataPoint],
    in size: CGSize,
    origin: CGPoint
  ) -> [ChartDataPoint] {
    guard !points.isEmpty else { return [] }

    let xStep = size.width / CGFloat(max(points.count - 1, 1))
    let valueRange = data.maxValue - data.minValue
    let yScale = valueRange > 0 ? size.height / CGFloat(valueRange) : 0

    return points.enumerated().map { index, point in
      var updatedPoint = point
      let x = origin.x + CGFloat(index) * xStep
      let y = origin.y + size.height - CGFloat(point.value - data.minValue) * yScale
      updatedPoint.position = CGPoint(x: x, y: y)
      return updatedPoint
    }
  }

  private func drawGrid(
    in context: GraphicsContext,
    size: CGSize,
    origin: CGPoint
  ) {
    let gridColor = Color.oldMoney.divider.opacity(0.3)
    let gridLineCount = 5

    for i in 0...gridLineCount {
      let y = origin.y + (size.height / CGFloat(gridLineCount)) * CGFloat(i)
      var path = Path()
      path.move(to: CGPoint(x: origin.x, y: y))
      path.addLine(to: CGPoint(x: origin.x + size.width, y: y))

      context.stroke(
        path,
        with: .color(gridColor),
        lineWidth: 0.5
      )
    }
  }

  private func drawAxes(
    in context: GraphicsContext,
    size: CGSize,
    origin: CGPoint
  ) {
    let axisColor = Color.oldMoney.text.opacity(0.3)
    var path = Path()

    // Y-axis
    path.move(to: origin)
    path.addLine(to: CGPoint(x: origin.x, y: origin.y + size.height))

    // X-axis
    path.move(to: CGPoint(x: origin.x, y: origin.y + size.height))
    path.addLine(to: CGPoint(x: origin.x + size.width, y: origin.y + size.height))

    context.stroke(
      path,
      with: .color(axisColor),
      lineWidth: 1.0
    )
  }

  private func drawLinePath(
    in context: GraphicsContext,
    points: [ChartDataPoint],
    size: CGSize,
    origin: CGPoint
  ) {
    guard points.count >= 2 else { return }

    var path = Path()
    path.move(to: points[0].position)

    for i in 1..<points.count {
      path.addLine(to: points[i].position)
    }

    // Trim the path based on animation progress
    let trimmedPath = path.trimmedPath(from: 0, to: animationProgress)

    context.stroke(
      trimmedPath,
      with: .color(.oldMoney.accent),
      style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round)
    )
  }

  private func drawGradientFill(
    in context: GraphicsContext,
    points: [ChartDataPoint],
    size: CGSize,
    origin: CGPoint
  ) {
    guard points.count >= 2 else { return }

    // Create filled path with gradient
    var path = Path()
    path.move(to: points[0].position)

    for i in 1..<points.count {
      path.addLine(to: points[i].position)
    }

    // Close the path to the bottom
    let lastPoint = points[points.count - 1]
    path.addLine(to: CGPoint(x: lastPoint.position.x, y: origin.y + size.height))
    path.addLine(to: CGPoint(x: points[0].position.x, y: origin.y + size.height))
    path.closeSubpath()

    // Trim based on animation progress
    let trimmedPath = path.trimmedPath(from: 0, to: animationProgress)

    let gradient = Gradient(colors: [
      Color.oldMoney.accent.opacity(0.3),
      Color.oldMoney.accent.opacity(0.05)
    ])

    context.fill(
      trimmedPath,
      with: .linearGradient(
        gradient,
        startPoint: CGPoint(x: 0, y: origin.y),
        endPoint: CGPoint(x: 0, y: origin.y + size.height)
      )
    )
  }

  private func drawDataPoints(
    in context: GraphicsContext,
    points: [ChartDataPoint]
  ) {
    for (index, point) in points.enumerated() {
      // Only draw points that have been revealed by animation
      let pointProgress = CGFloat(index) / CGFloat(max(points.count - 1, 1))
      guard pointProgress <= animationProgress else { continue }

      let isHighlighted = point.isHighlighted || point.id == highlightedPoint?.id
      let radius: CGFloat = isHighlighted ? 6.0 : 4.0
      let color: Color = isHighlighted ? .oldMoney.accent : .oldMoney.surface

      // Draw outer glow for highlighted point
      if isHighlighted {
        context.fill(
          Circle().path(in: CGRect(
            x: point.position.x - radius - 2,
            y: point.position.y - radius - 2,
            width: (radius + 2) * 2,
            height: (radius + 2) * 2
          )),
          with: .color(.oldMoney.accent.opacity(0.3))
        )
      }

      // Draw point
      context.fill(
        Circle().path(in: CGRect(
          x: point.position.x - radius,
          y: point.position.y - radius,
          width: radius * 2,
          height: radius * 2
        )),
        with: .color(color)
      )

      // Draw border
      context.stroke(
        Circle().path(in: CGRect(
          x: point.position.x - radius,
          y: point.position.y - radius,
          width: radius * 2,
          height: radius * 2
        )),
        with: .color(.oldMoney.accent),
        lineWidth: isHighlighted ? 3.0 : 2.0
      )
    }
  }

  private func drawAxisLabels(
    in context: GraphicsContext,
    size: CGSize,
    origin: CGPoint
  ) {
    // Y-axis labels (values)
    let labelCount = 5
    for i in 0...labelCount {
      let value = data.minValue + (data.maxValue - data.minValue) * (Double(i) / Double(labelCount))
      let y = origin.y + size.height - (size.height / CGFloat(labelCount)) * CGFloat(i)

      let text = Text(formatCurrency(value))
        .font(.caption2)
        .foregroundColor(.oldMoney.text.opacity(0.6))

      context.draw(
        text,
        at: CGPoint(x: origin.x - 8, y: y),
        anchor: .trailing
      )
    }
  }

  // MARK: - Gesture Handling

  private func chartGestureOverlay(size: CGSize) -> some View {
    Color.clear
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            handleDragGesture(at: value.location, in: size)
          }
          .onEnded { _ in
            handleGestureEnd()
          }
      )
      .simultaneousGesture(
        TapGesture()
          .onEnded { _ in
            handleTap()
          }
      )
  }

  private func handleDragGesture(at location: CGPoint, in size: CGSize) {
    let chartSize = CGSize(
      width: size.width - horizontalPadding * 2,
      height: chartHeight - verticalPadding * 2
    )
    let origin = CGPoint(x: horizontalPadding, y: verticalPadding)

    let points = calculatePointPositions(
      data: data.points,
      in: chartSize,
      origin: origin
    )

    // Find nearest point
    if let nearest = findNearestPoint(to: location, in: points) {
      if highlightedPoint?.id != nearest.id {
        highlightedPoint = nearest
        HapticEngine.shared.light()
      }
      interactionState = .dragging(point: nearest)
    }
  }

  private func handleGestureEnd() {
    highlightedPoint = nil
    interactionState = .idle
  }

  private func handleTap() {
    if let point = highlightedPoint {
      HapticEngine.shared.medium()

      // Trigger particle burst in full animation mode
      if AnimationSettings.shared.effectiveMode == .full {
        // Particle emission would be handled by parent view
      }

      interactionState = .tapped(point: point)
    }
  }

  func handleGesture(at location: CGPoint) -> Any? {
    // Implementation for protocol conformance
    return highlightedPoint
  }

  private func findNearestPoint(
    to location: CGPoint,
    in points: [ChartDataPoint]
  ) -> ChartDataPoint? {
    guard !points.isEmpty else { return nil }

    let nearest = points.min(by: { point1, point2 in
      let dist1 = hypot(point1.position.x - location.x, point1.position.y - location.y)
      let dist2 = hypot(point2.position.x - location.x, point2.position.y - location.y)
      return dist1 < dist2
    })

    // Only return if within reasonable distance (50 points)
    if let nearest = nearest {
      let distance = hypot(nearest.position.x - location.x, nearest.position.y - location.y)
      return distance < 50 ? nearest : nil
    }

    return nil
  }

  // MARK: - Callout View

  private func calloutView(for point: ChartDataPoint, in size: CGSize) -> some View {
    VStack(spacing: 4) {
      Text(formatDate(point.date))
        .font(.caption)
        .foregroundColor(.oldMoney.text.opacity(0.8))

      PhysicsNumberCounter(
        value: point.value,
        format: .currency(code: Locale.current.currency?.identifier ?? "BRL")
      )
      .font(.headline)
      .foregroundColor(.oldMoney.accent)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.oldMoney.surface)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    )
    .position(
      x: clamp(point.position.x, min: 60, max: size.width - 60),
      y: max(point.position.y - 40, 30)
    )
  }

  // MARK: - Animation

  private func animateEntry() {
    guard shouldAnimate else {
      animationProgress = 1.0
      return
    }

    withAnimation(AnimationEngine.gentleSpring.delay(0.3)) {
      animationProgress = 1.0
    }
  }

  func update(with newData: SpendingTrendsData) {
    // Implement smooth transition when data updates
    guard shouldAnimate else {
      return
    }

    withAnimation(AnimationEngine.gentleSpring) {
      // Data update would trigger view refresh
    }
  }

  // MARK: - Helpers

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = .current
    formatter.maximumFractionDigits = 0
    let fallback = value.formatted(.currency(
      code: Locale.current.currency?.identifier ?? "BRL"
    ))
    return formatter.string(from: NSNumber(value: value)) ?? fallback
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMd", options: 0, locale: .current)
    formatter.locale = .current
    return formatter.string(from: date)
  }

  private func clamp<T: Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
    return Swift.min(Swift.max(value, minValue), maxValue)
  }
}

// MARK: - Preview

#if DEBUG
struct SpendingTrendsChart_Previews: PreviewProvider {
  static var previews: some View {
    let sampleData = SpendingTrendsData(
      points: (0..<7).map { i in
        ChartDataPoint(
          date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
          value: Double.random(in: 50...300),
          transactions: []
        )
      }.reversed(),
      maxValue: 300,
      minValue: 50,
      dateRange: Date()...Date()
    )

    return VStack {
      AnimatedCard {
        SpendingTrendsChart(data: sampleData)
          .padding()
      }
      .padding()
    }
    .background(Color.oldMoney.background)
  }
}
#endif
