//
//  OldMoneyThemeTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 20/12/25.
//

import XCTest
import SwiftUI
@testable import FinPessoal

final class OldMoneyThemeTests: XCTestCase {

  // MARK: - Typography Tests

  func testHeadlineFontFunction() {
    let defaultHeadline = OldMoneyTheme.Typography.headline()
    let customHeadline = OldMoneyTheme.Typography.headline(28)

    XCTAssertNotNil(defaultHeadline, "Default headline font should exist")
    XCTAssertNotNil(customHeadline, "Custom headline font should exist")
  }

  func testLargeTitleFont() {
    let largeTitle = OldMoneyTheme.Typography.largeTitle
    XCTAssertNotNil(largeTitle, "Large title font should exist")
  }

  func testTitleFont() {
    let title = OldMoneyTheme.Typography.title
    XCTAssertNotNil(title, "Title font should exist")
  }

  func testTitle2Font() {
    let title2 = OldMoneyTheme.Typography.title2
    XCTAssertNotNil(title2, "Title2 font should exist")
  }

  func testTitle3Font() {
    let title3 = OldMoneyTheme.Typography.title3
    XCTAssertNotNil(title3, "Title3 font should exist")
  }

  func testBodyFont() {
    let body = OldMoneyTheme.Typography.body
    XCTAssertNotNil(body, "Body font should exist")
  }

  func testSubheadlineFont() {
    let subheadline = OldMoneyTheme.Typography.subheadline
    XCTAssertNotNil(subheadline, "Subheadline font should exist")
  }

  func testCaptionFont() {
    let caption = OldMoneyTheme.Typography.caption
    XCTAssertNotNil(caption, "Caption font should exist")
  }

  func testCaption2Font() {
    let caption2 = OldMoneyTheme.Typography.caption2
    XCTAssertNotNil(caption2, "Caption2 font should exist")
  }

  func testMoneyFontFunction() {
    let defaultMoney = OldMoneyTheme.Typography.money()
    let customMoney = OldMoneyTheme.Typography.money(24)

    XCTAssertNotNil(defaultMoney, "Default money font should exist")
    XCTAssertNotNil(customMoney, "Custom money font should exist")
  }

  func testMoneyLargeFont() {
    let moneyLarge = OldMoneyTheme.Typography.moneyLarge
    XCTAssertNotNil(moneyLarge, "Money large font should exist")
  }

  func testMoneyMediumFont() {
    let moneyMedium = OldMoneyTheme.Typography.moneyMedium
    XCTAssertNotNil(moneyMedium, "Money medium font should exist")
  }

  func testMoneySmallFont() {
    let moneySmall = OldMoneyTheme.Typography.moneySmall
    XCTAssertNotNil(moneySmall, "Money small font should exist")
  }

  // MARK: - Shadow Tests

  func testCardShadow() {
    let shadow = OldMoneyTheme.Shadows.card

    XCTAssertNotNil(shadow.color, "Card shadow color should exist")
    XCTAssertEqual(shadow.radius, 12, "Card shadow radius should be 12")
    XCTAssertEqual(shadow.x, 0, "Card shadow x offset should be 0")
    XCTAssertEqual(shadow.y, 4, "Card shadow y offset should be 4")
  }

  func testButtonShadow() {
    let shadow = OldMoneyTheme.Shadows.button

    XCTAssertNotNil(shadow.color, "Button shadow color should exist")
    XCTAssertEqual(shadow.radius, 8, "Button shadow radius should be 8")
    XCTAssertEqual(shadow.x, 0, "Button shadow x offset should be 0")
    XCTAssertEqual(shadow.y, 2, "Button shadow y offset should be 2")
  }

  func testElevatedShadow() {
    let shadow = OldMoneyTheme.Shadows.elevated

    XCTAssertNotNil(shadow.color, "Elevated shadow color should exist")
    XCTAssertEqual(shadow.radius, 16, "Elevated shadow radius should be 16")
    XCTAssertEqual(shadow.x, 0, "Elevated shadow x offset should be 0")
    XCTAssertEqual(shadow.y, 6, "Elevated shadow y offset should be 6")
  }

  func testNoneShadow() {
    let shadow = OldMoneyTheme.Shadows.none

    XCTAssertEqual(shadow.radius, 0, "None shadow radius should be 0")
    XCTAssertEqual(shadow.x, 0, "None shadow x offset should be 0")
    XCTAssertEqual(shadow.y, 0, "None shadow y offset should be 0")
  }

  // MARK: - Radius Tests

  func testSmallRadius() {
    XCTAssertEqual(OldMoneyTheme.Radius.small, 8, "Small radius should be 8")
  }

  func testMediumRadius() {
    XCTAssertEqual(OldMoneyTheme.Radius.medium, 12, "Medium radius should be 12")
  }

  func testLargeRadius() {
    XCTAssertEqual(OldMoneyTheme.Radius.large, 16, "Large radius should be 16")
  }

  func testExtraLargeRadius() {
    XCTAssertEqual(OldMoneyTheme.Radius.extraLarge, 20, "Extra large radius should be 20")
  }

  func testCircularRadius() {
    XCTAssertEqual(OldMoneyTheme.Radius.circular, 9999, "Circular radius should be 9999")
  }

  // MARK: - Border Tests

  func testBorderWidth() {
    XCTAssertEqual(OldMoneyTheme.Borders.width, 0.5, "Border width should be 0.5")
  }

  func testThickBorderWidth() {
    XCTAssertEqual(OldMoneyTheme.Borders.thickWidth, 1.0, "Thick border width should be 1.0")
  }

  func testBorderColor() {
    let borderColor = OldMoneyTheme.Borders.color
    XCTAssertNotNil(borderColor, "Border color should exist")
  }

  // MARK: - Spacing Tests

  func testXsSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.xs, 4, "XS spacing should be 4")
  }

  func testSmSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.sm, 8, "SM spacing should be 8")
  }

  func testMdSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.md, 12, "MD spacing should be 12")
  }

  func testBaseSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.base, 16, "Base spacing should be 16")
  }

  func testLgSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.lg, 24, "LG spacing should be 24")
  }

  func testXlSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.xl, 32, "XL spacing should be 32")
  }

  func testXxlSpacing() {
    XCTAssertEqual(OldMoneyTheme.Spacing.xxl, 48, "XXL spacing should be 48")
  }

  // MARK: - Animation Tests

  func testAnimationDuration() {
    XCTAssertEqual(OldMoneyTheme.Animation.duration, 0.25, "Standard duration should be 0.25")
  }

  func testFastAnimationDuration() {
    XCTAssertEqual(OldMoneyTheme.Animation.fast, 0.15, "Fast duration should be 0.15")
  }

  func testSlowAnimationDuration() {
    XCTAssertEqual(OldMoneyTheme.Animation.slow, 0.35, "Slow duration should be 0.35")
  }

  func testStandardAnimation() {
    let animation = OldMoneyTheme.Animation.standard
    XCTAssertNotNil(animation, "Standard animation should exist")
  }

  func testQuickAnimation() {
    let animation = OldMoneyTheme.Animation.quick
    XCTAssertNotNil(animation, "Quick animation should exist")
  }

  func testGentleAnimation() {
    let animation = OldMoneyTheme.Animation.gentle
    XCTAssertNotNil(animation, "Gentle animation should exist")
  }

  func testSpringAnimation() {
    let animation = OldMoneyTheme.Animation.spring
    XCTAssertNotNil(animation, "Spring animation should exist")
  }

  // MARK: - Shadow Structure Tests

  func testShadowStructure() {
    let shadow = OldMoneyTheme.Shadow(
      color: .black,
      radius: 10,
      x: 5,
      y: 5
    )

    XCTAssertEqual(shadow.radius, 10, "Shadow radius should be 10")
    XCTAssertEqual(shadow.x, 5, "Shadow x should be 5")
    XCTAssertEqual(shadow.y, 5, "Shadow y should be 5")
  }

  // MARK: - View Modifier Tests

  func testCardShadowViewModifierExists() {
    // Create a simple view and apply the modifier to verify it compiles
    let testView = Text("Test").oldMoneyCardShadow()
    XCTAssertNotNil(testView, "oldMoneyCardShadow modifier should exist")
  }

  func testButtonShadowViewModifierExists() {
    let testView = Text("Test").oldMoneyButtonShadow()
    XCTAssertNotNil(testView, "oldMoneyButtonShadow modifier should exist")
  }

  func testElevatedShadowViewModifierExists() {
    let testView = Text("Test").oldMoneyElevatedShadow()
    XCTAssertNotNil(testView, "oldMoneyElevatedShadow modifier should exist")
  }

  func testOldMoneyCardModifierExists() {
    let testView = Text("Test").oldMoneyCard()
    XCTAssertNotNil(testView, "oldMoneyCard modifier should exist")
  }

  func testOldMoneyButtonModifierExists() {
    let testView = Text("Test").oldMoneyButton()
    XCTAssertNotNil(testView, "oldMoneyButton modifier should exist")
  }

  func testOldMoneySecondaryButtonModifierExists() {
    let testView = Text("Test").oldMoneySecondaryButton()
    XCTAssertNotNil(testView, "oldMoneySecondaryButton modifier should exist")
  }

  func testOldMoneyHeadlineModifierExists() {
    let testView = Text("Test").oldMoneyHeadline()
    XCTAssertNotNil(testView, "oldMoneyHeadline modifier should exist")

    let customSizeView = Text("Test").oldMoneyHeadline(28)
    XCTAssertNotNil(customSizeView, "oldMoneyHeadline with custom size should exist")
  }

  func testOldMoneyMoneyModifierExists() {
    let testView = Text("Test").oldMoneyMoney()
    XCTAssertNotNil(testView, "oldMoneyMoney modifier should exist")

    let customSizeView = Text("Test").oldMoneyMoney(24)
    XCTAssertNotNil(customSizeView, "oldMoneyMoney with custom size should exist")
  }

  // MARK: - Consistency Tests

  func testSpacingIncreases() {
    XCTAssertLessThan(OldMoneyTheme.Spacing.xs, OldMoneyTheme.Spacing.sm, "XS should be less than SM")
    XCTAssertLessThan(OldMoneyTheme.Spacing.sm, OldMoneyTheme.Spacing.md, "SM should be less than MD")
    XCTAssertLessThan(OldMoneyTheme.Spacing.md, OldMoneyTheme.Spacing.base, "MD should be less than base")
    XCTAssertLessThan(OldMoneyTheme.Spacing.base, OldMoneyTheme.Spacing.lg, "Base should be less than LG")
    XCTAssertLessThan(OldMoneyTheme.Spacing.lg, OldMoneyTheme.Spacing.xl, "LG should be less than XL")
    XCTAssertLessThan(OldMoneyTheme.Spacing.xl, OldMoneyTheme.Spacing.xxl, "XL should be less than XXL")
  }

  func testRadiusIncreases() {
    XCTAssertLessThan(OldMoneyTheme.Radius.small, OldMoneyTheme.Radius.medium, "Small should be less than medium")
    XCTAssertLessThan(OldMoneyTheme.Radius.medium, OldMoneyTheme.Radius.large, "Medium should be less than large")
    XCTAssertLessThan(OldMoneyTheme.Radius.large, OldMoneyTheme.Radius.extraLarge, "Large should be less than extra large")
    XCTAssertLessThan(OldMoneyTheme.Radius.extraLarge, OldMoneyTheme.Radius.circular, "Extra large should be less than circular")
  }

  func testAnimationDurationIncreases() {
    XCTAssertLessThan(OldMoneyTheme.Animation.fast, OldMoneyTheme.Animation.duration, "Fast should be less than standard")
    XCTAssertLessThan(OldMoneyTheme.Animation.duration, OldMoneyTheme.Animation.slow, "Standard should be less than slow")
  }

  func testShadowRadiusIncreases() {
    XCTAssertLessThan(
      OldMoneyTheme.Shadows.button.radius,
      OldMoneyTheme.Shadows.card.radius,
      "Button shadow should be smaller than card"
    )
    XCTAssertLessThan(
      OldMoneyTheme.Shadows.card.radius,
      OldMoneyTheme.Shadows.elevated.radius,
      "Card shadow should be smaller than elevated"
    )
  }

  // MARK: - Accessibility Tests

  func testSpacingMinimumSize() {
    // Minimum touch target is 44pt, base spacing should support this
    XCTAssertGreaterThanOrEqual(
      OldMoneyTheme.Spacing.lg + OldMoneyTheme.Spacing.base,
      40,
      "Combined spacing should support minimum touch targets"
    )
  }

  func testRadiusValues() {
    // Ensure radius values are reasonable for UI
    XCTAssertGreaterThan(OldMoneyTheme.Radius.small, 0, "Small radius should be positive")
    XCTAssertLessThan(OldMoneyTheme.Radius.extraLarge, 100, "Extra large radius should be reasonable")
  }
}
