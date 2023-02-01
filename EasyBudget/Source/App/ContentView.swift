import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            CurrentPeriodView()
                .navigationTitle(titleDateFormatter.string(from: Date()).capitalized)
        }
    }
}

// TODO: перенести во ViewModel
private let titleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL YYYY"
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView()
    }
}
