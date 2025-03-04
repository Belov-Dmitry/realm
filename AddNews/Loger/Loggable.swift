import Foundation

/// Уровни логирования в приложении
enum LogLevel {
    case debug
    case info
    case notice
    case error
    case fault
}

// MARK: - AppCategory
/// Категории (модули) нашего приложения
enum AppCategory: String {
    case main
    case appFlowProcess
}
// MARK: - Loggable
/// Протокол который должен принимать любой дочерний логгер
protocol Loggable {
    /// Метод записи лог-сообщения с уточняющими (дополнительными) параметрами
    /// - Parameters:
    ///   - level: один из общепринятых уровней логирования (степень серьезности сообщения)
    ///   - message: описание происходящего события в текстовом виде
    ///   - category: категория (или модуль) приложения из которого отправляет сообщение.
    ///   Список модулей общий для всего приложения.
    func log(level: LogLevel, _ message: String, category: AppCategory)
}
