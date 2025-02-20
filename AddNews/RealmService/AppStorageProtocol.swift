import RealmSwift

protocol AppStorageProtocol {
    associatedtype T: Object // букву Т не трогать
    func save(_ object: T) throws
    func fetch() -> Results<T>?
    func fetchFiltered(filter: String) -> Results<T>?
    func findById(_ id: String) -> T?
    func delete(_ object: T) throws
    func deleteAll() throws
    func update(_ block: @escaping () -> Void) throws
}
