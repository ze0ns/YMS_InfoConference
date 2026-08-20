//
//  NetError.swift
//  yealinkCalc
//
//  Created by Oschepkov Aleksandr on 04.03.2024.
//

import Foundation

enum NetError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес сервера"
        case .invalidResponse(let statusCode):
            return "Сервер вернул ошибку (код \(statusCode))"
        case .decodingFailed:
            return "Не удалось разобрать ответ сервера"
        }
    }
}
