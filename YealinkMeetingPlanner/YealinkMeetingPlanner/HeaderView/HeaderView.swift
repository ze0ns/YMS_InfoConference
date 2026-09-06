import SwiftUI

struct HeaderView: View {
    let roomName: String
    @State private var viewModel: HeaderViewModel

    init(roomName: String, viewModel: HeaderViewModel? = nil) {
        self.roomName = roomName
        _viewModel = State(initialValue: viewModel ?? HeaderViewModel())
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(.meeting)
            VStack(alignment: .leading) {
                Text(roomName)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                Text("Добро пожаловать! Желаем продуктивной встречи.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.leading, 20)
            Spacer()
            VStack(alignment: .trailing) {
                Text(viewModel.dateString(from: viewModel.currentDate))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                Text(viewModel.timeString(from: viewModel.currentDate))
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .padding(.trailing, 20)
        }
    }
}

#Preview {
    HeaderView(roomName: "Библиотека")
}
