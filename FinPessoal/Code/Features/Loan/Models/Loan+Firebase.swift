//
//  Loan+Firebase.swift
//  FinPessoal
//
//  Created by Claude Code on 24/12/25.
//

import Foundation

// MARK: - Loan Firebase Extensions

extension Loan {
  func toDictionary() throws -> [String: Any] {
    return [
      "id": id,
      "name": name,
      "loanType": loanType.rawValue,
      "principalAmount": principalAmount,
      "currentBalance": currentBalance,
      "interestRate": interestRate,
      "term": term,
      "monthlyPayment": monthlyPayment,
      "startDate": startDate.timeIntervalSince1970,
      "endDate": endDate.timeIntervalSince1970,
      "paymentDay": paymentDay,
      "bankName": bankName,
      "purpose": purpose,
      "isActive": isActive,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970
    ]
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> Loan {
    guard let id = dict["id"] as? String,
          let name = dict["name"] as? String,
          let loanTypeRaw = dict["loanType"] as? String,
          let loanType = LoanType(rawValue: loanTypeRaw),
          let principalAmount = dict["principalAmount"] as? Double,
          let currentBalance = dict["currentBalance"] as? Double,
          let interestRate = dict["interestRate"] as? Double,
          let term = dict["term"] as? Int,
          let monthlyPayment = dict["monthlyPayment"] as? Double,
          let startDateTimestamp = dict["startDate"] as? TimeInterval,
          let _ = dict["endDate"] as? TimeInterval,
          let paymentDay = dict["paymentDay"] as? Int,
          let bankName = dict["bankName"] as? String,
          let purpose = dict["purpose"] as? String,
          let isActive = dict["isActive"] as? Bool,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
          let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required Loan fields")
    }

    return Loan(
      id: id,
      name: name,
      loanType: loanType,
      principalAmount: principalAmount,
      currentBalance: currentBalance,
      interestRate: interestRate,
      term: term,
      monthlyPayment: monthlyPayment,
      startDate: Date(timeIntervalSince1970: startDateTimestamp),
      paymentDay: paymentDay,
      bankName: bankName,
      purpose: purpose,
      isActive: isActive,
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
      updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
    )
  }
}

// MARK: - LoanPayment Firebase Extensions

extension LoanPayment {
  func toDictionary() throws -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "loanId": loanId,
      "amount": amount,
      "principalAmount": principalAmount,
      "interestAmount": interestAmount,
      "paymentDate": paymentDate.timeIntervalSince1970,
      "paymentMethod": paymentMethod,
      "userId": userId,
      "createdAt": createdAt.timeIntervalSince1970
    ]

    if let notes = notes {
      dict["notes"] = notes
    }

    return dict
  }

  static func fromDictionary(_ dict: [String: Any]) throws -> LoanPayment {
    guard let id = dict["id"] as? String,
          let loanId = dict["loanId"] as? String,
          let amount = dict["amount"] as? Double,
          let principalAmount = dict["principalAmount"] as? Double,
          let interestAmount = dict["interestAmount"] as? Double,
          let paymentDateTimestamp = dict["paymentDate"] as? TimeInterval,
          let paymentMethod = dict["paymentMethod"] as? String,
          let userId = dict["userId"] as? String,
          let createdAtTimestamp = dict["createdAt"] as? TimeInterval
    else {
      throw FirebaseError.invalidData("Missing required LoanPayment fields")
    }

    let notes = dict["notes"] as? String

    return LoanPayment(
      id: id,
      loanId: loanId,
      amount: amount,
      principalAmount: principalAmount,
      interestAmount: interestAmount,
      paymentDate: Date(timeIntervalSince1970: paymentDateTimestamp),
      paymentMethod: paymentMethod,
      notes: notes,
      userId: userId,
      createdAt: Date(timeIntervalSince1970: createdAtTimestamp)
    )
  }
}
