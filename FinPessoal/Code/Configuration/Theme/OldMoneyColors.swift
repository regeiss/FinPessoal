//
//  OldMoneyColors.swift
//  FinPessoal
//
//  Created by Claude Code on 18/12/25.
//

import SwiftUI

/// Old Money color palette - Minimal & Refined aesthetic
/// Understated elegance with muted grays, subtle gold, and cream tones
struct OldMoneyColors {

  // MARK: - Base Colors (Light Mode)

  struct Light {
    /// Primary background - #FAF8F5
    static let ivory = Color(red: 250/255, green: 248/255, blue: 245/255)

    /// Card/surface backgrounds - #F5F2EC
    static let cream = Color(red: 245/255, green: 242/255, blue: 236/255)

    /// Dividers, subtle borders - #E8E4DD
    static let warmGray = Color(red: 232/255, green: 228/255, blue: 221/255)

    /// Secondary text, icons - #9C9589
    static let stone = Color(red: 156/255, green: 149/255, blue: 137/255)

    /// Primary text - #3D3A36
    static let charcoal = Color(red: 61/255, green: 58/255, blue: 54/255)
  }

  // MARK: - Base Colors (Dark Mode)

  struct Dark {
    /// Primary background - #1C1B19
    static let charcoal = Color(red: 28/255, green: 27/255, blue: 25/255)

    /// Card/surface backgrounds - #2A2826
    static let slate = Color(red: 42/255, green: 40/255, blue: 38/255)

    /// Dividers, subtle borders - #3D3A36
    static let darkStone = Color(red: 61/255, green: 58/255, blue: 54/255)

    /// Secondary text, icons - #A8A49C
    static let mutedIvory = Color(red: 168/255, green: 164/255, blue: 156/255)

    /// Primary text - #FAF8F5
    static let ivory = Color(red: 250/255, green: 248/255, blue: 245/255)
  }

  // MARK: - Accent Colors

  struct Accent {
    /// Primary accent, CTAs, highlights - #B8965C
    static let antiqueGold = Color(red: 184/255, green: 150/255, blue: 92/255)

    /// Secondary accent, hover states - #D4BA8A
    static let softGold = Color(red: 212/255, green: 186/255, blue: 138/255)
  }

  // MARK: - Semantic Colors (Light Mode)

  struct SemanticLight {
    /// Income, positive amounts - #5C8A6B
    static let income = Color(red: 92/255, green: 138/255, blue: 107/255)

    /// Expenses, negative amounts - #A67070
    static let expense = Color(red: 166/255, green: 112/255, blue: 112/255)

    /// Warnings, approaching limits - #B89A5C
    static let warning = Color(red: 184/255, green: 154/255, blue: 92/255)

    /// Errors, overdue, exceeded - #8B5A5A
    static let error = Color(red: 139/255, green: 90/255, blue: 90/255)

    /// Completed, paid, active - #7A8B73
    static let success = Color(red: 122/255, green: 139/255, blue: 115/255)

    /// Neutral, inactive, pending - #6B7280
    static let neutral = Color(red: 107/255, green: 114/255, blue: 128/255)

    /// Due soon, attention needed - #A67A5C
    static let attention = Color(red: 166/255, green: 122/255, blue: 92/255)
  }

  // MARK: - Semantic Colors (Dark Mode)

  struct SemanticDark {
    /// Income, positive amounts - #6B9E7A
    static let income = Color(red: 107/255, green: 158/255, blue: 122/255)

    /// Expenses, negative amounts - #B88080
    static let expense = Color(red: 184/255, green: 128/255, blue: 128/255)

    /// Warnings, approaching limits - #C9AB6D
    static let warning = Color(red: 201/255, green: 171/255, blue: 109/255)

    /// Errors, overdue, exceeded - #9E6B6B
    static let error = Color(red: 158/255, green: 107/255, blue: 107/255)

    /// Completed, paid, active - #8A9B83
    static let success = Color(red: 138/255, green: 155/255, blue: 131/255)

    /// Neutral, inactive, pending - #9CA3AF
    static let neutral = Color(red: 156/255, green: 163/255, blue: 175/255)

    /// Due soon, attention needed - #B88A6C
    static let attention = Color(red: 184/255, green: 138/255, blue: 108/255)
  }

  // MARK: - Category Colors

  struct Category {
    /// Food & dining - #8B7355
    static let food = Color(red: 139/255, green: 115/255, blue: 85/255)

    /// Transportation - #5C6B7A
    static let transport = Color(red: 92/255, green: 107/255, blue: 122/255)

    /// Entertainment & leisure - #7A5C7A
    static let entertainment = Color(red: 122/255, green: 92/255, blue: 122/255)

    /// Medical & health - #5C7A7A
    static let healthcare = Color(red: 92/255, green: 122/255, blue: 122/255)

    /// Retail & shopping - #7A6B5C
    static let shopping = Color(red: 122/255, green: 107/255, blue: 92/255)

    /// Utilities & bills - #6B6B5C
    static let bills = Color(red: 107/255, green: 107/255, blue: 92/255)

    /// Salary income - #5C7A5C
    static let salary = Color(red: 92/255, green: 122/255, blue: 92/255)

    /// Investments - #5C6B6B
    static let investment = Color(red: 92/255, green: 107/255, blue: 107/255)

    /// Housing expenses - #7A6B6B
    static let housing = Color(red: 122/255, green: 107/255, blue: 107/255)

    /// Miscellaneous - #6B6B6B
    static let other = Color(red: 107/255, green: 107/255, blue: 107/255)
  }
}
