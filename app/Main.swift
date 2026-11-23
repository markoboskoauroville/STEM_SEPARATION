import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let log = NSTextView()
    let pick = NSButton(title: "Choose a song…", target: nil, action: nil)
    var job: Separator?
    // v4: the first row ON OFF … TOP PERMISSIONS ✕ (TopRow.swift); PERMISSIONS lives in it, only while one is missing
    lazy var row = TopRow(bold: "Stem", rest: " Separation") { Permissions.openMissing() }
    var lastMissing: [String]?

    static func main() { let a = NSApplication.shared; let d = AppDelegate(); a.delegate = d; a.setActivationPolicy(.regular); a.run() }

    func applicationDidFinishLaunching(_ n: Notification) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 560, height: 320), styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                          backing: .buffered, defer: false)
        window.title = "Stem Separation (Mantra) v\(VERSION)"
        // v4: the title bar is the first row's place: no title drawn, the row beside the traffic lights
        window.titleVisibility = .hidden; window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        pick.target = self; pick.action = #selector(choose); pick.bezelStyle = .rounded; pick.controlSize = .large
        let live = NSTextField(labelWithString: Live.url == nil ? "Ableton Live 12 is not installed"
            : "Ableton Live \(Live.version)" + (Live.canSeparate ? " · stem separation ready" : " · no stem separation: update to 12.3 or later"))
        live.textColor = Live.canSeparate ? .secondaryLabelColor : .systemOrange
        log.isEditable = false; log.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        let sc = NSScrollView(); sc.documentView = log; sc.hasVerticalScroller = true; log.autoresizingMask = [.width]
        sc.translatesAutoresizingMaskIntoConstraints = false; sc.heightAnchor.constraint(equalToConstant: 200).isActive = true
        sc.widthAnchor.constraint(equalToConstant: 520).isActive = true
        let top = NSStackView(views: [pick]); top.orientation = .horizontal
        top.widthAnchor.constraint(equalToConstant: 520).isActive = true
        showPermissions()
        // the window notices a permission switched on in System Settings within two seconds; redrawn only on a change
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.showPermissions() }
        let col = NSStackView(views: [row, top, live, sc]); col.orientation = .vertical; col.alignment = .leading; col.spacing = 12
        col.edgeInsets = NSEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        col.setCustomSpacing(8, after: row)
        row.leadingAnchor.constraint(equalTo: col.leadingAnchor, constant: 10).isActive = true
        row.trailingAnchor.constraint(equalTo: col.trailingAnchor, constant: -10).isActive = true
        window.contentView = col
        // v4: --shot <png> draws the window's page off screen (never shown, never in front), lists its Accessibility
        // identifiers and quits: the check of the first row without taking his screen
        if let i = CommandLine.arguments.firstIndex(of: "--shot"), i + 1 < CommandLine.arguments.count {
            shot(col, to: CommandLine.arguments[i + 1]); exit(0)
        }
        window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        TopRow.float(row.onTop)                                  // v4: TOP applied at launch
        Updater.checkAtStart()                                   // v5: asks to update at start
        // v3: never asked at login (--login); the word PERMISSIONS waits in the window instead
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: !CommandLine.arguments.contains("--login")] as CFDictionary)
        say("Pick a song: Live separates it into vocals, bass, drums and others; the stems and stems.json go to ~/Music/Stems.")
    }

    func shot(_ v: NSView, to path: String) {
        v.appearance = NSAppearance(named: .darkAqua)
        v.layoutSubtreeIfNeeded(); v.setFrameSize(v.fittingSize); v.layoutSubtreeIfNeeded()
        guard let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) else { return }
        NSAppearance(named: .darkAqua)!.performAsCurrentDrawingAppearance {
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
            NSColor.windowBackgroundColor.setFill(); v.bounds.fill()        // the window's ground under the page
            NSGraphicsContext.restoreGraphicsState()
            v.cacheDisplay(in: v.bounds, to: rep)
        }
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
        func ids(_ x: NSView) -> [String] { [x.accessibilityIdentifier()].filter { !$0.isEmpty } + x.subviews.flatMap(ids) }
        print("shot \(Int(v.bounds.width))x\(Int(v.bounds.height)) ids:", ids(v).joined(separator: " "))
    }

    func showPermissions() {
        let m = Permissions.missing
        if m != lastMissing { lastMissing = m; row.showPermissions(!m.isEmpty) }
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

    // v4: ✕ closes the window only, the app stays ON (MANTRA_MANIFEST swift-apps.md); OFF quits. The Dock click brings it back.
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows { window.makeKeyAndOrderFront(nil) }
        return true
    }
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
