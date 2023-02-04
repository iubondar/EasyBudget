import SwiftUI

struct EditCategoryView: View {
    // TODO: перенести в модель
    @State private var name: String = ""
    @State var parentCategory: Category?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: Отображение
    var body: some View {
        Form {
            TextField("Название:", text: $name)

            NavigationLink {
                CategoryListView(
                    shouldShowAddButton: false,
                    selectedCategory: $parentCategory,
                    onCategorySelected: { $0.dismiss() }
                )
            } label: {
                Text(parentCategory?.name ?? "<Родительская категория>")
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
        // TODO: придумать что сделать с дублированием
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
    private func validateAndSave() {
        let errorTitle = "Ошибка значения"

        guard !name.isEmpty else {
            err = ErrorInfo(id: 1, title: errorTitle, description: "Введи название")
            return
        }
        
        let newCategory = Category(context: viewContext)
        newCategory.name = name
        newCategory.parent = parentCategory

        do {
            try viewContext.save()
            
            dismiss()
        } catch {
            let nsError = error as NSError
            err = ErrorInfo(id: 3, title: "Ошибка сохранения", description: nsError.localizedDescription)
        }
    }
    
    // TODO: Придумать что сделать с дублированием
    @State private var err: ErrorInfo?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    @State static var category: Category?
    
    static var previews: some View {
        EditCategoryView()
    }
}
