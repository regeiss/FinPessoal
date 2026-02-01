//
//  GoalsWidget.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct GoalsWidgetProvider: TimelineProvider {

  func placeholder(in context: Context) -> GoalsWidgetEntry {
    GoalsWidgetEntry(date: Date(), data: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (GoalsWidgetEntry) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = GoalsWidgetEntry(date: Date(), data: data)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<GoalsWidgetEntry>) -> Void) {
    let data = SharedDataManager.shared.loadWidgetData()
    let entry = GoalsWidgetEntry(date: Date(), data: data)

    // Refresh every 2 hours
    let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - Timeline Entry

struct GoalsWidgetEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

// MARK: - Widget

struct GoalsWidget: Widget {
  let kind: String = "GoalsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: GoalsWidgetProvider()) { entry in
      GoalsWidgetView(data: entry.data)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Metas")
    .description("Acompanhe o progresso das suas metas.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}
