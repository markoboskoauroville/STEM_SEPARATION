import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let log = NSTextView()
    let pick = NSButton(title: "Choose a song…", target: nil, action: nil)
    var job: Separator?

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
        let col = NSStackView(views: [pick, live, sc]); col.orientation = .vertical; col.alignment = .leading; col.spacing = 12
        col.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        window.contentView = col; window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
        say("Pick a song: Live separates it into vocals, bass, drums and others; the stems and stems.json go to ~/Music/Stems.")
    }

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
