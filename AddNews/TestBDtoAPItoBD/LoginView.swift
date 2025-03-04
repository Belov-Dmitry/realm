//
//  LoginView.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// LoginView.swift
import UIKit
import Combine

final class LoginView: UIViewController {
    private let viewModel: LoginViewModel
    private let googleButton = UIButton(type: .system)
    private let phoneButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Настройка кнопки Google
        googleButton.setTitle("Continue with Google", for: .normal)
        googleButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        // Настройка кнопки телефона
        phoneButton.setTitle("Sign in with Phone", for: .normal)
        phoneButton.addTarget(self, action: #selector(signInWithPhone), for: .touchUpInside)
        
        // Настройка индикатора загрузки
        activityIndicator.hidesWhenStopped = true
        
        // Добавление элементов на экран
        view.addSubview(googleButton)
        view.addSubview(phoneButton)
        view.addSubview(activityIndicator)
        
        // Настройка констрейнтов
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        phoneButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            phoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        // Подписка на isLoading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        // Подписка на errorMessage
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showAlert(message: message)
            }
            .store(in: &cancellables)
        
        // Подписка на navigateToEditProfile
        viewModel.$navigateToEditProfile
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigateToEditProfile()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func signInWithGoogle() {
        Task {
            await viewModel.signInWithGoogle(presentingViewController: self)
        }
    }
    
    @objc private func signInWithPhone() {
        let phoneAlert = UIAlertController(
            title: "Enter Phone Number",
            message: "Enter phone number with country code",
            preferredStyle: .alert
        )
        
        phoneAlert.addTextField { $0.placeholder = "+1234567890" }
        
        phoneAlert.addAction(UIAlertAction(title: "Next", style: .default) { [weak self] _ in
            guard let self = self,
                  let phoneNumber = phoneAlert.textFields?.first?.text else { return }
            
            Task {
                await self.viewModel.startPhoneNumberVerification(
                    phoneNumber: phoneNumber,
                    presentingViewController: self
                )
                
                // Показ алерта для ввода кода после получения verificationID
                if self.viewModel.verificationID != nil {
                    self.showCodeVerificationAlert()
                }
            }
        })
        
        phoneAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(phoneAlert, animated: true)
    }
    
    private func showCodeVerificationAlert() {
        let codeAlert = UIAlertController(
            title: "Verification Code",
            message: "Enter code from SMS",
            preferredStyle: .alert
        )
        
        codeAlert.addTextField { $0.placeholder = "123456" }
        
        codeAlert.addAction(UIAlertAction(title: "Verify", style: .default) { [weak self] _ in
            guard let self = self,
                  let code = codeAlert.textFields?.first?.text else { return }
            
            Task {
                await self.viewModel.verifyPhoneNumberCode(code)
            }
        })
        
        codeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(codeAlert, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToEditProfile() {
        guard let user = viewModel.user else { return }
        
        let editProfileVM = EditProfileViewModel(
            uid: user.uid,
            firestoreService: FirestoreService(),
            appStorage: try! AppStorage<UserRealm>()
        )
        
        let editProfileView = EditProfileView(viewModel: editProfileVM)
        navigationController?.pushViewController(editProfileView, animated: true)
    }
    
    // MARK: - Helpers
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
