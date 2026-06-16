//
//  ContentView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 29.05.2026.
//



import SwiftUI
import Vision
import UIKit

struct ScanKey: View {
    // Состояние для хранения распознанного текста
    @State private var recognizedText = "Нажмите кнопку ниже, чтобы отсканировать текст..."
    // Состояние для показа/скрытия камеры
    @State private var showingCamera = false
    // Состояние для хранения снятого изображения
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            // Поле с текстом (используем TextEditor, чтобы текст можно было скопировать или отредактировать)
            TextEditor(text: $recognizedText)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(radius: 2)
            
            Spacer()
            
            // Кнопка открытия камеры
            Button(action: {
                showingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Сканировать текст")
                }
                .font(.title2)
                .bold()
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
        // Лист для показа камеры
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage, isPresented: $showingCamera)
        }
        // Отслеживание изменения изображения для запуска распознавания
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                recognizeText(in: image)
            }
        }
    }
    
    // Функция распознавания текста с помощью Vision
    private func recognizeText(in image: UIImage) {
        recognizedText = "Распознавание..."
        
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                recognizedText = "Ошибка: не удалось обработать изображение."
            }
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async {
                    recognizedText = "Ошибка распознавания."
                }
                return
            }
            
            // Собираем весь распознанный текст в одну строку
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                if recognizedStrings.isEmpty {
                    self.recognizedText = "Текст на изображении не найден."
                } else {
                    self.recognizedText = recognizedStrings.joined(separator: "\n")
                }
            }
        }
        
        // Устанавливаем язык и точность
        request.recognitionLanguages = ["ru-RU", "en-US"] // Поддержка русского и английского
        request.recognitionLevel = .accurate // Максимальная точность
        
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                recognizedText = "Ошибка при выполнении запроса: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Обертка над UIImagePickerController для доступа к камере
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        // Проверяем, доступна ли камера
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            // Если камера недоступна (например, на симуляторе), откроем библиотеку фото
            picker.sourceType = .photoLibrary
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    ScanKey()
}
