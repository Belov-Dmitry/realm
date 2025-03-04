//
//  LoginViewModel.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// LoginViewModel.swift
//import UIKit
//import Combine
//
//@MainActor
//final class LoginViewModel: ObservableObject {
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var navigateToEditProfile: Bool = false
//    @Published var user: User?
//    
//    private let authService: AuthServiceProtocol
//    private let firestoreService: FirestoreServiceProtocol
//    private let appStorage: AppStorage<UserRealm>
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(authService: AuthServiceProtocol, firestoreService: FirestoreServiceProtocol, appStorage: AppStorage<UserRealm>) {
//        self.authService = authService
//        self.firestoreService = firestoreService
//        self.appStorage = appStorage
//    }
//    
//    func signInWithGoogle(presentingViewController: UIViewController) async {
//        isLoading = true
//        do {
//            let uid = try await authService.signInWithGoogle(presentingViewController: presentingViewController)
//            await handleUser(uid: uid)
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        isLoading = false
//    }
//    
//    func signInWithPhoneNumber(phoneNumber: String, presentingViewController: UIViewController, verificationCode: String) async {
//        isLoading = true
//        do {
//            let verificationID = try await authService.signInWithPhoneNumber(phoneNumber: phoneNumber, presentingViewController: presentingViewController)
//            let uid = try await authService.verifyPhoneNumber(verificationID: verificationID, verificationCode: verificationCode)
//            await handleUser(uid: uid)
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        isLoading = false
//    }
//    
//    private func handleUser(uid: String) async {
//        do {
//            let exists = try await firestoreService.checkUserExists(uid: uid)
//            if exists {
//                let userData = try await firestoreService.fetchUserData(uid: uid)
//                self.user = userData
//                saveToRealm(user: userData)
//            } else {
//                self.user = User(uid: uid, username: nil, fullName: nil, email: nil, phoneNumber: nil, bio: nil, website: nil, isOnboardingComplit: false)
//                navigateToEditProfile = true
//            }
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//    
//    private func saveToRealm(user: User) {
//        let userRealm = UserRealm()
//        userRealm.uid = user.uid
//        userRealm.username = user.username
//        userRealm.fullName = user.fullName
//        userRealm.email = user.email
//        userRealm.phoneNumber = user.phoneNumber
//        userRealm.bio = user.bio
//        userRealm.website = user.website
//        userRealm.isOnboardingComplit = user.isOnboardingComplit
//        try? appStorage.save(userRealm)
//    }
//}


import UIKit
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var navigateToEditProfile: Bool = false
    @Published var user: User?
    
     var verificationID: String? // Для хранения ID верификации номера
    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let appStorage: AppStorage<UserRealm>
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol,
         firestoreService: FirestoreServiceProtocol,
         appStorage: AppStorage<UserRealm>) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.appStorage = appStorage
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(presentingViewController: UIViewController) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let uid = try await authService.signInWithGoogle(presentingViewController: presentingViewController)
            await handleUser(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Phone Auth
        func startPhoneNumberVerification(phoneNumber: String, presentingViewController: UIViewController) async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                verificationID = try await authService.signInWithPhoneNumber(
                    phoneNumber: phoneNumber,
                    presentingViewController: presentingViewController
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        func verifyPhoneNumberCode(_ code: String) async {
            isLoading = true
            defer { isLoading = false }
            
            guard let verificationID = verificationID else {
                errorMessage = "Verification process not started"
                return
            }
            
            do {
                let uid = try await authService.verifyPhoneNumber(
                    verificationID: verificationID,
                    verificationCode: code
                )
                await handleUser(uid: uid)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    
    // MARK: - User Handling
    private func handleUser(uid: String) async {
        do {
            let exists = try await firestoreService.checkUserExists(uid: uid)
            
            if exists {
                let userData = try await firestoreService.fetchUserData(uid: uid)
                self.user = userData
                saveToRealm(user: userData)
            } else {
                self.user = User(
                    uid: uid,
                    username: nil,
                    fullName: nil,
                    email: nil,
                    phoneNumber: nil,
                    bio: nil,
                    website: nil,
                    isOnboardingComplit: false
                )
                navigateToEditProfile = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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
