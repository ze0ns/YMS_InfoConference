import Foundation

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        true
    }

    func hash(into hasher: inout Hasher) {}

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(
                JSONNull.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Wrong type for JSONNull"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}