//
//  NewsViewController.swift
//  AddNews
//
//  Created by Dmitry Belov on 19.02.2025.
//


import UIKit
import RealmSwift

class NewsViewController: UIViewController {
    
    private var appStorage: AppStorage<FavoriteNews>!
    
    private var titleTextField: UITextField!
    private var linkTextField: UITextField!
    private var contentTextField: UITextField!
    private var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализация AppStorage для FavoriteNews
        do {
            appStorage = try AppStorage<FavoriteNews>()
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
        titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Enter title"
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        
        linkTextField = UITextField()
        linkTextField.translatesAutoresizingMaskIntoConstraints = false
        linkTextField.placeholder = "Enter link"
        linkTextField.borderStyle = .roundedRect
        view.addSubview(linkTextField)
        
        contentTextField = UITextField()
        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextField.placeholder = "Enter content"
        contentTextField.borderStyle = .roundedRect
        view.addSubview(contentTextField)
        
        // Кнопка "Сохранить"
        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save News", for: .normal)
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
            titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleTextField.widthAnchor.constraint(equalToConstant: 300),
            
            linkTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            linkTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            linkTextField.widthAnchor.constraint(equalToConstant: 300),
            
            contentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentTextField.topAnchor.constraint(equalTo: linkTextField.bottomAnchor, constant: 20),
            contentTextField.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: contentTextField.bottomAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            printButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            printButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            printButton.widthAnchor.constraint(equalToConstant: 150),
            printButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: printButton.bottomAnchor, constant: 30),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // Сохранение новостей
    @objc func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let link = linkTextField.text, !link.isEmpty,
              let content = contentTextField.text, !content.isEmpty else {
            resultLabel.text = "Please enter valid title, link, and content."
            return
        }
        
        let favoriteNews = FavoriteNews()
        favoriteNews.title = title
        favoriteNews.link = link
        favoriteNews.content = content
        
        do {
            try appStorage.save(favoriteNews)
            resultLabel.text = "News saved successfully!"
        } catch {
            resultLabel.text = "Error saving news: \(error.localizedDescription)"
        }
    }
    
    // Печать данных из базы
    @objc func printButtonTapped() {
        // Разворачиваем опционал с использованием guard let
        guard let newsList = appStorage.fetch() else {
            resultLabel.text = "Error fetching news or no news found."
            return
        }
        
        var resultText = "Favorite News in DB:\n"
        
        // Проверка на пустоту массива после разворачивания
        if newsList.isEmpty {
            resultText = "No news found."
        } else {
            for news in newsList {
                resultText += "Title: \(news.title), Link: \(news.link), Content: \(news.content)\n"
            }
        }
        
        resultLabel.text = resultText
    }
    
}
// Модель данных для новостей
final class FavoriteNews: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var link: String = ""
    @Persisted var content: String = ""
    @Persisted var date: Date = Date()
}
