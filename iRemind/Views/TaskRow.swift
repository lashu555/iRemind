//
//  TaskRow.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task

    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title ?? "")
                .font(.headline)
            
            if let description = task.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            
            if let dueDate = task.dueDate {
                Text("Due: \(formattedDate(dueDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if task.status == TaskStatus.doing.rawValue {
                ProgressView(value: task.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                Text("\(Int(task.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
