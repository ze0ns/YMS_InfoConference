import Foundation

// MARK: - Модели слотов

struct BusySlot {
    let title: String
    let start: String
    let end: String
}

struct ScheduleBlock: Identifiable {
    let id: String
    let times: [String]
    let isBusy: Bool
    let title: String?
}

enum ScheduleBlockTone {
    case endingSoon
    case endingLater
    case active
    case inactive
}

// MARK: - Formatter

enum ScheduleSlotFormatter {

    static func timeSlots() -> [String] {
        stride(from: 7.0, through: 20.0, by: 0.5).map { time in
            let hours = Int(time)
            let minutes = time.truncatingRemainder(dividingBy: 1) == 0.5 ? "30" : "00"
            return "\(hours):\(minutes)"
        }
    }

    static func minutes(of timeString: String) -> Int {
        TimeUtils.minutes(of: timeString)
    }

    static func minutes(of date: Date, calendar: Calendar = .current) -> Int {
        TimeUtils.minutes(of: date, calendar: calendar)
    }

    static func isBusy(_ time: String, slots: [BusySlot]) -> Bool {
        let slotMinutes = minutes(of: time)
        return slots.contains { slot in
            slotMinutes >= minutes(of: slot.start) && slotMinutes < minutes(of: slot.end)
        }
    }

    static func title(at time: String, slots: [BusySlot]) -> String? {
        slots.first { $0.start == time }?.title
    }

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

    static func tone(for block: ScheduleBlock, now: Date, calendar: Calendar = .current) -> ScheduleBlockTone {
        guard block.isBusy,
              let first = block.times.first,
              let last = block.times.last else {
            return .inactive
        }

        let start = minutes(of: first)
        let end = minutes(of: last) + 30
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
