//
//  AppConfig.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation

enum AppEnvironment {
  case development
  case staging
  case production
  
  static var current: AppEnvironment {
#if DEBUG
    return .development
#elseif STAGING
    return .staging
#else
    return .production
#endif
  }
}

class AppConfiguration {
  static let shared = AppConfiguration()
  
  private init() {}
  
  var useMockData: Bool {
#if DEBUG
    // Override with UserDefaults for testing if available
    if UserDefaults.standard.object(forKey: "use_mock_data") != nil {
      return UserDefaults.standard.bool(forKey: "use_mock_data")
    }
#endif
    
    switch AppEnvironment.current {
    case .development:
      return false  // Use mock data for development to avoid empty transaction screen
    case .staging:
      return false // Use real Firebase for staging
    case .production:
      return false // Use real Firebase for production
    }
  }
  
  var shouldUsePersistence: Bool {
    return !useMockData
  }
  
  // MARK: - Repository Factory
  
  func createAuthRepository() -> AuthRepositoryProtocol {
    if useMockData {
      return MockAuthRepository()
    } else {
      return AuthRepository()
    }
  }
  
  func createFinanceRepository() -> FinanceRepositoryProtocol {
    if useMockData {
      return MockFinanceRepository()
    } else {
      return FinanceRepository()
    }
  }
  
  func createAccountRepository() -> AccountRepositoryProtocol {
    if useMockData {
      return MockAccountRepository()
    } else {
      return FirebaseAccountRepository()
    }
  }
  
  func createTransactionRepository() -> TransactionRepositoryProtocol {
    if useMockData {
      return MockTransactionRepository()
    } else {
      return FirebaseTransactionRepository()
    }
  }
  
  // MARK: - Firebase Configuration
  
  var firebaseConfig: [String: Any] {
    return [
      "persistence": shouldUsePersistence,
      "cacheSize": 10 * 1024 * 1024, // 10MB
      "offlineSupport": true
    ]
  }
  
  // MARK: - Debug Settings
  
  var enableLogging: Bool {
    return AppEnvironment.current == .development
  }
  
  var enableAnalytics: Bool {
    return AppEnvironment.current == .production
  }
}

// MARK: - Development Utilities

#if DEBUG
extension AppConfiguration {
  
  // Force use of real Firebase for testing
  func forceUseFirebase() {
    UserDefaults.standard.set(false, forKey: "use_mock_data")
  }
  
  // Force use of mocks for UI testing
  func forceUseMocks() {
    UserDefaults.standard.set(true, forKey: "use_mock_data")
  }
  
  // Override useMockData with UserDefaults for testing
  var useMockDataOverride: Bool {
    if UserDefaults.standard.object(forKey: "use_mock_data") != nil {
      return UserDefaults.standard.bool(forKey: "use_mock_data")
    }
    return useMockData
  }
}
#endif

// MARK: - Logger

class AppLogger {
  static let shared = AppLogger()
  
  private init() {}
  
  func log(_ message: String, level: LogLevel = .info) {
    guard AppConfiguration.shared.enableLogging else { return }
    
    let timestamp = DateFormatter.logTimestamp.string(from: Date())
    print("[\(timestamp)] [\(level.rawValue)] \(message)")
  }
  
  func logError(_ error: Error, context: String = "") {
    log("ERROR: \(context) - \(error.localizedDescription)", level: .error)
  }
}

enum LogLevel: String {
  case debug = "DEBUG"
  case info = "INFO"
  case warning = "WARNING"
  case error = "ERROR"
}

extension DateFormatter {
  static let logTimestamp: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter
  }()
}
