//
//  File.swift
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
