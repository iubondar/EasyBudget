import SwiftUI

struct CurrentPeriodView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.date!, formatter: itemFormatter)")
                    } label: {
                        Text(item.date!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink {
                        EditItemView()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    // TODO: перенести во ViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.date, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.date = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // TODO: перенести во ViewModel
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// TODO: перенести во ViewModel
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct CurrentPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPeriodView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
