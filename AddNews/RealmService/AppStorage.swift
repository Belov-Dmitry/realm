//
//  RealmService.swift
//  AddNews
//
//  Created by Dmitry Belov on 11.02.2025.
//

import RealmSwift
import Foundation

final class AppStorage<T: Object>: AppStorageProtocol {
     var realm: Realm
    
    init() throws {
            // Конфигурация Realm с миграцией
            let config = Realm.Configuration(
                schemaVersion: 1, // увеличиваем версию схемы
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                        // Пример: если добавлено новое поле в модель
                        migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                            newObject?["newField"] = "default value" // Устанавливаем значение по умолчанию для нового поля
                        }
                    }
                }
            )
            
            do {
                realm = try Realm(configuration: config)
                print("файл с базой данных: \(realm.configuration.fileURL)")
            } catch {
                throw AppStorageError.initializationFailed
            }
        }
    
    // Сохранение объекта (с обновлением)
    func save(_ object: T) throws {
        DispatchQueue.global(qos: .background).async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    backgroundRealm.add(object, update: .modified)
                }
            } catch {
                DispatchQueue.main.async {
                    print(AppStorageError.saveFailed.localizedDescription)
                }
            }
        }
    }
    
    // Получение всех объектов
    func fetch() -> Results<T> {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.objects(T.self)
        } catch {
            DispatchQueue.main.async {
                print(AppStorageError.fetchFailed.localizedDescription)
            }
            return try! Realm().objects(T.self) // Возвращаем дефолтный объект при ошибке
        }
    }
    
    // Получение объектов с фильтром
    func fetchFiltered(filter: String) -> Results<T> {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.objects(T.self).filter(filter)
        } catch {
            DispatchQueue.main.async {
                print(AppStorageError.fetchFailed.localizedDescription)
            }
            return try! Realm().objects(T.self) // Возвращаем дефолтный объект при ошибке
        }
    }
    
    // Получение объекта по ID
    func findById(_ id: String) -> T? {
        do {
            let backgroundRealm = try Realm()
            return backgroundRealm.object(ofType: T.self, forPrimaryKey: id)
        } catch {
            DispatchQueue.main.async {
                print(AppStorageError.fetchFailed.localizedDescription)
            }
            return nil
        }
    }
    
    // Удаление объекта
    func delete(_ object: T) throws {
        DispatchQueue.global(qos: .background).async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    backgroundRealm.delete(object)
                }
            } catch {
                DispatchQueue.main.async {
                    print(AppStorageError.deleteFailed.localizedDescription)
                }
            }
        }
    }
    
    // Удаление всех объектов
    func deleteAll() throws {
        DispatchQueue.global(qos: .background).async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    let objects = backgroundRealm.objects(T.self)
                    backgroundRealm.delete(objects)
                }
            } catch {
                DispatchQueue.main.async {
                    print(AppStorageError.deleteFailed.localizedDescription)
                }
            }
        }
    }
    
    // Обновление в транзакции
    func update(_ block: @escaping () -> Void) throws {
        DispatchQueue.global(qos: .background).async {
            do {
                let backgroundRealm = try Realm()
                try backgroundRealm.write {
                    block()
                }
            } catch {
                DispatchQueue.main.async {
                    print(AppStorageError.updateFailed.localizedDescription)
                }
            }
        }
    }
}
