//
//  DataModelScheduler.swift
//  yealinkCalc
//
//  Created by Aleksandr Oschepkov on 05.03.2024.
//

import Foundation
import SwiftData

/// SwiftData-модель записи расписания конференции (локальный кэш).
@Model
class ConfDataModel: Identifiable, Hashable {
    var conferencePlanId: String
    var conferenceSubject: String
    var startDateTimeStamp: Int
    var startTime: String
    var endTime: String
    var organizerId: String
    var organizerName: String
    var organizeExt: String
    var plainEmailRemark: String
    var vID = UUID()

    init(
        conferencePlanId: String,
        conferenceSubject: String,
        startDateTimeStamp: Int,
        startTime: String,
        endTime: String,
        organizerId: String,
        organizerName: String,
        organizeExt: String,
        plainEmailRemark: String
    ) {
        self.conferencePlanId = conferencePlanId
        self.conferenceSubject = conferenceSubject
        self.startDateTimeStamp = startDateTimeStamp
        self.startTime = startTime
        self.endTime = endTime
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.organizeExt = organizeExt
        self.plainEmailRemark = plainEmailRemark
    }

    static func == (lhs: ConfDataModel, rhs: ConfDataModel) -> Bool {
        lhs.vID == rhs.vID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(vID)
    }
}