import Foundation
import os

/// Протокол `LogDataProviding` определяет методы для чтения логов и получения информации о файле логов.
protocol LogDataProviding {
    /// Читает данные из файла логов.
    ///
    /// - Returns: Данные из файла логов или nil, если чтение не удалось.
    func readLogData() -> Data?

    /// Получает информацию о файле логов.
    ///
    /// - Returns: Экземпляр `FileInformation`, содержащий информацию о файле логов.
    func getLogFileInformation() -> FileInformation
}

/// Структура `FileInformation` содержит информацию о файле.
struct FileInformation {
    /// Название файла без расширения.
    let name: String

    /// Расширение файла.
    let ext: String
}

final class SharedFileLogger {
    // MARK: Private properties
    private let logLevelsToLog: [LogLevel] = [.info, .notice, .error, .fault]
    private let maxFileSize: UInt64 = 5 * 1024 * 1024 // 5_242_880 байт
    private let logFileInformation: FileInformation
    private let fileName: String
    private let fileManager = FileManager.default
    private let appGroup = "group.org.Loginov.ios.MVVMRedux"
    private var fileURL: URL?
    private var tempURL: URL?

    // MARK: Initializers
    init() {
        let logFileInformation = FileInformation(name: "MVVMRedux", ext: "log")
        self.logFileInformation = logFileInformation

        let fileName = logFileInformation.name + "." + logFileInformation.ext
        self.fileName = fileName

        guard let directoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            return
        }

        fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)

        let tempName = "temp_" + fileName
        tempURL = directoryURL.appendingPathComponent(tempName, isDirectory: false)
    }
}

extension SharedFileLogger: Loggable {
    func log(level: LogLevel, _ message: String, category: AppCategory) {
        write(level: level, message: message, category: category)
    }
}

private extension SharedFileLogger {
    func write(level: LogLevel, message: String, category: AppCategory) {
        guard let fileURL,
              logLevelsToLog.contains(level),
              let data = encodeToData(level: level,
                                      timestamp: createTimestamp(),
                                      message: message,
                                      category: category) else {
            return
        }

        if !fileManager.fileExists(atPath: fileURL.path) {
            createEmptyFile(fileURL)
        }

        if isFileSizeLess(than: maxFileSize, placed: fileURL) {
            continueWriteInExistingFile(data, placed: fileURL)
        } else {
            startWriteInNewFile(data, at: fileURL)
        }
    }

    func createEmptyFile(_ fileURL: URL) {
        do {
            try Data().write(to: fileURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func encodeToData(level: LogLevel, timestamp: String, message: String, category: AppCategory) -> Data? {
        let levelIcon: String

        switch level {
        case .notice:
            levelIcon = "🔵"
        case .error:
            levelIcon = "🟡"
        case .fault:
            levelIcon = "🔴"
        default:
            levelIcon = "⚪"
        }

        let logMessag = [levelIcon, timestamp, "[\(category.rawValue.uppercased())]", message, "\n"]
            .joined(separator: " ")

        return logMessag.data(using: .utf8)
    }

    func createTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    func isFileSizeLess(than limit: UInt64, placed fileURL: URL) -> Bool {
        do {
            let attributesDictionary = try fileManager.attributesOfItem(atPath: fileURL.path)

            guard let fileSize = attributesDictionary[FileAttributeKey.size] as? UInt64 else {
                return false
            }

            return fileSize < limit
        } catch {
            return false
        }
    }

    func continueWriteInExistingFile(_ data: Data, placed fileURL: URL) {
        do {
            let fileHandler = try FileHandle(forWritingTo: fileURL)
            try fileHandler.seekToEnd()
            try fileHandler.write(contentsOf: data)
            try fileHandler.synchronize()
            try fileHandler.close()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func startWriteInNewFile(_ data: Data, at fileURL: URL) {
        do {
            try data.write(to: fileURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

// MARK: - Adopt LogDataProviding
extension SharedFileLogger: LogDataProviding {
    func readLogData() -> Data? {
        var data: Data?

        if copyInTempFile() {
            os_log(.info, "Чтение логов из копии файла")
            data = readLogDataFromCopy()
            deleteTempFile()
        } else {
            os_log(.info, "Чтение логов из оригинала файла")
            data = readLogDataFromOriginal()
        }

        return data
    }

    func getLogFileInformation() -> FileInformation {
        logFileInformation
    }
}
private extension SharedFileLogger {
    func deleteTempFile() {
        guard let tempURL else {
            return
        }

        try? fileManager.removeItem(at: tempURL)
    }

    func copyInTempFile() -> Bool {
        guard let fileURL,
              let tempURL else {
            return false
        }

        deleteTempFile()

        return copyLogFile(original: fileURL, temp: tempURL)
    }

    func copyLogFile(original: URL, temp: URL) -> Bool {
        do {
            try FileManager.default.copyItem(at: original, to: temp)

            return true
        } catch {
            return false
        }
    }

    func readLogDataFromCopy() -> Data? {
        guard let tempURL else {
            return nil
        }

        return try? Data(contentsOf: tempURL, options: .mappedIfSafe)
    }

    func readLogDataFromOriginal() -> Data? {
        guard let fileURL else {
            return nil
        }

        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            let data = fileHandle.readDataToEndOfFile()
            fileHandle.closeFile()

            return data
        } catch {
            return nil
        }
    }
}
