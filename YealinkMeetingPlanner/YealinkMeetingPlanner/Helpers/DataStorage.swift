import Foundation

// MARK: - Протокол хранилища

protocol DataStorage {
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
    func object(forKey defaultName: String) -> Any?
    func data(forKey defaultName: String) -> Data?

    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)

    func removeObject(forKey defaultName: String)
}

extension UserDefaults: DataStorage {}