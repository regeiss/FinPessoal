// FinPessoal/Code/Animation/Components/Charts/Models/ChartBar.swift
import SwiftUI

/// Data model for bar chart bars
struct ChartBar: Identifiable, Equatable {
  let id: String
  let value: Double
  let maxValue: Double
  let label: String
  let color: Color
  let date: Date?

  // Animation state
  var height: CGFloat = 0
  var opacity: Double = 0

  static func == (lhs: ChartBar, rhs: ChartBar) -> Bool {
    lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.maxValue == rhs.maxValue
  }
}
