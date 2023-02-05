import SwiftUI
import Combine

struct EditItemView: View {
    @State private var date = Date()
    @State private var amount = ""
    @State private var category: Category?
    @State private var comment = ""
    
    @State private var calendarId: Int = 0

    var body: some View {
        Form {
            DatePicker("Дата:", selection: $date, in: ...Date(), displayedComponents: .date)
                // Далее идёт грязный хак для того, чтобы пикер закрывался после выбора даты
                .id(calendarId)
                .onChange(of: date, perform: { _ in
                    calendarId += 1
                })
                .onTapGesture {
                    calendarId += 1
                }
            
            NavigationLink {
                CategoryListView(
                    shouldShowAddButton: true,
                    selectedCategory: $category,
                    onCategorySelected: { $0.dismiss() }
                )
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
            
            Section(header: Text("Комментарий:")) {
                TextEditor(text: $comment)
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
    
    // MARK: State management
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
        newItem.comment = comment

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            err = ErrorInfo(id: 3, title: "Ошибка сохранения", description: nsError.localizedDescription)
            return
        }
    }
    
    // TODO: Придумать что сделать с дублированием
    @State private var err: ErrorInfo?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView()
    }
}
