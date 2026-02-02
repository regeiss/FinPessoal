//
//  WidgetColorsTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 20/12/25.
//

import XCTest
import SwiftUI
@testable import FinPessoal
@MainActor

final class WidgetColorsTests: XCTestCase {

  // MARK: - Singleton Tests

  func testWidgetColorsSharedInstance() {
    let instance1 = WidgetColors.shared
    let instance2 = WidgetColors.shared

    XCTAssertTrue(instance1 == instance2, "WidgetColors should return the same singleton instance")
  }

  // MARK: - Light Mode Base Colors Tests

  func testBackgroundLightColor() {
    let background = WidgetColors.shared.backgroundLight
    let components = UIColor(background).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 232/255, accuracy: 0.01, "Red component should be 232/255")
    XCTAssertEqual(components[1], 228/255, accuracy: 0.01, "Green component should be 228/255")
    XCTAssertEqual(components[2], 221/255, accuracy: 0.01, "Blue component should be 221/255")
  }

  func testSurfaceLightColor() {
    let surface = WidgetColors.shared.surfaceLight
    let components = UIColor(surface).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 250/255, accuracy: 0.01, "Red component should be 250/255")
    XCTAssertEqual(components[1], 248/255, accuracy: 0.01, "Green component should be 248/255")
    XCTAssertEqual(components[2], 245/255, accuracy: 0.01, "Blue component should be 245/255")
  }

  func testDividerLightColor() {
    let divider = WidgetColors.shared.dividerLight
    let components = UIColor(divider).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 216/255, accuracy: 0.01, "Red component should be 216/255")
    XCTAssertEqual(components[1], 212/255, accuracy: 0.01, "Green component should be 212/255")
    XCTAssertEqual(components[2], 204/255, accuracy: 0.01, "Blue component should be 204/255")
  }

  func testTextSecondaryLightColor() {
    let textSecondary = WidgetColors.shared.textSecondaryLight
    let components = UIColor(textSecondary).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 156/255, accuracy: 0.01, "Red component should be 156/255")
    XCTAssertEqual(components[1], 149/255, accuracy: 0.01, "Green component should be 149/255")
    XCTAssertEqual(components[2], 137/255, accuracy: 0.01, "Blue component should be 137/255")
  }

  func testTextLightColor() {
    let text = WidgetColors.shared.textLight
    let components = UIColor(text).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 61/255, accuracy: 0.01, "Red component should be 61/255")
    XCTAssertEqual(components[1], 58/255, accuracy: 0.01, "Green component should be 58/255")
    XCTAssertEqual(components[2], 54/255, accuracy: 0.01, "Blue component should be 54/255")
  }

  // MARK: - Dark Mode Base Colors Tests

  func testBackgroundDarkColor() {
    let background = WidgetColors.shared.backgroundDark
    let components = UIColor(background).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 28/255, accuracy: 0.01, "Red component should be 28/255")
    XCTAssertEqual(components[1], 27/255, accuracy: 0.01, "Green component should be 27/255")
    XCTAssertEqual(components[2], 25/255, accuracy: 0.01, "Blue component should be 25/255")
  }

  func testSurfaceDarkColor() {
    let surface = WidgetColors.shared.surfaceDark
    let components = UIColor(surface).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 42/255, accuracy: 0.01, "Red component should be 42/255")
    XCTAssertEqual(components[1], 40/255, accuracy: 0.01, "Green component should be 40/255")
    XCTAssertEqual(components[2], 38/255, accuracy: 0.01, "Blue component should be 38/255")
  }

  func testDividerDarkColor() {
    let divider = WidgetColors.shared.dividerDark
    let components = UIColor(divider).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 61/255, accuracy: 0.01, "Red component should be 61/255")
    XCTAssertEqual(components[1], 58/255, accuracy: 0.01, "Green component should be 58/255")
    XCTAssertEqual(components[2], 54/255, accuracy: 0.01, "Blue component should be 54/255")
  }

  func testTextSecondaryDarkColor() {
    let textSecondary = WidgetColors.shared.textSecondaryDark
    let components = UIColor(textSecondary).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 168/255, accuracy: 0.01, "Red component should be 168/255")
    XCTAssertEqual(components[1], 164/255, accuracy: 0.01, "Green component should be 164/255")
    XCTAssertEqual(components[2], 156/255, accuracy: 0.01, "Blue component should be 156/255")
  }

  func testTextDarkColor() {
    let text = WidgetColors.shared.textDark
    let components = UIColor(text).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 250/255, accuracy: 0.01, "Red component should be 250/255")
    XCTAssertEqual(components[1], 248/255, accuracy: 0.01, "Green component should be 248/255")
    XCTAssertEqual(components[2], 245/255, accuracy: 0.01, "Blue component should be 245/255")
  }

  // MARK: - Accent Colors Tests

  func testAccentColor() {
    let accent = WidgetColors.shared.accent
    let components = UIColor(accent).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 184/255, accuracy: 0.01, "Red component should be 184/255")
    XCTAssertEqual(components[1], 150/255, accuracy: 0.01, "Green component should be 150/255")
    XCTAssertEqual(components[2], 92/255, accuracy: 0.01, "Blue component should be 92/255")
  }

  func testAccentSecondaryColor() {
    let accentSecondary = WidgetColors.shared.accentSecondary
    let components = UIColor(accentSecondary).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 212/255, accuracy: 0.01, "Red component should be 212/255")
    XCTAssertEqual(components[1], 186/255, accuracy: 0.01, "Green component should be 186/255")
    XCTAssertEqual(components[2], 138/255, accuracy: 0.01, "Blue component should be 138/255")
  }

  // MARK: - Semantic Colors Light Mode Tests

  func testIncomeLightColor() {
    let income = WidgetColors.shared.incomeLight
    let components = UIColor(income).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 92/255, accuracy: 0.01, "Red component should be 92/255")
    XCTAssertEqual(components[1], 138/255, accuracy: 0.01, "Green component should be 138/255")
    XCTAssertEqual(components[2], 107/255, accuracy: 0.01, "Blue component should be 107/255")
  }

  func testExpenseLightColor() {
    let expense = WidgetColors.shared.expenseLight
    let components = UIColor(expense).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 166/255, accuracy: 0.01, "Red component should be 166/255")
    XCTAssertEqual(components[1], 112/255, accuracy: 0.01, "Green component should be 112/255")
    XCTAssertEqual(components[2], 112/255, accuracy: 0.01, "Blue component should be 112/255")
  }

  func testWarningLightColor() {
    let warning = WidgetColors.shared.warningLight
    let components = UIColor(warning).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 184/255, accuracy: 0.01, "Red component should be 184/255")
    XCTAssertEqual(components[1], 154/255, accuracy: 0.01, "Green component should be 154/255")
    XCTAssertEqual(components[2], 92/255, accuracy: 0.01, "Blue component should be 92/255")
  }

  func testErrorLightColor() {
    let error = WidgetColors.shared.errorLight
    let components = UIColor(error).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 139/255, accuracy: 0.01, "Red component should be 139/255")
    XCTAssertEqual(components[1], 90/255, accuracy: 0.01, "Green component should be 90/255")
    XCTAssertEqual(components[2], 90/255, accuracy: 0.01, "Blue component should be 90/255")
  }

  func testSuccessLightColor() {
    let success = WidgetColors.shared.successLight
    let components = UIColor(success).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 122/255, accuracy: 0.01, "Red component should be 122/255")
    XCTAssertEqual(components[1], 139/255, accuracy: 0.01, "Green component should be 139/255")
    XCTAssertEqual(components[2], 115/255, accuracy: 0.01, "Blue component should be 115/255")
  }

  // MARK: - Semantic Colors Dark Mode Tests

  func testIncomeDarkColor() {
    let income = WidgetColors.shared.incomeDark
    let components = UIColor(income).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 107/255, accuracy: 0.01, "Red component should be 107/255")
    XCTAssertEqual(components[1], 158/255, accuracy: 0.01, "Green component should be 158/255")
    XCTAssertEqual(components[2], 122/255, accuracy: 0.01, "Blue component should be 122/255")
  }

  func testExpenseDarkColor() {
    let expense = WidgetColors.shared.expenseDark
    let components = UIColor(expense).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 184/255, accuracy: 0.01, "Red component should be 184/255")
    XCTAssertEqual(components[1], 128/255, accuracy: 0.01, "Green component should be 128/255")
    XCTAssertEqual(components[2], 128/255, accuracy: 0.01, "Blue component should be 128/255")
  }

  func testWarningDarkColor() {
    let warning = WidgetColors.shared.warningDark
    let components = UIColor(warning).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 201/255, accuracy: 0.01, "Red component should be 201/255")
    XCTAssertEqual(components[1], 171/255, accuracy: 0.01, "Green component should be 171/255")
    XCTAssertEqual(components[2], 109/255, accuracy: 0.01, "Blue component should be 109/255")
  }

  func testErrorDarkColor() {
    let error = WidgetColors.shared.errorDark
    let components = UIColor(error).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 158/255, accuracy: 0.01, "Red component should be 158/255")
    XCTAssertEqual(components[1], 107/255, accuracy: 0.01, "Green component should be 107/255")
    XCTAssertEqual(components[2], 107/255, accuracy: 0.01, "Blue component should be 107/255")
  }

  func testSuccessDarkColor() {
    let success = WidgetColors.shared.successDark
    let components = UIColor(success).cgColor.components ?? []

    XCTAssertEqual(components.count, 4, "Color should have RGBA components")
    XCTAssertEqual(components[0], 138/255, accuracy: 0.01, "Red component should be 138/255")
    XCTAssertEqual(components[1], 155/255, accuracy: 0.01, "Green component should be 155/255")
    XCTAssertEqual(components[2], 131/255, accuracy: 0.01, "Blue component should be 131/255")
  }

  // MARK: - Adaptive Color Tests

  func testAdaptiveColorsExist() {
    // Verify all adaptive colors are accessible
    let colors = WidgetColors.shared

    XCTAssertNotNil(colors.background, "Adaptive background should exist")
    XCTAssertNotNil(colors.surface, "Adaptive surface should exist")
    XCTAssertNotNil(colors.text, "Adaptive text should exist")
    XCTAssertNotNil(colors.textSecondary, "Adaptive textSecondary should exist")
    XCTAssertNotNil(colors.divider, "Adaptive divider should exist")
    XCTAssertNotNil(colors.income, "Adaptive income should exist")
    XCTAssertNotNil(colors.expense, "Adaptive expense should exist")
    XCTAssertNotNil(colors.warning, "Adaptive warning should exist")
    XCTAssertNotNil(colors.error, "Adaptive error should exist")
    XCTAssertNotNil(colors.success, "Adaptive success should exist")
  }

  // MARK: - Gradient Tests

  func testGoldGradientExists() {
    let gradient = WidgetColors.shared.goldGradient
    XCTAssertNotNil(gradient, "Gold gradient should exist")
  }

  // MARK: - Color Extension Tests

  func testColorWidgetExtension() {
    let colors = Color.widget

    XCTAssertNotNil(colors.background, "Color.widget.background should exist")
    XCTAssertNotNil(colors.surface, "Color.widget.surface should exist")
    XCTAssertNotNil(colors.text, "Color.widget.text should exist")
    XCTAssertNotNil(colors.accent, "Color.widget.accent should exist")
  }

  // MARK: - Color Contrast Tests

  func testLightModeSurfaceLighterThanBackground() {
    let background = WidgetColors.shared.backgroundLight
    let surface = WidgetColors.shared.surfaceLight

    let bgComponents = UIColor(background).cgColor.components ?? []
    let surfaceComponents = UIColor(surface).cgColor.components ?? []

    let bgLuminance = (bgComponents[0] + bgComponents[1] + bgComponents[2]) / 3
    let surfaceLuminance = (surfaceComponents[0] + surfaceComponents[1] + surfaceComponents[2]) / 3

    XCTAssertGreaterThan(surfaceLuminance, bgLuminance, "Surface should be lighter than background for card contrast")
  }

  func testDarkModeSurfaceLighterThanBackground() {
    let background = WidgetColors.shared.backgroundDark
    let surface = WidgetColors.shared.surfaceDark

    let bgComponents = UIColor(background).cgColor.components ?? []
    let surfaceComponents = UIColor(surface).cgColor.components ?? []

    let bgLuminance = (bgComponents[0] + bgComponents[1] + bgComponents[2]) / 3
    let surfaceLuminance = (surfaceComponents[0] + surfaceComponents[1] + surfaceComponents[2]) / 3

    XCTAssertGreaterThan(surfaceLuminance, bgLuminance, "Dark mode surface should be lighter than background")
  }

  // MARK: - Consistency Tests

  func testWidgetColorsMatchOldMoneyColors() {
    // Verify widget colors match main app colors
    let widgetBgLight = WidgetColors.shared.backgroundLight
    let appBgLight = OldMoneyColors.Light.ivory

    let widgetComponents = UIColor(widgetBgLight).cgColor.components ?? []
    let appComponents = UIColor(appBgLight).cgColor.components ?? []

    XCTAssertEqual(widgetComponents[0], appComponents[0], accuracy: 0.01, "Widget and app background red should match")
    XCTAssertEqual(widgetComponents[1], appComponents[1], accuracy: 0.01, "Widget and app background green should match")
    XCTAssertEqual(widgetComponents[2], appComponents[2], accuracy: 0.01, "Widget and app background blue should match")
  }

  func testWidgetAccentMatchesAppAccent() {
    let widgetAccent = WidgetColors.shared.accent
    let appAccent = OldMoneyColors.Accent.antiqueGold

    let widgetComponents = UIColor(widgetAccent).cgColor.components ?? []
    let appComponents = UIColor(appAccent).cgColor.components ?? []

    XCTAssertEqual(widgetComponents[0], appComponents[0], accuracy: 0.01, "Widget and app accent red should match")
    XCTAssertEqual(widgetComponents[1], appComponents[1], accuracy: 0.01, "Widget and app accent green should match")
    XCTAssertEqual(widgetComponents[2], appComponents[2], accuracy: 0.01, "Widget and app accent blue should match")
  }
}
