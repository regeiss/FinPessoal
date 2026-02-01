//
//  CreditCard+Firebase.swift
//  FinPessoal
//
//  Created by Claude Code on 24/12/25.ofx
//

import Foundation

// MARK: - CreditCard Firebase Extensions

extension CreditCard {
  func toDictionary() throws -> [String: Any] {
    return [
      "id": id,
      "name": name,
      "lastFourDigits": lastFourDigits,
      "brand": brand.rawValue,
      "creditLimit": creditLimit,
      "availableCredit": availableCredit,
      "currentBalance": currentBalance,
      "dueDate": dueDate,
      "closingDate": closingDate,
      "minimumPayment": minimumPayment,
      "annualFee": annualFee,
      "interestRate": interestRate,
      "isActive": isActive,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> CreditCard {
    guard let id = dict["id"] as? String,
          let name = dict["name"] as? String,
          let lastFourDigits = dict["lastFourDigits"] as? String,
          let brandRaw = dict["brand"] as? String,
          let brand = CreditCardBrand(rawValue: brandRaw),
          let creditLimit = dict["creditLimit"] as? Double,
          let availableCredit = dict["availableCredit"] as? Double,
          let currentBalance = dict["currentBalance"] as? Double,
          let dueDate = dict["dueDate"] as? Int,
          let closingDate = dict["closingDate"] as? Int,
          let minimumPayment = dict["minimumPayment"] as? Double,
          let annualFee = dict["annualFee"] as? Double,
          let interestRate = dict["interestRate"] as? Double,
          let isActive = dict["isActive"] as? Bool,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
          let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required CreditCard fields")
    }

    return CreditCard(
      id: id,
      name: name,
      lastFourDigits: lastFourDigits,
      brand: brand,
      creditLimit: creditLimit,
      availableCredit: availableCredit,
      currentBalance: currentBalance,
      dueDate: dueDate,
      closingDate: closingDate,
      minimumPayment: minimumPayment,
      annualFee: annualFee,
      interestRate: interestRate,
      isActive: isActive,
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
      updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
    )
  }
}

// MARK: - CreditCardTransaction Firebase Extensions

extension CreditCardTransaction {
  func toDictionary() throws -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "creditCardId": creditCardId,
      "amount": amount,
      "description": description,
      "category": category.rawValue,
      "date": date.timeIntervalSince1970,
      "installments": installments,
      "currentInstallment": currentInstallment,
      "isRecurring": isRecurring,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]

    if let subcategory = subcategory {
      dict["subcategory"] = subcategory.rawValue
    }

    return dict
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> CreditCardTransaction {
    guard let id = dict["id"] as? String,
          let creditCardId = dict["creditCardId"] as? String,
          let amount = dict["amount"] as? Double,
          let description = dict["description"] as? String,
          let categoryRaw = dict["category"] as? String,
          let category = TransactionCategory(rawValue: categoryRaw),
          let dateTimestamp = dict["date"] as? TimeInterval,
          let installments = dict["installments"] as? Int,
          let currentInstallment = dict["currentInstallment"] as? Int,
          let isRecurring = dict["isRecurring"] as? Bool,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
          let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required CreditCardTransaction fields")
    }

    let subcategory: TransactionSubcategory?
    if let subcategoryRaw = dict["subcategory"] as? String {
      subcategory = TransactionSubcategory(rawValue: subcategoryRaw)
    } else {
      subcategory = nil
    }

    return CreditCardTransaction(
      id: id,
      creditCardId: creditCardId,
      amount: amount,
      description: description,
      category: category,
      subcategory: subcategory,
      date: Date(timeIntervalSince1970: dateTimestamp),
      installments: installments,
      currentInstallment: currentInstallment,
      isRecurring: isRecurring,
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
      updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
    )
  }
}

// MARK: - CreditCardStatement Firebase Extensions

extension CreditCardStatement {
  func toDictionary() throws -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "creditCardId": creditCardId,
      "periodStartDate": period.startDate.timeIntervalSince1970,
      "periodEndDate": period.endDate.timeIntervalSince1970,
      "totalAmount": totalAmount,
      "minimumPayment": minimumPayment,
      "dueDate": dueDate.timeIntervalSince1970,
      "isPaid": isPaid,
      "paidAmount": paidAmount,
      "createdAt": createdAt.timeIntervalSince1970
    ]

    if let paidDate = paidDate {
      dict["paidDate"] = paidDate.timeIntervalSince1970
    }

    return dict
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> CreditCardStatement {
    guard let id = dict["id"] as? String,
          let creditCardId = dict["creditCardId"] as? String,
          let periodStartTimestamp = dict["periodStartDate"] as? TimeInterval,
          let periodEndTimestamp = dict["periodEndDate"] as? TimeInterval,
          let totalAmount = dict["totalAmount"] as? Double,
          let minimumPayment = dict["minimumPayment"] as? Double,
          let dueDateTimestamp = dict["dueDate"] as? TimeInterval,
          let isPaid = dict["isPaid"] as? Bool,
          let paidAmount = dict["paidAmount"] as? Double,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required CreditCardStatement fields")
    }

    let period = StatementPeriod(
      startDate: Date(timeIntervalSince1970: periodStartTimestamp),
      endDate: Date(timeIntervalSince1970: periodEndTimestamp)
    )

    let paidDate: Date?
    if let paidDateTimestamp = dict["paidDate"] as? TimeInterval {
      paidDate = Date(timeIntervalSince1970: paidDateTimestamp)
    } else {
      paidDate = nil
    }

    return CreditCardStatement(
      id: id,
      creditCardId: creditCardId,
      period: period,
      transactions: [], // Transactions will be loaded separately
      totalAmount: totalAmount,
      minimumPayment: minimumPayment,
      dueDate: Date(timeIntervalSince1970: dueDateTimestamp),
      isPaid: isPaid,
      paidAmount: paidAmount,
      paidDate: paidDate,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp)
    )
  }
}
