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

    init() {
        let transformer = PhotosTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("PhotosTransformer"))
    }

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
