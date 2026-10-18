// THE ONE ACTION: the song into Live, Live's stem separation, the four stems collected and analysed.
import AppKit
import AVFoundation

final class Separator {
    let song: URL
    let say: (String) -> Void
    var started = Date()
    init(song: URL, say: @escaping (String) -> Void) { self.song = song; self.say = say }

    var outDir: URL { stemsRoot.appendingPathComponent(song.deletingPathExtension().lastPathComponent) }

    func run() {
        started = Date()
        DispatchQueue.global().async {
            do { try self.steps() } catch { self.say("✗ " + error.localizedDescription); appendLog("failed: \(error)") }
        }
    }

    struct Fail: LocalizedError { let errorDescription: String?; init(_ s: String) { errorDescription = s } }

    func steps() throws {
        guard Live.url != nil else { throw Fail("Ableton Live 12 is not installed") }
        guard Live.canSeparate else { throw Fail("Live \(Live.version) has no stem separation: it came with Live 12.3 (Suite). Update Live, then try again.") }
        // 1. Live running, its control surface listening
        if NSRunningApplication.runningApplications(withBundleIdentifier: Live.bundleID).isEmpty {
            say("starting Ableton Live…")
            let c = NSWorkspace.OpenConfiguration(); c.activates = true
            let sem = DispatchSemaphore(value: 0)
            NSWorkspace.shared.openApplication(at: Live.url!, configuration: c) { _, _ in sem.signal() }
            sem.wait(); Thread.sleep(forTimeInterval: 25)          // Live and its remote scripts need their time
        }
        // 2. a new audio track at the top, the song in its first clip slot, that clip selected
        say("loading the song into Live…")
        OSC.send("/live/song/create_audio_track", [0]); Thread.sleep(forTimeInterval: 1)
        OSC.send("/live/clip_slot/create_audio_clip", [0, 0, song.path]); Thread.sleep(forTimeInterval: 3)
        OSC.send("/live/clip_slot/select", [0, 0]); Thread.sleep(forTimeInterval: 1)
        // 3. Live's own command, from its menu bar (Accessibility); else Marko's one right-click
        say("separating the stems in Live…")
        if !pressMenu(containing: "Separate Stems") {
            say("🟠 In Live: right-click the new clip (top track) → Separate Stems to New Audio Tracks. The app waits.")
        }
        // 4. the four stem files appear on disk: collected
        let found = try waitForStems(timeout: 1800)
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        for (name, url) in found {
            let dst = outDir.appendingPathComponent(name + "." + url.pathExtension)
            try? FileManager.default.removeItem(at: dst)
            try FileManager.default.copyItem(at: url, to: dst)
        }
        // 5. the analysis: every stem's waveform and level per second, beside the whole song's
        say("analysing the stems…")
        try analyse()
        say("✓ done: \(outDir.path)")
        NSWorkspace.shared.activateFileViewerSelecting([outDir])
    }

    // Live's menu bar, searched for the command (it may sit in Edit or Create; Live draws its context menus itself).
    func pressMenu(containing title: String) -> Bool {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: Live.bundleID).first else { return false }
        app.activate()
        let ax = AXUIElementCreateApplication(app.processIdentifier)
        var bar: CFTypeRef?
        guard AXUIElementCopyAttributeValue(ax, kAXMenuBarAttribute as CFString, &bar) == .success, let bar else { return false }
        func children(_ e: AXUIElement) -> [AXUIElement] {
            var v: CFTypeRef?; AXUIElementCopyAttributeValue(e, kAXChildrenAttribute as CFString, &v); return (v as? [AXUIElement]) ?? []
        }
        func titleOf(_ e: AXUIElement) -> String {
            var v: CFTypeRef?; AXUIElementCopyAttributeValue(e, kAXTitleAttribute as CFString, &v); return (v as? String) ?? ""
        }
        func search(_ e: AXUIElement, _ depth: Int) -> AXUIElement? {
            if titleOf(e).localizedCaseInsensitiveContains(title) { return e }
            guard depth < 5 else { return nil }
            for c in children(e) { if let f = search(c, depth + 1) { return f } }
            return nil
        }
        guard let item = search(bar as! AXUIElement, 0) else { appendLog("menu: no item with \(title)"); return false }
        var enabled: CFTypeRef?; AXUIElementCopyAttributeValue(item, kAXEnabledAttribute as CFString, &enabled)
        appendLog("menu: found \(titleOf(item)), enabled \(String(describing: enabled))")
        return AXUIElementPerformAction(item, kAXPressAction as CFString) == .success
    }

    // Where Live writes the stems is learnt from the first real run (LESSONS); until then every audio file that appears
    // after the start in Live's folders and beside the song, named after a stem, is a candidate. Finished = its size
    // has not changed for 5 s.
    func waitForStems(timeout: TimeInterval) throws -> [String: URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let roots = [home.appendingPathComponent("Music/Ableton"), home.appendingPathComponent("Library/Application Support/Ableton"),
                     song.deletingLastPathComponent(), URL(fileURLWithPath: NSTemporaryDirectory()).deletingLastPathComponent()]
        var sizes: [URL: (Int, Date)] = [:]
        let end = Date().addingTimeInterval(timeout)
        while Date() < end {
            var hits: [String: URL] = [:]
            for r in roots {
                guard let en = FileManager.default.enumerator(at: r, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                                                              options: [.skipsHiddenFiles]) else { continue }
                for case let u as URL in en {
                    guard ["wav", "aif", "aiff", "flac"].contains(u.pathExtension.lowercased()),
                          let v = try? u.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                          let m = v.contentModificationDate, m > started, let size = v.fileSize else { continue }
                    let n = u.lastPathComponent.lowercased()
                    guard let stem = stemNames.first(where: { n.contains($0) || ($0 == "others" && n.contains("other")) }) else { continue }
                    let prev = sizes[u]
                    if prev == nil || prev!.0 != size { sizes[u] = (size, Date()) }
                    else if Date().timeIntervalSince(prev!.1) > 5 { hits[stem] = u }
                }
            }
            if hits.count == stemNames.count {
                appendLog("stems: " + hits.map { "\($0.key)=\($0.value.path)" }.joined(separator: " ")); return hits
            }
            say("waiting for Live's stems… \(hits.count) of 4 written")
            Thread.sleep(forTimeInterval: 3)
        }
        throw Fail("no stems from Live within \(Int(timeout / 60)) minutes")
    }

    // stems.json: per stem (and the whole song) a peak waveform at 25 per second (0-255) and the level in dB per second.
    func analyse() throws {
        var out: [String: Any] = ["song": song.lastPathComponent, "made": ISO8601DateFormatter().string(from: Date()),
                                  "rate": 25, "source": "Ableton Live \(Live.version) stem separation"]
        var tracks: [[String: Any]] = []
        let files = [("song", song)] + stemNames.compactMap { n in
            (try? FileManager.default.contentsOfDirectory(at: outDir, includingPropertiesForKeys: nil))?
                .first { $0.deletingPathExtension().lastPathComponent == n }.map { (n, $0) } }
        for (name, url) in files {
            let f = try AVAudioFile(forReading: url)
            let sr = f.processingFormat.sampleRate, hop = Int(sr / 25)
            guard let buf = AVAudioPCMBuffer(pcmFormat: f.processingFormat, frameCapacity: AVAudioFrameCount(f.length)) else { continue }
            try f.read(into: buf)
            let n = Int(buf.frameLength), ch = Int(buf.format.channelCount)
            var peaks = [Float](), secs = [Float]()
            var i = 0, acc: Double = 0, accN = 0
            while i < n {
                var pk: Float = 0
                for j in i..<min(i + hop, n) { for c in 0..<ch { let v = abs(buf.floatChannelData![c][j]); pk = max(pk, v); acc += Double(v * v) }; accN += ch }
                peaks.append(pk); i += hop
                if peaks.count % 25 == 0 { secs.append(Float(10 * log10(acc / Double(max(accN, 1)) + 1e-12))); acc = 0; accN = 0 }
            }
            let top = peaks.sorted()[Int(Double(peaks.count - 1) * 0.995)]
            let bytes = peaks.map { UInt8(min(255, max(0, $0 / max(top, 1e-6) * 255))) }
            tracks.append(["name": name, "file": url.lastPathComponent, "wave": Data(bytes).base64EncodedString(),
                           "db_per_second": secs.map { ($0 * 10).rounded() / 10 }])
        }
        out["tracks"] = tracks
        try JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted]).write(to: outDir.appendingPathComponent("stems.json"))
    }
}
