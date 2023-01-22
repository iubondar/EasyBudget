import SwiftUI

struct EditCategoryView: View {
    // MARK: State management
    @State var parentCategory: Category?
    
    // MARK: Отображение
    @State private var err: ErrorInfo?
    
    var body: some View {
        Form {
            TextField("Название:", text: $name)

            NavigationLink {
                CategoryListView(
                    selectedCategory: $parentCategory,
                    onCategorySelected: { $0.dismiss() }
                )
            } label: {
                Text(category?.name ?? "<Родительская категория>")
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
        .navigationTitle("Новая категория")
        // TODO: перенести в базовый View?
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
    // TODO: перенести в модель
    @State private var name: String = ""
    @State var category: Category?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private func validateAndSave() {
        let errorTitle = "Ошибка значения"

        guard !name.isEmpty else {
            err = ErrorInfo(id: 1, title: errorTitle, description: "Введи название")
            return
        }
        
        let newCategory = Category(context: viewContext)
        newCategory.name = name
        newCategory.parent = category

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            err = ErrorInfo(id: 3, title: "Ошибка сохранения", description: nsError.localizedDescription)
        }
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    @State static var category: Category?
    
    static var previews: some View {
        EditCategoryView()
    }
}
