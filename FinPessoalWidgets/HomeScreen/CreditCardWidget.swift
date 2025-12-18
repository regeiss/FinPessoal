//
//  CreditCardWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct CreditCardWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> CreditCardWidgetEntry {
    CreditCardWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (CreditCardWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = CreditCardWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CreditCardWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = CreditCardWidgetEntry(date: Date(), data: data)

    // Refresh every hour
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct CreditCardWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct CreditCardWidget: Widget {
  let kind: String = "CreditCardWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CreditCardWidgetProvider()) { entry in
      CreditCardWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Cartões de Crédito")
    .description("Acompanhe a utilização dos seus cartões.")
    .supportedFamilies([.systemSmall, .systemMedium])
    .contentMarginsDisabled()
  }
}
