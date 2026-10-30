import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let log = NSTextView()
    let pick = NSButton(title: "Choose a song…", target: nil, action: nil)
    var job: Separator?
    // v3: the word PERMISSIONS at the top right of the first row, only while one is missing
    let perm = NSButton(title: "PERMISSIONS", target: nil, action: nil)
    var lastMissing: [String]?

    static func main() { let a = NSApplication.shared; let d = AppDelegate(); a.delegate = d; a.setActivationPolicy(.regular); a.run() }

    func applicationDidFinishLaunching(_ n: Notification) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 560, height: 320), styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        window.title = "Stem Separation (Mantra) v\(VERSION)"
        pick.target = self; pick.action = #selector(choose); pick.bezelStyle = .rounded; pick.controlSize = .large
        let live = NSTextField(labelWithString: Live.url == nil ? "Ableton Live 12 is not installed"
            : "Ableton Live \(Live.version)" + (Live.canSeparate ? " · stem separation ready" : " · no stem separation: update to 12.3 or later"))
        live.textColor = Live.canSeparate ? .secondaryLabelColor : .systemOrange
        log.isEditable = false; log.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        let sc = NSScrollView(); sc.documentView = log; sc.hasVerticalScroller = true; log.autoresizingMask = [.width]
        sc.translatesAutoresizingMaskIntoConstraints = false; sc.heightAnchor.constraint(equalToConstant: 200).isActive = true
        sc.widthAnchor.constraint(equalToConstant: 520).isActive = true
        perm.target = self; perm.action = #selector(openPermissions); perm.isBordered = false
        perm.attributedTitle = NSAttributedString(string: "PERMISSIONS", attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor(red: 0xE8/255, green: 0xA3/255, blue: 0x3D/255, alpha: 1)])
        perm.toolTip = "A permission is missing: this opens its page in System Settings"
        let gap = NSView(); gap.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let top = NSStackView(views: [pick, gap, perm]); top.orientation = .horizontal
        top.widthAnchor.constraint(equalToConstant: 520).isActive = true
        showPermissions()
        // the window notices a permission switched on in System Settings within two seconds; redrawn only on a change
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.showPermissions() }
        let col = NSStackView(views: [top, live, sc]); col.orientation = .vertical; col.alignment = .leading; col.spacing = 12
        col.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        window.contentView = col; window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        // v3: never asked at login (--login); the word PERMISSIONS waits in the window instead
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: !CommandLine.arguments.contains("--login")] as CFDictionary)
        say("Pick a song: Live separates it into vocals, bass, drums and others; the stems and stems.json go to ~/Music/Stems.")
    }

    func showPermissions() {
        let m = Permissions.missing
        if m != lastMissing { lastMissing = m; perm.isHidden = m.isEmpty }
    }
    @objc func openPermissions() { Permissions.openMissing() }

    func say(_ s: String) {
        appendLog(s)
        DispatchQueue.main.async { self.log.string += s + "\n"; self.log.scrollToEndOfDocument(nil) }
    }

    @objc func choose() {
        let p = NSOpenPanel(); p.allowedContentTypes = [.audio]; p.allowsMultipleSelection = false
        p.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Music/DJMantra")
        guard p.runModal() == .OK, let u = p.url else { return }
        say("song: " + u.lastPathComponent)
        job = Separator(song: u) { [weak self] in self?.say($0) }
        job?.run()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }
}

// v3, THE PERMISSIONS the app uses (MANTRA_MANIFEST swift-apps.md, last section): Accessibility, to press Live's menu
// item and its dialog's button (Separator.swift)
enum Permissions {
    static let needed = ["Accessibility"]
    static func allowed(_ p: String) -> Bool {
        switch p {
        case "Accessibility": return AXIsProcessTrusted()
        default: return true
        }
    }
    static var missing: [String] { needed.filter { !allowed($0) } }
    // the system's own request once (it puts the app in the list), then the page of the first one still missing
    static func openMissing() {
        guard let p = missing.first else { return }
        if p == "Accessibility" { _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary) }
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_" + p)!)
    }
}
