//
//  AppError.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

enum AppError: LocalizedError, Identifiable {
  case authenticationFailed(String)
  case networkError(String)
  case databaseError(String)
  case validationError(String)
  case unknownError
  
  var id: String {
    return errorDescription ?? "unknown"
  }
  
  var errorDescription: String? {
    switch self {
    case .authenticationFailed(let message):
      return NSLocalizedString("error.auth.failed", comment: "Authentication failed") + ": \(message)"
    case .networkError(let message):
      return NSLocalizedString("error.network", comment: "Network error") + ": \(message)"
    case .databaseError(let message):
      return NSLocalizedString("error.database", comment: "Database error") + ": \(message)"
    case .validationError(let message):
      return NSLocalizedString("error.validation", comment: "Validation error") + ": \(message)"
    case .unknownError:
      return NSLocalizedString("error.unknown", comment: "Unknown error")
    }
  }
  
  var recoverySuggestion: String? {
    switch self {
    case .authenticationFailed:
      return NSLocalizedString("error.auth.recovery", comment: "Please check your credentials and try again")
    case .networkError:
      return NSLocalizedString("error.network.recovery", comment: "Please check your internet connection")
    case .databaseError:
      return NSLocalizedString("error.database.recovery", comment: "Please try again later")
    case .validationError:
      return NSLocalizedString("error.validation.recovery", comment: "Please check your input and try again")
    case .unknownError:
      return NSLocalizedString("error.unknown.recovery", comment: "Please try again")
    }
  }
}
