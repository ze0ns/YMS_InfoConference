// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let conferenseSheduler = try? JSONDecoder().decode(ConferenseSheduler.self, from: jsonData)

import Foundation

// MARK: - ConferenseSheduler
struct ConferenseSheduler: Codable {
    let ret: Int
    let data: DataClass
    let error: JSONNull?
}

// MARK: - DataClass
struct DataClass: Codable {
    let total: Int
    let autoCount: Bool
    let orderbys: [Orderby]
    let data: [Datum]
    let skip, limit: Int
}

// MARK: - Datum
struct Datum: Codable {
    let participants: [Participant]
    let appointmentID: String
    let modifyTime: Int
    let communication: Communication?
    let conferencePlanID: String
    let conferenceSubject: ConferenceSubject
    let confType: String
    let conferenceTimePattern: ConferenceTimePattern
    let organizer: Organizer
    let plainEmailRemark: String
    let isPresenter, isRecurrence, isAvailable, isOrganizer: Bool
    let answerSettingEnable: Bool
    let state: String
    let independent: JSONNull?
    let id: String
    let rooms: [Room]
    let isIndependent: JSONNull?
    let enterpriseID: String
    let presenter: Bool
    let recurrenceID: String
    let recurrence: Bool
    let currentTimeStamp: Int
    let emailRemark: JSONNull?
    let messageNotifyEnable: Bool

    enum CodingKeys: String, CodingKey {
        case participants
        case appointmentID = "appointmentId"
        case modifyTime, communication
        case conferencePlanID = "conferencePlanId"
        case conferenceSubject, confType, conferenceTimePattern, organizer, plainEmailRemark, isPresenter, isRecurrence, isAvailable, isOrganizer, answerSettingEnable, state, independent, id, rooms, isIndependent
        case enterpriseID = "enterpriseId"
        case presenter
        case recurrenceID = "recurrenceId"
        case recurrence, currentTimeStamp, emailRemark, messageNotifyEnable
    }
}

// MARK: - Communication
struct Communication: Codable {
    let isPrivate: Bool
    let password, conferenceNumber: String
    let fsConfig: FSConfig
    let hasViewer: Bool
    let advanceConfig: AdvanceConfig
    let recordingMaster, showMode, profile, conferenceEntity: String
    let vmr: JSONNull?
}

// MARK: - AdvanceConfig
struct AdvanceConfig: Codable {
    let conferenceLockConfig: ConferenceLockConfig
    let broadcastEnable: Bool
    let reserveEnable, amountReserved, terminalLayout: JSONNull?
    let autoInviteAfterRegEnable, excessJoinEnable: Bool
    let videoSourceChangeEnable, pollingSetting: JSONNull?
    let guestsAutoMuteEnable, autoRecording: Bool
    let voicePromptMode: JSONNull?
    let autoInviteEnable, videoEnable: Bool
    let conferenceLiveBroadcast: ConferenceLiveBroadcast
    let subtitleEnable: JSONNull?
    let webRTCEnable: Bool
    let timeLimitBroadcast: JSONNull?
    let autoInviteFwVersion: [String]
    let autoUnmuteEnable, selfViewEnabled: JSONNull?
    let ipCallEnable, autoMuteEnable: Bool
    let pollingTime: JSONNull?

    enum CodingKeys: String, CodingKey {
        case conferenceLockConfig, broadcastEnable, reserveEnable, amountReserved, terminalLayout, autoInviteAfterRegEnable, excessJoinEnable, videoSourceChangeEnable, pollingSetting, guestsAutoMuteEnable, autoRecording, voicePromptMode, autoInviteEnable, videoEnable, conferenceLiveBroadcast, subtitleEnable
        case webRTCEnable = "webRtcEnable"
        case timeLimitBroadcast, autoInviteFwVersion, autoUnmuteEnable, selfViewEnabled, ipCallEnable, autoMuteEnable, pollingTime
    }
}

// MARK: - ConferenceLiveBroadcast
struct ConferenceLiveBroadcast: Codable {
    let description: String
    let enable: Bool
    let qrCodeURL: JSONNull?
    let verifyLogin: Bool
    let rtmpLayout: String
    let watchURL: JSONNull?
    let nameplateEnable, verifyPassword: Bool
    let videoSetting: String
    let password: JSONNull?
    let speakerDetailsEnable: Bool
    let definition: String
    let startTime, status: JSONNull?

    enum CodingKeys: String, CodingKey {
        case description, enable
        case qrCodeURL = "qrCodeUrl"
        case verifyLogin, rtmpLayout
        case watchURL = "watchUrl"
        case nameplateEnable, verifyPassword, videoSetting, password, speakerDetailsEnable, definition, startTime, status
    }
}

// MARK: - ConferenceLockConfig
struct ConferenceLockConfig: Codable {
    let autoLock, attendeeLobbyBypass: Bool
    let admissionPolicy: String
}

// MARK: - FSConfig
struct FSConfig: Codable {
    let autopromote, admissionPolicy: String
    let createEarly: Int
    let serverMode: String
    let remindEarly, maximumUserCount: Int
}

// MARK: - ConferenceSubject
struct ConferenceSubject: Codable {
    let subject, subjectPinyinAlia, subjectPinyin: String
}

// MARK: - ConferenceTimePattern
struct ConferenceTimePattern: Codable {
    let timeZone: TimeZone
    let conferenceTime: ConferenceTime
    let dstConfig: DstConfig
    let recurrencePattern: JSONNull?
}

// MARK: - ConferenceTime
struct ConferenceTime: Codable {
    let startDateTimeStamp: Double
    let endDateTimeStamp: Double
    let startTime: String
    let endTime: String
}
// MARK: - DstConfig
struct DstConfig: Codable {
    let dayLightDelta, dstEnable: Int
}

// MARK: - TimeZone
struct TimeZone: Codable {
    let zoneID, usZoneName, cnZoneName: String
    let utcOffset: Int
    let offsetDisplayName: String

    enum CodingKeys: String, CodingKey {
        case zoneID = "zoneId"
        case usZoneName, cnZoneName, utcOffset, offsetDisplayName
    }
}

// MARK: - Organizer
struct Organizer: Codable {
    let id, name, organizerExtension: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case organizerExtension = "extension"
    }
}
// MARK: - Participant
struct Participant: Codable {
    let externalPhone: JSONNull?
    let classification, id, role, displayText: String
    let scope, email: String
    let isLecturer: Bool
    let type: String
    let participantExtension, extensionAccount: JSONNull?

    enum CodingKeys: String, CodingKey {
        case externalPhone, classification, id, role, displayText, scope, email, isLecturer, type
        case participantExtension = "extension"
        case extensionAccount
    }
}

// MARK: - Room
struct Room: Codable {
    let id, name, type: String
}

// MARK: - Orderby
struct Orderby: Codable {
    let field: String
    let order: Int
}

