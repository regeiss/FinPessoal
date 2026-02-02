//
//  ColorPalette.swift
//  FinPessoal
//
//  Created by Claude Code on 21/12/25.
//

import Foundation

/// Color palette states based on financial health
enum ColorPalette: String, CaseIterable {
  case warm     // 70-100% health score - positive finances
  case neutral  // 30-69% health score - moderate state
  case cool     // 0-29% health score - needs attention

  /// Get palette for a given health score (0-100)
  static func palette(for healthScore: Int) -> ColorPalette {
    switch healthScore {
    case 70...100:
      return .warm
    case 30..<70:
      return .neutral
    case 0..<30:
      return .cool
    default:
      return .neutral
    }
  }
}
