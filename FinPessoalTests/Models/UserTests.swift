//
//  UserTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest

@testable import FinPessoal

final class UserTests: XCTestCase {

  // MARK: - Test Data

  private let testUser = User(
    id: "test-user-id",
    name: "John Doe",
    email: "john.doe@example.com",
    phoneNumber: "+55 11 99999-9999",
    currency: "BRL",
    profileImageURL: "https://example.com/profile.jpg",
    createdAt: Date(),
    lastLoginAt: Date(),
    isEmailVerified: true,
    preferences: UserPreferences(
      theme: .system,
      language: "pt-BR",
      notificationsEnabled: true,
      biometricEnabled: false
    )
  )

  // MARK: - Initialization Tests

  func testUserInitialization() throws {
    XCTAssertEqual(testUser.id, "test-user-id")
    XCTAssertEqual(testUser.name, "John Doe")
    XCTAssertEqual(testUser.email, "john.doe@example.com")
    XCTAssertEqual(testUser.phoneNumber, "+55 11 99999-9999")
    XCTAssertEqual(testUser.currency, "BRL")
    XCTAssertEqual(testUser.profileImageURL, "https://example.com/profile.jpg")
    XCTAssertTrue(testUser.isEmailVerified)
    XCTAssertNotNil(testUser.preferences)
  }

  func testUserInitializationWithOptionalFields() throws {
    let minimalUser = User(
      id: "minimal-user-id",
      name: "Jane Smith",
      email: "jane.smith@example.com",
      phoneNumber: nil,
      currency: "USD",
      profileImageURL: nil,
      createdAt: Date(),
      lastLoginAt: nil,
      isEmailVerified: false,
      preferences: UserPreferences()
    )

    XCTAssertEqual(minimalUser.id, "minimal-user-id")
    XCTAssertEqual(minimalUser.name, "Jane Smith")
    XCTAssertEqual(minimalUser.email, "jane.smith@example.com")
    XCTAssertNil(minimalUser.phoneNumber)
    XCTAssertEqual(minimalUser.currency, "USD")
    XCTAssertNil(minimalUser.profileImageURL)
    XCTAssertNil(minimalUser.lastLoginAt)
    XCTAssertFalse(minimalUser.isEmailVerified)
  }

  // MARK: - User Preferences Tests

  func testUserPreferencesInitialization() throws {
    let preferences = UserPreferences(
      theme: .dark,
      language: "en-US",
      notificationsEnabled: false,
      biometricEnabled: true
    )

    XCTAssertEqual(preferences.theme, .dark)
    XCTAssertEqual(preferences.language, "en-US")
    XCTAssertFalse(preferences.notificationsEnabled)
    XCTAssertTrue(preferences.biometricEnabled)
  }

  func testUserPreferencesDefaultValues() throws {
    let defaultPreferences = UserPreferences()

    XCTAssertEqual(defaultPreferences.theme, .system)
    XCTAssertEqual(defaultPreferences.language, "pt-BR")
    XCTAssertTrue(defaultPreferences.notificationsEnabled)
    XCTAssertFalse(defaultPreferences.biometricEnabled)
  }

  // MARK: - Dictionary Conversion Tests

  func testUserToDictionary() throws {
    let dictionary = testUser.toDictionary()

    XCTAssertEqual(dictionary["id"] as? String, "test-user-id")
    XCTAssertEqual(dictionary["name"] as? String, "John Doe")
    XCTAssertEqual(dictionary["email"] as? String, "john.doe@example.com")
    XCTAssertEqual(dictionary["phoneNumber"] as? String, "+55 11 99999-9999")
    XCTAssertEqual(dictionary["currency"] as? String, "BRL")
    XCTAssertEqual(
      dictionary["profileImageURL"] as? String,
      "https://example.com/profile.jpg"
    )
    XCTAssertEqual(dictionary["isEmailVerified"] as? Bool, true)
    XCTAssertNotNil(dictionary["createdAt"])
    XCTAssertNotNil(dictionary["lastLoginAt"])
    XCTAssertNotNil(dictionary["preferences"])
  }

  func testUserFromDictionary() throws {
    let dictionary: [String: Any] = [
      "id": "dict-user-id",
      "name": "Dictionary User",
      "email": "dict@example.com",
      "phoneNumber": "+1 555-1234",
      "currency": "USD",
      "profileImageURL": "https://example.com/dict.jpg",
      "createdAt": Date().timeIntervalSince1970,
      "lastLoginAt": Date().timeIntervalSince1970,
      "isEmailVerified": false,
      "preferences": [
        "theme": "dark",
        "language": "en-US",
        "notificationsEnabled": false,
        "biometricEnabled": true,
      ],
    ]

    let user = try XCTUnwrap(User.fromDictionary(dictionary))

    XCTAssertEqual(user.id, "dict-user-id")
    XCTAssertEqual(user.name, "Dictionary User")
    XCTAssertEqual(user.email, "dict@example.com")
    XCTAssertEqual(user.phoneNumber, "+1 555-1234")
    XCTAssertEqual(user.currency, "USD")
    XCTAssertEqual(user.profileImageURL, "https://example.com/dict.jpg")
    XCTAssertFalse(user.isEmailVerified)
    XCTAssertEqual(user.preferences?.theme, .dark)
    XCTAssertEqual(user.preferences?.language, "en-US")
    XCTAssertEqual(user.preferences?.notificationsEnabled, false)
    XCTAssertEqual(user.preferences?.biometricEnabled, true)
  }

  func testUserFromDictionaryWithMissingOptionalFields() throws {
    let dictionary: [String: Any] = [
      "id": "minimal-dict-user-id",
      "name": "Minimal User",
      "email": "minimal@example.com",
      "currency": "EUR",
      "createdAt": Date().timeIntervalSince1970,
      "isEmailVerified": true,
      "preferences": [
        "theme": "light",
        "language": "pt-BR",
        "notificationsEnabled": true,
        "biometricEnabled": false,
      ],
    ]

    let user = try XCTUnwrap(User.fromDictionary(dictionary))

    XCTAssertEqual(user.id, "minimal-dict-user-id")
    XCTAssertEqual(user.name, "Minimal User")
    XCTAssertEqual(user.email, "minimal@example.com")
    XCTAssertNil(user.phoneNumber)
    XCTAssertEqual(user.currency, "EUR")
    XCTAssertNil(user.profileImageURL)
    XCTAssertNil(user.lastLoginAt)
    XCTAssertTrue(user.isEmailVerified)
  }

  func testUserFromDictionaryWithInvalidData() throws {
    let invalidDictionary: [String: Any] = [
      "id": "invalid-user",
      "name": "Invalid User",
        // Missing required fields like email, currency, etc.
    ]

    XCTAssertNil(User.fromDictionary(invalidDictionary))
  }

  // MARK: - UserPreferences Dictionary Conversion Tests

  func testUserPreferencesToDictionary() throws {
    let preferences = UserPreferences(
      theme: .dark,
      language: "es-ES",
      notificationsEnabled: false,
      biometricEnabled: true
    )

    let dictionary = preferences.toDictionary()

    XCTAssertEqual(dictionary["theme"] as? String, "dark")
    XCTAssertEqual(dictionary["language"] as? String, "es-ES")
    XCTAssertEqual(dictionary["notificationsEnabled"] as? Bool, false)
    XCTAssertEqual(dictionary["biometricEnabled"] as? Bool, true)
  }

  func testUserPreferencesFromDictionary() throws {
    let dictionary: [String: Any] = [
      "theme": "light",
      "language": "fr-FR",
      "notificationsEnabled": true,
      "biometricEnabled": false,
    ]

    let preferences = try XCTUnwrap(UserPreferences.fromDictionary(dictionary))

    XCTAssertEqual(preferences.theme, .light)
    XCTAssertEqual(preferences.language, "fr-FR")
    XCTAssertTrue(preferences.notificationsEnabled)
    XCTAssertFalse(preferences.biometricEnabled)
  }

  func testUserPreferencesFromDictionaryWithMissingFields() throws {
    let partialDictionary: [String: Any] = [
      "theme": "system",
      "notificationsEnabled": false,
        // Missing language and biometricEnabled
    ]

    let preferences = try XCTUnwrap(
      UserPreferences.fromDictionary(partialDictionary)
    )

    XCTAssertEqual(preferences.theme, .system)
    XCTAssertEqual(preferences.language, "pt-BR")  // Default value
    XCTAssertFalse(preferences.notificationsEnabled)
    XCTAssertFalse(preferences.biometricEnabled)  // Default value
  }

  // MARK: - Edge Cases Tests

  func testUserWithEmptyStrings() throws {
    let emptyStringUser = User(
      id: "empty-user-id",
      name: "",
      email: "",
      phoneNumber: "",
      currency: "",
      profileImageURL: "",
      createdAt: Date(),
      lastLoginAt: Date(),
      isEmailVerified: false,
      preferences: UserPreferences()
    )

    XCTAssertEqual(emptyStringUser.name, "")
    XCTAssertEqual(emptyStringUser.email, "")
    XCTAssertEqual(emptyStringUser.phoneNumber, "")
    XCTAssertEqual(emptyStringUser.currency, "")
    XCTAssertEqual(emptyStringUser.profileImageURL, "")
  }

  func testUserWithSpecialCharacters() throws {
    let specialCharUser = User(
      id: "special-user-id",
      name: "José da Silva-Santos",
      email: "josé+test@example.com",
      phoneNumber: "+55 (11) 99999-9999",
      currency: "BRL",
      profileImageURL: "https://example.com/profile?id=123&size=large",
      createdAt: Date(),
      lastLoginAt: Date(),
      isEmailVerified: true,
      preferences: UserPreferences()
    )

    XCTAssertEqual(specialCharUser.name, "José da Silva-Santos")
    XCTAssertEqual(specialCharUser.email, "josé+test@example.com")
    XCTAssertEqual(specialCharUser.phoneNumber, "+55 (11) 99999-9999")
    XCTAssertEqual(
      specialCharUser.profileImageURL,
      "https://example.com/profile?id=123&size=large"
    )
  }
}
