//
//  ViewController.swift
//  AddNews
//
//  Created by Aaa on 11.02.2025.
//


import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    private var appStorage: AppStorage<User>!
    
    private var nameTextField: UITextField!
    private var ageTextField: UITextField!
    private var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализация AppStorage для модели User
        do {
            appStorage = try AppStorage<User>()
        } catch {
            print("Error initializing AppStorage: \(error)")
        }
        
        setupUI()
    }
    
    // Настройка UI
    func setupUI() {
        // Устанавливаем фоновый цвет
        view.backgroundColor = .white
        
        // Создаем поле для ввода имени
        nameTextField = UITextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = "Enter name"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        
        // Создаем поле для ввода возраста
        ageTextField = UITextField()
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.placeholder = "Enter age"
        ageTextField.borderStyle = .roundedRect
        ageTextField.keyboardType = .numberPad
        view.addSubview(ageTextField)
        
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
        
        // Метка для вывода результатов
        resultLabel = UILabel()
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(resultLabel)
        
        // Устанавливаем ограничения для всех элементов
        NSLayoutConstraint.activate([
            // nameTextField
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            nameTextField.widthAnchor.constraint(equalToConstant: 300),
            
            // ageTextField
            ageTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            ageTextField.widthAnchor.constraint(equalToConstant: 300),
            
            // saveButton
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // printButton
            printButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            printButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            printButton.widthAnchor.constraint(equalToConstant: 150),
            printButton.heightAnchor.constraint(equalToConstant: 50),
            
            // resultLabel
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: printButton.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Обработчик нажатия на кнопку "Сохранить"
    @objc func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageText = ageTextField.text, let age = Int(ageText) else {
            resultLabel.text = "Please enter valid name and age."
            return
        }
        
        
        let user = User()
        user.name = name
        user.age = age
        do {
            try appStorage.save(user)
            resultLabel.text = "User saved successfully!"
        } catch {
            resultLabel.text = "Error saving user: \(error.localizedDescription)"
        }
    }
    
    // Обработчик нажатия на кнопку "Печать из базы"
    @objc func printButtonTapped() {
        // Разворачиваем опционал с использованием guard let
        guard let users = appStorage.fetch() else {
            resultLabel.text = "Error fetching users or no users found."
            return
        }
        
        var resultText = "Users in DB:\n"
        
        // Проверка на пустоту массива после разворачивания
        if users.isEmpty {
            resultText = "No users found."
        } else {
            for user in users {
                resultText += "Name: \(user.name), Age: \(user.age)\n"
            }
        }
        
        resultLabel.text = resultText
    }
    
}
// Модели данных
final class User: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var age: Int = 0
}
