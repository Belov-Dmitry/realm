import RealmSwift
import Foundation

final class AppStorage<T: Object>: AppStorageProtocol {
    
    private let realmQueue = DispatchQueue(label: "com.appnews.realmQueue", qos: .background)
    
    var realm: Realm
    
    init() throws {
        // Конфигурация Realm с миграцией
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { _, _ in }
        )
        do {
            realm = try Realm(configuration: config)
        } catch {
            throw AppStorageError.initializationFailed
        }
    }
    // Сохранение объекта (с обновлением)
    func save(_ object: T) throws {
        realmQueue.async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    backgroundRealm.add(object, update: .modified)
                }
            } catch {
                // Handle error (будет обработано позже с сервисом логгирования)
                print(AppStorageError.saveFailed.localizedDescription)
            }
        }
    }
    // Получение всех объектов
    func fetch() -> Results<T>? {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.objects(T.self)
        } catch {
            // Handle error (будет обработано позже с сервисом логгирования)
            print(AppStorageError.fetchFailed.localizedDescription)
            
            return nil
        }
    }
    // Получение объектов с фильтром
    func fetchFiltered(filter: String) -> Results<T>? {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.objects(T.self).filter(filter)
        } catch {
            // Handle error (будет обработано позже с сервисом логгирования)
            print(AppStorageError.fetchFailed.localizedDescription)
            
            return nil
        }
    }
    // Получение объекта по ID
    func findById(_ id: String) -> T? {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.object(ofType: T.self, forPrimaryKey: id)
        } catch {
            // Handle error (будет обработано позже с сервисом логгирования)
            print(AppStorageError.fetchFailed.localizedDescription)
            return nil
        }
    }
    // Удаление объекта
    func delete(_ object: T) throws {
        realmQueue.async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    backgroundRealm.delete(object)
                }
            } catch {
                // Handle error (будет обработано позже с сервисом логгирования)
                print(AppStorageError.deleteFailed.localizedDescription)
                
            }
        }
    }
    // Удаление всех объектов
    func deleteAll() throws {
        realmQueue.async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    let objects = backgroundRealm.objects(T.self)
                    backgroundRealm.delete(objects)
                }
            } catch {
                // Handle error (будет обработано позже с сервисом логгирования)
                print(AppStorageError.deleteFailed.localizedDescription)
                
            }
        }
    }
    // Обновление в транзакции
    func update(_ block: @escaping () -> Void) throws {
        realmQueue.async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    block()
                }
            } catch {
                // Handle error (будет обработано позже с сервисом логгирования)
                print(AppStorageError.updateFailed.localizedDescription)
                
            }
        }
    }
}
