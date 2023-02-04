import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CurrentPeriodView(rootCategory: nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView(rootCategory: nil)
    }
}
