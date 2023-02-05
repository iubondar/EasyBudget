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
        .navigationBarTitle(
            Text(viewTitle()),
            displayMode: .inline
        )
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
                    makeCategoryViewFrom(categoryViewData)
                }
            } else {
                makeCategoryViewFrom(categoryViewData)
                    .padding(.trailing, 18)
            }
        }
    }
    
    private func makeCategoryViewDataList() -> [CategoryViewData] {
        var categoryViewDataList = [CategoryViewData]()
        
        if let rootCategory = rootCategory {
            // Детальное представление для корневой категории - список её дочерних категорий
            for child in rootCategory.childrenList {
                categoryViewDataList.append(CategoryViewData(category: child, level: 1))
            }
        } else {
            // Стартовый экран по всем категориям первого уровня с суммой по записям больше 0
            for category in categories.filter(
                { $0.parent == nil && $0.calculateSum(month: Date.currentMonth, year: Date.currentYear) > 0 }
            ) {
                categoryViewDataList.append(CategoryViewData(category: category, level: 1))
            }
        }
        
        return categoryViewDataList
    }
    
    private func categoryAndChildrenViewData(from category: Category, level: Int) -> [CategoryViewData] {
        var categoryViewDataList = [CategoryViewData(category: category, level: level)]
        
        for child in category.childrenList {
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: child, level: level + 1))
        }
        
        return categoryViewDataList
    }
    
    @ViewBuilder private func makeCategoryViewFrom(_ data: CategoryViewData) -> some View {
        HStack {
            Text(data.category.name ?? "")
            Spacer()
            Text(sumString(from: data.category))
        }
    }
    
    private func viewTitle() -> String {
        let result: String
        
        if let rootCategory = rootCategory {
            result = (rootCategory.name ?? "") + " " + sumString(from: rootCategory)
        } else {
            result = titleDateFormatter.string(from: Date()).capitalized
        }
        
        return result
    }
    
    private func sumString(from category: Category) -> String {
        let number = NSNumber(value: category.calculateSum(month: Date.currentMonth, year: Date.currentYear))
        return sumFormatter.string(from: number) ?? ""
    }
}

// TODO: перенести во ViewModel
private let titleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL YYYY"
    return formatter
}()

private let sumFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    return formatter
}()

struct CurrentPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView(rootCategory: nil)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
