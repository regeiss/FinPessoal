//
//  HelpDataProvider.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/09/25.
//

import Foundation
import Combine

class HelpDataProvider: ObservableObject {
  static let shared = HelpDataProvider()
  
  @Published var helpTopics: [HelpTopic] = []
  @Published var helpSections: [HelpSection] = []
  
  private init() {
    loadHelpContent()
  }
  
  private func loadHelpContent() {
    helpTopics = createAllHelpTopics()
    helpSections = createHelpSections()
  }
  
  func getTopicsByCategory(_ category: HelpCategory) -> [HelpTopic] {
    return helpTopics.filter { $0.category == category }
  }
  
  func getFAQs() -> [HelpTopic] {
    return helpTopics.filter { $0.isFrequentlyAsked }
  }
  
  func searchTopics(_ query: String) -> [HelpTopic] {
    guard !query.isEmpty else { return helpTopics }
    
    let lowercaseQuery = query.lowercased()
    return helpTopics.filter { topic in
      topic.title.lowercased().contains(lowercaseQuery) ||
      topic.content.lowercased().contains(lowercaseQuery) ||
      topic.keywords.contains { $0.lowercased().contains(lowercaseQuery) }
    }
  }
  
  private func createAllHelpTopics() -> [HelpTopic] {
    return [
      // Getting Started
      HelpTopic(
        id: "welcome_overview",
        title: String(localized: "help.welcome.title"),
        content: String(localized: "help.welcome.content"),
        category: .gettingStarted,
        keywords: ["início", "começar", "primeiro", "setup"],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "first_transaction",
        title: String(localized: "help.first.transaction.title"),
        content: String(localized: "help.first.transaction.content"),
        category: .gettingStarted,
        keywords: ["primeira", "transação", "adicionar", "registro"],
        steps: [
          HelpStep(id: "step1", stepNumber: 1, title: String(localized: "help.first.transaction.step1.title"), description: String(localized: "help.first.transaction.step1.desc")),
          HelpStep(id: "step2", stepNumber: 2, title: String(localized: "help.first.transaction.step2.title"), description: String(localized: "help.first.transaction.step2.desc")),
          HelpStep(id: "step3", stepNumber: 3, title: String(localized: "help.first.transaction.step3.title"), description: String(localized: "help.first.transaction.step3.desc"))
        ],
        isFrequentlyAsked: true
      ),
      
      // Transactions
      HelpTopic(
        id: "add_transaction",
        title: String(localized: "help.add.transaction.title"),
        content: String(localized: "help.add.transaction.content"),
        category: .transactions,
        keywords: ["adicionar", "nova", "transação", "gasto", "receita"],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "edit_transaction",
        title: String(localized: "help.edit.transaction.title"),
        content: String(localized: "help.edit.transaction.content"),
        category: .transactions,
        keywords: ["editar", "modificar", "alterar", "corrigir"]
      ),
      
      HelpTopic(
        id: "delete_transaction",
        title: String(localized: "help.delete.transaction.title"),
        content: String(localized: "help.delete.transaction.content"),
        category: .transactions,
        keywords: ["excluir", "deletar", "remover", "apagar"]
      ),
      
      HelpTopic(
        id: "recurring_transactions",
        title: String(localized: "help.recurring.title"),
        content: String(localized: "help.recurring.content"),
        category: .transactions,
        keywords: ["recorrente", "automática", "repetir", "mensal"]
      ),
      
      // Budgets
      HelpTopic(
        id: "create_budget",
        title: String(localized: "help.create.budget.title"),
        content: String(localized: "help.create.budget.content"),
        category: .budgets,
        keywords: ["orçamento", "limite", "categoria", "planejamento"],
        steps: [
          HelpStep(id: "budget_step1", stepNumber: 1, title: String(localized: "help.budget.step1.title"), description: String(localized: "help.budget.step1.desc")),
          HelpStep(id: "budget_step2", stepNumber: 2, title: String(localized: "help.budget.step2.title"), description: String(localized: "help.budget.step2.desc")),
          HelpStep(id: "budget_step3", stepNumber: 3, title: String(localized: "help.budget.step3.title"), description: String(localized: "help.budget.step3.desc"))
        ],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "budget_alerts",
        title: String(localized: "help.budget.alerts.title"),
        content: String(localized: "help.budget.alerts.content"),
        category: .budgets,
        keywords: ["alerta", "notificação", "limite", "ultrapassar"]
      ),
      
      // Goals
      HelpTopic(
        id: "set_goals",
        title: String(localized: "help.set.goals.title"),
        content: String(localized: "help.set.goals.content"),
        category: .goals,
        keywords: ["meta", "objetivo", "economizar", "poupar"],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "track_goals",
        title: String(localized: "help.track.goals.title"),
        content: String(localized: "help.track.goals.content"),
        category: .goals,
        keywords: ["acompanhar", "progresso", "meta", "status"]
      ),
      
      // Reports
      HelpTopic(
        id: "view_reports",
        title: String(localized: "help.view.reports.title"),
        content: String(localized: "help.view.reports.content"),
        category: .reports,
        keywords: ["relatório", "gráfico", "análise", "resumo"],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "export_data",
        title: String(localized: "help.export.data.title"),
        content: String(localized: "help.export.data.content"),
        category: .reports,
        keywords: ["exportar", "PDF", "CSV", "compartilhar"]
      ),
      
      // Accounts
      HelpTopic(
        id: "manage_profile",
        title: String(localized: "help.manage.profile.title"),
        content: String(localized: "help.manage.profile.content"),
        category: .accounts,
        keywords: ["perfil", "conta", "dados", "informações"]
      ),
      
      HelpTopic(
        id: "sync_data",
        title: String(localized: "help.sync.data.title"),
        content: String(localized: "help.sync.data.content"),
        category: .accounts,
        keywords: ["sincronizar", "backup", "nuvem", "dados"]
      ),
      
      // Troubleshooting
      HelpTopic(
        id: "app_crashes",
        title: String(localized: "help.app.crashes.title"),
        content: String(localized: "help.app.crashes.content"),
        category: .troubleshooting,
        keywords: ["travamento", "erro", "fechar", "problema"],
        isFrequentlyAsked: true
      ),
      
      HelpTopic(
        id: "data_missing",
        title: String(localized: "help.data.missing.title"),
        content: String(localized: "help.data.missing.content"),
        category: .troubleshooting,
        keywords: ["dados", "perdidos", "sumiram", "backup"]
      ),
      
      HelpTopic(
        id: "sync_issues",
        title: String(localized: "help.sync.issues.title"),
        content: String(localized: "help.sync.issues.content"),
        category: .troubleshooting,
        keywords: ["sincronização", "erro", "conexão", "internet"]
      ),
      
      // Security
      HelpTopic(
        id: "data_privacy",
        title: String(localized: "help.data.privacy.title"),
        content: String(localized: "help.data.privacy.content"),
        category: .security,
        keywords: ["privacidade", "segurança", "dados", "proteção"]
      ),
      
      HelpTopic(
        id: "account_security",
        title: String(localized: "help.account.security.title"),
        content: String(localized: "help.account.security.content"),
        category: .security,
        keywords: ["conta", "senha", "autenticação", "segurança"]
      )
    ]
  }
  
  private func createHelpSections() -> [HelpSection] {
    return [
      HelpSection(
        id: "quick_start",
        title: String(localized: "help.section.quick.start"),
        topics: helpTopics.filter { $0.category == .gettingStarted }
      ),
      HelpSection(
        id: "frequently_asked",
        title: String(localized: "help.section.faq"),
        topics: helpTopics.filter { $0.isFrequentlyAsked }
      ),
      HelpSection(
        id: "all_categories",
        title: String(localized: "help.section.all.categories"),
        topics: helpTopics
      )
    ]
  }
}
