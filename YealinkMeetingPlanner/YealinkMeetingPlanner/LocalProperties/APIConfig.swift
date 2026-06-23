//
//  APIConfig.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.06.2026.
//


import Foundation

struct APIConfig {
    private static func loadPlistDict() -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Ошибка: Файл YourFileName.plist не найден или поврежден")
            return nil
        }
        return dict
    }
    static let ylSecretKey = loadPlistDict()?["ylSecretKey"] as? String ?? ""
    static let ylAccessKey = loadPlistDict()?["ylAccessKey"] as? String ?? ""
    static let baseUrl = loadPlistDict()?["baseUrl"] as? String ?? ""
    static let hostURL = loadPlistDict()?["hostURL"] as? String ?? ""

}
