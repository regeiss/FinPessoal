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
            
            Text(String(localized: "reports.error.title"))
              .font(.headline)
              .fontWeight(.semibold)
            
            Text(errorMessage)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
            
            Button(String(localized: "common.try.again")) {
              viewModel.refreshData()
            }
            .buttonStyle(.bordered)
          }
          .padding()
          .background(Color(.systemBackground))
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .shadow(color: .gray.opacity(0.2), radius: 8)
          .padding()
        }
    }
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        // Period selector
        Button {
          viewModel.showingPeriodPicker = true
        } label: {
          Image(systemName: "calendar")
        }

        // View toggle (chart/table)
        Button {
          viewModel.toggleView()
        } label: {
          Image(systemName: viewModel.showingChartView ? "list.bullet" : "chart.bar")
        }

        // Export options
        Button {
          viewModel.showingExportOptions = true
        } label: {
          Image(systemName: "square.and.arrow.up")
        }
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
