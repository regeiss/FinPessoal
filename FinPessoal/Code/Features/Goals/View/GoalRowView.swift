//
//  GoalRowView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct GoalRowView: View {
  let goal: Goal
  
  var body: some View {
    HStack(spacing: 12) {
      // Category icon
      Image(systemName: goal.category.icon)
        .font(.system(size: 20))
        .foregroundColor(Color(goal.category.color))
        .frame(width: 40, height: 40)
        .background(Color(goal.category.color).opacity(0.1))
        .clipShape(Circle())
      
      // Goal info
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(goal.name)
            .font(.headline)
            .foregroundColor(.primary)
          
          Spacer()
          
          if goal.isCompleted {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
          }
        }
        
        Text(goal.category.displayName)
          .font(.caption)
          .foregroundColor(.secondary)
        
        // Progress bar
        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text(CurrencyFormatter.shared.string(from: goal.currentAmount))
              .font(.caption)
              .fontWeight(.medium)
            
            Text("/ \(CurrencyFormatter.shared.string(from: goal.targetAmount))")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(goal.progressPercentage))%")
              .font(.caption)
              .fontWeight(.medium)
              .foregroundColor(Color(goal.category.color))
          }
          
          ProgressView(value: goal.progressPercentage / 100.0)
            .progressViewStyle(LinearProgressViewStyle(tint: Color(goal.category.color)))
            .scaleEffect(x: 1, y: 0.8, anchor: .center)
        }
      }
      
      // Chevron
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
  }
}