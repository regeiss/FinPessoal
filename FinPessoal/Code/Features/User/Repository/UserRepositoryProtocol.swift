//
//  UserRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import FirebaseDatabase
import Combine
import FirebaseAuth

protocol UserRepositoryProtocol {
  func getCurrentUser() -> AnyPublisher<User?, AppError>
  func updateUser(_ user: User) -> AnyPublisher<Void, AppError>
  func deleteUser(_ userId: String) -> AnyPublisher<Void, AppError>
}

class UserRepository: UserRepositoryProtocol {
  private let database = Database.database().reference()
  
  func getCurrentUser() -> AnyPublisher<User?, AppError> {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
      return Just(nil)
        .setFailureType(to: AppError.self)
        .eraseToAnyPublisher()
    }
    
    return Future { promise in
      self.database.child("users").child(currentUserId).observeSingleEvent(of: .value) { snapshot in
        guard snapshot.exists() else {
          promise(.success(nil))
          return
        }
        
        do {
          let data = try JSONSerialization.data(withJSONObject: snapshot.value ?? [:])
          let user = try JSONDecoder().decode(User.self, from: data)
          promise(.success(user))
        } catch {
          promise(.failure(.databaseError(error.localizedDescription)))
        }
      } withCancel: { error in
        promise(.failure(.databaseError(error.localizedDescription)))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func updateUser(_ user: User) -> AnyPublisher<Void, AppError> {
    Future { promise in
      do {
        let data = try JSONEncoder().encode(user)
        let json = try JSONSerialization.jsonObject(with: data)
        
        self.database.child("users").child(user.id).setValue(json) { error, _ in
          if let error = error {
            promise(.failure(.databaseError(error.localizedDescription)))
          } else {
            promise(.success(()))
          }
        }
      } catch {
        promise(.failure(.databaseError(error.localizedDescription)))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func deleteUser(_ userId: String) -> AnyPublisher<Void, AppError> {
    Future { promise in
      self.database.child("users").child(userId).removeValue { error, _ in
        if let error = error {
          promise(.failure(.databaseError(error.localizedDescription)))
        } else {
          promise(.success(()))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
