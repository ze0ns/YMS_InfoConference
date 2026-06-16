//
//  ScheduleView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI

struct ScheduleView: View {
    let currentDate: Date
    let busySlots: [(title: String, start: String, end: String)]
    
    private let timeSlots: [String] = {
        stride(from: 7.0, through: 20.0, by: 0.5).map { time in
            let hours = Int(time)
            let minutes = time.truncatingRemainder(dividingBy: 1) == 0.5 ? "30" : "00"
            return "\(hours):\(minutes)"
        }
    }()
    
    private struct ScheduleBlock: Identifiable {
        let id = UUID()
        let times: [String]
        let isBusy: Bool
        let title: String?
    }
    
    private var groupedSlots: [ScheduleBlock] {
        var blocks: [ScheduleBlock] = []
        var currentTimes: [String] = []
        var currentIsBusy: Bool? = nil
        var currentTitle: String? = nil
        
        for time in timeSlots {
            let busy = isTimeSlotBusy(time: time)
            let title = getTitleForTime(time)
            
            if busy == currentIsBusy {
                currentTimes.append(time)
            } else {
                if let isBusy = currentIsBusy {
                    blocks.append(ScheduleBlock(times: currentTimes, isBusy: isBusy, title: currentTitle))
                }
                currentTimes = [time]
                currentIsBusy = busy
                currentTitle = title
            }
        }
        if let isBusy = currentIsBusy {
            blocks.append(ScheduleBlock(times: currentTimes, isBusy: isBusy, title: currentTitle))
        }
        return blocks
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ЗАНЯТОСТЬ")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(formattedDate(currentDate))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .bold()
            ScrollView{
                VStack(spacing: 0) {
                    ForEach(Array(groupedSlots.enumerated()), id: \.element.id) { index, block in
                        if block.isBusy {
                            busyBlockView(block: block)
                        } else {
                            VStack(spacing: 4) {
                                ForEach(block.times, id: \.self) { time in
                                    freeRowView(time: time)
                                    Divider()
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                        
                        if index < groupedSlots.count - 1 {
                            let nextBlock = groupedSlots[index + 1]
                            if block.isBusy != nextBlock.isBusy {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)

        }
    }
    
    // MARK: - Вью для объединенного занятого блока
    @ViewBuilder
    private func busyBlockView(block: ScheduleBlock) -> some View {
        // ИСПОЛЬЗУЕМ HSTACK ДЛЯ РАЗДЕЛЕНИЯ КОЛОНК
        HStack(spacing: 0) {
            // 1. Левая колонка: Время (без цветного фона)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(block.times.enumerated()), id: \.element) { index, time in
                    Text(time)
                        .foregroundColor(.white.opacity(0.4))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                        .padding(.vertical, 6)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 8) // Отступ перед цветным блоком
            
            // 2. Правая колонка: Заголовок + Динамический фон
            ZStack {
                if let title = block.title {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 8) // Отступ текста от краев цветного блока
                }
            }
            .frame(maxHeight: .infinity) // Растягиваем на всю высоту блока
            // 🔽 ДИНАМИЧЕСКИЙ ЦВЕТ ПРИМЕНЯЕТСЯ ТОЛЬКО К ПРАВОЙ ЧАСТИ 🔽
            .background(busyBlockColor(for: block))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Вью для свободной строки
    @ViewBuilder
    private func freeRowView(time: String) -> some View {
        HStack(spacing: 8) {
            Text(time)
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 40, alignment: .leading)
            Spacer()
            Text("Свободно")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
}

// MARK: - Логика, форматтеры и Цвета
extension ScheduleView {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    private func formattedDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
    
    private func timeToMinutes(_ timeString: String) -> Int {
        let parts = timeString.split(separator: ":")
        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]) else { return 0 }
        return hours * 60 + minutes
    }
    
    private func getCurrentTimeInMinutes() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return hour * 60 + minute
    }
    
    private func busyBlockColor(for block: ScheduleBlock) -> Color {
        guard let firstTime = block.times.first,
              let lastTime = block.times.last else {
            return .pink.opacity(0.15)
        }
        
        let startMinutes = timeToMinutes(firstTime)
        let endMinutes = timeToMinutes(lastTime) + 30
        
        let currentMinutes = getCurrentTimeInMinutes()
        
        if currentMinutes >= startMinutes && currentMinutes < endMinutes {
            let timeLeft = endMinutes - currentMinutes
            
            if timeLeft <= 30 {
                return .orange.opacity(0.25)
            } else if timeLeft <= 60 {
                return .red.opacity(0.4)
            } else {
                return .pink.opacity(0.2)
            }
        }
        
        return .green.opacity(0.15)
    }
    
    private func isTimeSlotBusy(time: String) -> Bool {
        let slotTime = timeToMinutes(time)
        for slot in busySlots {
            let start = timeToMinutes(slot.start)
            let end = timeToMinutes(slot.end)
            if slotTime >= start && slotTime < end { return true }
        }
        return false
    }
    
    private func getTitleForTime(_ time: String) -> String? {
        for slot in busySlots {
            if time == slot.start { return slot.title }
        }
        return nil
    }
}

#Preview {
    // Создаем слот, который гарантированно идет сейчас для проверки цветов
    let currentHour = Calendar.current.component(.hour, from: Date())
    
    return ScheduleView(currentDate: Date(), busySlots: [
        ("Обсуждение проекта", "7:00", "8:30"),
        ("Маркетинговая стратегия", "10:00", "12:00"),
        ("Планирование спринта", "14:00", "15:00")
    ])
}

