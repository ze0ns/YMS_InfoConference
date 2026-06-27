import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ScanViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Поле 1
                InputRow(title: "Секретный код 1", text: $viewModel.text1) {
                    viewModel.openScanner(for: 1)
                }
                
                // Поле 2
                InputRow(title: "Секретный код 2", text: $viewModel.text2) {
                    viewModel.openScanner(for: 2)
                }
                
                Spacer()
                
                // Кнопка Сохранить
                Button(action: {
                    viewModel.saveData()
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isSaveEnabled ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.isSaveEnabled)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            .navigationTitle("Безопасное хранение")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isScannerPresented) {
                QRScannerView { scannedText in
                    viewModel.handleScannedText(scannedText)
                }
                .ignoresSafeArea()
            }
        }
    }
}

// Компонент для переиспользования (TextField + Кнопка сканирования)
struct InputRow: View {
    let title: String
    @Binding var text: String
    let onScan: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Введите или отсканируйте", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(.body, design: .monospaced)) // Моноширинный шрифт для hex
                
                Button(action: onScan) {
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
