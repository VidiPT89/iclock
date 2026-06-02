import SwiftUI

struct ClockTheme: Identifiable, Equatable {
    let id: String
    let namePT: String
    let nameEN: String
    let onColor: Color

    var offColor: Color { onColor.opacity(0.07) }

    func name(lang: AppLanguage) -> String {
        lang == .english ? nameEN : namePT
    }

    // Legacy accessor for code that doesn't pass language
    var name: String { namePT }

    static let all: [ClockTheme] = [
        ClockTheme(id: "amber",  namePT: "Âmbar",   nameEN: "Amber",  onColor: Color(red: 1.00, green: 0.60, blue: 0.08)),
        ClockTheme(id: "green",  namePT: "Verde",    nameEN: "Green",  onColor: Color(red: 0.08, green: 1.00, blue: 0.28)),
        ClockTheme(id: "cyan",   namePT: "Ciano",    nameEN: "Cyan",   onColor: Color(red: 0.00, green: 0.88, blue: 1.00)),
        ClockTheme(id: "red",    namePT: "Vermelho", nameEN: "Red",    onColor: Color(red: 1.00, green: 0.18, blue: 0.08)),
        ClockTheme(id: "purple", namePT: "Roxo",     nameEN: "Purple", onColor: Color(red: 0.72, green: 0.18, blue: 1.00)),
        ClockTheme(id: "white",  namePT: "Gelo",     nameEN: "Ice",    onColor: Color(red: 0.88, green: 0.93, blue: 1.00)),
    ]

    static let `default` = all[0]

    static func find(id: String) -> ClockTheme {
        all.first { $0.id == id } ?? .default
    }
}
