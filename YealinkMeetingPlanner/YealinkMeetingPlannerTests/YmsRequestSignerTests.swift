//
//  YmsRequestSignerTests.swift
//  YealinkMeetingPlannerTests
//
//  Created by Oschepkov Aleksandr on 06.09.2026.
//

import XCTest
import CryptoKit
@testable import YealinkMeetingPlanner

@MainActor
final class YmsRequestSignerTests: XCTestCase {

    private struct FakeConfig: APICredentialsProviding {
        var hostURL: String { "https://example.com" }
        var currentYlSecretKey: String { "secret-key" }
        var currentYlAccessKey: String { "access-key" }
        var usesKeychainKeys: Bool { false }
    }

    func testHeadersContainAllRequiredKeys() {
        let body = Data("{\"limit\":100}".utf8)
        let headers = YmsRequestSigner(config: FakeConfig()).headers(
            method: "POST",
            path: "api/open/v1/room/pagedList",
            bodyData: body
        )

        XCTAssertEqual(
            headers.keys.sorted(),
            ["Content-MD5", "Content-Type", "X-Ca-Key", "X-Ca-Nonce", "X-Ca-Signature", "X-Ca-Timestamp"].sorted()
        )
        XCTAssertEqual(headers["X-Ca-Key"], "access-key")
        XCTAssertEqual(headers["Content-Type"], "application/json;charset=UTF-8")
        XCTAssertFalse(headers["X-Ca-Signature"]!.isEmpty)
        XCTAssertFalse(headers["X-Ca-Nonce"]!.isEmpty)
        XCTAssertFalse(headers["X-Ca-Timestamp"]!.isEmpty)
    }

    func testContentMD5MatchesBody() {
        let body = Data("{\"skip\":1}".utf8)
        let expected = Data(Insecure.MD5.hash(data: body)).base64EncodedString()
        let headers = YmsRequestSigner(config: FakeConfig()).headers(method: "POST", path: "path", bodyData: body)
        XCTAssertEqual(headers["Content-MD5"], expected)
    }

    func testEmptyBodyProducesEmptyContentMD5() {
        let headers = YmsRequestSigner(config: FakeConfig()).headers(method: "POST", path: "path", bodyData: nil)
        XCTAssertEqual(headers["Content-MD5"], "")
    }

    func testSignatureChangesWithPath() {
        let signer = YmsRequestSigner(config: FakeConfig())
        let a = signer.headers(method: "POST", path: "path/A", bodyData: nil)
        let b = signer.headers(method: "POST", path: "path/B", bodyData: nil)
        XCTAssertNotEqual(a["X-Ca-Signature"], b["X-Ca-Signature"])
    }
}