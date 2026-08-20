//
//  ScheduleView.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 28.05.2026.
//

import SwiftUI

struct ScheduleView: View {
    let currentDate: Date
    let busySlots: [BusySlot]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ЗАНЯТОСТЬ")
                .font(.headline)
                .foregroundColor(.white)

            Text(formattedDate(currentDate))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .bold()

            ScrollView {
                VStack(spacing: 0) {
                    let blocks = ScheduleSlotFormatter.groupedBlocks(from: busySlots)

                    ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
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

                        if index < blocks.count - 1 {
                            let nextBlock = blocks[index + 1]
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
        HStack(spacing: 0) {
            // Левая колонка: время (без цветного фона)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(block.times, id: \.self) { time in
                    Text(time)
                        .foregroundColor(.white.opacity(0.4))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                        .padding(.vertical, 6)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)

            // Правая колонка: заголовок + динамический фон
            ZStack {
                if let title = block.title {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 8)
                }
            }
            .frame(maxHeight: .infinity)
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

// MARK: - Форматтер даты и цвета

extension ScheduleView {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    private func formattedDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private func busyBlockColor(for block: ScheduleBlock) -> Color {
        switch ScheduleSlotFormatter.tone(for: block, now: Date()) {
        case .endingSoon:  return .orange.opacity(0.25)
        case .endingLater: return .red.opacity(0.4)
        case .active:      return .pink.opacity(0.2)
        case .inactive:    return .green.opacity(0.15)
        }
    }
}

#Preview {
    ScheduleView(
        currentDate: Date(),
        busySlots: [
            BusySlot(title: "Обсуждение проекта", start: "7:00", end: "8:30"),
            BusySlot(title: "Маркетинговая стратегия", start: "10:00", end: "12:00"),
            BusySlot(title: "Планирование спринта", start: "14:00", end: "15:00")
        ]
    )
}
