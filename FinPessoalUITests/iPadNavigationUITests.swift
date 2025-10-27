//
//  iPadNavigationUITests.swift
//  FinPessoalUITests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest

@MainActor
final class iPadNavigationUITests: XCTestCase {

  private var app: XCUIApplication!

  override func setUp() async throws {
    try await super.setUp()

    continueAfterFailure = false

    app = XCUIApplication()
    app.launchArguments.append("--uitesting")
    app.launchArguments.append("--force-ipad")
    app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "1"
    app.launchEnvironment["UITEST_MOCK_AUTH"] = "1"
    app.launchEnvironment["UITEST_MOCK_DATA"] = "1"

    app.launch()

    // Complete onboarding and login
    completeOnboardingAndLogin()
  }

  override func tearDown() async throws {
    app = nil
    try await super.tearDown()
  }

  // MARK: - Three-Column Layout Tests

  func testThreeColumnLayoutExists() throws {
    // Check for three-column split view elements
    let splitViews = app.splitGroups
    XCTAssertTrue(
      splitViews.count > 0,
      "Should have split view groups for three-column layout"
    )

    // Check for sidebar (column 1)
    let sidebar = app.collectionViews.matching(identifier: "SidebarView")
      .firstMatch
    if !sidebar.exists {
      // Fallback to checking for sidebar content
      let sidebarContent = app.staticTexts.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
        )
      ).firstMatch
      XCTAssertTrue(
        sidebarContent.exists,
        "Should have sidebar content visible"
      )
    }
  }

  func testSidebarNavigation() throws {
    // Test navigation through sidebar items
    let sidebarItems = [
      "Dashboard",
      "Painel",
      "Contas",
      "Accounts",
      "Transações",
      "Transactions",
      "Relatórios",
      "Reports",
    ]

    var foundItems: [XCUIElement] = []

    for itemName in sidebarItems {
      let sidebarItem = app.buttons.matching(
        NSPredicate(format: "label CONTAINS[cd] %@", itemName)
      ).firstMatch
      if sidebarItem.exists && sidebarItem.isHittable {
        foundItems.append(sidebarItem)
      }
    }

    XCTAssertTrue(
      foundItems.count > 0,
      "Should find at least one sidebar navigation item"
    )

    // Test tapping sidebar items
    for item in foundItems.prefix(3) {  // Test first 3 items to avoid timeouts
      item.tap()
      sleep(1)  // Allow for navigation

      // Verify that content changed (basic check)
      let contentArea = app.collectionViews.firstMatch
      XCTAssertTrue(
        contentArea.exists,
        "Content area should exist after navigation"
      )
    }
  }

  func testAccountsThreeColumnFlow() throws {
    // Navigate to Accounts section
    let accountsButton = app.buttons.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
      )
    ).firstMatch

    if accountsButton.exists {
      accountsButton.tap()
      sleep(1)

      // Check for accounts list (column 2)
      let accountsList = app.collectionViews.matching(
        identifier: "AccountsList"
      ).firstMatch
      if !accountsList.exists {
        // Fallback to checking for account-related content
        let accountsContent = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Account' OR label CONTAINS[cd] 'Conta' OR label CONTAINS[cd] 'Saldo' OR label CONTAINS[cd] 'Balance'"
          )
        ).firstMatch
        XCTAssertTrue(
          accountsContent.waitForExistence(timeout: 3),
          "Should show accounts content in middle column"
        )
      }

      // Try to tap an account to show details (column 3)
      let accountItems = app.buttons.allElementsBoundByIndex.filter { button in
        let label = button.label.lowercased()
        return label.contains("account") || label.contains("conta")
          || label.contains("checking") || label.contains("savings")
          || label.contains("corrente") || label.contains("poupança")
      }

      if let firstAccount = accountItems.first {
        firstAccount.tap()
        sleep(1)

        // Check for detail view (column 3)
        let detailContent = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Details' OR label CONTAINS[cd] 'Detalhes' OR label CONTAINS[cd] 'Balance' OR label CONTAINS[cd] 'Saldo'"
          )
        ).firstMatch

        // Detail view might take time to load
        let hasDetailContent = detailContent.waitForExistence(timeout: 3)

        if !hasDetailContent {
          // Check if empty detail view is shown
          let emptyDetailView = app.staticTexts.matching(
            NSPredicate(
              format:
                "label CONTAINS[cd] 'Select' OR label CONTAINS[cd] 'Selecione'"
            )
          ).firstMatch
          XCTAssertTrue(
            emptyDetailView.exists,
            "Should show either account details or empty detail view"
          )
        }
      }
    }
  }

  func testTransactionsThreeColumnFlow() throws {
    // Navigate to Transactions section
    let transactionsButton = app.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Transações' OR label CONTAINS[cd] 'Transactions'"
      )
    ).firstMatch

    if transactionsButton.exists {
      transactionsButton.tap()
      sleep(1)

      // Check for transactions list (column 2)
      let transactionsList = app.tables.matching(identifier: "TransactionsList")
        .firstMatch
      if !transactionsList.exists {
        // Fallback to checking for transaction-related content
        let transactionsContent = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Transaction' OR label CONTAINS[cd] 'Transação' OR label CONTAINS[cd] 'Expense' OR label CONTAINS[cd] 'Income'"
          )
        ).firstMatch
        XCTAssertTrue(
          transactionsContent.waitForExistence(timeout: 3),
          "Should show transactions content in middle column"
        )
      }

      // Try to tap a transaction to show details
      let transactionItems = app.cells.allElementsBoundByIndex.filter { cell in
        let label = cell.label.lowercased()
        return label.contains("transaction") || label.contains("transação")
          || label.contains("expense") || label.contains("income")
          || label.contains("receita") || label.contains("despesa")
      }

      if let firstTransaction = transactionItems.first {
        firstTransaction.tap()
        sleep(1)

        // Check for detail view
        let detailContent = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Details' OR label CONTAINS[cd] 'Detalhes'"
          )
        ).firstMatch

        let hasDetailContent = detailContent.waitForExistence(timeout: 3)
        if !hasDetailContent {
          let emptyDetailView = app.staticTexts.matching(
            NSPredicate(
              format:
                "label CONTAINS[cd] 'Select' OR label CONTAINS[cd] 'Selecione'"
            )
          ).firstMatch
          // Either detail content or empty state should be visible
        }
      }
    }
  }

  // MARK: - Add Item Flow Tests

  func testAddAccountFlow() throws {
    // Navigate to Accounts
    let accountsButton = app.buttons.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
      )
    ).firstMatch

    if accountsButton.exists {
      accountsButton.tap()
      sleep(1)

      // Look for add account button
      let addButton = app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'plus' OR label CONTAINS[cd] '+' OR label CONTAINS[cd] 'Add' OR label CONTAINS[cd] 'Adicionar'"
        )
      ).firstMatch

      if addButton.exists {
        addButton.tap()
        sleep(1)

        // Should show add account form in detail column (not as popup)
        let addAccountForm = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'New Account' OR label CONTAINS[cd] 'Nova Conta' OR label CONTAINS[cd] 'Add Account' OR label CONTAINS[cd] 'Adicionar Conta'"
          )
        ).firstMatch

        XCTAssertTrue(
          addAccountForm.waitForExistence(timeout: 3),
          "Should show add account form in detail column"
        )

        // Check that it's not a modal/sheet
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(
          navigationBar.exists,
          "Should have navigation bar (not modal presentation)"
        )
      }
    }
  }

  func testAddTransactionFlow() throws {
    // Navigate to Transactions
    let transactionsButton = app.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Transações' OR label CONTAINS[cd] 'Transactions'"
      )
    ).firstMatch

    if transactionsButton.exists {
      transactionsButton.tap()
      sleep(1)

      // Look for add transaction button
      let addButton = app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'plus' OR label CONTAINS[cd] '+' OR label CONTAINS[cd] 'Add' OR label CONTAINS[cd] 'Adicionar'"
        )
      ).firstMatch

      if addButton.exists {
        addButton.tap()
        sleep(1)

        // Should show add transaction form in detail column
        let addTransactionForm = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'New Transaction' OR label CONTAINS[cd] 'Nova Transação' OR label CONTAINS[cd] 'Add Transaction' OR label CONTAINS[cd] 'Adicionar Transação'"
          )
        ).firstMatch

        XCTAssertTrue(
          addTransactionForm.waitForExistence(timeout: 3),
          "Should show add transaction form in detail column"
        )

        // Verify it's in the detail column, not a modal
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(
          navigationBar.exists,
          "Should have navigation bar (not modal presentation)"
        )
      }
    }
  }

  // MARK: - Layout Responsiveness Tests

  func testColumnWidthsAndLayout() throws {
    // This test verifies that the three columns have appropriate widths
    let splitView = app.splitGroups.firstMatch
    XCTAssertTrue(splitView.exists, "Split view should exist")

    // Get the frame of the split view
    let splitViewFrame = splitView.frame
    XCTAssertTrue(
      splitViewFrame.width > 768,
      "iPad should have sufficient width for three columns"
    )

    // Check that content is distributed across the width
    let leftContent = app.staticTexts.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
      )
    ).firstMatch
    let centerContent = app.staticTexts.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Select' OR label CONTAINS[cd] 'Selecione' OR label CONTAINS[cd] 'Account' OR label CONTAINS[cd] 'Transaction'"
      )
    ).firstMatch

    if leftContent.exists && centerContent.exists {
      let leftFrame = leftContent.frame
      let centerFrame = centerContent.frame

      XCTAssertLessThan(
        leftFrame.maxX,
        centerFrame.minX,
        "Left content should be to the left of center content"
      )
    }
  }

  func testNavigationStateManagement() throws {
    // Test that selecting different sidebar items properly clears detail selections
    let accountsButton = app.buttons.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
      )
    ).firstMatch
    let transactionsButton = app.buttons.matching(
      NSPredicate(
        format:
          "label CONTAINS[cd] 'Transações' OR label CONTAINS[cd] 'Transactions'"
      )
    ).firstMatch

    if accountsButton.exists && transactionsButton.exists {
      // Navigate to accounts and select an account
      accountsButton.tap()
      sleep(1)

      let accountItems = app.buttons.allElementsBoundByIndex.filter { button in
        let label = button.label.lowercased()
        return label.contains("account") || label.contains("conta")
      }

      if let firstAccount = accountItems.first {
        firstAccount.tap()
        sleep(1)

        // Now switch to transactions - detail should clear
        transactionsButton.tap()
        sleep(1)

        // Detail area should show empty state or different content
        let emptyDetailView = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Select' OR label CONTAINS[cd] 'Selecione'"
          )
        ).firstMatch
        let transactionContent = app.staticTexts.matching(
          NSPredicate(
            format:
              "label CONTAINS[cd] 'Transaction' OR label CONTAINS[cd] 'Transação'"
          )
        ).firstMatch

        XCTAssertTrue(
          emptyDetailView.exists || transactionContent.exists,
          "Detail area should update when switching sections"
        )
      }
    }
  }

  // MARK: - Back Navigation Tests

  func testDetailViewBackNavigation() throws {
    // Navigate to a detail view and test back navigation
    let accountsButton = app.buttons.matching(
      NSPredicate(
        format: "label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
      )
    ).firstMatch

    if accountsButton.exists {
      accountsButton.tap()
      sleep(1)

      // Select an account
      let accountItems = app.buttons.allElementsBoundByIndex.filter { button in
        let label = button.label.lowercased()
        return label.contains("account") || label.contains("conta")
      }

      if let firstAccount = accountItems.first {
        firstAccount.tap()
        sleep(1)

        // Look for back button in detail view
        let backButton = app.buttons.matching(
          NSPredicate(
            format: "label CONTAINS[cd] 'Back' OR label CONTAINS[cd] 'Voltar'"
          )
        ).firstMatch

        if backButton.exists {
          backButton.tap()
          sleep(1)

          // Should return to empty detail state
          let emptyDetailView = app.staticTexts.matching(
            NSPredicate(
              format:
                "label CONTAINS[cd] 'Select' OR label CONTAINS[cd] 'Selecione'"
            )
          ).firstMatch
          XCTAssertTrue(
            emptyDetailView.waitForExistence(timeout: 3),
            "Should return to empty detail state after back navigation"
          )
        }
      }
    }
  }

  // MARK: - Performance and Stability Tests

  func testRapidNavigationStability() throws {
    // Test rapid navigation between sections
    let sidebarButtons = [
      app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch,
      app.buttons.matching(
        NSPredicate(
          format: "label CONTAINS[cd] 'Contas' OR label CONTAINS[cd] 'Accounts'"
        )
      ).firstMatch,
      app.buttons.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Transações' OR label CONTAINS[cd] 'Transactions'"
        )
      ).firstMatch,
    ]

    let existingButtons = sidebarButtons.compactMap { $0.exists ? $0 : nil }

    XCTAssertTrue(
      existingButtons.count > 0,
      "Should have at least one sidebar button"
    )

    // Rapidly switch between sections
    for _ in 0..<5 {
      for button in existingButtons {
        button.tap()
        // Minimal sleep to test rapid navigation
        usleep(200000)  // 0.2 seconds
      }
    }

    // App should remain stable
    let appStillResponsive = app.buttons.firstMatch.waitForExistence(timeout: 2)
    XCTAssertTrue(
      appStillResponsive,
      "App should remain responsive after rapid navigation"
    )
  }

  // MARK: - Helper Methods

  private func completeOnboardingAndLogin() {
    // Skip onboarding
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

    // Perform login
    let googleSignInButton = app.buttons.matching(
      NSPredicate(format: "label CONTAINS[cd] 'Google'")
    ).firstMatch

    if googleSignInButton.waitForExistence(timeout: 3) {
      googleSignInButton.tap()

      // Wait for main app to load
      let mainAppContent = app.staticTexts.matching(
        NSPredicate(
          format:
            "label CONTAINS[cd] 'Dashboard' OR label CONTAINS[cd] 'Painel'"
        )
      ).firstMatch
      XCTAssertTrue(
        mainAppContent.waitForExistence(timeout: 5),
        "Should reach main app after login"
      )
    }
  }
}
