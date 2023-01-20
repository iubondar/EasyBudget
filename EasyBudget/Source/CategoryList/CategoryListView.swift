import SwiftUI

struct CategoryListView: View {
    // MARK: State management
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
    @State private var err: ErrorInfo?
    
    var body: some View {
        List {
            ForEach(categories) { category in
                // TODO: перенести в функцию, развернуть рекурсивно с разными вью и отступами
                Text(category.name ?? "").font(.title).padding()
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
                    EditCategoryView()
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
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView()
    }
}
