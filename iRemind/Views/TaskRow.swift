import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusIcon
                
                Text(task.title ?? "")
                    .font(.headline)
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                if let dueDate = task.dueDate {
                    dueDateLabel(dueDate)
                }
            }
            
            if let description = task.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .lineLimit(2)
            }
            
            if task.status == TaskStatus.doing.rawValue {
                progressView
            }
            
            if let photosData = task.photos as? [Data], !photosData.isEmpty {
                thumbnailView(photosData: photosData)
            }
        }
        .padding(.vertical, 4)
        .modifier(TaskRowStyle())
    }
    
    private var statusIcon: some View {
        let iconName: String
        let color: Color
        
        switch TaskStatus(rawValue: Int(task.status)) ?? .todo {
        case .todo:
            iconName = "circle"
            color = Theme.todoColor
        case .doing:
            iconName = "arrow.triangle.2.circlepath"
            color = Theme.doingColor
        case .done:
            iconName = "checkmark.circle.fill"
            color = Theme.doneColor
        }
        
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
    
    private var progressView: some View {
        VStack(spacing: 4) {
            ProgressView(value: task.progress)
                .progressViewStyle(.linear)
                .tint(Theme.doingColor)
            
            HStack {
                Spacer()
                Text("\(Int(task.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
            }
        }
    }
    
    private func dueDateLabel(_ date: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption)
            Text(date, style: .date)
                .font(.caption)
        }
        .foregroundColor(date < Date() ? Theme.destructive : Theme.secondaryText)
    }
    
    private func thumbnailView(photosData: [Data]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(photosData.prefix(3), id: \.self) { data in
                    if let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                if photosData.count > 3 {
                    Text("+\(photosData.count - 3)")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(Theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
} 
