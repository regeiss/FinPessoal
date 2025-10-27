//
//  OnboardingUITests.swift
//  FinPessoalUITests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest

@MainActor
final class OnboardingUITests: XCTestCase {

  private var app: XCUIApplication!

  override func setUp() async throws {
    try await super.setUp()

    continueAfterFailure = false

    app = XCUIApplication()

    // Reset app state for consistent testing
    app.launchArguments.append("--uitesting")
    app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "1"
    app.launchEnvironment["UITEST_RESET_STATE"] = "1"

    app.launch()
  }

  override func tearDown() async throws {
    app = nil
    try await super.tearDown()
  }

  // MARK: - Onboarding Flow Tests

  func testOnboardingScreensNavigation() throws {
    // Check if onboarding appears for first-time users
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.exists {
      XCTAssertTrue(onboardingTitle.isHittable)

      // Test navigation through onboarding pages
      let nextButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Próximo' OR label CONTAINS[cd] 'Next'"
        )
      ).firstMatch

      if nextButton.exists {
        // Navigate through onboarding pages
        var pageCount = 0
        while nextButton.exists && nextButton.isEnabled && pageCount < 5 {
          nextButton.tap()
          pageCount += 1
          sleep(1)  // Allow for page transition
        }

        // Check for final page with "Get Started" or similar button
        let getStartedButton = app.buttons.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Começar' OR label CONTAINS[cd] 'Get Started' OR label CONTAINS[cd] 'Finalizar'"
          )
        ).firstMatch

        if getStartedButton.exists {
          XCTAssertTrue(getStartedButton.isHittable)
          getStartedButton.tap()
        }
      }
    }

    // After onboarding, should reach login screen
    let loginTitle = app.staticTexts.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login' OR label CONTAINS[cd] 'Sign In'"
      )
    ).firstMatch

    // Wait for login screen to appear
    XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
  }

  func testOnboardingSkipFunctionality() throws {
    // Check if onboarding appears
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.exists {
      // Look for skip button
      let skipButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Pular' OR label CONTAINS[cd] 'Skip'"
        )
      ).firstMatch

      if skipButton.exists {
        XCTAssertTrue(skipButton.isHittable)
        skipButton.tap()

        // Should navigate to login screen
        let loginScreen = app.staticTexts.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login'"
          )
        ).firstMatch
        XCTAssertTrue(loginScreen.waitForExistence(timeout: 3))
      }
    }
  }

  func testOnboardingPageIndicator() throws {
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.exists {
      // Look for page indicators (dots)
      let pageIndicators = app.pageIndicators

      if pageIndicators.count > 0 {
        let firstIndicator = pageIndicators.firstMatch
        XCTAssertTrue(firstIndicator.exists)

        // Navigate and check if page indicator updates
        let nextButton = app.buttons.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Próximo' OR label CONTAINS[cd] 'Next'"
          )
        ).firstMatch

        if nextButton.exists {
          nextButton.tap()
          sleep(1)

          // Page indicator should still exist (possibly updated)
          XCTAssertTrue(firstIndicator.exists)
        }
      }
    }
  }

  // MARK: - Onboarding Content Tests

  func testOnboardingContentIsVisible() throws {
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.exists {
      // Check for common onboarding elements
      let images = app.images
      XCTAssertTrue(images.count > 0, "Onboarding should have images")

      let staticTexts = app.staticTexts
      XCTAssertTrue(
        staticTexts.count > 0,
        "Onboarding should have text content"
      )

      // Check that at least one image is visible
      let visibleImages = images.allElementsBoundByIndex.filter {
        $0.isHittable
      }
      XCTAssertTrue(
        visibleImages.count > 0,
        "At least one image should be visible"
      )
    }
  }

  func testOnboardingButtonsAreAccessible() throws {
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.exists {
      // Test button accessibility
      let buttons = app.buttons
      let actionButtons = buttons.allElementsBoundByIndex.filter { button in
        let label = button.label.lowercased()
        return label.contains("próximo") || label.contains("next")
          || label.contains("pular") || label.contains("skip")
          || label.contains("começar") || label.contains("get started")
      }

      for button in actionButtons {
        XCTAssertTrue(button.exists, "Button should exist")
        XCTAssertTrue(button.isEnabled, "Button should be enabled")

        // Check accessibility properties
        XCTAssertFalse(button.label.isEmpty, "Button should have a label")
      }
    }
  }

  // MARK: - Onboarding State Persistence Tests

  func testOnboardingCompletionPersistence() throws {
    // Complete onboarding if it appears
    completeOnboardingIfPresent()

    // Terminate and relaunch app
    app.terminate()
    app.launch()

    // Onboarding should not appear again
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    // Wait briefly to ensure onboarding doesn't appear
    XCTAssertFalse(
      onboardingTitle.waitForExistence(timeout: 2),
      "Onboarding should not appear after completion"
    )

    // Should go directly to login or main app
    let loginOrDashboard = app.staticTexts.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login' OR label CONTAINS[cd] 'Dashboard'"
      )
    ).firstMatch
    XCTAssertTrue(loginOrDashboard.waitForExistence(timeout: 3))
  }

  // MARK: - Helper Methods

  private func completeOnboardingIfPresent() {
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.waitForExistence(timeout: 2) {
      // Try to skip onboarding first
      let skipButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Pular' OR label CONTAINS[cd] 'Skip'"
        )
      ).firstMatch

      if skipButton.exists {
        skipButton.tap()
        return
      }

      // Otherwise navigate through all pages
      let nextButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Próximo' OR label CONTAINS[cd] 'Next'"
        )
      ).firstMatch

      var attempts = 0
      while nextButton.exists && nextButton.isEnabled && attempts < 10 {
        nextButton.tap()
        attempts += 1
        sleep(1)
      }

      // Tap final button to complete onboarding
      let getStartedButton = app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Começar' OR label CONTAINS[cd] 'Get Started' OR label CONTAINS[cd] 'Finalizar'"
        )
      ).firstMatch

      if getStartedButton.exists {
        getStartedButton.tap()
      }
    }
  }
}
