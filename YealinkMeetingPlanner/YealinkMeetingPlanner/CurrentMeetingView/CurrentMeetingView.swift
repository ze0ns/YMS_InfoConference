//
//  CurrentMeetingView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI

enum RoomStatus {
    case free, occupied
}

struct CurrentMeetingView: View {
    let title: String
    let time: String
    let contactName: String
    let contactPhone: String
    let status: RoomStatus
    
    var statusColor: Color {
        status == .occupied ? .red : .green
    }
    
    var statusText: String {
        switch status {
        case .free: return "СЕЙЧАС СВОБОДНА"
        case .occupied: return "СЕЙЧАС ЗАНЯТА"
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(statusText)
                .font(.headline)
                .foregroundColor(statusColor)
                .padding(.top, 4)
            
            // 🔽 НОВЫЙ БЛОК: КРУГ С ИЗОБРАЖЕНИЕМ И СВЕЧЕНИЕМ 🔽
            ZStack {
                // Фоновый круг с эффектом свечения
                Circle()
                    .fill(statusColor) // Цвет круга (зеленый или красный)
                    .frame(width: 130, height: 130) // Размер круга
                    // Двойной shadow для более красивого и плотного свечения (Glow)
                    .shadow(color: statusColor.opacity(0.6), radius: 10, x: 0, y: 0)
                    .shadow(color: statusColor.opacity(0.3), radius: 20, x: 0, y: 0)
                
                // Изображение поверх круга
                Image(.metting)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 130, height: 130)

            }
            // 🔽 КОНЕЦ БЛОКА 🔽
            
            VStack(alignment: .center, spacing: 20) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                Divider()
                HStack(alignment: .center){
                    Image(systemName: "clock")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                    Text("Время")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 60)
                HStack(alignment: .center){
                    Image(systemName: "person.circle")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                    Text("Контакт")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(contactName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 60)
                HStack(alignment: .center){
                    Image(systemName: "phone")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(.green)
                        .frame(width: 30, height: 30)
                    Text("Телефон")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Spacer()
                    Text(contactPhone)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 60)
            }
            .padding()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .background(.bgColorScheduler)
    }
       
}
#Preview {
    CurrentMeetingView(title: "Обсуждение спринта", time: "10:00 - 12:00", contactName: "Иванов И.И.", contactPhone: "+ 7 (123) 356-45-67", status: .free)
}
