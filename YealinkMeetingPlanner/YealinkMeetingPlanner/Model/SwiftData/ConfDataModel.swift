//
//  DataModelScheduler.swift
//  yealinkCalc
//
//  Created by Aleksandr Oschepkov on 05.03.2024.
//

import Foundation
import SwiftData
@Model
class ConfDataModel: Identifiable, Hashable{
    var conferencePlanId: String
    var conferenceSubject: String
    var startDateTimeStamp: Int
    var endDateTimeStamp: Int
    var startTime: String
    var endTime: String
    var organizerId: String
    var organizerName: String
    var organizeExt: String
    let vID = UUID()
    var plainEmailRemark: String
    init(conferencePlanId: String, conferenceSubject: String, startDateTimeStamp: Int, endDateTimeStamp: Int, startTime: String, endTime: String, organizerId: String, organizerName: String, organizeExt: String, plainEmailRemark: String) {
        self.conferencePlanId = conferencePlanId
        self.conferenceSubject = conferenceSubject
        self.startDateTimeStamp = startDateTimeStamp
        self.endDateTimeStamp = endDateTimeStamp
        self.startTime = startTime
        self.endTime = endTime
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.organizeExt = organizeExt
        self.plainEmailRemark = plainEmailRemark
    }

    // MARK: - Дата начала/окончания (epoch)

    /// Дата начала встречи.
    var startDate: Date { Self.date(fromTimestamp: startDateTimeStamp) }

    /// Дата окончания встречи.
    var endDate: Date { Self.date(fromTimestamp: endDateTimeStamp) }

    /// YMS отдаёт timestamp и в секундах, и в миллисекундах —
    /// различаем по порядку величины.
    static func date(fromTimestamp timestamp: Int) -> Date {
        let seconds = timestamp > 1_000_000_000_000
            ? TimeInterval(timestamp) / 1000
            : TimeInterval(timestamp)
        return Date(timeIntervalSince1970: seconds)
    }

    static func == (lhs: ConfDataModel, rhs: ConfDataModel) -> Bool {
  let areEqual: Bool = lhs.vID == rhs.vID
        return areEqual
       }
       func hash(into hasher: inout Hasher) {
           hasher.combine(vID) // UUID
       }
}
