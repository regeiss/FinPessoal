// FinPessoalTests/Animation/ChartsAccessibilityTests.swift
import XCTest
@testable import FinPessoal

@MainActor
final class ChartsAccessibilityTests: XCTestCase {

  // MARK: - Setup

  override func setUp() {
    super.setUp()
    // Reset animation settings before each test
    AnimationSettings.shared.mode = .full
  }

  // MARK: - Haptic Engine Tests

  func testHapticEngineRespectsReduceMotion() {
    // RED: Test that HapticEngine disables haptics in Minimal mode
    AnimationSettings.shared.mode = .minimal

    let hapticEngine = HapticEngine.shared

    // This will fail until HapticEngine checks AnimationSettings
    XCTAssertTrue(
      hapticEngine.shouldSuppressHaptics,
      "HapticEngine should suppress haptics when AnimationSettings.effectiveMode is .minimal"
    )
  }

  func testHapticEngineAllowsHapticsInFullMode() {
    // Test that haptics are enabled in Full mode
    AnimationSettings.shared.mode = .full

    let hapticEngine = HapticEngine.shared

    XCTAssertFalse(
      hapticEngine.shouldSuppressHaptics,
      "HapticEngine should allow haptics when AnimationSettings.effectiveMode is .full"
    )
  }

  func testHapticEngineAllowsHapticsInReducedMode() {
    // Test that haptics are enabled in Reduced mode (only suppressed in Minimal)
    AnimationSettings.shared.mode = .reduced

    let hapticEngine = HapticEngine.shared

    XCTAssertFalse(
      hapticEngine.shouldSuppressHaptics,
      "HapticEngine should allow haptics when AnimationSettings.effectiveMode is .reduced"
    )
  }

  // MARK: - Chart Data Model Tests

  func testChartSegmentAccessibilityDescription() {
    // Test that we can format accessibility descriptions for segments
    let segment = ChartSegment(
      id: "food",
      value: 500,
      percentage: 25.5,
      label: "Food & Dining",
      color: .blue,
      category: nil
    )

    // Format the accessibility value
    let percentageText = String(format: "%.1f%%", segment.percentage)
    XCTAssertEqual(percentageText, "25.5%", "Percentage should format to 1 decimal place")

    // Verify value formatting
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    let valueText = formatter.string(from: NSNumber(value: segment.value)) ?? ""

    XCTAssertEqual(valueText, "$500", "Value should format as currency")
  }

  func testChartBarAccessibilityDescription() {
    // Test that we can format accessibility descriptions for bars
    let bar = ChartBar(
      id: "jan",
      value: 1500.50,
      maxValue: 2000,
      label: "January",
      color: .blue,
      date: nil
    )

    // Verify currency formatting
    let valueText = bar.value.formatted(.currency(code: "USD"))
    XCTAssertTrue(
      valueText.contains("1,500") || valueText.contains("1500"),
      "Bar value should format as USD currency: \(valueText)"
    )
  }
}
