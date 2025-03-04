//
//  UserRealm.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// UserRealm.swift
import RealmSwift

class UserRealm: Object {
    @Persisted(primaryKey: true) var uid: String = ""
    @Persisted var username: String?
    @Persisted var fullName: String?
    @Persisted var email: String?
    @Persisted var phoneNumber: String?
    @Persisted var bio: String?
    @Persisted var website: String?
    @Persisted var isOnboardingComplit: Bool = false
}