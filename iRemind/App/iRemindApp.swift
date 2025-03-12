//
//  iRemindApp.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 06.03.25.
//

import SwiftUI
import UserNotifications

@main
struct iRemindApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        let transformer = PhotosTransformer()
        requestNotificationPermissions()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("PhotosTransformer"))
    }

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
}
