//
//  EditProfileView.swift
//  AddNews
//
//  Created by Dmitry Belov on 26.02.2025.
//


// EditProfileView.swift
import UIKit
import Combine

final class EditProfileView: UIViewController {
    private let viewModel: EditProfileViewModel
    private let usernameTextField = UITextField()
    private let fullNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let phoneTextField = UITextField()
    private let bioTextField = UITextField()
    private let websiteTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: EditProfileViewModel) {
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
        usernameTextField.placeholder = "Username"
        fullNameTextField.placeholder = "Full Name"
        emailTextField.placeholder = "E-mail"
        phoneTextField.placeholder = "Phone Number"
        bioTextField.placeholder = "Bio"
        websiteTextField.placeholder = "Website"
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
        activityIndicator.hidesWhenStopped = true
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, fullNameTextField, emailTextField, phoneTextField, bioTextField, websiteTextField, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.$isSaved
            .filter { $0 }
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func saveProfile() {
        viewModel.username = usernameTextField.text ?? ""
        viewModel.fullName = fullNameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        viewModel.phoneNumber = phoneTextField.text ?? ""
        viewModel.bio = bioTextField.text ?? ""
        viewModel.website = websiteTextField.text ?? ""
        Task {
            await viewModel.saveProfile()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}