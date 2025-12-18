//
//  TransactionsWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct TransactionsWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> TransactionsWidgetEntry {
    TransactionsWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (TransactionsWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = TransactionsWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TransactionsWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = TransactionsWidgetEntry(date: Date(), data: data)

    // Refresh every 15 minutes for transaction updates
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct TransactionsWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct TransactionsWidget: Widget {
  let kind: String = "TransactionsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TransactionsWidgetProvider()) { entry in
      TransactionsWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Transações")
    .description("Veja suas transações recentes.")
    .supportedFamilies([.systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}
