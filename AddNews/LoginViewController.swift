//
//  LoginViewController.swift
//  AddNews
//
//  Created by Dmitry Belov on 19.02.2025.
//


import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    private var appStorage: AppStorage<UserProfile>!
    
    private var firstNameTextField: UITextField!
    private var lastNameTextField: UITextField!
    private var emailTextField: UITextField!
    private var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализация AppStorage для UserProfile
        do {
            appStorage = try AppStorage<UserProfile>()
        } catch {
            print("Error initializing AppStorage: \(error)")
        }
        
        setupUI()
    }
    
    // Настройка UI
    func setupUI() {
        // Устанавливаем фоновый цвет
        view.backgroundColor = .white
        
        // Создаем поля для ввода
        firstNameTextField = UITextField()
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.placeholder = "Enter first name"
        firstNameTextField.borderStyle = .roundedRect
        view.addSubview(firstNameTextField)
        
        lastNameTextField = UITextField()
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.placeholder = "Enter last name"
        lastNameTextField.borderStyle = .roundedRect
        view.addSubview(lastNameTextField)
        
        emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        view.addSubview(emailTextField)
        
        // Кнопка "Сохранить"
        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        // Кнопка "Печать из базы"
        let printButton = UIButton()
        printButton.translatesAutoresizingMaskIntoConstraints = false
        printButton.setTitle("Print from DB", for: .normal)
        printButton.backgroundColor = .systemGreen
        printButton.layer.cornerRadius = 8
        printButton.addTarget(self, action: #selector(printButtonTapped), for: .touchUpInside)
        view.addSubview(printButton)
        
        // Кнопка для перехода на экран новостей
        let newsButton = UIButton()
        newsButton.translatesAutoresizingMaskIntoConstraints = false
        newsButton.setTitle("Go to News", for: .normal)
        newsButton.backgroundColor = .systemOrange
        newsButton.layer.cornerRadius = 8
        newsButton.addTarget(self, action: #selector(goToNewsButtonTapped), for: .touchUpInside)
        view.addSubview(newsButton)
        
        // Метка для вывода результатов
        resultLabel = UILabel()
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(resultLabel)
        
        // Устанавливаем ограничения для всех элементов
        NSLayoutConstraint.activate([
            firstNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            firstNameTextField.widthAnchor.constraint(equalToConstant: 300),
            
            lastNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
            lastNameTextField.widthAnchor.constraint(equalToConstant: 300),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            printButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            printButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            printButton.widthAnchor.constraint(equalToConstant: 150),
            printButton.heightAnchor.constraint(equalToConstant: 50),
            
            newsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newsButton.topAnchor.constraint(equalTo: printButton.bottomAnchor, constant: 20),
            newsButton.widthAnchor.constraint(equalToConstant: 150),
            newsButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: newsButton.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Сохранение данных
    @objc func saveButtonTapped() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            resultLabel.text = "Please enter valid name, last name, and email."
            return
        }
        
        let userProfile = UserProfile()
        userProfile.firstName = firstName
        userProfile.lastName = lastName
        userProfile.email = email
        
        do {
            try appStorage.save(userProfile)
            resultLabel.text = "User profile saved successfully!"
        } catch {
            resultLabel.text = "Error saving user profile: \(error.localizedDescription)"
        }
    }
    
    // Печать данных из базы
    @objc func printButtonTapped() {
        let userProfiles = appStorage.fetch()
        var resultText = "User Profiles in DB:\n"
        
        for userProfile in userProfiles {
            resultText += "Name: \(userProfile.firstName) \(userProfile.lastName), Email: \(userProfile.email)\n"
        }
        
        if userProfiles.isEmpty {
            resultText = "No user profiles found."
        }
        
        resultLabel.text = resultText
    }
    
    // Переход на экран новостей
    @objc func goToNewsButtonTapped() {
        let newsVC = NewsViewController()
        present(newsVC, animated: true)
    }
}

// Модель данных
final class UserProfile: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var email: String = ""
}
