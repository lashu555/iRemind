//
//  AddTaskView.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//
import SwiftUI
import PhotosUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var includeDueDate = false
    @State private var selectedPhotos: [UIImage] = []
    @State private var showPhotosPicker = false
    @State private var isShowingCamera = false
    @State private var status: TaskStatus = .todo
    @State private var progress: Double = 0.0
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Task Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Task Details")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        TextField("Title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Theme.secondaryBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .modifier(CardStyle())
                    
                    // Due Date Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Due Date")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        Toggle("Set Due Date", isOn: $includeDueDate)
                            .tint(Theme.primary)
                        
                        if includeDueDate {
                            DatePicker("Select Date", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(Theme.primary)
                        }
                    }
                    .modifier(CardStyle())
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        HStack(spacing: 0) {
                            ForEach(TaskStatus.allCases) { taskStatus in
                                Button(action: { status = taskStatus }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: taskStatus.icon)
                                            .imageScale(.small)
                                        Text(taskStatus.description)
                                            .font(.subheadline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(status == taskStatus ? taskStatus.color.opacity(0.2) : Theme.secondaryBackground)
                                    .foregroundColor(status == taskStatus ? taskStatus.color : Theme.secondaryText)
                                }
                                .buttonStyle(.plain)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(status == taskStatus ? taskStatus.color : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .modifier(CardStyle())
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Progress")
                                .font(.headline)
                                .foregroundColor(Theme.text)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                        }
                        
                        Slider(value: $progress, in: 0...1, step: 0.01)
                            .tint(status.color)
                    }
                    .modifier(CardStyle())
                    
                    // Attachments Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attachments")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                        
                        HStack(spacing: 16) {
                            Button(action: { showPhotosPicker = true }) {
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                    Text("Gallery")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.secondaryBackground)
                                .cornerRadius(8)
                            }
                            
                            Button(action: { isShowingCamera = true }) {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.title2)
                                    Text("Camera")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.secondaryBackground)
                                .cornerRadius(8)
                            }
                        }
                        .foregroundColor(Theme.primary)
                        
                        if !selectedPhotos.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedPhotos.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedPhotos[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button(action: { selectedPhotos.remove(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.5)))
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .modifier(CardStyle())
                }
                .padding()
            }
            .navigationTitle("Add New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.destructive)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? Theme.secondaryText : Theme.primary)
                }
            }
        }
        .sheet(isPresented: $showPhotosPicker) {
            PhotoPicker(selectedImages: $selectedPhotos)
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(image: $selectedPhotos)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveTask() {
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = description.isEmpty ? nil : description
        newTask.status = Int16(status.rawValue)
        newTask.progress = progress
        newTask.creationDate = Date()
        newTask.deletedDate = nil
        newTask.dueDate = includeDueDate ? dueDate : nil
        newTask.photos = selectedPhotos.compactMap { $0.pngData() } as NSObject
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
            showError = true
        }
    }
}

// Placeholder views for the camera and photo picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // 0 means no limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let image = info[.originalImage] as? UIImage {
                parent.image.append(image)
            }
        }
    }
}
#Preview {
    AddTaskView()
}
