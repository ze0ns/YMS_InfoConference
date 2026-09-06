//
//  YmsApiResponse.swift
//  yealinkCalc
//
//  Created by Oschepkov Aleksandr on 04.03.2024.
//
import Foundation
import CryptoKit
import os

// MARK: - Протокол сервиса (позволяет подменять реализацию в тестах)

/// Сервис YMS API: расписание конференций и список комнат.
protocol YmsApiService {
    /// Расписание конференций указанной комнаты.
    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler
    /// Список доступных комнат.
    func getRooms() async throws -> RoomList
}

// MARK: - Типизированные тела запросов

/// Тело запроса расписания: пустой JSON `{}` (как раньше слался пустой словарь)
struct ConferenceScheduleRequest: Encodable {}

/// Тело запроса списка комнат. nil-поля кодируются как явный null,
/// чтобы совпадать с прежним форматом [String: Any?] через JSONSerialization.
struct RoomListRequest: Encodable {
    var key: String? = nil
    var categoryID: String? = nil
    var type: String? = nil
    var skip: Int? = nil
    var limit: Int = 100

    enum CodingKeys: String, CodingKey {
        case key, categoryID, type, skip, limit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .key)
        try container.encodeNil(forKey: .categoryID)
        try container.encodeNil(forKey: .type)
        try container.encodeNil(forKey: .skip)
        try container.encode(limit, forKey: .limit)
    }
}

// MARK: - Реализация

struct YmsApiResponse: YmsApiService {
    private let config: APICredentialsProviding

    init(config: APICredentialsProviding = APIConfig()) {
        self.config = config
    }

    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler {
        try await post(
            path: "api/open/v1/conference/record/\(roomId)/pagedList",
            body: ConferenceScheduleRequest()
        )
    }

    func getRooms() async throws -> RoomList {
        try await post(path: "api/open/v1/room/pagedList", body: RoomListRequest())
    }

    /// Единственная точка построения POST-запроса к YMS API с подписью.
    private func post<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body
    ) async throws -> Response {
        let bodyData = try JSONEncoder().encode(body)

        let base = config.hostURL
        let trimmedBase = base.hasSuffix("/") ? String(base.dropLast()) : base
        guard let url = URL(string: trimmedBase + "/" + path) else {
            throw NetError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = signedHeaders(method: "POST", path: path, bodyData: bodyData)
        request.httpBody = bodyData

        AppLog.network.info("Запрос: POST \(path, privacy: .public)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            AppLog.network.error("Ответ сервера с ошибкой: \(code) \(path, privacy: .public)")
            throw NetError.invalidResponse(statusCode: code)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            AppLog.network.error("Ошибка декодирования \(path, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw NetError.decodingFailed(underlying: error)
        }
    }

    // MARK: - Подпись запроса (HMAC-SHA256)

    private func signedHeaders(method: String, path: String, bodyData: Data?) -> [String: String] {
        let accessKey = config.currentYlAccessKey
        let secretKey = config.currentYlSecretKey
        let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)

        let contentMD5: String
        if let bodyData {
            contentMD5 = Data(Insecure.MD5.hash(data: bodyData)).base64EncodedString()
        } else {
            contentMD5 = ""
        }

        let signString = "\(method)\nContent-MD5:\(contentMD5)\nX-Ca-Key:\(accessKey)\nX-Ca-Nonce:\(nonce)\nX-Ca-Timestamp:\(timestamp)\n\(path)"

        var signature = ""
        if let secretData = secretKey.data(using: .utf8),
           let stringData = signString.data(using: .utf8) {
            let hmac = HMAC<SHA256>.authenticationCode(for: stringData, using: SymmetricKey(data: secretData))
            signature = Data(hmac).base64EncodedString()
        }

        return [
            "Content-MD5": contentMD5,
            "X-Ca-Key": accessKey,
            "X-Ca-Nonce": nonce,
            "X-Ca-Timestamp": timestamp,
            "X-Ca-Signature": signature,
            "Content-Type": "application/json;charset=UTF-8"
        ]
    }
}
