//
//  APIError.swift
//  AppNews
//
//  Created by Amirov Foma on 18.02.2025.
//

import Foundation

enum APIError: LocalizedError {
    case badRequest(description: String, reason: String?)
    case decodingError(description: String)
    case urlSessionFailed(URLError)
    case unknownError
    case serverError(statusCode: Int, description: String?, responseData: Data?)

    var errorDescription: String? {
        switch self {
        case .badRequest(let description, _):
            return description
        case .decodingError(let description):
            return description
        case .urlSessionFailed(let urlError):
            return urlError.localizedDescription
        case .unknownError:
            return "Неизвестная ошибка."
        case .serverError(let statusCode, let description, let responseData):
            var errorText = "Ошибка сервера. Код: \(statusCode), описание: \(description ?? "Нет описания")"
            if let data = responseData, let jsonString = String(data: data, encoding: .utf8) {
                errorText += "\nОтвет: \(jsonString)"
            }
            return errorText
        }
    }

    var failureReason: String? {
        switch self {
        case .badRequest(_, let reason):
            return reason
        case .decodingError(let description):
            return description
        case .urlSessionFailed(let urlError):
            return "Ошибка URL сессии: \(urlError.localizedDescription)"
        case .unknownError:
            return "Неизвестная ошибка произошла."
        case .serverError(let statusCode, _, _):
            return "Сервер вернул ошибку с кодом: \(statusCode)"
        }
    }
}
