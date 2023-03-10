import SwiftUI

struct CategoryItemsView: View {
    let category: Category
    
    @State private var isItemCommentShown = false
    
    @FetchRequest private var fetchRequest: FetchedResults<Item>
    
    init(category: Category, month: Int, year: Int) {
        self.category = category
        
        let interval = Date.monthInterval(month: month, year: year)
        let predicate = NSPredicate(
            format: "category = %@ && date >= %@ && date <= %@",
            category,
            interval.start as NSDate,
            interval.end as NSDate
        )
        
        _fetchRequest = FetchRequest<Item>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: false)],
            predicate: predicate
        )
    }
    
    var body: some View {
        Form {
            // Категория
            HStack {
                Text(category.name ?? "")
                Spacer()
                Text(sumString(from: category))
            }
            
            // Записи
            List {
                ForEach(fetchRequest) { item in
                    HStack {
                        Text(itemDateFormatter.string(from: item.date ?? Date()))
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        Text(sumFormatter.string(from: item.amount ?? 0) ?? "")
                        
                        if let comment = item.comment, !comment.isEmpty {
                            Button {
                                isItemCommentShown = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .sheet(isPresented: $isItemCommentShown) {
                                Text(comment)
                            }
                        }
                    }
                }
            }
        }
    }

    // TODO: убрать дублирование
    private func sumString(from category: Category) -> String {
        let number = NSNumber(value: category.calculateSum(month: Date.currentMonth, year: Date.currentYear))
        return sumFormatter.string(from: number) ?? ""
    }
}

// TODO: убрать дублирование
private let sumFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    return formatter
}()

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM"
    return formatter
}()

struct CategoryItemsView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryItemsView(category: Category(), month: 1, year: 2023)
    }
}
