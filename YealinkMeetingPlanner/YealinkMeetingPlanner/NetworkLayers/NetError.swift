import Foundation

enum NetError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlying: Error)
    case missingConfiguration

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес сервера"
        case .invalidResponse(let statusCode):
            return "Сервер вернул ошибку (код \(statusCode))"
        case .decodingFailed:
            return "Не удалось разобрать ответ сервера"
        case .missingConfiguration:
            return "Ключи доступа не настроены — отсканируйте их в настройках"
        }
    }
}
