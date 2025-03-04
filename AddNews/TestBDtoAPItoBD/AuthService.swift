//
//  AuthServiceProtocol.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// AuthService.swift
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

protocol AuthServiceProtocol {
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> String
    func signInWithPhoneNumber(phoneNumber: String, presentingViewController: UIViewController) async throws -> String
    func verifyPhoneNumber(verificationID: String, verificationCode: String) async throws -> String
}

final class FirebaseAuthService: AuthServiceProtocol {
    // Google SignIn
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> String {
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw AuthError.invalidClientID }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let signInResult = try await GIDSignIn.sharedInstance.signInAsync(withPresenting: presentingViewController)
        guard let idToken = signInResult.user.idToken?.tokenString else { throw AuthError.invalidClientID }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: signInResult.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user.uid
    }
    
    // Phone Auth
    func signInWithPhoneNumber(phoneNumber: String, presentingViewController: UIViewController) async throws -> String {
        do {
            return try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        } catch {
            throw AuthError.phoneAuthFailed
        }
    }
    
    func verifyPhoneNumber(verificationID: String, verificationCode: String) async throws -> String {
        do {
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
            )
            let authResult = try await Auth.auth().signIn(with: credential)
            return authResult.user.uid
        } catch {
            throw AuthError.invalidVerificationCode
        }
    }
}

extension GIDSignIn {
    func signInAsync(withPresenting presentingViewController: UIViewController) async throws -> GIDSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            self.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "GIDSignInError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
                    ))
                }
            }
        }
    }
}

enum AuthError: Error {
    case invalidClientID
    case invalidVerificationCode
    case phoneAuthFailed
}
