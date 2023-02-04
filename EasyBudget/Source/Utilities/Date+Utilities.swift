import Foundation

extension Date {
    static var currentMonth: Int {
        Calendar.current.component(.month, from: Date.now)
    }
    
    static var currentYear: Int {
        Calendar.current.component(.year, from: Date.now)
    }
}
