//
//  AuthError.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import Foundation

enum AuthError: LocalizedError {
  case noPresentingViewController
  case noClientID
  case noIDToken
  case invalidAppleCredential
  
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
    }
  }
}
