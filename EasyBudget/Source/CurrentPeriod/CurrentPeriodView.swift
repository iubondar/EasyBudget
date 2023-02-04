import SwiftUI

// TODO: Сделать детальный экран по категории, а на главном оставить только категории первого уровня
struct CurrentPeriodView: View {
    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    let rootCategory: Category? = nil
    
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
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddButton { isEditItemShown = true }
                    Spacer()
                }
            }
        }
        .navigationTitle(titleDateFormatter.string(from: Date()).capitalized)
        .navigationDestination(isPresented: $isEditItemShown) {
            EditItemView()
        }
    }

    private func makeCategoryListView() -> some View {
        ForEach(makeCategoryViewDataList()) { categoryViewData in
            NavigationLink {
                // TODO: открыть это же представление, но по выбранной категории
            } label: {
                CurrentPeriodCategoryView(data: categoryViewData)
            }
        }
    }
    
    private func makeCategoryViewDataList() -> [CurrentPeriodCategoryViewData] {
        var categoryViewDataList = [CurrentPeriodCategoryViewData]()
        
        if let rootCategory = rootCategory {
            // Детальное представление для корневой категории
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: rootCategory, level: 1))
        } else {
            // Стартовый экран по всем категориям первого уровня с суммой по записям больше 0
            for category in categories.filter(
                { $0.parent == nil && $0.calculateSum(month: Date.currentMonth, year: Date.currentYear) > 0 }
            ) {
                categoryViewDataList.append(CurrentPeriodCategoryViewData(category: category, level: 1))
            }
        }
        
        return categoryViewDataList
    }
    
    private func categoryAndChildrenViewData(from category: Category, level: Int) -> [CurrentPeriodCategoryViewData] {
        var categoryViewDataList = [CurrentPeriodCategoryViewData(category: category, level: level)]
        
        if let children = category.children as? Set<Category>, children.count > 0 {
            for child in children.sorted(by: { $0.name ?? "" > $1.name ?? "" }) {
                categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: child, level: level + 1))
            }
        }
        
        return categoryViewDataList
    }
}

// TODO: перенести во ViewModel
private let titleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL YYYY"
    return formatter
}()

struct CurrentPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
