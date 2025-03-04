//
//  APIClient.swift
//  AppNews
//
//  Created by Amirov Foma on 18.02.2025.
//

import Foundation

// MARK: - API Fetcher Protocol
/// Протокол для асинхронного получения данных из API
protocol APIFetcher {
    func fetch<R: APIRequest>(_ request: R) async throws -> R.ReturnType
}

// MARK: - API Client
/// Клиент для работы с API, реализующий сетевые запросы
final class APIClient: NSObject {

    let config: APIConfiguration

    // MARK: - Initialization
    /// Инициализация клиента с заданной конфигурацией API
    init(config: APIConfiguration = .defaultNews) {
        self.config = config
        super.init()
    }
}

// MARK: - APIFetcher
/// Реализация методов протокола APIFetcher
extension APIClient: APIFetcher {
    ///  Запрос к API без параметров.
    func fetch<R>(_ request: R) async throws -> R.ReturnType where R: APIRequest {
        try await fetch(request, option: .none)
    }

    ///  Запрос к API с дополнительными параметрами.
    func fetch<R>(_ request: R, option: QueryItemOption) async throws -> R.ReturnType where R: APIRequest {
        guard let urlRequest = request.asURLRequest(for: self, with: option) else {
            throw APIError.badRequest(description: "Не удалось создать URL-запрос", reason: nil)
        }

        let urlSession = createURLSession(delegate: self)

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError(statusCode: 0, description: "Неизвестный ответ сервера", responseData: nil)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: httpResponse.statusCode, description: "Ошибка сервера", responseData: data)
            }

            let decodedResponse =  try JSONDecoder().decode(R.ReturnType.self, from: data)
            return decodedResponse

        } catch {
            throw mapToAPIError(error)
        }
    }
}

// MARK: - URLSession Delegate
/// Делегат URLSession для обработки HTTPS-аутентификации
extension APIClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}

// MARK: - Private Helpers
private extension APIClient {
    /// Создание URLSession
    func createURLSession(delegate: URLSessionDelegate?) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        let urlSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

        return urlSession
    }

    /// Настройка и обработка ошибок
    func mapToAPIError(_ error: Error) -> APIError {
        let apiError: APIError
        switch error {
        case let decodingError as DecodingError:
            apiError = .decodingError(description: decodingError.localizedDescription)
        case let urlError as URLError:
            apiError = .urlSessionFailed(urlError)
        case let error as APIError:
            apiError = error
        default:
            apiError = .unknownError
        }
        print("API Error: \(apiError.errorDescription ?? "No description")")
        return apiError
    }
}
