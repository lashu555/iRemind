import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditTask = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                headerSection
                
                if let description = task.taskDescription, !description.isEmpty {
                    descriptionSection(description)
                }
                
                statusSection
                
                if let dueDate = task.dueDate {
                    dueDateSection(dueDate)
                }
                
                if let photosData = task.photos as? [Data], !photosData.isEmpty {
                    photosSection(photosData)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditTask = true
                } label: {
                    Text("Edit")
                        .foregroundColor(Theme.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Theme.destructive)
                }
            }
        }
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Move to Recycle Bin", role: .destructive) {
                moveToRecycleBin()
            }
        } message: {
            Text("This task will be moved to the Recycle Bin.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(task.title ?? "")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
            
            statusBadge
        }
        .modifier(CardStyle())
    }
    
    private var statusBadge: some View {
        let status = TaskStatus(rawValue: Int(task.status)) ?? .todo
        return Text(status.description)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .clipShape(Capsule())
    }
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(Theme.text)
            
            Text(description)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardStyle())
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
                .foregroundColor(Theme.text)
            
            if task.status == TaskStatus.doing.rawValue {
                ProgressView(value: task.progress)
                    .progressViewStyle(.linear)
                    .tint(Theme.doingColor)
                
                Text("\(Int(task.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text(task.status == TaskStatus.done.rawValue ? "Completed" : "Not Started")
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .modifier(CardStyle())
    }
    
    private func dueDateSection(_ date: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Due Date")
                .font(.headline)
                .foregroundColor(Theme.text)
            
            HStack {
                Image(systemName: "calendar")
                Text(date, style: .date)
                    .foregroundColor(date < Date() ? Theme.destructive : Theme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardStyle())
    }
    
    private func photosSection(_ photosData: [Data]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photos")
                .font(.headline)
                .foregroundColor(Theme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photosData, id: \.self) { data in
                        if let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .modifier(CardStyle())
    }
    
    private func moveToRecycleBin() {
        withAnimation {
            task.deletedDate = Date()
            do {
                try viewContext.save()
            } catch {
                print("Error moving task to recycle bin: \(error)")
            }
        }
    }
} 
