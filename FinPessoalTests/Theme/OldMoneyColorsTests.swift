//
//  OldMoneyColorsTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 20/12/25.
//

import XCTest
import SwiftUI
@testable import FinPessoal

final class OldMoneyColorsTests: XCTestCase {

  // MARK: - Light Mode Base Colors Tests

  func testLightModeIvoryColor() {
    // Background color - darker for card contrast
    let ivory = OldMoneyColors.Light.ivory
    let components = UIColor(ivory).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 232/255, accuracy: 0.01, "Red component should be 232/255")
    XCTAssertEqual(components[1], 228/255, accuracy: 0.01, "Green component should be 228/255")
    XCTAssertEqual(components[2], 221/255, accuracy: 0.01, "Blue component should be 221/255")
  }

  func testLightModeCreamColor() {
    // Surface/card color - lighter for cards to pop
    let cream = OldMoneyColors.Light.cream
    let components = UIColor(cream).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 250/255, accuracy: 0.01, "Red component should be 250/255")
    XCTAssertEqual(components[1], 248/255, accuracy: 0.01, "Green component should be 248/255")
    XCTAssertEqual(components[2], 245/255, accuracy: 0.01, "Blue component should be 245/255")
  }

  func testLightModeWarmGrayColor() {
    // Dividers color
    let warmGray = OldMoneyColors.Light.warmGray
    let components = UIColor(warmGray).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 216/255, accuracy: 0.01, "Red component should be 216/255")
    XCTAssertEqual(components[1], 212/255, accuracy: 0.01, "Green component should be 212/255")
    XCTAssertEqual(components[2], 204/255, accuracy: 0.01, "Blue component should be 204/255")
  }

  func testLightModeStoneColor() {
    // Secondary text color
    let stone = OldMoneyColors.Light.stone
    let components = UIColor(stone).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 156/255, accuracy: 0.01, "Red component should be 156/255")
    XCTAssertEqual(components[1], 149/255, accuracy: 0.01, "Green component should be 149/255")
    XCTAssertEqual(components[2], 137/255, accuracy: 0.01, "Blue component should be 137/255")
  }

  func testLightModeCharcoalColor() {
    // Primary text color
    let charcoal = OldMoneyColors.Light.charcoal
    let components = UIColor(charcoal).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 61/255, accuracy: 0.01, "Red component should be 61/255")
    XCTAssertEqual(components[1], 58/255, accuracy: 0.01, "Green component should be 58/255")
    XCTAssertEqual(components[2], 54/255, accuracy: 0.01, "Blue component should be 54/255")
  }

  // MARK: - Dark Mode Base Colors Tests

  func testDarkModeCharcoalColor() {
    // Dark mode background
    let charcoal = OldMoneyColors.Dark.charcoal
    let components = UIColor(charcoal).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 28/255, accuracy: 0.01, "Red component should be 28/255")
    XCTAssertEqual(components[1], 27/255, accuracy: 0.01, "Green component should be 27/255")
    XCTAssertEqual(components[2], 25/255, accuracy: 0.01, "Blue component should be 25/255")
  }

  func testDarkModeSlateColor() {
    // Dark mode surface
    let slate = OldMoneyColors.Dark.slate
    let components = UIColor(slate).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 42/255, accuracy: 0.01, "Red component should be 42/255")
    XCTAssertEqual(components[1], 40/255, accuracy: 0.01, "Green component should be 40/255")
    XCTAssertEqual(components[2], 38/255, accuracy: 0.01, "Blue component should be 38/255")
  }

  func testDarkModeDarkStoneColor() {
    // Dark mode dividers
    let darkStone = OldMoneyColors.Dark.darkStone
    let components = UIColor(darkStone).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 61/255, accuracy: 0.01, "Red component should be 61/255")
    XCTAssertEqual(components[1], 58/255, accuracy: 0.01, "Green component should be 58/255")
    XCTAssertEqual(components[2], 54/255, accuracy: 0.01, "Blue component should be 54/255")
  }

  func testDarkModeMutedIvoryColor() {
    // Dark mode secondary text
    let mutedIvory = OldMoneyColors.Dark.mutedIvory
    let components = UIColor(mutedIvory).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 168/255, accuracy: 0.01, "Red component should be 168/255")
    XCTAssertEqual(components[1], 164/255, accuracy: 0.01, "Green component should be 164/255")
    XCTAssertEqual(components[2], 156/255, accuracy: 0.01, "Blue component should be 156/255")
  }

  func testDarkModeIvoryColor() {
    // Dark mode primary text
    let ivory = OldMoneyColors.Dark.ivory
    let components = UIColor(ivory).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 250/255, accuracy: 0.01, "Red component should be 250/255")
    XCTAssertEqual(components[1], 248/255, accuracy: 0.01, "Green component should be 248/255")
    XCTAssertEqual(components[2], 245/255, accuracy: 0.01, "Blue component should be 245/255")
  }

  // MARK: - Accent Colors Tests

  func testAntiqueGoldColor() {
    let antiqueGold = OldMoneyColors.Accent.antiqueGold
    let components = UIColor(antiqueGold).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 184/255, accuracy: 0.01, "Red component should be 184/255")
    XCTAssertEqual(components[1], 150/255, accuracy: 0.01, "Green component should be 150/255")
    XCTAssertEqual(components[2], 92/255, accuracy: 0.01, "Blue component should be 92/255")
  }

  func testSoftGoldColor() {
    let softGold = OldMoneyColors.Accent.softGold
    let components = UIColor(softGold).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 212/255, accuracy: 0.01, "Red component should be 212/255")
    XCTAssertEqual(components[1], 186/255, accuracy: 0.01, "Green component should be 186/255")
    XCTAssertEqual(components[2], 138/255, accuracy: 0.01, "Blue component should be 138/255")
  }

  // MARK: - Semantic Colors Light Mode Tests

  func testSemanticLightIncomeColor() {
    let income = OldMoneyColors.SemanticLight.income
    let components = UIColor(income).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 92/255, accuracy: 0.01, "Red component should be 92/255")
    XCTAssertEqual(components[1], 138/255, accuracy: 0.01, "Green component should be 138/255")
    XCTAssertEqual(components[2], 107/255, accuracy: 0.01, "Blue component should be 107/255")
  }

  func testSemanticLightExpenseColor() {
    let expense = OldMoneyColors.SemanticLight.expense
    let components = UIColor(expense).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 166/255, accuracy: 0.01, "Red component should be 166/255")
    XCTAssertEqual(components[1], 112/255, accuracy: 0.01, "Green component should be 112/255")
    XCTAssertEqual(components[2], 112/255, accuracy: 0.01, "Blue component should be 112/255")
  }

  func testSemanticLightWarningColor() {
    let warning = OldMoneyColors.SemanticLight.warning
    let components = UIColor(warning).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 184/255, accuracy: 0.01, "Red component should be 184/255")
    XCTAssertEqual(components[1], 154/255, accuracy: 0.01, "Green component should be 154/255")
    XCTAssertEqual(components[2], 92/255, accuracy: 0.01, "Blue component should be 92/255")
  }

  func testSemanticLightErrorColor() {
    let error = OldMoneyColors.SemanticLight.error
    let components = UIColor(error).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 139/255, accuracy: 0.01, "Red component should be 139/255")
    XCTAssertEqual(components[1], 90/255, accuracy: 0.01, "Green component should be 90/255")
    XCTAssertEqual(components[2], 90/255, accuracy: 0.01, "Blue component should be 90/255")
  }

  func testSemanticLightSuccessColor() {
    let success = OldMoneyColors.SemanticLight.success
    let components = UIColor(success).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 122/255, accuracy: 0.01, "Red component should be 122/255")
    XCTAssertEqual(components[1], 139/255, accuracy: 0.01, "Green component should be 139/255")
    XCTAssertEqual(components[2], 115/255, accuracy: 0.01, "Blue component should be 115/255")
  }

  // MARK: - Category Colors Tests

  func testCategoryFoodColor() {
    let food = OldMoneyColors.Category.food
    let components = UIColor(food).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 139/255, accuracy: 0.01, "Red component should be 139/255")
    XCTAssertEqual(components[1], 115/255, accuracy: 0.01, "Green component should be 115/255")
    XCTAssertEqual(components[2], 85/255, accuracy: 0.01, "Blue component should be 85/255")
  }

  func testCategoryTransportColor() {
    let transport = OldMoneyColors.Category.transport
    let components = UIColor(transport).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 92/255, accuracy: 0.01, "Red component should be 92/255")
    XCTAssertEqual(components[1], 107/255, accuracy: 0.01, "Green component should be 107/255")
    XCTAssertEqual(components[2], 122/255, accuracy: 0.01, "Blue component should be 122/255")
  }

  // MARK: - Color Contrast Tests

  func testBackgroundSurfaceContrast() {
    // Verify background is darker than surface (cards should pop)
    let background = OldMoneyColors.Light.ivory
    let surface = OldMoneyColors.Light.cream

    let bgComponents = UIColor(background).cgColor.components ?? []
    let surfaceComponents = UIColor(surface).cgColor.components ?? []

    // Surface (cards) should be lighter than background
    let bgLuminance = (bgComponents[0] + bgComponents[1] + bgComponents[2]) / 3
    let surfaceLuminance = (surfaceComponents[0] + surfaceComponents[1] + surfaceComponents[2]) / 3

    XCTAssertGreaterThan(surfaceLuminance, bgLuminance, "Surface (cards) should be lighter than background")
  }

  func testDarkModeBackgroundSurfaceContrast() {
    // Verify dark mode surface is lighter than background
    let background = OldMoneyColors.Dark.charcoal
    let surface = OldMoneyColors.Dark.slate

    let bgComponents = UIColor(background).cgColor.components ?? []
    let surfaceComponents = UIColor(surface).cgColor.components ?? []

    let bgLuminance = (bgComponents[0] + bgComponents[1] + bgComponents[2]) / 3
    let surfaceLuminance = (surfaceComponents[0] + surfaceComponents[1] + surfaceComponents[2]) / 3

    XCTAssertGreaterThan(surfaceLuminance, bgLuminance, "Dark mode surface should be lighter than background")
  }

  func testTextBackgroundContrast() {
    // Verify sufficient contrast between text and background
    let text = OldMoneyColors.Light.charcoal
    let background = OldMoneyColors.Light.ivory

    let textComponents = UIColor(text).cgColor.components ?? []
    let bgComponents = UIColor(background).cgColor.components ?? []

    let textLuminance = (textComponents[0] + textComponents[1] + textComponents[2]) / 3
    let bgLuminance = (bgComponents[0] + bgComponents[1] + bgComponents[2]) / 3

    let contrast = abs(bgLuminance - textLuminance)
    XCTAssertGreaterThan(contrast, 0.5, "Text should have sufficient contrast with background")
  }

  // MARK: - Color Extension Tests

  func testOldMoneyColorExtensionExists() {
    // Verify the Color.oldMoney extension works
    let background = Color.oldMoney.background
    let surface = Color.oldMoney.surface
    let text = Color.oldMoney.text
    let accent = Color.oldMoney.accent

    XCTAssertNotNil(background, "Color.oldMoney.background should exist")
    XCTAssertNotNil(surface, "Color.oldMoney.surface should exist")
    XCTAssertNotNil(text, "Color.oldMoney.text should exist")
    XCTAssertNotNil(accent, "Color.oldMoney.accent should exist")
  }

  func testOldMoneySemanticColors() {
    let income = Color.oldMoney.income
    let expense = Color.oldMoney.expense
    let warning = Color.oldMoney.warning
    let error = Color.oldMoney.error
    let success = Color.oldMoney.success

    XCTAssertNotNil(income, "Color.oldMoney.income should exist")
    XCTAssertNotNil(expense, "Color.oldMoney.expense should exist")
    XCTAssertNotNil(warning, "Color.oldMoney.warning should exist")
    XCTAssertNotNil(error, "Color.oldMoney.error should exist")
    XCTAssertNotNil(success, "Color.oldMoney.success should exist")
  }

  func testOldMoneyCategoryColorFunction() {
    // Test that category color function returns valid colors
    let foodColor = Color.oldMoney.category(.food)
    let transportColor = Color.oldMoney.category(.transport)
    let entertainmentColor = Color.oldMoney.category(.entertainment)

    XCTAssertNotNil(foodColor, "Category color for food should exist")
    XCTAssertNotNil(transportColor, "Category color for transport should exist")
    XCTAssertNotNil(entertainmentColor, "Category color for entertainment should exist")
  }
}
