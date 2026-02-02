// FinPessoal/Code/Animation/Components/PhysicsNumberCounter.swift
import SwiftUI

/// Animated number counter with spring physics
public struct PhysicsNumberCounter: View {
  @Binding public var value: Double
  public let format: FloatingPointFormatStyle<Double>.Currency
  public let font: Font

  @State private var displayValue: Double

  public init(
    value: Binding<Double>,
    format: FloatingPointFormatStyle<Double>.Currency,
    font: Font? = nil
  ) {
    self._value = value
    self.format = format
    self.font = font ?? OldMoneyTheme.Typography.moneyLarge
    self._displayValue = State(initialValue: value.wrappedValue)
  }

  // Convenience initializer for testing
  public init(
    value: Double,
    format: FloatingPointFormatStyle<Double>.Currency,
    font: Font? = nil
  ) {
    self._value = .constant(value)
    self.format = format
    self.font = font ?? OldMoneyTheme.Typography.moneyLarge
    self._displayValue = State(initialValue: value)
  }

  public var body: some View {
    Text(displayValue.formatted(format))
      .font(font)
      .onChange(of: value) { oldValue, newValue in
        animateChange(from: oldValue, to: newValue)
      }
      .onAppear {
        displayValue = value
      }
  }

  @MainActor
  private func animateChange(from oldValue: Double, to newValue: Double) {
    let settings = AnimationSettings.shared

    guard settings.effectiveMode != .minimal else {
      // Instant change in minimal mode
      displayValue = newValue
      return
    }

    // Animate with spring physics
    let animation = settings.effectiveMode == .full
      ? AnimationEngine.gentleSpring
      : AnimationEngine.quickFade

    withAnimation(animation) {
      displayValue = newValue
    }

    // Haptic feedback for significant changes
    if abs(newValue - oldValue) > 100 {
      if newValue > oldValue {
        HapticEngine.shared.light()
      } else {
        HapticEngine.shared.selection()
      }
    }
  }
}
