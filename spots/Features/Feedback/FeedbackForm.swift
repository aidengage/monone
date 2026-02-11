////
////  FeedbackForm.swift
////  spots
////
////  Created by Aiden Gage on 2/8/26.
////
//
//import SwiftUI
//import PhotosUI
//
//struct FeedbackForm: View {
//    @Environment(\.dismiss) var dismiss
//    @State var message: String = ""
//    @State var feedbackType: FeedbackType = .general
//    
//    @State private var selectedPhotos: [PhotosPickerItem] = []
//    @State private var selectedImages: [UIImage] = []
//    @State private var showImagePicker = false
//    
//    private let maxCharacters = 1000
//    
//    var body: some View {
//        VStack {
//            Form {
//                // feedback type
//                Section {
//                    Picker("Type", selection: $feedbackType) {
//                        ForEach([FeedbackType.bug, .feature, .improvement, .general], id: \.self) { type in
//                            Label {
//                                Text(type.displayName)
//                            } icon: {
//                                Image(systemName: type.iconName)
//                                    .foregroundColor(type.color)
//                            }
////                            .tag(type)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                } header: {
//                    Text("What type of feedback is this?")
//                } footer: {
//                    Text(feedbackType.description)
//                }
//                
//                // message section
//                Section {
//                    ZStack(alignment: .topLeading) {
//                        if message.isEmpty {
//                            Text("Describe your feedback in detail...")
//                                .foregroundColor(.secondary)
//                                .padding(.top, 8)
//                                .padding(.leading, 4)
//                        }
//                        
//                        TextEditor(text: $message)
//                            .frame(minHeight: 150)
//                            .onChange(of: message) { newValue in
//                                if newValue.count > maxCharacters {
//                                    message = String(newValue.prefix(maxCharacters))
//                                }
//                            }
//                    }
//                    
//                    HStack {
//                        Spacer()
//                        Text("\(message.count)/\(maxCharacters)")
//                            .font(.caption)
//                            .foregroundColor(message.count > maxCharacters - 50 ? .orange : .secondary)
//                    }
//                } header: {
//                    Text("Message")
//                } footer: {
//                    Text("Please be as specific as possible. Include steps to reproduce if reporting a bug.")
//                }
//                
//                // photo picker
//                Section {
//                    PhotosPicker(
//                        selection: $selectedPhotos,
//                        maxSelectionCount: 3,
//                        matching: .images
//                    ) {
//                        Label("Add Screenshots", systemImage: "photo.on.rectangle.angled")
//                    }
////                    .onChange(of: selectedPhotos) { newItems in
////                        Task {
////                            await loadImages(from: newItems)
////                        }
////                    }
//                    
//                    if !selectedImages.isEmpty {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 12) {
//                                ForEach(selectedImages.indices, id: \.self) { index in
//                                    ZStack(alignment: .topTrailing) {
//                                        Image(uiImage: selectedImages[index])
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 100, height: 100)
//                                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                                        
////                                        Button {
////                                            removeImage(at: index)
////                                        } label: {
////                                            Image(systemName: "xmark.circle.fill")
////                                                .foregroundColor(.white)
////                                                .background(Color.black.opacity(0.6))
////                                                .clipShape(Circle())
////                                        }
////                                        .padding(4)
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                } header: {
//                    Text("Screenshots (Optional)")
//                } footer: {
//                    Text("You can attach up to 3 screenshots to help us understand the issue.")
//                }
//            }
//            
//        }
//    }
//}

import SwiftUI
import PhotosUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    
    
    
    @State private var feedbackType: FeedbackType = .general
    @State private var message = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                // Feedback Type
                Section("Type") {
                    Picker("Feedback Type", selection: $feedbackType) {
                        Text("Bug").tag(FeedbackType.bug)
                        Text("Feature").tag(FeedbackType.feature)
                        Text("Improvement").tag(FeedbackType.improvement)
                        Text("General").tag(FeedbackType.general)
                    }
                    .pickerStyle(.segmented)
                }
                
                // Message
                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 150)
                }
                
                // Screenshots
                Section("Screenshots (Optional)") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 3,
                        matching: .images
                    ) {
                        Label("Add Screenshots", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotos) { newItems in
                        Task {
                            await loadImages(from: newItems)
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: selectedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button {
                                            selectedImages.remove(at: index)
                                            selectedPhotos.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Submit Button
                Section {
                    Button {
                        submitFeedback()
                    } label: {
                        if isSubmitting {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(message.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been submitted.")
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImages.append(image)
            }
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        Task {
            do {
                _ = try await Firebase.shared.submitFeedback(
                    message: message,
                    feedbackType: feedbackType,
                    screenshots: selectedImages
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                }
                print("Error submitting feedback: \(error)")
            }
        }
    }
}
