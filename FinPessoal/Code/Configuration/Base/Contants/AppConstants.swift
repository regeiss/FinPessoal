//
//  AppConstants.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import UIKit

// MARK: - Firebase Constants

enum FirebaseConstants {
  static let usersCollection = "users"
  static let accountsCollection = "accounts"
  static let transactionsCollection = "transactions"
  static let budgetsCollection = "budgets"
  static let goalsCollection = "goals"
  static let categoriesCollection = "categories"
  static let billsCollection = "bills"
  static let loansCollection = "loans"
  static let creditCardsCollection = "creditCards"
}

// MARK: - App Constants

enum AppConstants {
  static let defaultCurrency = "BRL"
  static let defaultLanguage = "pt-BR"
  static let maxTransactionsPerLoad = 50
  static let maxAccountsPerUser = 20
  static let maxBudgetsPerUser = 50
  static let maxTransactionDescriptionLength = 100
  static let maxAccountNameLength = 50
  static let maxBudgetNameLength = 50
  
  // Cache settings
  static let cacheExpirationTimeInterval: TimeInterval = 5 * 60 // 5 minutes
  static let maxCacheSize = 10 * 1024 * 1024 // 10MB
  
  // UI Constants
  static let defaultAnimationDuration: Double = 0.3
  static let defaultCornerRadius: Double = 12.0
  static let defaultPadding: Double = 16.0
}

// MARK: - Validation Constants

enum ValidationConstants {
  static let minPasswordLength = 8
  static let maxPasswordLength = 128
  static let minAccountNameLength = 1
  static let maxAccountNameLength = 50
  static let minTransactionDescriptionLength = 1
  static let maxTransactionDescriptionLength = 100
  static let minBudgetNameLength = 1
  static let maxBudgetNameLength = 50
  static let minTransactionAmount = 0.01
  static let maxTransactionAmount = 999999.99
  static let minBudgetAmount = 1.0
  static let maxBudgetAmount = 999999.99
}

// MARK: - Format Constants

enum FormatConstants {
  static let currencyCode = "BRL"
  static let localeIdentifier = "pt_BR"
  static let dateFormatShort = "dd/MM/yyyy"
  static let dateFormatLong = "dd 'de' MMMM 'de' yyyy"
  static let timeFormat = "HH:mm"
  static let dateTimeFormat = "dd/MM/yyyy HH:mm"
}

// MARK: - Network Constants

enum NetworkConstants {
  static let requestTimeout: TimeInterval = 30.0
  static let retryAttempts = 3
  static let retryDelay: TimeInterval = 1.0
}

// MARK: - Storage Constants

enum StorageConstants {
  static let userDefaultsPrefix = "FinPessoal_"
  static let keychainServiceName = "FinPessoal"
  static let documentsDirectoryName = "FinPessoal"
}

// MARK: - Analytics Constants

enum AnalyticsConstants {
  static let sessionTimeout: TimeInterval = 30 * 60 // 30 minutes
  static let maxEventsPerSession = 100
  static let maxEventNameLength = 50
  static let maxEventParameterCount = 25
}

// MARK: - Error Constants

enum ErrorConstants {
  static let defaultErrorMessage = "Ocorreu um erro inesperado"
  static let networkErrorMessage = "Verifique sua conexão com a internet"
  static let authErrorMessage = "Erro de autenticação"
  static let validationErrorMessage = "Dados inválidos"
}

// MARK: - Feature Flags

enum FeatureFlags {
  static let enableBiometricAuth = true
  static let enableOfflineMode = true
  static let enableAnalytics = true
  static let enableCrashReporting = true
  static let enablePerformanceMonitoring = true
  static let enableRemoteConfig = false
  static let enablePushNotifications = true
  static let enableDarkMode = true
  static let enableExportFeature = false
  static let enableBudgetSharing = false
}

// MARK: - URL Constants

enum URLConstants {
  static let privacyPolicyURL = "https://finpessoal.com/privacy"
  static let termsOfServiceURL = "https://finpessoal.com/terms"
  static let supportURL = "https://finpessoal.com/support"
  static let appStoreURL = "https://apps.apple.com/app/finpessoal/id123456789"
  static let contactEmail = "contato@finpessoal.com"
  static let supportEmail = "suporte@finpessoal.com"
}

// MARK: - Notification Constants

enum NotificationConstants {
  static let budgetAlertCategory = "BUDGET_ALERT"
  static let transactionReminderCategory = "TRANSACTION_REMINDER"
  static let monthlyReportCategory = "MONTHLY_REPORT"
  
  // Notification identifiers
  static let budgetOverLimitNotification = "budget_over_limit"
  static let budgetNearLimitNotification = "budget_near_limit"
  static let monthlyReportNotification = "monthly_report"
  static let transactionReminderNotification = "transaction_reminder"
}

// MARK: - System Constants

enum SystemConstants {
  static let minimumIOSVersion = "15.0"
  static let minimumSwiftVersion = "5.5"
  static let bundleIdentifier = "br.com.werkstatdg.FinPessoal"
  static let appName = "FinPessoal"
  static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
  static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
}

// MARK: - Helper Extensions

extension AppConstants {
  static var formattedAppVersion: String {
    return "\(SystemConstants.appName) v\(SystemConstants.appVersion) (\(SystemConstants.buildNumber))"
  }
  
  static var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
  
  static var deviceModel: String {
    return UIDevice.current.model
  }
  
  static var systemVersion: String {
    return UIDevice.current.systemVersion
  }
}
