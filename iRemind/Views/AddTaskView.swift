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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var includeDueDate = false
    @State private var selectedPhotos: [UIImage] = []
    @State private var showPhotosPicker = false
    @State private var isShowingCamera = false
    @State private var status: TaskStatus = .todo
    @State private var progress: Double = 0.0
    
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
                
                Section(header: Text("Attachments")) {
                    Button(action: {
                        showPhotosPicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add from Photos")
                        }
                    }
                    
                    Button(action: {
                        isShowingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                    }
                    
                    if !selectedPhotos.isEmpty {
                        ForEach(0..<selectedPhotos.count, id: \.self) { index in
                            HStack {
                                Image(uiImage: selectedPhotos[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedPhotos.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
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
            .navigationTitle("Add New Task")
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
            .sheet(isPresented: $showPhotosPicker) {
                PhotoPicker(selectedImages: $selectedPhotos)
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraView(image: $selectedPhotos)
            }
        }
    }
    
    private func saveTask() {
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = description.isEmpty ? nil : description
        newTask.status = status.rawValue
        newTask.progress = progress
        newTask.creationDate = Date()
        newTask.deletedDate = nil
        newTask.dueDate = includeDueDate ? dueDate : nil
        
        saveContext()
        presentationMode.wrappedValue.dismiss()
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
