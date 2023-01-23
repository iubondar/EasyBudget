import SwiftUI

fileprivate struct CategoryViewData: Identifiable {
    let category: Category
    let level: Int
    
    var id: ObjectIdentifier {
        return category.id
    }
}

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
            makeCategoryListView()
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
    
    private func makeCategoryListView() -> some View {
        var categoryViewDataList = [CategoryViewData]()
        for category in categories.filter({ $0.parent == nil }) {
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: category, level: 1))
        }
        
        return ForEach(categoryViewDataList) { categoryViewData in
            Button {
                selectedCategory = categoryViewData.category
                onCategorySelected?(self)
            } label: {
                makeCategoryViewFrom(categoryViewData)
            }
        }
        .onDelete(perform: deleteCategories)
    }
    
    private func categoryAndChildrenViewData(from category: Category, level: Int) -> [CategoryViewData] {
        var categoryViewDataList = [CategoryViewData(category: category, level: level)]
        
        if let children = category.children as? Set<Category>, children.count > 0 {
            for child in children.sorted(by: { $0.name ?? "" > $1.name ?? "" }) {
                categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: child, level: level + 1))
            }
        }
        
        return categoryViewDataList
    }
    
    private func makeCategoryViewFrom(_ data: CategoryViewData) -> some View {
        let font: Font
        
        switch data.level {
        case 1: font = Font.title
        case 2: font = Font.title2
        case 3: font = Font.title3
        default: font = Font.body
        }
        
        return Text(data.category.name ?? "")
            .font(font)
            .foregroundColor(.black)
            .padding(.leading, CGFloat(12 * (data.level - 1)))
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