//
//  ModelContext+DeleteAll.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 05.09.2026.
//

import SwiftData

extension ModelContext {

    /// Удаляет все записи указанного типа (замена дублирующихся clearXInternal).
    func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        let items = try fetch(FetchDescriptor<T>())
        for item in items {
            delete(item)
        }
    }
}