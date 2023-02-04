import SwiftUI

// TODO: Сделать детальный экран по категории, а на главном оставить только категории первого уровня
struct CurrentPeriodView: View {
    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    let rootCategory: Category?
    
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
        .navigationTitle(viewTitle())
        .navigationDestination(isPresented: $isEditItemShown) {
            EditItemView()
        }
    }

    private func makeCategoryListView() -> some View {
        ForEach(makeCategoryViewDataList()) { categoryViewData in
            if categoryViewData.category.hasChildren {
                NavigationLink {
                    CurrentPeriodView(rootCategory: categoryViewData.category)
                } label: {
                    CurrentPeriodCategoryView(data: categoryViewData)
                }
            } else {
                CurrentPeriodCategoryView(data: categoryViewData)
                    .padding(.trailing, 18)
            }
        }
    }
    
    private func makeCategoryViewDataList() -> [CurrentPeriodCategoryViewData] {
        var categoryViewDataList = [CurrentPeriodCategoryViewData]()
        
        if let rootCategory = rootCategory {
            // Детальное представление для корневой категории - список её дочерних категорий
            for child in rootCategory.childrenList {
                categoryViewDataList.append(CurrentPeriodCategoryViewData(category: child, level: 1))
            }
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
        
        for child in category.childrenList {
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: child, level: level + 1))
        }
        
        return categoryViewDataList
    }
    
    private func viewTitle() -> String {
        let result: String
        
        if let rootCategory = rootCategory {
            result = (rootCategory.name ?? "")
                + " "
                + String(rootCategory.calculateSum(month: Date.currentMonth, year: Date.currentYear))
        } else {
            result = titleDateFormatter.string(from: Date()).capitalized
        }
        
        return result
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
        CurrentPeriodView(rootCategory: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
