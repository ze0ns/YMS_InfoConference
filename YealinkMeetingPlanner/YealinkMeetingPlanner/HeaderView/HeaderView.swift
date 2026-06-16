//
//  HeaderView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//
import SwiftUI


struct HeaderView: View {
    let roomName: String
    let date = Date()
    let headerViewModel = HeaderViewModel()
    
    var body: some View {
        HStack(spacing: 8) {
            Image(.metting)
            VStack(alignment: .leading){
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
            VStack(alignment: .trailing){
                Text(headerViewModel.extractDateString(from: date))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                Text(headerViewModel.extractTimeOnly(from: date) ?? "22 Мая 2000")
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
