import SwiftUI

// MARK: - Balance Card Skeleton

struct BalanceCardSkeleton: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Title
      SkeletonView.textLine(width: 120, height: 16, cornerRadius: 4)

      // Balance amount (large)
      SkeletonView.textLine(width: 180, height: 36, cornerRadius: 6)

      Spacer()
        .frame(height: 8)

      // Monthly expenses section
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          SkeletonView.textLine(width: 100, height: 14, cornerRadius: 4)
          SkeletonView.textLine(width: 120, height: 20, cornerRadius: 5)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 6) {
          SkeletonView.textLine(width: 80, height: 14, cornerRadius: 4)
          SkeletonView.textLine(width: 100, height: 20, cornerRadius: 5)
        }
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity)
    .frame(height: 180)
    .background(Color.oldMoney.surface)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
  }
}

// MARK: - Spending Trends Chart Skeleton

struct SpendingTrendsChartSkeleton: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Chart title
      HStack {
        SkeletonView.textLine(width: 140, height: 18, cornerRadius: 4)
        Spacer()
        SkeletonView.textLine(width: 60, height: 14, cornerRadius: 4)
      }

      // Chart area placeholder
      ZStack(alignment: .bottomLeading) {
        // Background grid pattern (static, not animated)
        chartGridPattern
          .opacity(0.3)

        // Placeholder line segments
        chartPlaceholderPath

        // Placeholder data points
        HStack(alignment: .bottom, spacing: 0) {
          ForEach(0..<7, id: \.self) { index in
            StaggeredSkeletonGroup(staggerDelay: Double(index) * 0.05) {
              SkeletonView.circle(diameter: 8)
                .padding(.bottom, CGFloat.random(in: 20...120))
            }
            if index < 6 {
              Spacer()
            }
          }
        }
        .padding(.horizontal, 16)
      }
      .frame(height: 200)
      .background(Color.oldMoney.surface.opacity(0.5))
      .cornerRadius(12)
    }
    .padding(20)
    .background(Color.oldMoney.surface)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
  }

  private var chartGridPattern: some View {
    GeometryReader { geometry in
      Path { path in
        let gridLineCount = 5
        let height = geometry.size.height
        let width = geometry.size.width

        // Horizontal grid lines
        for i in 0...gridLineCount {
          let y = (height / CGFloat(gridLineCount)) * CGFloat(i)
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: width, y: y))
        }

        // Vertical grid lines
        for i in 0...6 {
          let x = (width / 6) * CGFloat(i)
          path.move(to: CGPoint(x: x, y: 0))
          path.addLine(to: CGPoint(x: x, y: height))
        }
      }
      .stroke(Color.oldMoney.divider.opacity(0.2), lineWidth: 0.5)
    }
  }

  private var chartPlaceholderPath: some View {
    GeometryReader { geometry in
      Path { path in
        let width = geometry.size.width
        let height = geometry.size.height

        // Create a placeholder wavy line
        path.move(to: CGPoint(x: 0, y: height * 0.7))

        for i in 1...6 {
          let x = (width / 6) * CGFloat(i)
          let y = height * CGFloat.random(in: 0.3...0.8)
          path.addLine(to: CGPoint(x: x, y: y))
        }
      }
      .stroke(
        Color.oldMoney.divider.opacity(0.5),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
      )
    }
  }
}

// MARK: - Recent Transactions Skeleton

struct RecentTransactionsSkeleton: View {
  let rowCount: Int

  init(rowCount: Int = 5) {
    self.rowCount = rowCount
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Section title
      HStack {
        SkeletonView.textLine(width: 160, height: 18, cornerRadius: 4)
        Spacer()
        SkeletonView.textLine(width: 60, height: 14, cornerRadius: 4)
      }

      // Transaction rows
      VStack(spacing: 12) {
        ForEach(0..<rowCount, id: \.self) { index in
          StaggeredSkeletonGroup(staggerDelay: Double(index) * 0.05) {
            transactionRowSkeleton
          }
        }
      }
    }
    .padding(20)
    .background(Color.oldMoney.surface)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
  }

  private var transactionRowSkeleton: some View {
    HStack(spacing: 12) {
      // Icon circle
      SkeletonView.circle(diameter: 40)

      // Transaction details
      VStack(alignment: .leading, spacing: 6) {
        SkeletonView.textLine(width: 140, height: 16, cornerRadius: 4)
        SkeletonView.textLine(width: 100, height: 14, cornerRadius: 4)
      }

      Spacer()

      // Amount
      VStack(alignment: .trailing, spacing: 6) {
        SkeletonView.textLine(width: 80, height: 18, cornerRadius: 4)
        SkeletonView.textLine(width: 60, height: 12, cornerRadius: 4)
      }
    }
    .padding(12)
    .background(Color.oldMoney.background.opacity(0.5))
    .cornerRadius(12)
  }
}

// MARK: - Quick Stats Skeleton

struct QuickStatsSkeleton: View {
  var body: some View {
    HStack(spacing: 16) {
      ForEach(0..<3, id: \.self) { index in
        StaggeredSkeletonGroup(staggerDelay: Double(index) * 0.05) {
          quickStatCardSkeleton
        }
      }
    }
  }

  private var quickStatCardSkeleton: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        SkeletonView.circle(diameter: 32)
        Spacer()
      }

      VStack(alignment: .leading, spacing: 6) {
        SkeletonView.textLine(width: 60, height: 14, cornerRadius: 4)
        SkeletonView.textLine(width: 80, height: 24, cornerRadius: 6)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color.oldMoney.surface)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

// MARK: - Full Dashboard Skeleton

struct DashboardSkeleton: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Balance card
        BalanceCardSkeleton()

        // Quick stats
        QuickStatsSkeleton()

        // Spending trends chart
        SpendingTrendsChartSkeleton()

        // Recent transactions
        RecentTransactionsSkeleton(rowCount: 5)
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .padding(.bottom, 40)
    }
    .background(Color.oldMoney.background)
  }
}

// MARK: - Preview

#if DEBUG
struct DashboardSkeletons_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Individual skeletons
      VStack(spacing: 20) {
        BalanceCardSkeleton()

        QuickStatsSkeleton()

        RecentTransactionsSkeleton(rowCount: 3)
      }
      .padding()
      .background(Color.oldMoney.background)
      .previewDisplayName("Individual Components")

      // Full dashboard skeleton
      DashboardSkeleton()
        .previewDisplayName("Full Dashboard")

      // Dark mode
      DashboardSkeleton()
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")

      // Chart skeleton detail
      SpendingTrendsChartSkeleton()
        .padding()
        .background(Color.oldMoney.background)
        .previewDisplayName("Chart Detail")
    }
  }
}
#endif
