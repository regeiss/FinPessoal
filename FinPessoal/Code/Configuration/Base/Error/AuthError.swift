//
//  AuthError.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import Foundation
import FirebaseAuth

enum AuthError: LocalizedError, Equatable {
  case noPresentingViewController
  case noClientID
  case noIDToken
  case invalidAppleCredential
  case noCurrentUser
  case emailAlreadyInUse
  case weakPassword
  case invalidEmail
  case userNotFound
  case wrongPassword
  case networkError
  case userDisabled
  case tooManyRequests
  case operationNotAllowed
  case unknown(String)
  
  var errorDescription: String? {
    switch self {
    case .noPresentingViewController:
      return "Não foi possível encontrar a view controller para apresentação"
    case .noClientID:
      return "Client ID não configurado"
    case .noIDToken:
      return "Token de ID não encontrado"
    case .invalidAppleCredential:
      return "Credencial do Apple ID inválida"
    case .noCurrentUser:
      return "Nenhum usuário autenticado"
    case .emailAlreadyInUse:
      return "Este email já está sendo usado por outra conta"
    case .weakPassword:
      return "A senha é muito fraca"
    case .invalidEmail:
      return "Email inválido"
    case .userNotFound:
      return "Usuário não encontrado"
    case .wrongPassword:
      return "Senha incorreta"
    case .networkError:
      return "Erro de conexão. Verifique sua internet"
    case .userDisabled:
      return "Esta conta foi desabilitada"
    case .tooManyRequests:
      return "Muitas tentativas. Tente novamente mais tarde"
    case .operationNotAllowed:
      return "Operação não permitida"
    case .unknown(let message):
      return "Erro desconhecido: \(message)"
    }
  }
  
  var recoverySuggestion: String? {
    switch self {
    case .noPresentingViewController:
      return "Tente novamente"
    case .noClientID:
      return "Verifique a configuração do Firebase"
    case .noIDToken:
      return "Tente fazer login novamente"
    case .invalidAppleCredential:
      return "Tente usar o Apple ID novamente"
    case .noCurrentUser:
      return "Faça login primeiro"
    case .emailAlreadyInUse:
      return "Tente fazer login ou use outro email"
    case .weakPassword:
      return "Use uma senha com pelo menos 8 caracteres"
    case .invalidEmail:
      return "Verifique o formato do email"
    case .userNotFound:
      return "Verifique o email ou crie uma nova conta"
    case .wrongPassword:
      return "Verifique a senha ou redefina-a"
    case .networkError:
      return "Verifique sua conexão e tente novamente"
    case .userDisabled:
      return "Entre em contato com o suporte"
    case .tooManyRequests:
      return "Aguarde alguns minutos antes de tentar novamente"
    case .operationNotAllowed:
      return "Entre em contato com o suporte"
    case .unknown:
      return "Tente novamente ou entre em contato com o suporte"
    }
  }
}

// MARK: - Firebase Auth Error Mapping

extension AuthError {
  static func from(_ error: Error) -> AuthError {
    // Se for um NSError, tenta extrair o código do erro
    guard let nsError = error as NSError? else {
      return .unknown(error.localizedDescription)
    }
    
    // Verifica se é um erro do Firebase Auth baseado no domain
    guard nsError.domain == "FIRAuthErrorDomain" else {
      return .unknown(error.localizedDescription)
    }
    
    // Mapeia os códigos de erro do Firebase Auth
    switch nsError.code {
    case 17007: // FIRAuthErrorCodeEmailAlreadyInUse
      return .emailAlreadyInUse
    case 17026: // FIRAuthErrorCodeWeakPassword
      return .weakPassword
    case 17008: // FIRAuthErrorCodeInvalidEmail
      return .invalidEmail
    case 17011: // FIRAuthErrorCodeUserNotFound
      return .userNotFound
    case 17009: // FIRAuthErrorCodeWrongPassword
      return .wrongPassword
    case 17020: // FIRAuthErrorCodeNetworkError
      return .networkError
    case 17005: // FIRAuthErrorCodeUserDisabled
      return .userDisabled
    case 17010: // FIRAuthErrorCodeTooManyRequests
      return .tooManyRequests
    case 17006: // FIRAuthErrorCodeOperationNotAllowed
      return .operationNotAllowed
    default:
      return .unknown(error.localizedDescription)
    }
  }
}

// MARK: - Alternative mapping using string comparison (more reliable)

extension AuthError {
  static func fromFirebaseError(_ error: Error) -> AuthError {
    let errorMessage = error.localizedDescription.lowercased()
    
    if errorMessage.contains("email") && errorMessage.contains("already") {
      return .emailAlreadyInUse
    } else if errorMessage.contains("weak") || errorMessage.contains("password") && errorMessage.contains("short") {
      return .weakPassword
    } else if errorMessage.contains("invalid") && errorMessage.contains("email") {
      return .invalidEmail
    } else if errorMessage.contains("user") && errorMessage.contains("not found") {
      return .userNotFound
    } else if errorMessage.contains("wrong") || errorMessage.contains("incorrect") {
      return .wrongPassword
    } else if errorMessage.contains("network") || errorMessage.contains("connection") {
      return .networkError
    } else if errorMessage.contains("disabled") {
      return .userDisabled
    } else if errorMessage.contains("too many") || errorMessage.contains("rate") {
      return .tooManyRequests
    } else if errorMessage.contains("operation") && errorMessage.contains("not allowed") {
      return .operationNotAllowed
    } else {
      return .unknown(error.localizedDescription)
    }
  }
}

// MARK: - Helper Methods

extension AuthError {
  var isRecoverable: Bool {
    switch self {
    case .wrongPassword, .invalidEmail, .userNotFound, .weakPassword:
      return true
    case .networkError, .tooManyRequests:
      return true
    case .userDisabled, .operationNotAllowed:
      return false
    default:
      return false
    }
  }
  
  var shouldShowRetry: Bool {
    switch self {
    case .networkError, .tooManyRequests, .noPresentingViewController:
      return true
    default:
      return false
    }
  }
  
  var priority: ErrorPriority {
    switch self {
    case .userDisabled, .operationNotAllowed:
      return .high
    case .tooManyRequests, .networkError:
      return .medium
    default:
      return .low
    }
  }
}

enum ErrorPriority {
  case low
  case medium
  case high
}
