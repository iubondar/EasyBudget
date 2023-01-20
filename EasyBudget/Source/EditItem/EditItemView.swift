import SwiftUI
import Combine

struct EditItemView: View {
    @State var date = Date()
    @State var amount = ""
    @State var category: Category?
    
    @State private var err: ErrorInfo?
    
    var body: some View {
        Form {
            DatePicker("Дата:", selection: $date, in: ...Date(), displayedComponents: .date)
            
            NavigationLink {
                CategoryListView()
            } label: {
                Text(category?.name ?? "Выбери категорию")
            }
            
            TextField("Сумма:", text: $amount)
                .keyboardType(.numberPad)
                .onReceive(Just(amount)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.amount = filtered
                    }
                }
            
            Section {
                Button {
                    validateAndSave()
                } label: {
                    HStack {
                        Spacer()
                        Text("Сохранить")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Новая запись")
        .alert(
            item: $err,
            content: { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.description)
                )
            }
        )
    }
    
    /// State management
    @Environment(\.managedObjectContext) private var viewContext
    
    private func validateAndSave() {
        let errorTitle = "Ошибка значения"
        
        guard let category = category else {
            err = ErrorInfo(id: 1, title: errorTitle, description: "Выбери категорию")
            return
        }

        guard !amount.isEmpty else {
            err = ErrorInfo(id: 2, title: errorTitle, description: "Введи сумму")
            return
        }
        
        let newItem = Item(context: viewContext)
        newItem.date = date
        newItem.category = category
        newItem.amount = NSDecimalNumber(string: amount)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            err = ErrorInfo(id: 3, title: "Ошибка сохранения", description: nsError.localizedDescription)
        }
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView()
    }
}
