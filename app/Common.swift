// Stem Separation (Mantra): pick a song, Ableton Live separates it into its stems, the app collects and analyses them.
// Marko, 18.10.2026: "make a swift application called stem separation that will automatically load the song into
// Ableton Live and you'll separate stems, export stems and analyze them. It's just one shot action with the file picker."
import Foundation

// v3 (30.10.2026, Marko: "If permissions are not set, it needs to have text in the top right: Permissions"): PERMISSIONS
// in amber at the top right while Accessibility is missing; a click opens that page in System Settings
// v4 (31.10.2026): ON OFF … TOP PERMISSIONS ✕ first row (TopRow.swift)
let VERSION = 4
let stemNames = ["vocals", "bass", "drums", "others"]
let stemsRoot = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Music/Stems")
let logFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/stem-separation.log")

func appendLog(_ s: String) {
    let f = ISO8601DateFormatter(); f.timeZone = .current
    let line = "\(f.string(from: Date())) \(s)\n"
    if let h = try? FileHandle(forWritingTo: logFile) { h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); try? h.close() }
    else { try? line.write(to: logFile, atomically: true, encoding: .utf8) }
}

// The Live on this Mac, and whether it can separate stems (Live 12.3 and later, Suite).
enum Live {
    static let bundleID = "com.ableton.live"
    static var url: URL? {
        let apps = (try? FileManager.default.contentsOfDirectory(atPath: "/Applications")) ?? []
        return apps.filter { $0.hasPrefix("Ableton Live 12") && $0.hasSuffix(".app") }.sorted().last
            .map { URL(fileURLWithPath: "/Applications/" + $0) }
    }
    static var version: String {
        guard let u = url, let d = NSDictionary(contentsOf: u.appendingPathComponent("Contents/Info.plist")),
              let v = d["CFBundleShortVersionString"] as? String else { return "" }
        return v.components(separatedBy: " ").first ?? v
    }
    static var canSeparate: Bool {
        let p = version.split(separator: ".").compactMap { Int($0) }
        guard p.count >= 2 else { return false }
        return p[0] > 12 || (p[0] == 12 && p[1] >= 3)
    }
}
