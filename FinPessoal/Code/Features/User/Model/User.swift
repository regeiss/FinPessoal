//
//  User.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import FirebaseAuth

struct User: Identifiable, Codable {
  let id: String
  let name: String
  let email: String
  let profileImageURL: String?
  let createdAt: Date
  let settings: UserSettings
  
  init(id: String, name: String, email: String, profileImageURL: String? = nil, createdAt: Date = Date(), settings: UserSettings = UserSettings()) {
    self.id = id
    self.name = name
    self.email = email
    self.profileImageURL = profileImageURL
    self.createdAt = createdAt
    self.settings = settings
  }
  
  init(from firebaseUser: FirebaseAuth.User) {
    self.id = firebaseUser.uid
    self.name = firebaseUser.displayName ?? "Usuário"
    self.email = firebaseUser.email ?? ""
    self.profileImageURL = firebaseUser.photoURL?.absoluteString
    self.createdAt = firebaseUser.metadata.creationDate ?? Date()
    self.settings = UserSettings()
  }
}

struct UserSettings: Codable {
  var currency: String = "BRL"
  var language: String = "pt-BR"
  var notifications: Bool = true
  var biometricAuth: Bool = false
}
