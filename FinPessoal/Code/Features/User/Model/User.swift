//
//  User.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct User: Codable, Identifiable {
  let id: String
  let name: String
  let email: String
  let createdAt: Date
  let isActive: Bool
  
  enum CodingKeys: String, CodingKey {
    case id, name, email, createdAt, isActive
  }
}
