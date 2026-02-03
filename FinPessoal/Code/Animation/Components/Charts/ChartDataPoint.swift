import Foundation
import SwiftUI

/// Represents a single data point in a chart
struct ChartDataPoint: Identifiable, Equatable {
  let id: UUID
  let date: Date
  let value: Double
  let transactions: [Transaction]

  var position: CGPoint
  var isHighlighted: Bool

  init(
    id: UUID = UUID(),
    date: Date,
    value: Double,
    transactions: [Transaction] = [],
    position: CGPoint = .zero,
    isHighlighted: Bool = false
  ) {
    self.id = id
    self.date = date
    self.value = value
    self.transactions = transactions
    self.position = position
    self.isHighlighted = isHighlighted
  }

  static func == (lhs: ChartDataPoint, rhs: ChartDataPoint) -> Bool {
    lhs.id == rhs.id &&
    lhs.date == rhs.date &&
    lhs.value == rhs.value &&
    lhs.position == rhs.position &&
    lhs.isHighlighted == rhs.isHighlighted
  }
}

/// Data model for spending trends chart
struct SpendingTrendsData: Equatable {
  let points: [ChartDataPoint]
  let maxValue: Double
  let minValue: Double
  let dateRange: ClosedRange<Date>

  var previousPoints: [ChartDataPoint]?

  init(
    points: [ChartDataPoint],
    maxValue: Double,
    minValue: Double,
    dateRange: ClosedRange<Date>,
    previousPoints: [ChartDataPoint]? = nil
  ) {
    self.points = points
    self.maxValue = maxValue
    self.minValue = minValue
    self.dateRange = dateRange
    self.previousPoints = previousPoints
  }

  static func == (lhs: SpendingTrendsData, rhs: SpendingTrendsData) -> Bool {
    lhs.points == rhs.points &&
    lhs.maxValue == rhs.maxValue &&
    lhs.minValue == rhs.minValue &&
    lhs.dateRange == rhs.dateRange
  }
}
