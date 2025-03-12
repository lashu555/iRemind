import SwiftUI
import CoreData

struct TaskListView: View {
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.creationDate, ascending: true)],
        predicate: NSPredicate(format: "deletedDate == nil")
    ) var tasks: FetchedResults<Task>
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false
    @State private var showingRecycleBin = false
    
    var body: some View {
        NavigationView {
            List {
                taskSection(title: "To Do", status: .todo, color: Theme.todoColor)
                taskSection(title: "Doing", status: .doing, color: Theme.doingColor)
                taskSection(title: "Done", status: .done, color: Theme.doneColor)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("iRemind")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingRecycleBin = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(Theme.secondaryText)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingRecycleBin) {
                RecycleBinView()
            }
        }
    }
    
    private func taskSection(title: String, status: TaskStatus, color: Color) -> some View {
        Section {
            let filteredTasks = tasks.filter { $0.status == status.rawValue }
            
            if filteredTasks.isEmpty {
                Text("No tasks")
                    .font(.callout)
                    .foregroundColor(Theme.secondaryText)
                    .padding(.vertical, 8)
            } else {
                ForEach(filteredTasks) { task in
                    NavigationLink {
                        TaskDetailView(task: task)
                    } label: {
                        TaskRow(task: task)
                    }
                }
                .onDelete { indexSet in
                    deleteTask(at: indexSet, status: status)
                }
            }
        } header: {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(tasks.filter { $0.status == status.rawValue }.count)")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.secondaryBackground)
                    .clipShape(Capsule())
            }
            .padding(.vertical, 4)
        }
    }
    
    private func deleteTask(at offsets: IndexSet, status: TaskStatus) {
        withAnimation {
            for index in offsets {
                let task = tasks.filter { $0.status == status.rawValue }[index]
                task.deletedDate = Date()
                saveContext()
            }
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 
