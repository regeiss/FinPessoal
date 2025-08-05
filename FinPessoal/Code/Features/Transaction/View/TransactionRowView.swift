import SwiftUI

struct TransactionRow: View {
  let transaction: Transaction
  
  var body: some View {
    HStack {
      Image(systemName: transaction.category.icon)
        .font(.title3)
        .foregroundColor(.blue)
        .frame(width: 32, height: 32)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.description)
          .font(.headline)
        
        HStack {
          Text(transaction.category.rawValue)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Text(dateFormatted(transaction.date))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      Text(transaction.formattedAmount)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(transaction.type == .expense ? .red : .green)
    }
    .padding(.vertical, 4)
  }
  
  private func dateFormatted(_ date: Date) -> String {
    DateFormatter.transaction.string(from: date)
  }
}
