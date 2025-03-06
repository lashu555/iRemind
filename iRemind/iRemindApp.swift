//
//  iRemindApp.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 06.03.25.
//

import SwiftUI

@main
struct iRemindApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
