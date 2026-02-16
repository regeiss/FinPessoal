// FinPessoal/Code/Animation/Components/Charts/Models/ChartSegment.swift
import SwiftUI

/// Data model for pie/donut chart segments
struct ChartSegment: Identifiable, Equatable {
  let id: String
  let value: Double
  let percentage: Double
  let label: String
  let color: Color
  let category: Category?

  // Animation state
  var trimEnd: Double = 0
  var scale: CGFloat = 1.0
  var opacity: Double = 1.0

  static func == (lhs: ChartSegment, rhs: ChartSegment) -> Bool {
    lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.percentage == rhs.percentage
  }
}
