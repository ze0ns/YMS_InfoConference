//
//  YmsApiResponse.swift
//  yealinkCalc
//
//  Created by Oschepkov Aleksandr on 04.03.2024.
//
import Foundation
import CryptoKit
import SwiftData
struct YmsApiResponce{
   
    func useYLCredentials(type: String, url: String, data: Data?) -> [String:String] {
        let ylAccessKey = APIConfig.ylAccessKey
        let ylSecretKey = APIConfig.ylSecretKey
        let guid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let curDate = Date().timeIntervalSince1970 * 1000
        let dateToString = String(format: "%.0f", curDate)
        var signString = ""
        var contentMd5 = ""
        var hashInB64 = ""
        if type == "GET" {
            signString = "\(type)\nX-Ca-Key:\(ylAccessKey)\nX-Ca-Nonce:\(guid)\nX-Ca-Timestamp:\(dateToString)\n\(url)"
            if let data = data {
                signString += "\n\(data)"
            }
        } else {
            guard let data = data else { return ["":""]}
                let md5Data = Insecure.MD5.hash(data: data)
                contentMd5 = Data(md5Data).base64EncodedString()
                print(contentMd5)
            signString = "\(type)\nContent-MD5:\(contentMd5)\nX-Ca-Key:\(ylAccessKey)\nX-Ca-Nonce:\(guid)\nX-Ca-Timestamp:\(dateToString)\n\(url)"
        }
        if let secretData = ylSecretKey.data(using: .utf8), let stringData = signString.data(using: .utf8) {
            let hmac = HMAC<SHA256>.authenticationCode(for: stringData, using: SymmetricKey(data: secretData))
            hashInB64 = Data(hmac).base64EncodedString()
        }
        print(ylAccessKey)
        print("Запрос")
        print(ylSecretKey)
        return type == "GET" ? [
            "X-Ca-Key": ylAccessKey,
            "X-Ca-Nonce": guid,
            "X-Ca-Timestamp": dateToString,
            "X-Ca-Signature": hashInB64
        ] : [
            "Content-MD5": contentMd5,
            "X-Ca-Key": ylAccessKey,
            "X-Ca-Nonce": guid,
            "X-Ca-Timestamp": dateToString,
            "X-Ca-Signature": hashInB64,
            "Content-Type": "application/json;charset=UTF-8"
        ]
    }
    func getConfSchedule(funcURL: String, json: [String: Any]?) async throws-> ConferenseSheduler {
        let hostURL = "https://ms.i-npz.ru:15443/"
        let ymsURL = hostURL  + funcURL
        var request: URLRequest!
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            guard let url = URL(string: ymsURL) else {
                throw NetError.invalidURL
            }
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = useYLCredentials(type: "POST", url: funcURL, data: jsonData)
            request.httpBody = jsonData
        } else {
            guard let url = URL(string: ymsURL) else {
                throw NetError.invalidURL
            }
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = useYLCredentials(type: "GET", url: funcURL, data: nil)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetError.invalidResponce
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ConferenseSheduler.self, from: data)
        } catch {
            throw NetError.invalidData
        }
    }
    func getInfo(funcURL: String, json: [String: Any]?) async throws -> RoomList{
        let hostURL = "https://ms.i-npz.ru:15443/"
        let ymsURL = hostURL  + funcURL
        var request: URLRequest!
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            guard let url = URL(string: ymsURL) else {
                throw NetError.invalidURL
            }
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = useYLCredentials(type: "POST", url: funcURL, data: jsonData)
            request.httpBody = jsonData
        } else {
            guard let url = URL(string: ymsURL) else {
                throw NetError.invalidURL
            }
            request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = useYLCredentials(type: "GET", url: funcURL, data: nil)
        }
        print("Запрос")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetError.invalidResponce
        }
        do {
            print("Response success")
            let decoder = JSONDecoder()
            return try decoder.decode(RoomList.self, from: data)
            
        } catch {
            throw NetError.invalidData
        }
    }

    
    
}
