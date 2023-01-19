import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            CurrentPeriodView()
                .navigationTitle("Текущий период")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView()
    }
}
