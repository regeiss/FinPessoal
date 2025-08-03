import SwiftUI

struct AddBudgetScreen: View {

  @EnvironmentObject var budgetViewModel: BudgetViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      Form {
        Section("Informações Básicas") {
          TextField("Nome do Orçamento", text: $budgetViewModel.name)

          Picker("Categoria", selection: $budgetViewModel.selectedCategory) {
            ForEach(TransactionCategory.allCases, id: \.self) { category in
              Label(category.rawValue, systemImage: category.icon)
                .tag(category)
            }
          }
        }

        Section("Valor e Período") {
          HStack {
            Text("R$")
            TextField("0,00", text: $budgetViewModel.budgetAmount)
              .keyboardType(.decimalPad)
          }

          Picker("Período", selection: $budgetViewModel.selectedPeriod) {
            ForEach(BudgetPeriod.allCases, id: \.self) { period in
              Label(period.rawValue, systemImage: period.icon)
                .tag(period)
            }
          }

          DatePicker(
            "Data de Início",
            selection: $budgetViewModel.startDate,
            displayedComponents: .date
          )
        }

        Section("Configurações de Alerta") {
          VStack(alignment: .leading, spacing: 8) {
            Text(
              "Alerta em \(Int(budgetViewModel.alertThreshold * 100))% do orçamento"
            )
            .font(.caption)
            .foregroundColor(.secondary)

            Slider(
              value: $budgetViewModel.alertThreshold,
              in: 0.5...0.95,
              step: 0.05
            )
            .tint(.blue)
          }
        }

        Section {
          Button("Criar Orçamento") {
            Task {
              await createBudget()
            }
          }
          .disabled(!budgetViewModel.isValidBudget || budgetViewModel.isLoading)
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Novo Orçamento")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            dismiss()
          }
        }
      }
      .alert(
        "Erro",
        isPresented: .constant(budgetViewModel.errorMessage != nil)
      ) {
        Button("OK") {
          budgetViewModel.errorMessage = nil
        }
      } message: {
        Text(budgetViewModel.errorMessage ?? "")
      }
    }
  }

  private func createBudget() async {
    guard let budget = budgetViewModel.createBudget() else {
      budgetViewModel.errorMessage = "Dados inválidos"
      return
    }

    await financeViewModel.addBudget(budget)
    budgetViewModel.reset()
    dismiss()
  }
}
