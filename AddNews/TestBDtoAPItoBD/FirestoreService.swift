//
//  FirestoreServiceProtocol.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// FirestoreService.swift
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func checkUserExists(uid: String) async throws -> Bool
    func fetchUserData(uid: String) async throws -> User
    func saveUserData(user: User) async throws
}

final class FirestoreService: FirestoreServiceProtocol {
    private let db = Firestore.firestore()
    
    func checkUserExists(uid: String) async throws -> Bool {
        let doc = try await db.collection("users").document(uid).getDocument()
        return doc.exists
    }
    
    func fetchUserData(uid: String) async throws -> User {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else { throw FirestoreError.dataNotFound }
        return User(
            uid: uid,
            username: data["username"] as? String,
            fullName: data["fullName"] as? String,
            email: data["email"] as? String,
            phoneNumber: data["phoneNumber"] as? String,
            bio: data["bio"] as? String,
            website: data["website"] as? String,
            isOnboardingComplit: data["isOnboardingComplit"] as? Bool ?? false
        )
    }
    
    func saveUserData(user: User) async throws {
        let data: [String: Any] = [
            "username": user.username ?? "",
            "fullName": user.fullName ?? "",
            "email": user.email ?? "",
            "phoneNumber": user.phoneNumber ?? "",
            "bio": user.bio ?? "",
            "website": user.website ?? "",
            "isOnboardingComplit": user.isOnboardingComplit
        ]
        try await db.collection("users").document(user.uid).setData(data)
    }
}

enum FirestoreError: Error {
    case dataNotFound
}