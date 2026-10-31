# Takeover

State 18.10.2026: the plan only (README). Blocker: Live 12.2.7 on the Mac has no stem separation; Live 12.3+ Suite has it
(right-click a clip: "Separate Stems to New Audio Tracks", four stems). Marko updates Live by hand (his Ableton account,
a large download over the 4G SIM).

Already there: AbletonOSC in ~/Music/Ableton/User Library/Remote Scripts/AbletonOSC (port 11001, used by
ABLETON_LIVE_ACTIONS); it reads a clip's `file_path`. Missing: loading an audio file (to add), and finding where 12.3
puts the separate command in the menu bar (Live draws its own context menus, which Accessibility cannot open).

## v1 built 18.10.2026 (not yet run against Live 12.3)

- `app/`: Common (Live's version check, the log ~/Library/Logs/stem-separation.log), OSC (send-only to 11000),
  Separator (the steps), Main (the window and the file picker). `./build.sh` builds, signs "Mantra Apps", installs.
- AbletonOSC got two commands in `abletonosc/clip_slot.py` (backup beside it, `.before-stem-separation`):
  `/live/clip_slot/create_audio_clip <track> <slot> <path>` and `/live/clip_slot/select <track> <slot>`. Live loads
  them at its next start. Not committed upstream (that folder is a clone of AbletonOSC).
- Answers from AbletonOSC go to 11001, held by Ableton Live Actions; reply routing for 11002 was refused by the safety
  system (shared resource), so the app sends only and finds the stems on disk (files named after a stem, written after
  the start, size steady 5 s) in ~/Music/Ableton, ~/Library/Application Support/Ableton, beside the song and the temp
  folders. **First real run: learn where Live 12.3 writes its stems and narrow the search (LESSONS).**
- The separate command is searched in Live's menu bar (Accessibility; the app asks for the permission at its first
  start). If it is only in Live's own context menu, the app asks Marko for the right-click and waits.
- Out: ~/Music/Stems/<song>/vocals, bass, drums, others (as Live writes them) and stems.json (per track: 25/s peak
  waveform base64, dB per second; the song itself as "song").

## v2, 18.10.2026: after the first real run

The first separation (Secret ID, I Follow Rivers) was run by hand with the app's steps (AbletonOSC + Accessibility from
the terminal) to learn Live 12.4.6: see LESSONS. v2 opens a new Live set first (waits while Live asks about saving),
presses Create → Separate Stems to New Audio Tracks and the dialog's Separate, and watches only
~/Music/Ableton/Live Recordings/*/Samples/Processed/Stems for "<song> … (Stem).wav". **Not yet run as the app**: its first
start asks for Accessibility (Marko's click in System Settings). The stems of both songs are in ~/Music/Stems and on the
DJ Mantra site (v36, the educational player's stem lanes).
- v4 (31.10.2026): app/TopRow.swift, ON OFF … TOP PERMISSIONS ✕ in AppKit in the title bar; ids `off`, `top`, `permissions`, `close`; TOP = UserDefaults `onTop`; ✕ closes only, the app stays ON; `StemSeparation --shot <png>` renders off screen.
