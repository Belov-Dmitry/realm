//
//  EditProfileViewModel.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// EditProfileViewModel.swift
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var bio: String = ""
    @Published var website: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSaved: Bool = false
    
    private let firestoreService: FirestoreServiceProtocol
    private let appStorage: AppStorage<UserRealm>
    private let uid: String
    private var cancellables = Set<AnyCancellable>()
    
    init(uid: String, firestoreService: FirestoreServiceProtocol, appStorage: AppStorage<UserRealm>) {
        self.uid = uid
        self.firestoreService = firestoreService
        self.appStorage = appStorage
    }
    
    func saveProfile() async {
        isLoading = true
        let user = User(
            uid: uid,
            username: username,
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            bio: bio,
            website: website,
            isOnboardingComplit: true
        )
        do {
            try await firestoreService.saveUserData(user: user)
            saveToRealm(user: user)
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func saveToRealm(user: User) {
        let userRealm = UserRealm()
        userRealm.uid = user.uid
        userRealm.username = user.username
        userRealm.fullName = user.fullName
        userRealm.email = user.email
        userRealm.phoneNumber = user.phoneNumber
        userRealm.bio = user.bio
        userRealm.website = user.website
        userRealm.isOnboardingComplit = user.isOnboardingComplit
        try? appStorage.save(userRealm)
    }
}