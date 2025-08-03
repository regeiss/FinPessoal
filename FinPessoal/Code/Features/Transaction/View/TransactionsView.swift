
import SwiftUI 

struct TransactionsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    NavigationView {
      List {
        ForEach(financeViewModel.transactions) { transaction in
          TransactionRow(transaction: transaction)
        }
      }
      .navigationTitle("Transações")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            // Action to add new transaction
          }
        }
      }
    }
  }
}
