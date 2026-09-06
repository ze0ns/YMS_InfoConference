//
//  YmsApiClient.swift
//  YealinkMeetingPlanner
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import Foundation
import CryptoKit
import os

// MARK: - Подпись запроса (HMAC-SHA256)

/// Строит заголовки подписи для запроса к YMS API (выделено из `YmsApiResponse` — SRP).
struct YmsRequestSigner {
    private let config: APICredentialsProviding

    init(config: APICredentialsProviding) {
        self.config = config
    }

    /// Строит заголовки HMAC-подписи для запроса.
    /// - Parameters:
    ///   - method: HTTP-метод (например, "POST").
    ///   - path: путь запроса (без хоста).
    ///   - bodyData: сериализованное тело запроса; `nil`, если тела нет.
    func headers(method: String, path: String, bodyData: Data?) -> [String: String] {
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

// MARK: - HTTP-клиент

/// Единственная точка POST-запросов к YMS API с подписью.
struct YmsHTTPClient {
    private let config: APICredentialsProviding
    private let signer: YmsRequestSigner

    init(config: APICredentialsProviding) {
        self.config = config
        self.signer = YmsRequestSigner(config: config)
    }

    /// POST-запрос к YMS API с подписью и декодированием ответа.
    /// - Parameters:
    ///   - path: путь запроса (без хоста).
    ///   - body: сериализуемое тело запроса.
    /// - Returns: декодированный ответ типа `Response`.
    func post<Body: Encodable, Response: Decodable>(
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
        request.allHTTPHeaderFields = signer.headers(method: "POST", path: path, bodyData: bodyData)
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
}

// MARK: - Конференции

/// API расписания конференций.
struct YmsConferenceApi {
    private let client: YmsHTTPClient

    init(config: APICredentialsProviding = APIConfig()) {
        self.client = YmsHTTPClient(config: config)
    }

    /// Расписание конференций указанной комнаты.
    func getConferenceSchedule(roomId: String) async throws -> ConferenceScheduler {
        try await client.post(
            path: "api/open/v1/conference/record/\(roomId)/pagedList",
            body: ConferenceScheduleRequest()
        )
    }
}

// MARK: - Комнаты

/// API списка комнат.
struct YmsRoomApi {
    private let client: YmsHTTPClient

    init(config: APICredentialsProviding = APIConfig()) {
        self.client = YmsHTTPClient(config: config)
    }

    /// Список доступных комнат.
    func getRooms() async throws -> RoomList {
        try await client.post(path: "api/open/v1/room/pagedList", body: RoomListRequest())
    }
}