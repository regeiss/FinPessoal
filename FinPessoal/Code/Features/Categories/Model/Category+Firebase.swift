//
//  Category+Firebase.swift
//  FinPessoal
//
//  Created by Claude Code on 25/12/25.
//

import Foundation

// MARK: - Category Firebase Extensions

extension Category {
  func toDictionary() throws -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "name": name,
      "icon": icon,
      "color": color,
      "transactionType": transactionType.rawValue,
      "isActive": isActive,
      "sortOrder": sortOrder,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]

    if let description = description {
      dict["description"] = description
    }

    return dict
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> Category {
    guard let id = dict["id"] as? String,
          let name = dict["name"] as? String,
          let icon = dict["icon"] as? String,
          let color = dict["color"] as? String,
          let transactionTypeRaw = dict["transactionType"] as? String,
          let transactionType = TransactionType(rawValue: transactionTypeRaw),
          let isActive = dict["isActive"] as? Bool,
          let sortOrder = dict["sortOrder"] as? Int,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
          let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required Category fields")
    }

    let description = dict["description"] as? String

    return Category(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color,
      transactionType: transactionType,
      isActive: isActive,
      sortOrder: sortOrder,
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
      updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
    )
  }
}
