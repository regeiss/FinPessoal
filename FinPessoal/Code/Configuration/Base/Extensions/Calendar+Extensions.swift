//
//  Calendar+Extensions.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import Foundation

extension Calendar {
  func startOfMonth(for date: Date) -> Date? {
    let components = dateComponents([.year, .month], from: date)
    return self.date(from: components)
  }
  
  func endOfMonth(for date: Date) -> Date? {
    guard let startOfMonth = startOfMonth(for: date) else { return nil }
    guard let nextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth) else { return nil }
    return self.date(byAdding: .day, value: -1, to: nextMonth)
  }
  
  func startOfWeek(for date: Date) -> Date? {
    let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    return self.date(from: components)
  }
  
  func endOfWeek(for date: Date) -> Date? {
    guard let startOfWeek = startOfWeek(for: date) else { return nil }
    return self.date(byAdding: .day, value: 6, to: startOfWeek)
  }
  
  func startOfYear(for date: Date) -> Date? {
    let components = dateComponents([.year], from: date)
    return self.date(from: components)
  }
  
  func endOfYear(for date: Date) -> Date? {
    guard let startOfYear = startOfYear(for: date) else { return nil }
    guard let nextYear = self.date(byAdding: .year, value: 1, to: startOfYear) else { return nil }
    return self.date(byAdding: .day, value: -1, to: nextYear)
  }
  
  func isDateInCurrentMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: Date(), toGranularity: .month)
  }
  
  func isDateInCurrentWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
  }
  
  func isDateInCurrentYear(_ date: Date) -> Bool {
    return isDate(date, equalTo: Date(), toGranularity: .year)
  }
  
  func numberOfDaysInMonth(for date: Date) -> Int {
    guard let range = range(of: .day, in: .month, for: date) else { return 0 }
    return range.count
  }
  
  func monthsAgo(_ months: Int, from date: Date = Date()) -> Date? {
    return self.date(byAdding: .month, value: -months, to: date)
  }
  
  func weeksAgo(_ weeks: Int, from date: Date = Date()) -> Date? {
    return self.date(byAdding: .weekOfYear, value: -weeks, to: date)
  }
  
  func daysAgo(_ days: Int, from date: Date = Date()) -> Date? {
    return self.date(byAdding: .day, value: -days, to: date)
  }
  
  func monthsBetween(_ startDate: Date, and endDate: Date) -> Int {
    let components = dateComponents([.month], from: startDate, to: endDate)
    return components.month ?? 0
  }
  
  func daysBetween(_ startDate: Date, and endDate: Date) -> Int {
    let components = dateComponents([.day], from: startDate, to: endDate)
    return components.day ?? 0
  }
}

// MARK: - Date Extensions

extension Date {
  var startOfMonth: Date? {
    return Calendar.current.startOfMonth(for: self)
  }
  
  var endOfMonth: Date? {
    return Calendar.current.endOfMonth(for: self)
  }
  
  var startOfWeek: Date? {
    return Calendar.current.startOfWeek(for: self)
  }
  
  var endOfWeek: Date? {
    return Calendar.current.endOfWeek(for: self)
  }
  
  var startOfYear: Date? {
    return Calendar.current.startOfYear(for: self)
  }
  
  var endOfYear: Date? {
    return Calendar.current.endOfYear(for: self)
  }
  
  var isInCurrentMonth: Bool {
    return Calendar.current.isDateInCurrentMonth(self)
  }
  
  var isInCurrentWeek: Bool {
    return Calendar.current.isDateInCurrentWeek(self)
  }
  
  var isInCurrentYear: Bool {
    return Calendar.current.isDateInCurrentYear(self)
  }
  
  var monthName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: self)
  }
  
  var monthAbbreviation: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: self)
  }
  
  var dayOfWeekName: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: self)
  }
  
  var dayOfWeekAbbreviation: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: self)
  }
  
  func adding(_ component: Calendar.Component, value: Int) -> Date? {
    return Calendar.current.date(byAdding: component, value: value, to: self)
  }
  
  func subtracting(_ component: Calendar.Component, value: Int) -> Date? {
    return Calendar.current.date(byAdding: component, value: -value, to: self)
  }
  
  func isSameDay(as date: Date) -> Bool {
    return Calendar.current.isDate(self, inSameDayAs: date)
  }
  
  func isSameMonth(as date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
  }
  
  func isSameYear(as date: Date) -> Bool {
    return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
  }
}

// MARK: - Period Helpers

enum TimePeriod {
  case day
  case week
  case month
  case quarter
  case year
  case custom(start: Date, end: Date)
  
  func dateRange(from referenceDate: Date = Date()) -> (start: Date, end: Date) {
    let calendar = Calendar.current
    
    switch self {
    case .day:
      let start = calendar.startOfDay(for: referenceDate)
      let end = calendar.date(byAdding: .day, value: 1, to: start) ?? referenceDate
      return (start, end)
      
    case .week:
      let start = calendar.startOfWeek(for: referenceDate) ?? referenceDate
      let end = calendar.endOfWeek(for: referenceDate) ?? referenceDate
      return (start, end)
      
    case .month:
      let start = calendar.startOfMonth(for: referenceDate) ?? referenceDate
      let end = calendar.endOfMonth(for: referenceDate) ?? referenceDate
      return (start, end)
      
    case .quarter:
      let month = calendar.component(.month, from: referenceDate)
      let quarterStartMonth = ((month - 1) / 3) * 3 + 1
      
      var components = calendar.dateComponents([.year], from: referenceDate)
      components.month = quarterStartMonth
      components.day = 1
      
      let start = calendar.date(from: components) ?? referenceDate
      let quarterEnd = calendar.date(byAdding: .month, value: 3, to: start) ?? referenceDate
      let end = calendar.date(byAdding: .day, value: -1, to: quarterEnd) ?? referenceDate
      
      return (start, end)
      
    case .year:
      let start = calendar.startOfYear(for: referenceDate) ?? referenceDate
      let end = calendar.endOfYear(for: referenceDate) ?? referenceDate
      return (start, end)
      
    case .custom(let start, let end):
      return (start, end)
    }
  }
  
  var displayName: String {
    switch self {
    case .day: return "Dia"
    case .week: return "Semana"
    case .month: return "Mês"
    case .quarter: return "Trimestre"
    case .year: return "Ano"
    case .custom: return "Personalizado"
    }
  }
}
