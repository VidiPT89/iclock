import SwiftUI

enum ClockStyle: String, CaseIterable {
    case segments = "segments"
    case flip     = "flip"
    case dots     = "dots"
    case analog   = "analog"

    func name(lang: AppLanguage) -> String {
        switch self {
        case .segments: return lang == .english ? "Digital"  : "Digital"
        case .flip:     return lang == .english ? "Flip"     : "Flip"
        case .dots:     return lang == .english ? "Dots"     : "Pontos"
        case .analog:   return lang == .english ? "Analog"   : "Analógico"
        }
    }

    var icon: String {
        switch self {
        case .segments: return "rectangle.split.3x1"
        case .flip:     return "square.stack"
        case .dots:     return "circle.grid.3x3.fill"
        case .analog:   return "clock"
        }
    }
}
