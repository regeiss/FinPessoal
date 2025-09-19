//
//  TransactionEnum.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import Foundation

enum TransactionPeriod: CaseIterable {
  case today
  case thisWeek
  case thisMonth
  case all
  
  var displayName: String {
    switch self {
    case .today: return String(localized: "transactions.filter.today")
    case .thisWeek: return String(localized: "transactions.filter.week")
    case .thisMonth: return String(localized: "transactions.filter.month")
    case .all: return String(localized: "transactions.filter.all")
    }
  }
}

enum TransactionType: String, CaseIterable, Codable {
  case income = "income"
  case expense = "expense"
  case transfer = "transfer"
  
  var displayName: String {
    switch self {
    case .income: return String(localized: "transaction.type.income")
    case .expense: return String(localized: "transaction.type.expense")
    case .transfer: return String(localized: "transaction.type.transfer")
    }
  }
  
  var icon: String {
    switch self {
    case .income: return "plus.circle"
    case .expense: return "minus.circle"
    case .transfer: return "arrow.left.arrow.right.circle"
    }
  }
}

enum TransactionCategory: String, CaseIterable, Codable, Comparable {
  case food = "food"
  case transport = "transport"
  case entertainment = "entertainment"
  case healthcare = "healthcare"
  case shopping = "shopping"
  case bills = "bills"
  case salary = "salary"
  case investment = "investment"
  case other = "other"
  case housing = "housing"
  
  var displayName: String {
    switch self {
    case .food: return String(localized: "transaction.category.food")
    case .transport: return String(localized: "transaction.category.transport")
    case .entertainment: return String(localized: "transaction.category.entertainment")
    case .healthcare: return String(localized: "transaction.category.healthcare")
    case .shopping: return String(localized: "transaction.category.shopping")
    case .bills: return String(localized: "transaction.category.bills")
    case .salary: return String(localized: "transaction.category.salary")
    case .investment: return String(localized: "transaction.category.investment")
    case .housing: return String(localized: "transaction.category.housing")
    case .other: return String(localized: "transaction.category.other")
    }
  }
  
  var icon: String {
    switch self {
    case .food: return "fork.knife"
    case .transport: return "car"
    case .entertainment: return "gamecontroller"
    case .healthcare: return "cross"
    case .shopping: return "bag"
    case .bills: return "doc.text"
    case .salary: return "dollarsign.circle"
    case .investment: return "chart.line.uptrend.xyaxis"
    case .housing: return "house"
    case .other: return "questionmark.circle"
    }
  }
  
  
  
  // MARK: - Comparable Implementation
  static func < (lhs: TransactionCategory, rhs: TransactionCategory) -> Bool {
    return lhs.displayName < rhs.displayName
  }
  
  // Ordem customizada para organização lógica (opcional)
  var sortOrder: Int {
    switch self {
    case .salary: return 0  // Receitas primeiro
    case .investment: return 1
    case .food: return 2  // Despesas essenciais
    case .healthcare: return 3
    case .bills: return 4
    case .transport: return 5  // Despesas de mobilidade
    case .shopping: return 6  // Despesas opcionais
    case .entertainment: return 7
    case .other: return 8
    case .housing: return 9
    }
  }
  
  // Método para ordenação customizada (alternativa)
  static func sortedByLogicalOrder(_ categories: [TransactionCategory])
  -> [TransactionCategory]
  {
    return categories.sorted { $0.sortOrder < $1.sortOrder }
  }
  
  // MARK: - Subcategories
  
  var subcategories: [TransactionSubcategory] {
    switch self {
    case .food:
      return TransactionSubcategory.foodSubcategories
    case .transport:
      return TransactionSubcategory.transportSubcategories
    case .entertainment:
      return TransactionSubcategory.entertainmentSubcategories
    case .healthcare:
      return TransactionSubcategory.healthcareSubcategories
    case .shopping:
      return TransactionSubcategory.shoppingSubcategories
    case .bills:
      return TransactionSubcategory.billsSubcategories
    case .salary:
      return TransactionSubcategory.salarySubcategories
    case .investment:
      return TransactionSubcategory.investmentSubcategories
    case .housing:
      return TransactionSubcategory.housingSubcategories
    case .other:
      return TransactionSubcategory.otherSubcategories
    }
  }
}

enum TransactionSubcategory: String, CaseIterable, Codable, Comparable {
  // Food subcategories
  case restaurants = "restaurants"
  case groceries = "groceries"
  case fastFood = "fastFood"
  case delivery = "delivery"
  case coffee = "coffee"
  case alcohol = "alcohol"
  
  // Transport subcategories
  case fuel = "fuel"
  case publicTransport = "publicTransport"
  case taxi = "taxi"
  case parking = "parking"
  case maintenance = "maintenance"
  case insurance = "insurance"
  
  // Entertainment subcategories
  case movies = "movies"
  case games = "games"
  case concerts = "concerts"
  case sports = "sports"
  case books = "books"
  case streaming = "streaming"
  
  // Healthcare subcategories
  case doctor = "doctor"
  case pharmacy = "pharmacy"
  case dental = "dental"
  case hospital = "hospital"
  case therapy = "therapy"
  case supplements = "supplements"
  
  // Shopping subcategories
  case clothing = "clothing"
  case electronics = "electronics"
  case homeGoods = "homeGoods"
  case beauty = "beauty"
  case gifts = "gifts"
  case accessories = "accessories"
  
  // Bills subcategories
  case electricity = "electricity"
  case water = "water"
  case internet = "internet"
  case phone = "phone"
  case subscription = "subscription"
  case taxes = "taxes"
  
  // Salary subcategories
  case primaryJob = "primaryJob"
  case secondaryJob = "secondaryJob"
  case freelance = "freelance"
  case bonus = "bonus"
  case commission = "commission"
  case benefits = "benefits"
  
  // Investment subcategories
  case stocks = "stocks"
  case bonds = "bonds"
  case realEstate = "realEstate"
  case cryptocurrency = "cryptocurrency"
  case retirement = "retirement"
  case savings = "savings"
  
  // Housing subcategories
  case rent = "rent"
  case mortgage = "mortgage"
  case repairs = "repairs"
  case furniture = "furniture"
  case utilities = "utilities"
  case cleaning = "cleaning"
  
  // Other subcategories
  case fees = "fees"
  case donations = "donations"
  case education = "education"
  case pets = "pets"
  case miscellaneous = "miscellaneous"
  
  var displayName: String {
    switch self {
    // Food
    case .restaurants: return String(localized: "transaction.subcategory.restaurants")
    case .groceries: return String(localized: "transaction.subcategory.groceries")
    case .fastFood: return String(localized: "transaction.subcategory.fastFood")
    case .delivery: return String(localized: "transaction.subcategory.delivery")
    case .coffee: return String(localized: "transaction.subcategory.coffee")
    case .alcohol: return String(localized: "transaction.subcategory.alcohol")
    
    // Transport
    case .fuel: return String(localized: "transaction.subcategory.fuel")
    case .publicTransport: return String(localized: "transaction.subcategory.publicTransport")
    case .taxi: return String(localized: "transaction.subcategory.taxi")
    case .parking: return String(localized: "transaction.subcategory.parking")
    case .maintenance: return String(localized: "transaction.subcategory.maintenance")
    case .insurance: return String(localized: "transaction.subcategory.insurance")
    
    // Entertainment
    case .movies: return String(localized: "transaction.subcategory.movies")
    case .games: return String(localized: "transaction.subcategory.games")
    case .concerts: return String(localized: "transaction.subcategory.concerts")
    case .sports: return String(localized: "transaction.subcategory.sports")
    case .books: return String(localized: "transaction.subcategory.books")
    case .streaming: return String(localized: "transaction.subcategory.streaming")
    
    // Healthcare
    case .doctor: return String(localized: "transaction.subcategory.doctor")
    case .pharmacy: return String(localized: "transaction.subcategory.pharmacy")
    case .dental: return String(localized: "transaction.subcategory.dental")
    case .hospital: return String(localized: "transaction.subcategory.hospital")
    case .therapy: return String(localized: "transaction.subcategory.therapy")
    case .supplements: return String(localized: "transaction.subcategory.supplements")
    
    // Shopping
    case .clothing: return String(localized: "transaction.subcategory.clothing")
    case .electronics: return String(localized: "transaction.subcategory.electronics")
    case .homeGoods: return String(localized: "transaction.subcategory.homeGoods")
    case .beauty: return String(localized: "transaction.subcategory.beauty")
    case .gifts: return String(localized: "transaction.subcategory.gifts")
    case .accessories: return String(localized: "transaction.subcategory.accessories")
    
    // Bills
    case .electricity: return String(localized: "transaction.subcategory.electricity")
    case .water: return String(localized: "transaction.subcategory.water")
    case .internet: return String(localized: "transaction.subcategory.internet")
    case .phone: return String(localized: "transaction.subcategory.phone")
    case .subscription: return String(localized: "transaction.subcategory.subscription")
    case .taxes: return String(localized: "transaction.subcategory.taxes")
    
    // Salary
    case .primaryJob: return String(localized: "transaction.subcategory.primaryJob")
    case .secondaryJob: return String(localized: "transaction.subcategory.secondaryJob")
    case .freelance: return String(localized: "transaction.subcategory.freelance")
    case .bonus: return String(localized: "transaction.subcategory.bonus")
    case .commission: return String(localized: "transaction.subcategory.commission")
    case .benefits: return String(localized: "transaction.subcategory.benefits")
    
    // Investment
    case .stocks: return String(localized: "transaction.subcategory.stocks")
    case .bonds: return String(localized: "transaction.subcategory.bonds")
    case .realEstate: return String(localized: "transaction.subcategory.realEstate")
    case .cryptocurrency: return String(localized: "transaction.subcategory.cryptocurrency")
    case .retirement: return String(localized: "transaction.subcategory.retirement")
    case .savings: return String(localized: "transaction.subcategory.savings")
    
    // Housing
    case .rent: return String(localized: "transaction.subcategory.rent")
    case .mortgage: return String(localized: "transaction.subcategory.mortgage")
    case .repairs: return String(localized: "transaction.subcategory.repairs")
    case .furniture: return String(localized: "transaction.subcategory.furniture")
    case .utilities: return String(localized: "transaction.subcategory.utilities")
    case .cleaning: return String(localized: "transaction.subcategory.cleaning")
    
    // Other
    case .fees: return String(localized: "transaction.subcategory.fees")
    case .donations: return String(localized: "transaction.subcategory.donations")
    case .education: return String(localized: "transaction.subcategory.education")
    case .pets: return String(localized: "transaction.subcategory.pets")
    case .miscellaneous: return String(localized: "transaction.subcategory.miscellaneous")
    }
  }
  
  var icon: String {
    switch self {
    // Food
    case .restaurants: return "fork.knife.circle"
    case .groceries: return "cart"
    case .fastFood: return "takeoutbag.and.cup.and.straw"
    case .delivery: return "shippingbox"
    case .coffee: return "cup.and.saucer"
    case .alcohol: return "wineglass"
    
    // Transport
    case .fuel: return "fuelpump"
    case .publicTransport: return "bus"
    case .taxi: return "car.circle"
    case .parking: return "parkingsign"
    case .maintenance: return "wrench.and.screwdriver"
    case .insurance: return "shield.checkered"
    
    // Entertainment
    case .movies: return "popcorn"
    case .games: return "gamecontroller"
    case .concerts: return "music.note"
    case .sports: return "sportscourt"
    case .books: return "book"
    case .streaming: return "tv"
    
    // Healthcare
    case .doctor: return "stethoscope"
    case .pharmacy: return "pills"
    case .dental: return "mouth"
    case .hospital: return "cross.case"
    case .therapy: return "brain.head.profile"
    case .supplements: return "leaf"
    
    // Shopping
    case .clothing: return "tshirt"
    case .electronics: return "desktopcomputer"
    case .homeGoods: return "house.and.flag"
    case .beauty: return "comb"
    case .gifts: return "gift"
    case .accessories: return "eyeglasses"
    
    // Bills
    case .electricity: return "bolt"
    case .water: return "drop"
    case .internet: return "wifi"
    case .phone: return "phone"
    case .subscription: return "rectangle.stack"
    case .taxes: return "doc.text"
    
    // Salary
    case .primaryJob: return "briefcase"
    case .secondaryJob: return "briefcase.circle"
    case .freelance: return "laptopcomputer"
    case .bonus: return "star.circle"
    case .commission: return "percent"
    case .benefits: return "heart.circle"
    
    // Investment
    case .stocks: return "chart.line.uptrend.xyaxis"
    case .bonds: return "doc.richtext"
    case .realEstate: return "building.2"
    case .cryptocurrency: return "bitcoinsign.circle"
    case .retirement: return "calendar.badge.clock"
    case .savings: return "banknote"
    
    // Housing
    case .rent: return "key"
    case .mortgage: return "house.lodge"
    case .repairs: return "hammer"
    case .furniture: return "chair.lounge"
    case .utilities: return "lightbulb"
    case .cleaning: return "paintbrush"
    
    // Other
    case .fees: return "dollarsign.square"
    case .donations: return "heart"
    case .education: return "graduationcap"
    case .pets: return "pawprint"
    case .miscellaneous: return "questionmark.circle"
    }
  }
  
  // MARK: - Comparable Implementation
  static func < (lhs: TransactionSubcategory, rhs: TransactionSubcategory) -> Bool {
    return lhs.displayName < rhs.displayName
  }
  
  // MARK: - Static subcategory arrays
  static let foodSubcategories: [TransactionSubcategory] = [
    .restaurants, .groceries, .fastFood, .delivery, .coffee, .alcohol
  ]
  
  static let transportSubcategories: [TransactionSubcategory] = [
    .fuel, .publicTransport, .taxi, .parking, .maintenance, .insurance
  ]
  
  static let entertainmentSubcategories: [TransactionSubcategory] = [
    .movies, .games, .concerts, .sports, .books, .streaming
  ]
  
  static let healthcareSubcategories: [TransactionSubcategory] = [
    .doctor, .pharmacy, .dental, .hospital, .therapy, .supplements
  ]
  
  static let shoppingSubcategories: [TransactionSubcategory] = [
    .clothing, .electronics, .homeGoods, .beauty, .gifts, .accessories
  ]
  
  static let billsSubcategories: [TransactionSubcategory] = [
    .electricity, .water, .internet, .phone, .subscription, .taxes
  ]
  
  static let salarySubcategories: [TransactionSubcategory] = [
    .primaryJob, .secondaryJob, .freelance, .bonus, .commission, .benefits
  ]
  
  static let investmentSubcategories: [TransactionSubcategory] = [
    .stocks, .bonds, .realEstate, .cryptocurrency, .retirement, .savings
  ]
  
  static let housingSubcategories: [TransactionSubcategory] = [
    .rent, .mortgage, .repairs, .furniture, .utilities, .cleaning
  ]
  
  static let otherSubcategories: [TransactionSubcategory] = [
    .fees, .donations, .education, .pets, .miscellaneous
  ]
}
