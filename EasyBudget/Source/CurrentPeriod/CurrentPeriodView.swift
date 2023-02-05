import SwiftUI

fileprivate struct CategoryViewData: Identifiable {
    let category: Category
    let level: Int
    
    var id: ObjectIdentifier {
        return category.id
    }
}

struct CurrentPeriodView: View {
    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    let rootCategory: Category?
    
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
            // Для стартового экрана имеем возможность провалиться внутрь выбранной категории где есть потомки
            if rootCategory == nil && categoryViewData.category.hasChildren {
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
            // Детальное представление для корневой категории
            categoryViewDataList.append(contentsOf: categoryAndChildrenViewData(from: rootCategory, level: 1))
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
                .padding(.leading, CGFloat(16 * (data.level - 1)))
            
            Spacer()
            
            Text(sumString(from: data.category))
        }
    }
    
    private func viewTitle() -> String {
        var result = ""
        
        if rootCategory == nil {
            result = titleDateFormatter.string(from: Date()).capitalized
        }
        
        return result
    }
    
    private func sumString(from category: Category) -> String {
        let number = NSNumber(value: category.calculateSum(month: Date.currentMonth, year: Date.currentYear))
        return sumFormatter.string(from: number) ?? ""
    }
}

// TODO: перенести в презентер
private let titleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL"
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
