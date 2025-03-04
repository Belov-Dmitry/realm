import Foundation

protocol AppErrorHandling {
    var next: AppErrorHandling? { get set }

    func handle(error: Error) -> String
}

final class MainAppErrorHandler: AppErrorHandling {
    var next: AppErrorHandling?

    private init() { }

    static func chain() -> MainAppErrorHandler {
        let links: [AppErrorHandling] = [ ]

        let root = MainAppErrorHandler()
        var parent: AppErrorHandling = root

        for link in links {
            parent.next = link
            parent = link
        }

        return root
    }

    func handle(error: Error) -> String {
        next?.handle(error: error) ?? error.localizedDescription
    }
}

class AppErrorHandler: AppErrorHandling {
    var next: AppErrorHandling?

    func handle(error: Error) -> String {
        next?.handle(error: error) ?? error.localizedDescription
    }
}
