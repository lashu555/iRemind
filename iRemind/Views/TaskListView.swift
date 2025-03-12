//
//  TaskListView.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

struct TaskListView: View {
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.creationDate, ascending: true)],
        predicate: NSPredicate(format: "deletedDate == nil")
    ) var tasks: FetchedResults<Task>
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false

    var body: some View {
        NavigationView {
            List {
                // To Do Section
                Section(header: Text("To Do")) {
                    ForEach(tasks.filter { $0.status == TaskStatus.todo.rawValue }) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete { indexSet in
                        deleteTask(at: indexSet, status: .todo)
                    }
                }
                
                // Doing Section
                Section(header: Text("Doing")) {
                    ForEach(tasks.filter { $0.status == TaskStatus.doing.rawValue }) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete { indexSet in
                        deleteTask(at: indexSet, status: .doing)
                    }
                }
                
                // Done Section
                Section(header: Text("Done")) {
                    ForEach(tasks.filter { $0.status == TaskStatus.done.rawValue }) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete { indexSet in
                        deleteTask(at: indexSet, status: .done)
                    }
                }
            }
            .navigationTitle("Personal Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet, status: TaskStatus) {
        for index in offsets {
            let task = tasks.filter { $0.status == status.rawValue }[index]
            task.deletedDate = Date()
            saveContext()
        }
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
    TaskListView()
}
