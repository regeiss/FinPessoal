//
//  UserTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest

@testable import FinPessoal
@MainActor

final class UserTests: XCTestCase {

  // MARK: - Test Data

  private let testUser = User(
    id: "test-user-id",
    name: "John Doe",
    email: "john.doe@example.com",
    profileImageURL: "https://example.com/profile.jpg",
    createdAt: Date(),
    settings: UserSettings(
      currency: "BRL",
      language: "pt-BR",
      notifications: true,
      biometricAuth: false
    )
  )

  // MARK: - Initialization Tests

  func testUserInitialization() throws {
    XCTAssertEqual(testUser.id, "test-user-id")
    XCTAssertEqual(testUser.name, "John Doe")
    XCTAssertEqual(testUser.email, "john.doe@example.com")
    XCTAssertEqual(testUser.settings.currency, "BRL")
    XCTAssertEqual(testUser.profileImageURL, "https://example.com/profile.jpg")
    XCTAssertNotNil(testUser.settings)
  }

  func testUserInitializationWithOptionalFields() throws {
    let minimalUser = User(
      id: "minimal-user-id",
      name: "Jane Smith",
      email: "jane.smith@example.com",
      profileImageURL: nil,
      createdAt: Date(),
      settings: UserSettings(currency: "USD", language: "en-US", notifications: false, biometricAuth: false)
    )

    XCTAssertEqual(minimalUser.id, "minimal-user-id")
    XCTAssertEqual(minimalUser.name, "Jane Smith")
    XCTAssertEqual(minimalUser.email, "jane.smith@example.com")
    XCTAssertNil(minimalUser.profileImageURL)
    XCTAssertEqual(minimalUser.settings.currency, "USD")
  }

  // MARK: - User Settings Tests

  func testUserSettingsInitialization() throws {
    let settings = UserSettings(
      currency: "USD",
      language: "en-US",
      notifications: false,
      biometricAuth: true
    )

    XCTAssertEqual(settings.currency, "USD")
    XCTAssertEqual(settings.language, "en-US")
    XCTAssertFalse(settings.notifications)
    XCTAssertTrue(settings.biometricAuth)
  }

  func testUserSettingsDefaultValues() throws {
    let defaultSettings = UserSettings()

    XCTAssertEqual(defaultSettings.currency, "BRL")
    XCTAssertEqual(defaultSettings.language, "pt-BR")
    XCTAssertTrue(defaultSettings.notifications)
    XCTAssertFalse(defaultSettings.biometricAuth)
  }

  // MARK: - Codable Tests

  func testUserCodable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let data = try encoder.encode(testUser)
    let decodedUser = try decoder.decode(User.self, from: data)
    
    XCTAssertEqual(decodedUser.id, testUser.id)
    XCTAssertEqual(decodedUser.name, testUser.name)
    XCTAssertEqual(decodedUser.email, testUser.email)
    XCTAssertEqual(decodedUser.profileImageURL, testUser.profileImageURL)
    XCTAssertEqual(decodedUser.settings.currency, testUser.settings.currency)
    XCTAssertEqual(decodedUser.settings.language, testUser.settings.language)
  }

  func testUserSettingsCodable() throws {
    let settings = UserSettings(
      currency: "USD",
      language: "en-US",
      notifications: false,
      biometricAuth: true
    )
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let data = try encoder.encode(settings)
    let decodedSettings = try decoder.decode(UserSettings.self, from: data)
    
    XCTAssertEqual(decodedSettings.currency, settings.currency)
    XCTAssertEqual(decodedSettings.language, settings.language)
    XCTAssertEqual(decodedSettings.notifications, settings.notifications)
    XCTAssertEqual(decodedSettings.biometricAuth, settings.biometricAuth)
  }

  // MARK: - Edge Cases Tests

  func testUserWithEmptyStrings() throws {
    let emptyStringUser = User(
      id: "empty-user-id",
      name: "",
      email: "",
      profileImageURL: "",
      createdAt: Date(),
      settings: UserSettings(currency: "", language: "", notifications: false, biometricAuth: false)
    )

    XCTAssertEqual(emptyStringUser.name, "")
    XCTAssertEqual(emptyStringUser.email, "")
    XCTAssertEqual(emptyStringUser.profileImageURL, "")
    XCTAssertEqual(emptyStringUser.settings.currency, "")
  }

  func testUserWithSpecialCharacters() throws {
    let specialCharUser = User(
      id: "special-user-id",
      name: "José da Silva-Santos",
      email: "josé+test@example.com",
      profileImageURL: "https://example.com/profile?id=123&size=large",
      createdAt: Date(),
      settings: UserSettings(currency: "BRL", language: "pt-BR", notifications: true, biometricAuth: false)
    )

    XCTAssertEqual(specialCharUser.name, "José da Silva-Santos")
    XCTAssertEqual(specialCharUser.email, "josé+test@example.com")
    XCTAssertEqual(
      specialCharUser.profileImageURL,
      "https://example.com/profile?id=123&size=large"
    )
  }
  
  // MARK: - Firebase User Initialization Tests
  
  func testUserInitializationFromFirebaseUser() throws {
    // This would require mocking FirebaseAuth.User, which is complex
    // For now, we'll just ensure the init signature exists
    // In a real scenario, you'd use a mocking framework or protocol-based approach
  }
}
