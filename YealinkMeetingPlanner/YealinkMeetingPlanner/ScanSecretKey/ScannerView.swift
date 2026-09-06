import SwiftUI

struct KeysScannerView: View {
    @State private var viewModel = ScanViewModel()

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        VStack(spacing: 24) {

            InputRow(title: "Секретный ключ (ylSecretKey)", text: $bindableViewModel.text1) {
                viewModel.openScanner(for: 1)
            }

            InputRow(title: "Ключ доступа (ylAccessKey)", text: $bindableViewModel.text2) {
                viewModel.openScanner(for: 2)
            }

            Spacer()

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

            Button(role: .destructive, action: {
                viewModel.deleteData()
            }) {
                Text("Удалить ключи и использовать Config.plist")
                    .font(.subheadline)
            }
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .navigationTitle("Ключи доступа")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $bindableViewModel.isScannerPresented) {
            QRScannerView { scannedText in
                viewModel.handleScannedText(scannedText)
            }
            .ignoresSafeArea()
        }
        .alert(viewModel.saveResultMessage ?? "", isPresented: .init(
            get: { viewModel.saveResultMessage != nil },
            set: { if !$0 { viewModel.saveResultMessage = nil } }
        )) {
            Button("ОК", role: .cancel) {}
        }
    }
}

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
    NavigationStack {
        KeysScannerView()
    }
}
