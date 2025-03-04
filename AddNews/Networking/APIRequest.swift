//
//  APIRequest.swift
//  AppNews
//
//  Created by Amirov Foma on 18.02.2025.
//

import Foundation

// MARK: - Protocol Definition
/// Определение протокола APIRequest для создания сетевых запросов
protocol APIRequest {
    associatedtype ReturnType: Decodable

    var scheme: URLScheme { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }

    func asURLRequest(for api: APIClient, with option: QueryItemOption) -> URLRequest?
    func createQueryItems() -> [URLQueryItem]
    func createBody() -> Data?
}

// MARK: - Default Implementations
/// Дефолтные реализации свойств протокола APIRequest
extension APIRequest {
    var scheme: URLScheme {
        .https
    }

    var method: HTTPMethod {
        .get
    }

    var contentType: String {
        "application/json"
    }
}

// MARK: - Request Building
/// Логика построения URLRequest из параметров запроса
extension APIRequest {
    func asURLRequest(for api: APIClient, with option: QueryItemOption) -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = api.config.host
        components.port = api.config.port
        components.path = api.config.path + path

        var queryItems = [URLQueryItem(name: "apikey", value: api.config.apiKey)]
        queryItems.append(contentsOf: createQueryItems())
        queryItems.append(contentsOf: option.queryItems)
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = createBody()

        return request
    }

    func createQueryItems() -> [URLQueryItem] {
        []
    }

    func createBody() -> Data? {
        nil
    }
}

// MARK: - Query Options
/// Структура для дополнительных параметров запроса (query items)
struct QueryItemOption {
    let queryItems: [URLQueryItem]
    static let none = QueryItemOption([])

    init(_ items: [URLQueryItem] = []) {
        self.queryItems = items
    }

    static func with(parameters: [String: String]) -> QueryItemOption {
        let items = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return QueryItemOption(items)
    }
}

// MARK: - Networking Types
/// Базовые перечисления для схемы URL и HTTP-методов
enum URLScheme: String {
    case https
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
