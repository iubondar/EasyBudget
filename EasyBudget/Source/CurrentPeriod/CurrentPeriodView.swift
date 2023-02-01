import SwiftUI

fileprivate struct CategoryViewData: Identifiable {
    let category: Category
    let level: Int
    
    var id: ObjectIdentifier {
        return category.id
    }
}

// TODO: Сделать детальный экран по категории, а на главном оставить только категории первого уровня
struct CurrentPeriodView: View {
    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    // TODO: добавить фильтрацию по текущему месяцу
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    @State private var isEditItemShown = false
    
    var body: some View {
        ZStack {
            List {
                makeCategoryListView()
            }
            
            NavigationLink("Hidden link to item add view", isActive: $isEditItemShown) {
                EditItemView(
                    onItemSaved: { view in
                        view.dismiss()
                    }
                )
            }
            .hidden()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddButtonBuilder.buildAddButton {
                        isEditItemShown = true
                    }
                    Spacer()
                }
            }
        }
    }

    private func makeCategoryListView() -> some View {
        var categoryViewDataList = [CategoryViewData]()
        for category in categories.filter({ $0.parent == nil }) {
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: category, level: 1))
        }
        
        return ForEach(categoryViewDataList) { categoryViewData in
            NavigationLink {
                // TODO: открыть это же представление, но по выбранной категории
            } label: {
                makeCategoryViewFrom(categoryViewData)
            }
        }
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
    
    @ViewBuilder private func makeCategoryViewFrom(_ data: CategoryViewData) -> some View {
        HStack {
            Text(data.category.name ?? "")
                .font(fontFor(level: data.level))
                .foregroundColor(.black)
                .padding(.leading, CGFloat(12 * (data.level - 1)))
            
            Spacer()
            
            Text(
                String(data.category.calculateSum(
                    month: Calendar.current.component(.month, from: Date.now),
                    year: Calendar.current.component(.year, from: Date.now)
                ))
            )
                .font(fontFor(level: data.level))
                .foregroundColor(.black)
        }
    }
    
    private func fontFor(level: Int) -> Font {
        switch level {
        case 1: return Font.title
        case 2: return Font.title2
        case 3: return Font.title3
        default: return Font.body
        }
    }
}

struct CurrentPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
