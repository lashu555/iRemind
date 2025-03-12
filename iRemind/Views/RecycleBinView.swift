//
//  RecycleBinView.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

struct RecycleBinView: View {
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.deletedDate, ascending: true)],
        predicate: NSPredicate(format: "deletedDate != nil")
    ) var deletedTasks: FetchedResults<Task>
    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            List {
                ForEach(deletedTasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.title ?? "")
                            .font(.headline)
                        
                        if let deletedDate = task.deletedDate {
                            Text("Deleted on: \(formattedDate(deletedDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Will be permanently deleted after 2 weeks")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .swipeActions {
                        Button("Restore") {
                            restoreTask(task: task)
                        }
                        .tint(.green)
                        
                        Button("Delete") {
                            permanentlyDeleteTask(task: task)
                        }
                        .tint(.red)
                    }
                }
            }
            .navigationTitle("Recycle Bin")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func restoreTask(task: Task) {
        task.deletedDate = nil
        saveContext()
    }
    
    private func permanentlyDeleteTask(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    RecycleBinView()
}
