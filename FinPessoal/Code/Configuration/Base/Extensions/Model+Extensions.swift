//
//  Model+Extensions.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation

// MARK: - Account Extensions

extension Account {
  static func fromDictionary(_ data: [String: Any]) throws -> Account {
    guard let id = data["id"] as? String,
          let name = data["name"] as? String,
          let typeRawValue = data["type"] as? String,
          let type = AccountType(rawValue: typeRawValue),
          let balance = data["balance"] as? Double,
          let currency = data["currency"] as? String,
          let isActive = data["isActive"] as? Bool,
          let userId = data["userId"] as? String else {
      throw FirebaseError.invalidData
    }
    
    let createdAtTimestamp = data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
    let updatedAtTimestamp = data["updatedAt"] as? TimeInterval ?? Date().timeIntervalSince1970
    
    let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
    let updatedAt = Date(timeIntervalSince1970: updatedAtTimestamp)
    
    return Account(
      id: id,
      name: name,
      type: type,
      balance: balance,
      currency: currency,
      isActive: isActive,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
  
  func toDictionary() throws -> [String: Any] {
    return [
      "id": id,
      "name": name,
      "type": type.rawValue,
      "balance": balance,
      "currency": currency,
      "isActive": isActive,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]
  }
}

// MARK: - Transaction Extensions

extension Transaction {
  static func fromDictionary(_ data: [String: Any]) throws -> Transaction {
    guard let id = data["id"] as? String,
          let accountId = data["accountId"] as? String,
          let amount = data["amount"] as? Double,
          let description = data["description"] as? String,
          let categoryRawValue = data["category"] as? String,
          let category = TransactionCategory(rawValue: categoryRawValue),
          let typeRawValue = data["type"] as? String,
          let type = TransactionType(rawValue: typeRawValue),
          let dateTimestamp = data["date"] as? TimeInterval,
          let isRecurring = data["isRecurring"] as? Bool,
          let userId = data["userId"] as? String else {
      throw FirebaseError.invalidData
    }
    
    let date = Date(timeIntervalSince1970: dateTimestamp)
    
    let createdAtTimestamp = data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
    let updatedAtTimestamp = data["updatedAt"] as? TimeInterval ?? Date().timeIntervalSince1970
    
    let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
    let updatedAt = Date(timeIntervalSince1970: updatedAtTimestamp)
    
    return Transaction(
      id: id,
      accountId: accountId,
      amount: amount,
      description: description,
      category: category,
      type: type,
      date: date,
      isRecurring: isRecurring,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
  
  func toDictionary() throws -> [String: Any] {
    return [
      "id": id,
      "accountId": accountId,
      "amount": amount,
      "description": description,
      "category": category.rawValue,
      "type": type.rawValue,
      "date": date.timeIntervalSince1970,
      "isRecurring": isRecurring,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]
  }
}

// MARK: - Budget Extensions

extension Budget {
  static func fromDictionary(_ data: [String: Any]) throws -> Budget {
    guard let id = data["id"] as? String,
          let name = data["name"] as? String,
          let categoryRawValue = data["category"] as? String,
          let category = TransactionCategory(rawValue: categoryRawValue),
          let budgetAmount = data["budgetAmount"] as? Double,
          let spent = data["spent"] as? Double,
          let periodRawValue = data["period"] as? String,
          let period = BudgetPeriod(rawValue: periodRawValue),
          let startDateTimestamp = data["startDate"] as? TimeInterval,
          let endDateTimestamp = data["endDate"] as? TimeInterval,
          let isActive = data["isActive"] as? Bool,
          let alertThreshold = data["alertThreshold"] as? Double else {
      throw FirebaseError.invalidData
    }
    
    let startDate = Date(timeIntervalSince1970: startDateTimestamp)
    let endDate = Date(timeIntervalSince1970: endDateTimestamp)
    
    let userId = data["userId"] as? String
    
    let createdAtTimestamp = data["createdAt"] as? TimeInterval
    let updatedAtTimestamp = data["updatedAt"] as? TimeInterval
    
    let createdAt = createdAtTimestamp != nil ? Date(timeIntervalSince1970: createdAtTimestamp!) : nil
    let updatedAt = updatedAtTimestamp != nil ? Date(timeIntervalSince1970: updatedAtTimestamp!) : nil
    
    return Budget(
      id: id,
      name: name,
      category: category,
      budgetAmount: budgetAmount,
      spent: spent,
      period: period,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      alertThreshold: alertThreshold,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
  
  func toDictionary() throws -> [String: Any] {
    var dictionary: [String: Any] = [
      "id": id,
      "name": name,
      "category": category.rawValue,
      "budgetAmount": budgetAmount,
      "spent": spent,
      "period": period.rawValue,
      "startDate": startDate.timeIntervalSince1970,
      "endDate": endDate.timeIntervalSince1970,
      "isActive": isActive,
      "alertThreshold": alertThreshold
    ]
    
    if let userId = userId {
      dictionary["userId"] = userId
    }
    
    if let createdAt = createdAt {
      dictionary["createdAt"] = createdAt.timeIntervalSince1970
    }
    
    if let updatedAt = updatedAt {
      dictionary["updatedAt"] = updatedAt.timeIntervalSince1970
    }
    
    return dictionary
  }
}

// MARK: - User Extensions

extension User {
  static func fromDictionary(_ data: [String: Any]) throws -> User {
    guard let id = data["id"] as? String,
          let name = data["name"] as? String,
          let email = data["email"] as? String else {
      throw FirebaseError.invalidData
    }
    
    let profileImageURL = data["profileImageURL"] as? String
    
    let createdAtTimestamp = data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
    let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
    
    // Parse settings if available
    var settings = UserSettings()
    if let settingsData = data["settings"] as? [String: Any] {
      if let currency = settingsData["currency"] as? String {
        settings.currency = currency
      }
      if let language = settingsData["language"] as? String {
        settings.language = language
      }
      if let notifications = settingsData["notifications"] as? Bool {
        settings.notifications = notifications
      }
      if let biometricAuth = settingsData["biometricAuth"] as? Bool {
        settings.biometricAuth = biometricAuth
      }
    }
    
    return User(
      id: id,
      name: name,
      email: email,
      profileImageURL: profileImageURL,
      createdAt: createdAt,
      settings: settings
    )
  }
  
  func toDictionary() throws -> [String: Any] {
    var dictionary: [String: Any] = [
      "id": id,
      "name": name,
      "email": email,
      "createdAt": createdAt.timeIntervalSince1970,
      "settings": [
        "currency": settings.currency,
        "language": settings.language,
        "notifications": settings.notifications,
        "biometricAuth": settings.biometricAuth
      ]
    ]
    
    if let profileImageURL = profileImageURL {
      dictionary["profileImageURL"] = profileImageURL
    }
    
    return dictionary
  }
}
