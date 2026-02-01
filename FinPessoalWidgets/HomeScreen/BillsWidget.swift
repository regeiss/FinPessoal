//
//  BillsWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct BillsWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BillsWidgetEntry {
    BillsWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BillsWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BillsWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BillsWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BillsWidgetEntry(date: Date(), data: data)

    // Refresh every hour
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct BillsWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct BillsWidget: Widget {
  let kind: String = "BillsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BillsWidgetProvider()) { entry in
      BillsWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Contas a Pagar")
    .description("Veja suas próximas contas.")
    .supportedFamilies([.systemSmall, .systemMedium])
    .contentMarginsDisabled()
  }
}
