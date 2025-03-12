//
//  TaskService.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//
import CoreData
import UIKit

class TaskService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addTask(title: String, status: TaskStatus, progress: Double, photos: [UIImage]) {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.status = status.rawValue
        newTask.progress = progress
        newTask.photos = photos.compactMap { $0.pngData() } as NSObject
        newTask.deletedDate = nil
        
        saveContext()
    }

    func addSubtask(to task: Task, title: String, isCompleted: Bool) {
        let newSubtask = Subtask(context: context)
        newSubtask.id = UUID()
        newSubtask.title = title
        newSubtask.isCompleted = isCompleted
        newSubtask.parentTask = task

        saveContext()
    }

    func updateTask(_ task: Task, title: String? = nil, status: TaskStatus? = nil, progress: Double? = nil, photos: [UIImage]? = nil) {
        if let title = title {
            task.title = title
        }

        if let status = status {
            task.status = status.rawValue
        }

        if let progress = progress {
            task.progress = progress
        }

        if let photos = photos {
            task.photos = photos.compactMap { $0.pngData() } as NSObject
        }

        saveContext()
    }

    func deleteTask(_ task: Task) {
        task.deletedDate = Date()
        saveContext()
    }

    func restoreTask(_ task: Task) {
        task.deletedDate = nil
        saveContext()
    }

    func permanentlyDeleteTask(_ task: Task) {
        context.delete(task)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
