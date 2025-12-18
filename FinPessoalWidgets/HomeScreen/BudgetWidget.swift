//
//  BudgetWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct BudgetWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> BudgetWidgetEntry {
    BudgetWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (BudgetWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BudgetWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = BudgetWidgetEntry(date: Date(), data: data)

    // Refresh every hour
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct BudgetWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct BudgetWidget: Widget {
  let kind: String = "BudgetWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BudgetWidgetProvider()) { entry in
      BudgetWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Orçamentos")
    .description("Acompanhe seus orçamentos.")
    .supportedFamilies([.systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}
