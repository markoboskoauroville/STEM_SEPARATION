# Stem Separation (Mantra)

**v5 · Live 12.4.6 separates; the app itself not yet run (Accessibility) · github.com/markoboskoauroville/STEM_SEPARATION (private)**

One action: pick a song, and Ableton Live separates it into its stems (vocals, bass, drums, others; Live 12.3 Suite,
local, Music AI's model), the app collects the four files, and analyses them (a waveform and the activity of each
stem through time) for the DJ Mantra site's educational player.

The road, planned 18.10.2026:

1. The file picker (Swift, a Mantra app, signed "Mantra Apps").
2. Live is started if it is not running; the song goes into an empty clip slot through AbletonOSC (UDP 11010, reply 11011), with a
   handler added to the AbletonOSC remote script that calls Live 12's `ClipSlot.create_audio_clip(path)`.
3. "Separate Stems to New Audio Tracks" (Live 12.3+) on that clip: the one step done through Live's menus.
4. The four new tracks' clips tell their `file_path` through AbletonOSC: the stems are copied to
   `~/Music/Stems/<song>/vocals.wav, bass.wav, drums.wav, others.wav`.
5. The analysis: per stem a 3-band waveform and its level per bar (djay Pro's grid when djay knows the song).

| Document | For whom |
|---|---|
| [TAKEOVER.md](TAKEOVER.md) | the next session |
| [LESSONS.md](LESSONS.md) | before changing a decision |
| [momentaryupdates.md](momentaryupdates.md) | Marko's requests, word for word |
