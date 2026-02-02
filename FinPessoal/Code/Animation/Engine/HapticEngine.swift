// FinPessoal/Code/Animation/Engine/HapticEngine.swift
import UIKit
import CoreHaptics

/// Centralized haptic feedback engine
@MainActor
public class HapticEngine {
  public static let shared = HapticEngine()

  private var impactLight: UIImpactFeedbackGenerator?
  private var impactMedium: UIImpactFeedbackGenerator?
  private var impactHeavy: UIImpactFeedbackGenerator?
  private var notification: UINotificationFeedbackGenerator?
  private var selectionGenerator: UISelectionFeedbackGenerator?

  private var hapticEngine: CHHapticEngine?
  private var supportsHaptics: Bool = false

  private init() {
    setupHapticEngine()
  }

  private func setupHapticEngine() {
    // Check if device supports haptics
    supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    guard supportsHaptics else { return }

    // Initialize feedback generators
    impactLight = UIImpactFeedbackGenerator(style: .light)
    impactMedium = UIImpactFeedbackGenerator(style: .medium)
    impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    notification = UINotificationFeedbackGenerator()
    selectionGenerator = UISelectionFeedbackGenerator()

    // Setup Core Haptics engine for custom patterns
    do {
      hapticEngine = try CHHapticEngine()
      try hapticEngine?.start()
    } catch {
      print("Haptic engine failed to start: \(error)")
    }
  }

  // MARK: - Impact Haptics

  public func light() {
    guard supportsHaptics else { return }
    impactLight?.prepare()
    impactLight?.impactOccurred()
  }

  public func medium() {
    guard supportsHaptics else { return }
    impactMedium?.prepare()
    impactMedium?.impactOccurred()
  }

  public func heavy() {
    guard supportsHaptics else { return }
    impactHeavy?.prepare()
    impactHeavy?.impactOccurred()
  }

  public func selection() {
    guard supportsHaptics else { return }
    selectionGenerator?.prepare()
    selectionGenerator?.selectionChanged()
  }

  // MARK: - Notification Haptics

  public func success() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.success)
  }

  public func warning() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.warning)
  }

  public func error() {
    guard supportsHaptics else { return }
    notification?.prepare()
    notification?.notificationOccurred(.error)
  }

  // MARK: - Custom Patterns

  /// Gentle success pattern (tap-tap-tap)
  public func gentleSuccess() {
    guard supportsHaptics, let engine = hapticEngine else {
      // Fallback to simple haptic
      success()
      return
    }

    do {
      let pattern = try CHHapticPattern(
        events: [
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0),
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.1),
          CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        ],
        parameters: []
      )

      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      // Fallback
      success()
    }
  }

  /// Crescendo pattern for celebrations (light → medium → heavy)
  public func crescendo() {
    guard supportsHaptics else { return }

    light()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.medium()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.heavy()
    }
  }

  /// Warning pattern (tap-pause-tap)
  public func warningPattern() {
    guard supportsHaptics else { return }

    medium()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.medium()
    }
  }
}
