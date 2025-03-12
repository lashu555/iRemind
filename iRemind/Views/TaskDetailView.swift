//
//  TaskDetailView.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//
import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditTask = false

    var body: some View {
        VStack {
            Text(task.title ?? "")
                .font(.largeTitle)
                .padding()

            if let description = task.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .padding()
            }

            if let dueDate = task.dueDate {
                Text("Due: \(formattedDate(dueDate))")
                    .font(.caption)
                    .padding()
            }

            if task.status == TaskStatus.doing.rawValue {
                ProgressView(value: task.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                Text("\(Int(task.progress * 100))%")
                    .font(.caption)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("Task Details")
        .navigationBarItems(trailing: Button("Edit") {
            showingEditTask = true
        })
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
