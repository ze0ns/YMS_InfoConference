//
//  ScheduleSlotFormatter.swift
//  YealinkMeetingPlanner
//

import Foundation

// MARK: - Модели слотов

struct BusySlot {
    let title: String
    let start: String
    let end: String
}

struct ScheduleBlock: Identifiable {
    /// Время начала блока — уникальный стабильный идентификатор
    let id: String
    let times: [String]
    let isBusy: Bool
    let title: String?
}

/// Тон занятого блока (View превращает в цвет)
enum ScheduleBlockTone {
    case endingSoon   // идёт, до конца ≤30 минут — оранжевый
    case endingLater  // идёт, до конца ≤60 минут — красный
    case active       // идёт, до конца >60 минут — розовый
    case inactive     // сейчас не идёт — зелёный
}

// MARK: - Форматтер (чистая логика, покрывается unit-тестами)

enum ScheduleSlotFormatter {

    /// Слоты расписания: 7:00–20:00 с шагом 30 минут
    static func timeSlots() -> [String] {
        stride(from: 7.0, through: 20.0, by: 0.5).map { time in
            let hours = Int(time)
            let minutes = time.truncatingRemainder(dividingBy: 1) == 0.5 ? "30" : "00"
            return "\(hours):\(minutes)"
        }
    }

    /// "9:30" → 570 минут от начала дня
    static func minutes(of timeString: String) -> Int {
        TimeUtils.minutes(of: timeString)
    }

    static func minutes(of date: Date, calendar: Calendar = .current) -> Int {
        TimeUtils.minutes(of: date, calendar: calendar)
    }

    /// Занят ли слот хотя бы одной встречей
    static func isBusy(_ time: String, slots: [BusySlot]) -> Bool {
        let slotMinutes = minutes(of: time)
        return slots.contains { slot in
            slotMinutes >= minutes(of: slot.start) && slotMinutes < minutes(of: slot.end)
        }
    }

    /// Заголовок встречи, начинающейся в указанное время
    static func title(at time: String, slots: [BusySlot]) -> String? {
        slots.first { $0.start == time }?.title
    }

    /// Сливает соседние слоты одинаковой занятости в блоки
    static func groupedBlocks(from slots: [BusySlot]) -> [ScheduleBlock] {
        var blocks: [ScheduleBlock] = []
        var currentTimes: [String] = []
        var currentIsBusy: Bool?
        var currentTitle: String?

        for time in timeSlots() {
            let busy = isBusy(time, slots: slots)
            let title = title(at: time, slots: slots)

            if busy == currentIsBusy {
                currentTimes.append(time)
            } else {
                if let isBusy = currentIsBusy {
                    blocks.append(ScheduleBlock(id: currentTimes.first ?? "", times: currentTimes, isBusy: isBusy, title: currentTitle))
                }
                currentTimes = [time]
                currentIsBusy = busy
                currentTitle = title
            }
        }
        if let isBusy = currentIsBusy {
            blocks.append(ScheduleBlock(id: currentTimes.first ?? "", times: currentTimes, isBusy: isBusy, title: currentTitle))
        }
        return blocks
    }

    /// Тон занятого блока в зависимости от текущего времени
    static func tone(for block: ScheduleBlock, now: Date, calendar: Calendar = .current) -> ScheduleBlockTone {
        guard block.isBusy,
              let first = block.times.first,
              let last = block.times.last else {
            return .inactive
        }

        let start = minutes(of: first)
        let end = minutes(of: last) + 30 // слот длится 30 минут
        let current = minutes(of: now, calendar: calendar)

        guard current >= start, current < end else {
            return .inactive
        }

        let timeLeft = end - current
        if timeLeft <= 30 { return .endingSoon }
        if timeLeft <= 60 { return .endingLater }
        return .active
    }
}
