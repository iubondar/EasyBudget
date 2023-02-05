import Foundation

extension Date {
    static var currentMonth: Int {
        Calendar.current.component(.month, from: Date.now)
    }
    
    static var currentYear: Int {
        Calendar.current.component(.year, from: Date.now)
    }
    
    static func monthInterval(month: Int, year: Int) -> DateInterval {
        // Начальная дата
        var components = DateComponents()
        components.month = month
        components.year = year
        
        guard let startDateOfMonth = Calendar.current.date(from: components) else {
            fatalError("Не удалось получить начальную дату. Месяц: \(month), год: \(year)")
        }

        // Конечная дата
        components.year = 0
        components.month = 1
        components.day = -1
        
        guard let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDateOfMonth) else {
            fatalError("Не удалось получить конечную дату. Месяц: \(month), год: \(year)")
        }
        
        return DateInterval(start: startDateOfMonth, end: endDateOfMonth)
    }
}
