# Lessons

- 18.10.2026: Live's stem separation is 12.3 and later, Suite only. Check the version first (`defaults read
  "/Applications/Ableton Live 12 Suite.app/Contents/Info.plist" CFBundleShortVersionString`).
- 18.10.2026: Cloudflare Pages answers no byte ranges (a range request gets 200 and the whole file): audio published for
  the site must be HLS segments, or it cannot be seeked.
