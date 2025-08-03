//
//  DetailRow.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct DetailRow: View {
  let label: String
  let value: String
  
  var body: some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}
