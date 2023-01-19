import SwiftUI
import Combine

struct EditItemView: View {
    @State var date = Date()
    @State var amount = ""
    @State var category: Category?
    
    var body: some View {
        Form {
            DatePicker("Дата:", selection: $date, in: ...Date(), displayedComponents: .date)
            
            NavigationLink {
                // TODO: переход на экран выбора категории
                Text("Destination")
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
        }
        .navigationTitle("Новая запись")
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView()
    }
}
