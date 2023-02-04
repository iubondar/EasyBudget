import Foundation

extension Category {
    var hasChildren: Bool {
        return childrenList.count > 0
    }
    
    var childrenList: [Category] {
        var result = [Category]()
        
        if let children = children as? Set<Category>, children.count > 0 {
            result = children.sorted(by: { $0.name ?? "" > $1.name ?? "" })
        }
        
        return result
    }
    
    func calculateSum(month: Int, year: Int) -> Int {
        guard month >= 1 && month <= 12 else {
            fatalError("Ожидаем месяц в интервале [1...12], получили \(month)")
        }
        
        guard year >= 2000 && year <= Calendar.current.component(.year, from: Date()) else {
            fatalError("Ожидаем год в интервале [2000...<Текущий год>], получили \(year)")
        }
        
        let components = DateComponents(year: year, month: month, day: 1)
        guard let startDate = Calendar.current.date(from: components) else {
            fatalError("Не удалось создать дату из переданных компонентов месяц: \(month), год: \(year)")
        }
                
        var result = 0
        
        // Сумма по записям в этой категории
        if let items = self.items as? Set<Item> {
            result = items.filter({
                if let date = $0.date {
                    return (startDate...Date.now).contains(date)
                } else {
                    return false
                }
            }).reduce(result, { $0 + ($1.amount?.intValue ?? 0) })
        }
        
        // Сумма по всем подкатегориям
        result = childrenList.reduce(result, { $0 + $1.calculateSum(month: month, year: year) })
        
        return result
    }
}
