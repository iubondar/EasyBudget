//
//  EasyBudgetApp.swift
//  EasyBudget
//
//  Created by Бондарь Иван on 18.01.2023.
//

import SwiftUI

@main
struct EasyBudgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
