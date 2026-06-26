import SwiftUI

// MARK: - Hex Color Convenience
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >>  8) & 0xFF) / 255.0
        let b = Double( int        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - Paperdoodle Design Tokens
/// All colours, fonts, and per-category helpers for the Field Notes redesign.
/// Add Caveat-Bold.ttf, PatrickHand-Regular.ttf, Kalam-Regular.ttf to your Xcode target
/// and declare them under "Fonts provided by application" in Info.plist.
struct PD {

    // ── Surface / ink palette ────────────────────────────────
    struct Colors {
        static let paper50       = Color(hex: "FFFDF6")   // brightest sheet (header bg)
        static let paper100      = Color(hex: "FBF6E9")   // default page bg
        static let paper200      = Color(hex: "F4ECD8")   // hover well
        static let paper300      = Color(hex: "EDE0C4")   // separator / rule
        static let paper400      = Color(hex: "E2D1AC")   // strong divider
        static let ink900        = Color(hex: "221F1A")   // primary text
        static let ink800        = Color(hex: "2B2620")   // heading / icon
        static let ink600        = Color(hex: "5B5347")   // body text
        static let ink400        = Color(hex: "8C8270")   // secondary text
        static let ink300        = Color(hex: "B3A98F")   // muted / captions
        static let ink100        = Color(hex: "CFC4A6")   // hairlines / disabled
        static let accent        = Color(hex: "2D5BA8")   // ballpoint blue – primary action
        static let accentInk     = Color(hex: "1E3F77")   // darker blue – button shadow
        static let accentSuccess = Color(hex: "2D7A4F")   // green – save success state
        static let hiYellow      = Color(hex: "F6DE71")   // highlighter swipe / washi
        static let hiYellowDeep  = Color(hex: "EFCF3F")   // washi border
    }

    // ── Per-category foreground & background ─────────────────
    static func catColor(for category: String) -> Color {
        switch category {
        case "Jobs":           return Color(hex: "2D7A4F")
        case "Articles":       return Color(hex: "B8610A")
        case "Opportunities":  return Color(hex: "6B4FA0")
        case "To Do":          return Color(hex: "CB4536")
        case "Videos":         return Color(hex: "B0366A")
        default:               return Color(hex: "2D5BA8")   // General
        }
    }

    static func catBackground(for category: String) -> Color {
        switch category {
        case "Jobs":           return Color(hex: "BFE3C2")
        case "Articles":       return Color(hex: "F9D4A0")
        case "Opportunities":  return Color(hex: "EDE6F7")
        case "To Do":          return Color(hex: "F6DCD6")
        case "Videos":         return Color(hex: "F4B7C8")
        default:               return Color(hex: "DCE6F5")   // General
        }
    }

    // ── Fonts ────────────────────────────────────────────────
    /// Caveat Variable — display / brand name
    static func script(_ size: CGFloat) -> Font {
        Font.custom("Caveat", size: size).weight(.bold)
    }
    /// Patrick Hand — UI labels, button text, badges, domain names
    static func marker(_ size: CGFloat) -> Font {
        Font.custom("PatrickHand-Regular", size: size)
    }
    /// Kalam Regular — input fields, body text, dates
    static func body(_ size: CGFloat) -> Font {
        Font.custom("Kalam-Regular", size: size)
    }
}

// MARK: - Thin rule helper
struct PDRule: View {
    var color: Color = PD.Colors.paper300
    var body: some View {
        color.frame(height: 1).frame(maxWidth: .infinity)
    }
}
