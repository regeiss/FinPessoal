//
//  ReportsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct ReportsScreen: View {
  @StateObject private var viewModel = ReportsViewModel()
  
  var body: some View {
    ZStack {
        if viewModel.isLoading && viewModel.reportSummary == nil {
          ProgressView(String(localized: "reports.loading"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .accessibilityLabel(String(localized: "reports.loading"))
            .accessibilityAddTraits(.updatesFrequently)
        } else {
          ScrollView {
            LazyVStack(spacing: 20) {
              // Summary Card
              if let summary = viewModel.reportSummary {
                ReportSummaryCard(summary: summary)
              }
              
              // Category Spending
              if !viewModel.categorySpending.isEmpty {
                CategorySpendingView(
                  categorySpending: viewModel.categorySpending,
                  showingChart: viewModel.showingChartView
                )
              }
              
              // Monthly Trends
              if !viewModel.monthlyTrends.isEmpty {
                MonthlyTrendsView(
                  monthlyTrends: viewModel.monthlyTrends,
                  showingChart: viewModel.showingChartView
                )
              }
              
              // Budget Performance
              if !viewModel.budgetPerformance.isEmpty {
                BudgetPerformanceView(
                  budgetPerformance: viewModel.budgetPerformance,
                  showingChart: viewModel.showingChartView
                )
              }
              
              // Space for bottom content
              Color.clear.frame(height: 20)
            }
            .padding()
          }
          .background(Color(.systemGroupedBackground))
        }
        
        // Error overlay
        if let errorMessage = viewModel.errorMessage {
          VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
              .font(.system(size: 48))
              .foregroundColor(.orange)
              .accessibilityHidden(true)

            Text(String(localized: "reports.error.title"))
              .font(.headline)
              .fontWeight(.semibold)
              .accessibilityAddTraits(.isHeader)

            Text(errorMessage)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)

            Button(String(localized: "common.try.again")) {
              viewModel.refreshData()
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(String(localized: "common.try.again"))
            .accessibilityHint("Reloads the reports data")
          }
          .padding()
          .background(Color(.systemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .shadow(color: .gray.opacity(0.2), radius: 8)
          .padding()
          .accessibilityElement(children: .contain)
          .accessibilityLabel("Error loading reports")
        }
    }
    .navigationTitle(String(localized: "sidebar.reports"))
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        // Period selector
        Button {
          viewModel.showingPeriodPicker = true
        } label: {
          Image(systemName: "calendar")
        }
        .accessibilityLabel("Select report period")
        .accessibilityHint("Opens period selection dialog")

        // View toggle (chart/table)
        Button {
          viewModel.toggleView()
        } label: {
          Image(systemName: viewModel.showingChartView ? "list.bullet" : "chart.bar")
        }
        .accessibilityLabel(viewModel.showingChartView ? "Switch to table view" : "Switch to chart view")
        .accessibilityHint("Toggles between chart and table visualization")

        // Export options
        Button {
          viewModel.showingExportOptions = true
        } label: {
          Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Export reports")
        .accessibilityHint("Opens export options for PDF, CSV, or sharing")
      }
    }
    .refreshable {
      viewModel.refreshData()
    }
    .confirmationDialog(
      String(localized: "reports.period.selector"),
      isPresented: $viewModel.showingPeriodPicker,
      titleVisibility: .visible
    ) {
      ForEach(ReportPeriod.allCases, id: \.self) { period in
        Button(period.displayName) {
          viewModel.selectedPeriod = period
        }
      }
    }
    .actionSheet(isPresented: $viewModel.showingExportOptions) {
      ActionSheet(
        title: Text(String(localized: "reports.export.title")),
        buttons: [
          .default(Text(String(localized: "reports.export.pdf"))) {
            viewModel.exportToPDF()
          },
          .default(Text(String(localized: "reports.export.csv"))) {
            viewModel.exportToCSV()
          },
          .default(Text(String(localized: "reports.share"))) {
            viewModel.shareReport()
          },
          .cancel()
        ]
      )
    }
    .onAppear {
      viewModel.refreshData()
    }
  }
}
