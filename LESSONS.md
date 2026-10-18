# Lessons

- 18.10.2026: Live's stem separation is 12.3 and later, Suite only. Check the version first (`defaults read
  "/Applications/Ableton Live 12 Suite.app/Contents/Info.plist" CFBundleShortVersionString`).
- 18.10.2026: Cloudflare Pages answers no byte ranges (a range request gets 200 and the whole file): audio published for
  the site must be HLS segments, or it cannot be seeked.
- 18.10.2026, first run (Live 12.4.6): the command is **Create → Separate Stems to New Audio Tracks** in the menu bar,
  so Accessibility can press it; it opens a small "Separate Stems" window: four stem checkboxes (all on), Merge to
  Single Track (off), a High Speed / High Quality switch, and two untitled buttons: 1 Separate, 2 Cancel. The switch
  does not follow Accessibility (its values change, its drawing and state do not): leave Live's default, High Speed.
- Live writes the stems into the set's project: an unsaved set's is ~/Music/Ableton/Live Recordings/<date> Temp
  Project/Samples/Processed/Stems/<clip name> [time] (Vocals|Drums|Bass|Others).wav, 44.1 kHz stereo, plus .asd files.
  Secret ID (6:55) took about 40 s.
- The stems add back up to the song: 99.7 % (Secret ID) and 99.3 % (I Follow Rivers) by cross-correlation; Secret ID's
  stems sit 37.6 ms early against the m4a, I Follow Rivers' 9 ms late: measure, don't assume.
- Live reopens the last set after an update: never add tracks to whatever is open; File → New Live Set first, and a
  save question is Marko's.
- AbletonOSC's own logger breaks on create_audio_clip's arguments ("not all arguments converted"): a logging error
  only, the clip is created.
