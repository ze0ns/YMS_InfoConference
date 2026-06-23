//
//  RoomsModel.swift
//  yealinkCalc
//
//  Created by Aleksandr Oschepkov on 10.10.2024.
//


import Foundation

// MARK: - RoomList
struct RoomList: Codable {
    let ret: Int
    let data: RoomListData
    let error: JSONNull?
}

// MARK: - DataClass
struct RoomListData: Codable {
    let skip: JSONNull?
    let data: [DatumRoom]
    enum CodingKeys: String, CodingKey {
        case skip, data
    }
}

// MARK: - Datum
struct DatumRoom: Codable, Identifiable, Hashable {
    static func == (lhs: DatumRoom, rhs: DatumRoom) -> Bool {
        if lhs.id != rhs.id { return false }
        return true
    }
    let id, categoryName: String
    let deviceAccount, deviceID: String
    let namePinyin: String
    let name, categoryID: String
    let vID = UUID()
    enum CodingKeys: String, CodingKey {
        case id, categoryName
        case deviceAccount
        case deviceID = "deviceId"
        case namePinyin
        case name
        case categoryID = "categoryId"
    }
}
