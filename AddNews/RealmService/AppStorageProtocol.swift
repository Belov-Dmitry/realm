//
//  RealmServiceProtocol.swift
//  AddNews
//
//  Created by Dmitry Belov on 11.02.2025.
//

import RealmSwift

protocol AppStorageProtocol {
    associatedtype T: Object
    func save(_ object: T) throws
    func fetch() -> Results<T>
    func fetchFiltered(filter: String) -> Results<T>
    func findById(_ id: String) -> T?
    func delete(_ object: T) throws
    func deleteAll() throws
    func update(_ block: @escaping () -> Void) throws
}
