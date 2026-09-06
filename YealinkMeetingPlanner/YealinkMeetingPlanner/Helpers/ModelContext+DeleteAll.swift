import SwiftData

extension ModelContext {
    func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        let items = try fetch(FetchDescriptor<T>())
        for item in items {
            delete(item)
        }
    }
}