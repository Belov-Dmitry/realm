import Foundation

// MARK: - AppLogger
/// Главный логгер приложения, внутри себе содержит логику распределения лог-сообщений в дочерние логгеры
final class AppLogger {
    // MARK: LoggerType
    enum LoggerType {
        case fileLogger
        case osLogger
    }

    static let isWritingToFile: Bool = false

    // MARK: Static properties
    static var children: [LoggerType] = [.fileLogger, .osLogger] {
        didSet {
            var newChildren: [LoggerType] = AppLogger.children

            #if DEBUG
            if !isWritingToFile {
                newChildren = children.filter { $0 != .fileLogger }
            }
            #endif

            var newLoggers: [Loggable] = []
            newChildren.forEach { type in
                switch type {
                case .fileLogger:
                    newLoggers.append(AppLogger.fileLogger)
                case .osLogger:
                    newLoggers.append(AppLogger.osLogger)
                }
            }

            AppLogger.default.loggers = newLoggers
        }
    }

    // MARK: Private static properties
    private static var fileLogger: Loggable & LogDataProviding = SharedFileLogger()
    private static var osLogger: Loggable = OSLogger()
    private static let `default` = AppLogger(loggers: getDefaultLoggers())
    private static let errorHandler = MainAppErrorHandler.chain()

    // MARK: Private properties
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = String(describing: AppLogger.self)
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var loggers: [Loggable]

    // MARK: Initializers
    private init(loggers: [Loggable]) {
        self.loggers = loggers
    }
}

private extension AppLogger {
    static func getDefaultLoggers() -> [Loggable] {
        // в release мы ведем запись и в файл и в единую систему логирования Apple
        var loggers = [fileLogger, osLogger]

        #if DEBUG
        if !isWritingToFile {
            loggers = [osLogger]
        }
        #endif

        return loggers
    }
}

private extension AppLogger {
    // swiftlint:disable function_parameter_count
    func log(
        level: LogLevel,
        message: String,
        category: AppCategory,
        fileID: String,
        method: String,
        line: UInt
    ) {
        if !message.isEmpty {
            queue.addBarrierBlock { [weak self] in
                guard let self else {
                    return
                }

                let fullMessage = self.buildFullMessage(fileID: fileID, method: method, line: line, message: message)
                self.loggers.forEach { $0.log(level: level, fullMessage, category: category) }
            }
        }
    }

    // swiftlint:enable function_parameter_count
    func buildFullMessage(fileID: String, method: String, line: UInt, message: String) -> String {
        [
            fileID.components(separatedBy: "/").last ?? fileID,
            method,
            line == 0 ? "" : String(line),
            "\"\(message)\""
        ]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Methods for public usage
extension AppLogger {
    
    static func getLogData() -> Data? {
        fileLogger.readLogData()
    }

    static func getLogFileInformation() -> FileInformation {
        fileLogger.getLogFileInformation()
    }

    static func logPrettyJSON(
        _ dictionary: [AnyHashable: Any],
        category: AppCategory = .main,
        level: LogLevel = .notice,
        fileID: String = #file,
        method: String = #function,
        line: UInt = #line
    ) {
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let message = String(data: data, encoding: .utf8) {
            AppLogger.default.log(
                level: level,
                message: message,
                category: category,
                fileID: fileID,
                method: method,
                line: line
            )
        } else {
            AppLogger.default.log(
                level: .error,
                message: "Ошибка логирования словаря",
                category: category,
                fileID: fileID,
                method: method,
                line: line
            )
        }
    }

    static func logPrettyJson(
        _ string: String,
        category: AppCategory = .main,
        level: LogLevel = .notice,
        fileID: String = #file,
        method: String = #function,
        line: UInt = #line
    ) {
        if let data = string.data(using: .utf8) {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let newData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                    if let message = String(data: newData, encoding: .utf8) {
                        AppLogger.default.log(
                            level: level,
                            message: message,
                            category: category,
                            fileID: fileID,
                            method: method,
                            line: line
                        )
                    }
                }
            }
        } else {
            AppLogger.default.log(
                level: .error,
                message: "Ошибка логирования json: String",
                category: category,
                fileID: fileID,
                method: method,
                line: line
            )
        }
    }

    static func log(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #file,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .notice,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func log(
        level: LogLevel,
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #file,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: level,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func debug(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .debug,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func info(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .info,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func notice(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .notice,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func error(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .error,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func fault(
        _ message: String,
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        AppLogger.default.log(
            level: .fault,
            message: message,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }

    static func error(
        _ error: Error,
        _ message: String = "",
        category: AppCategory = .main,
        fileID: String = #fileID,
        method: String = #function,
        line: UInt = #line
    ) {
        let description = errorHandler.handle(error: error)
        return AppLogger.default.log(
            level: .error,
            message: message + ": " + description,
            category: category,
            fileID: fileID,
            method: method,
            line: line
        )
    }
}
