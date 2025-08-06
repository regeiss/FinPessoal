//
//  Encodable+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import Foundation

extension Encodable {
  func toDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError(domain: "Invalid Dictionary", code: 0, userInfo: nil)
    }
    return dictionary
  }
}

extension Decodable {
  static func fromDictionary<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(T.self, from: data)
  }
}

// Extensões específicas para os modelos
extension Account {
  static func fromDictionary(_ dictionary: [String: Any]) throws -> Account {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(Account.self, from: data)
  }
}

extension Transaction {
  static func fromDictionary(_ dictionary: [String: Any]) throws -> Transaction {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(Transaction.self, from: data)
  }
}

extension Budget {
  static func fromDictionary(_ dictionary: [String: Any]) throws -> Budget {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(Budget.self, from: data)
  }
}

extension User {
  static func fromDictionary(_ dictionary: [String: Any]) throws -> User {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(User.self, from: data)
  }
}
