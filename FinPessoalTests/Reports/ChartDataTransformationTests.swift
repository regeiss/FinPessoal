import XCTest
@testable import FinPessoal

@MainActor
final class ChartDataTransformationTests: XCTestCase {

  func testCategorySpendingToChartSegment() {
    let spending = CategorySpending(
      category: .food,
      amount: 500,
      percentage: 25,
      transactionCount: 10
    )

    let segment = spending.toChartSegment(totalSpent: 2000)

    XCTAssertEqual(segment.id, "food")
    XCTAssertEqual(segment.value, 500)
    XCTAssertEqual(segment.percentage, 25)
    XCTAssertEqual(segment.label, spending.category.displayName)
    XCTAssertNil(segment.category)
  }

  func testMonthlyTrendToChartBar() {
    let trend = MonthlyTrend(
      month: "Jan 2026",
      income: 5000,
      expenses: 1500,
      netIncome: 3500
    )

    let bar = trend.toChartBar(maxAmount: 2000)

    XCTAssertEqual(bar.id, "Jan 2026")
    XCTAssertEqual(bar.value, 1500)
    XCTAssertEqual(bar.maxValue, 2000)
    XCTAssertEqual(bar.label, "Jan")
  }
}
