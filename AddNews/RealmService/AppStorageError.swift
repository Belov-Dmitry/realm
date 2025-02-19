//
//  RealmError.swift
//  AddNews
//
//  Created by Dmitry Belov on 11.02.2025.
//


enum AppStorageError: Error {
    case initializationFailed
    case saveFailed
    case fetchFailed
    case deleteFailed
    case updateFailed
    
    var localizedDescription: String {
        switch self {
        case .initializationFailed:
            return "Failed to initialize the database."
        case .saveFailed:
            return "Failed to save the object."
        case .fetchFailed:
            return "Failed to fetch the objects."
        case .deleteFailed:
            return "Failed to delete the object."
        case .updateFailed:
            return "Failed to update the object."
        }
    }
}
