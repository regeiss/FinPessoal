//
//  FirebaseService+Extensions.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import FirebaseCore

// Extension para obter a app do Firebase (referenciado no FirebaseService)
extension FirebaseService {
  var app: FirebaseApp? {
    return FirebaseApp.app()
  }
}
