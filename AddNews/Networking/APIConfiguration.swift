//
//  APIConfiguration.swift
//  AppNews
//
//  Created by Amirov Foma on 25.02.2025.
//

import Foundation

/// Конфигурация для настройки базовых параметров API, таких как схема, хост, путь и порт
struct APIConfiguration {
    let scheme: URLScheme
    let host: String
    let path: String
    let port: Int?
    let apiKey: String

    /// Стандартная конфигурация для API новостей (newsdata.io) с HTTPS.
    static let defaultNews = APIConfiguration(
        scheme: .https,
        host: "newsdata.io",
        path: "",
        port: nil,
        apiKey: "pub_713995077332877d2b5cb2ea8135d39dd296f"
    )
}
