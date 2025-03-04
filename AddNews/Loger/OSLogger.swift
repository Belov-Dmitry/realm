import os

/// Осуществляет запись в единую систему логгирования Apple
///
/// Сообщения, отправленные в этот логер можно исследовать в Xcode debug console, приложении Console.app,
/// в командной строке
struct OSLogger: Loggable {
    func log(level: LogLevel, _ message: String, category: AppCategory) {
        osLog(level: level, category: category.rawValue.uppercased(), message: message)
    }
}

private extension OSLogger {
    func osLog(level: LogLevel, category: String, message: String) {
        let osLogger = Logger(subsystem: "log.main.app", category: category)

        switch level {
        case .debug:
            osLogger.debug("🟡 \(message, privacy: .public)")
        case .info:
            osLogger.info("🟢 \(message, privacy: .public)")
        case .notice:
            osLogger.notice("🔵 \(message, privacy: .public)")
        case .error:
            osLogger.error("🔴 \(message, privacy: .public)")
        case .fault:
            osLogger.fault("🔴 \(message, privacy: .public)")
        }
    }
}
