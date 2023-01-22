import SwiftUI

struct CategoryListView: View {
    // MARK: State management
    @Binding var selectedCategory: Category?
    var onCategorySelected: ((_ view: CategoryListView) -> ())?
        
    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    // TODO: сделать generic функцию в модели
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                err = ErrorInfo(id: 1, title: "Ошибка удаления", description: nsError.localizedDescription)
            }
        }
    }
    
    // MARK: Отображение
    var body: some View {
        List {
            ForEach(categories) { category in
                // TODO: перенести в функцию, развернуть рекурсивно с разными вью и отступами
                Button {
                    selectedCategory = category
                    onCategorySelected?(self)
                } label: {
                    Text(category.name ?? "").font(.title).padding()
                }
            }
            .onDelete(perform: deleteCategories)
        }
        // Пустое состояние списка категорий
        .overlay {
            if categories.isEmpty {
                Text("Категорий пока нет:(")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
                    .ignoresSafeArea()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                NavigationLink {
                    EditCategoryView(onCategorySaved: { $0.dismiss() })
                } label: {
                    Label("Новая категория", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Категории")
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
    
    // TODO: Придумать что сделать с дублированием
    @State private var err: ErrorInfo?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct CategoryListView_Previews: PreviewProvider {
    @State static var category: Category?
    
    static var previews: some View {
        CategoryListView(selectedCategory: $category)
    }
}
