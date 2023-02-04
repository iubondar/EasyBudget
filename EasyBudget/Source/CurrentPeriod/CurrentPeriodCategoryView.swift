import SwiftUI

struct CurrentPeriodCategoryView: View {
    let data: CurrentPeriodCategoryViewData
    
    var body: some View {
        HStack {
            Text(data.category.name ?? "")
                .font(fontFor(level: data.level))
                .foregroundColor(.black)
                .padding(.leading, CGFloat(12 * (data.level - 1)))
            
            Spacer()
            
            Text(
                String(data.category.calculateSum(month: Date.currentMonth, year: Date.currentYear))
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

struct CurrentPeriodCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodCategoryView(
            data: CurrentPeriodCategoryViewData(category: Category(), level: 1)
        )
    }
}
