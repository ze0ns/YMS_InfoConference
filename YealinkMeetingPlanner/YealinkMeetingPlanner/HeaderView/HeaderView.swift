//
//  HeaderView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//
import SwiftUI

struct HeaderView: View {
    let roomName: String
    @State private var headerViewModel = HeaderViewModel()

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
                Text(headerViewModel.dateString(from: headerViewModel.currentDate))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                Text(headerViewModel.timeString(from: headerViewModel.currentDate))
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
