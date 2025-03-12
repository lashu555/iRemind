//
//  EditTaskView.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var includeDueDate: Bool
    @State private var status: TaskStatus
    @State private var progress: Double
    
    // Custom initializer to ensure all properties are initialized
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _description = State(initialValue: task.taskDescription ?? "")
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _includeDueDate = State(initialValue: task.dueDate != nil)
        _status = State(initialValue: TaskStatus(rawValue: Int(task.status)) ?? .todo)
        _progress = State(initialValue: task.progress)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    
                    TextField("Description (Optional)", text: $description)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Set Due Date", isOn: $includeDueDate)
                    
                    if includeDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.description).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Progress")) {
                    Slider(value: $progress, in: 0...1, step: 0.01)
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        task.title = title
        task.taskDescription = description.isEmpty ? nil : description
        task.status = Int16(status.rawValue)
        task.progress = progress
        task.dueDate = includeDueDate ? dueDate : nil
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
