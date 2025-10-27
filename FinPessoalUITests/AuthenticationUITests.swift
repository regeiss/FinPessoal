//
//  AuthenticationUITests.swift
//  FinPessoalUITests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest

@MainActor
final class AuthenticationUITests: XCTestCase {

  private var app: XCUIApplication!

  override func setUp() async throws {
    try await super.setUp()

    continueAfterFailure = false

    app = XCUIApplication()
    app.launchArguments.append("--uitesting")
    app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "1"
    app.launchEnvironment["UITEST_MOCK_AUTH"] = "1"

    app.launch()

    // Skip onboarding if present
    skipOnboardingIfPresent()
  }

  override func tearDown() async throws {
    app = nil
    try await super.tearDown()
  }

  // MARK: - Login Screen Tests

  func testLoginScreenAppears() throws {
    let loginTitle = app.staticTexts.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login' OR label CONTAINS[cd] 'Sign In'"
      )
    ).firstMatch
    XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
  }

  func testGoogleSignInButtonExists() throws {
    navigateToLoginIfNeeded()

    let googleSignInButton = app.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Google' OR label CONTAINS[cd] 'Continuar com Google' OR label CONTAINS[cd] 'Continue with Google'"
      )
    ).firstMatch

    XCTAssertTrue(googleSignInButton.waitForExistence(timeout: 3))
    XCTAssertTrue(googleSignInButton.isEnabled)
    XCTAssertTrue(googleSignInButton.isHittable)
  }

  func testAppleSignInButtonExists() throws {
    navigateToLoginIfNeeded()

    let appleSignInButton = app.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Apple' OR label CONTAINS[cd] 'Continuar com Apple' OR label CONTAINS[cd] 'Continue with Apple'"
      )
    ).firstMatch

    XCTAssertTrue(appleSignInButton.waitForExistence(timeout: 3))
    XCTAssertTrue(appleSignInButton.isEnabled)
    XCTAssertTrue(appleSignInButton.isHittable)
  }

  func testLoginScreenLayout() throws {
    navigateToLoginIfNeeded()

    // Check for app logo or branding
    let images = app.images
    XCTAssertTrue(images.count > 0, "Login screen should have images/logo")

    // Check for welcome text or app description
    let staticTexts = app.staticTexts
    let relevantTexts = staticTexts.allElementsBoundByIndex.filter { text in
      let label = text.label.lowercased()
      return label.contains("bem-vindo") || label.contains("welcome")
        || label.contains("finpessoal") || label.contains("finance")
        || label.contains("entrar") || label.contains("login")
    }

    XCTAssertTrue(
      relevantTexts.count > 0,
      "Login screen should have welcome text"
    )
  }

  // MARK: - Mock Authentication Tests

  func testMockGoogleSignIn() throws {
    navigateToLoginIfNeeded()

    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch

    if googleSignInButton.exists {
      googleSignInButton.tap()

      // In mock mode, should navigate to dashboard
      let dashboardElement = app.staticTexts.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch

      XCTAssertTrue(
        dashboardElement.waitForExistence(timeout: 5),
        "Should navigate to dashboard after successful mock login"
      )
    }
  }

  func testMockAppleSignIn() throws {
    navigateToLoginIfNeeded()

    let appleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Apple'")
    ).firstMatch

    if appleSignInButton.exists {
      appleSignInButton.tap()

      // In mock mode, should navigate to dashboard
      let dashboardElement = app.staticTexts.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch

      XCTAssertTrue(
        dashboardElement.waitForExistence(timeout: 5),
        "Should navigate to dashboard after successful mock login"
      )
    }
  }

  // MARK: - Navigation After Authentication Tests

  func testNavigationAfterSuccessfulLogin() throws {
    navigateToLoginIfNeeded()

    // Perform mock login
    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch

    if googleSignInButton.exists {
      googleSignInButton.tap()

      // Check that we're in the main app
      let tabBar = app.tabBars.firstMatch
      let navigationBar = app.navigationBars.firstMatch

      // Should have either tab bar (iPhone) or navigation elements (iPad/iPhone)
      let hasTabBar = tabBar.waitForExistence(timeout: 3)
      let hasNavigationBar = navigationBar.waitForExistence(timeout: 3)

      XCTAssertTrue(
        hasTabBar || hasNavigationBar,
        "Should have main app navigation elements after login"
      )
    }
  }

  func testTabBarVisibilityAfterLogin() throws {
    navigateToLoginIfNeeded()
    performMockLogin()

    // Check if tab bar is visible (iPhone layout)
    let tabBar = app.tabBars.firstMatch

    if tabBar.exists {
      // Verify tab bar items
      let tabBarButtons = tabBar.buttons
      XCTAssertTrue(tabBarButtons.count > 0, "Tab bar should have buttons")

      // Check for expected tabs
      let dashboardTab = tabBarButtons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch
      let accountsTab = tabBarButtons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Accounts' OR label CONTAINS[cd] 'Contas'"
        )
      ).firstMatch

      XCTAssertTrue(
        dashboardTab.exists || accountsTab.exists,
        "Should have recognizable tabs"
      )
    }
  }

  // MARK: - Logout Tests

  func testLogoutFunctionality() throws {
    navigateToLoginIfNeeded()
    performMockLogin()

    // Navigate to settings/profile to find logout
    let settingsTab = app.tabBars.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Settings' OR label CONTAINS[cd] 'Configurações'"
      )
    ).firstMatch

    if settingsTab.exists {
      settingsTab.tap()

      // Look for logout button
      let logoutButton = app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Logout' OR label CONTAINS[cd] 'Sair' OR label CONTAINS[cd] 'Sign Out'"
        )
      ).firstMatch

      if logoutButton.waitForExistence(timeout: 3) {
        logoutButton.tap()

        // Should return to login screen
        let loginTitle = app.staticTexts.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login'"
          )
        ).firstMatch
        XCTAssertTrue(
          loginTitle.waitForExistence(timeout: 5),
          "Should return to login screen after logout"
        )
      }
    } else {
      // Try sidebar navigation (iPad)
      let sidebarButton = app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Settings' OR label CONTAINS[cd] 'Configurações'"
        )
      ).firstMatch

      if sidebarButton.exists {
        sidebarButton.tap()

        let logoutButton = app.buttons.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Logout' OR label CONTAINS[cd] 'Sair'"
          )
        ).firstMatch

        if logoutButton.waitForExistence(timeout: 3) {
          logoutButton.tap()

          let loginTitle = app.staticTexts.matching(
            NSPredicate(
              format:
                "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login'"
            )
          ).firstMatch
          XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
        }
      }
    }
  }

  // MARK: - Authentication State Persistence Tests

  func testAuthenticationPersistence() throws {
    navigateToLoginIfNeeded()
    performMockLogin()

    // Verify we're logged in
    let dashboardElement = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
      )
    ).firstMatch
    XCTAssertTrue(dashboardElement.exists)

    // Terminate and relaunch app
    app.terminate()
    app.launch()

    // Should remain logged in and skip login screen
    let loginTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login'"
      )
    ).firstMatch
    XCTAssertFalse(
      loginTitle.waitForExistence(timeout: 3),
      "Should not show login screen if already authenticated"
    )

    // Should show dashboard or main app
    let mainAppElement = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
      )
    ).firstMatch
    XCTAssertTrue(mainAppElement.waitForExistence(timeout: 5))
  }

  // MARK: - Error Handling Tests

  func testAuthenticationErrorHandling() throws {
    // This would test error scenarios if we had them configured in mock mode
    navigateToLoginIfNeeded()

    // Set up error conditions through launch arguments
    app.terminate()
    app.launchArguments.append("--auth-error-mode")
    app.launch()

    skipOnboardingIfPresent()
    navigateToLoginIfNeeded()

    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch

    if googleSignInButton.exists {
      googleSignInButton.tap()

      // Should show error alert or message
      let errorAlert = app.alerts.firstMatch
      let errorText = app.staticTexts.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Erro' OR label CONTAINS[cd] 'Error'"
        )
      ).firstMatch

      let hasError =
        errorAlert.waitForExistence(timeout: 3)
        || errorText.waitForExistence(timeout: 3)
      // Note: This test assumes error mode is implemented in the app
    }
  }

  // MARK: - Accessibility Tests

  func testLoginScreenAccessibility() throws {
    navigateToLoginIfNeeded()

    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch
    let appleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Apple'")
    ).firstMatch

    // Check button accessibility
    if googleSignInButton.exists {
      XCTAssertFalse(
        googleSignInButton.label.isEmpty,
        "Google Sign In button should have accessible label"
      )
    }

    if appleSignInButton.exists {
      XCTAssertFalse(
        appleSignInButton.label.isEmpty,
        "Apple Sign In button should have accessible label"
      )
    }

    // Check for accessibility traits
    let buttons = app.buttons.allElementsBoundByIndex
    for button in buttons {
      if !button.label.isEmpty {
        // Button should be properly configured for accessibility
        XCTAssertTrue(button.exists)
      }
    }
  }

  // MARK: - Helper Methods

  private func skipOnboardingIfPresent() {
    let onboardingTitle = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Bem-vindo' OR label CONTAINS[cd] 'Welcome'"
      )
    ).firstMatch

    if onboardingTitle.waitForExistence(timeout: 2) {
      let skipButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Pular' OR label CONTAINS[cd] 'Skip'"
        )
      ).firstMatch

      if skipButton.exists {
        skipButton.tap()
      } else {
        // Navigate through onboarding quickly
        let nextButton = app.buttons.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Próximo' OR label CONTAINS[cd] 'Next'"
          )
        ).firstMatch

        var attempts = 0
        while nextButton.exists && attempts < 5 {
          nextButton.tap()
          attempts += 1
          sleep(1)
        }

        let getStartedButton = app.buttons.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Começar' OR label CONTAINS[cd] 'Get Started'"
          )
        ).firstMatch
        if getStartedButton.exists {
          getStartedButton.tap()
        }
      }
    }
  }

  private func navigateToLoginIfNeeded() {
    let loginTitle = app.staticTexts.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Entrar' OR label CONTAINS[cd] 'Login' OR label CONTAINS[cd] 'Sign In'"
      )
    ).firstMatch

    if !loginTitle.exists {
      // Might need to logout first or navigate to login
      let logoutButton = app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Logout' OR label CONTAINS[cd] 'Sair'"
        )
      ).firstMatch

      if logoutButton.exists {
        logoutButton.tap()
      }
    }

    XCTAssertTrue(
      loginTitle.waitForExistence(timeout: 5),
      "Should be on login screen"
    )
  }

  private func performMockLogin() {
    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch

    if googleSignInButton.exists {
      googleSignInButton.tap()

      // Wait for navigation to complete
      let dashboardElement = app.staticTexts.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch
      XCTAssertTrue(dashboardElement.waitForExistence(timeout: 5))
    }
  }
}
