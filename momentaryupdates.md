# Stem Separation (Mantra) — Marko's requests, word for word

## 18.10.2026, request 1 (the app)

> For local stamp separation you need to run Ableton Live. You can even make a swift application called stamp separation that will automatically load the song into Ableton Live and you'll separate stamps, export stems and analyze them. It's just one shot action to do with the file picker.

> Please start building the track separation through Ableton Live and I don't care about copyrights so please use this song and give it credits. I think that will be enough full credits for the song. That's it.

**Status:** v2 18.10.2026. Marko updated Live to 12.4.6; the first separation (Secret ID, I Follow Rivers) ran with the app's steps by hand; v2 carries what it taught. Not yet run as the app (its Accessibility permission).

## 18.10.2026, request 2 (what the stems are for)

> Since now, when we break the song into stems, we have different waveforms for different parts of the song. We can use that to actually make four waveforms or whatever many are running together, plus a whole waveform. So the user can see how the instruments are changing through time. This is a very good educational tool, please.

**Status:** done 18.10.2026: the stem lanes in the DJ Mantra educational player (v36).

## 18.10.2026, request 3

> Ableton 1246 is there. Please, it's done. Do the stem separation now.

> It is done.

**Status:** done: both songs separated by Live 12.4.6 in a new set (his "hang mapped" untouched), stems in ~/Music/Stems.

## 30.10.2026: PERMISSIONS at the top right

> "please make this in every application that needs some permission. If permissions are not set, it needs to have text in the top right: "Permissions." Then I click on it, and it opens me directly to my settings page where I need to set permissions." (Marko, 30.10.2026)

The word PERMISSIONS (amber) on the ON / OFF row, right of the spacer and left of the ✕, only while a permission the app uses is missing; a click opens that page in System Settings (MANTRA_MANIFEST swift-apps.md, last section).

**Status:** built v3 30.10.2026: the window had no ON / OFF row, so PERMISSIONS (amber) sits at the right end of its first row (beside Choose a song…) while Accessibility (pressing Live's menu and dialog) is missing; checked every 2 s, changed only on a change; a click asks once and opens the Accessibility page. The launch no longer asks with --login. The app was not running, so not started and not seen by screenshot. Marko to try.

## 31.10.2026: ON, OFF and TOP in every application

> Please go to all the interface of my applications. Each needs to have the same user interface elements. On, off and top. Please build it in every application.

(MANTRA_MANIFEST modules/swift-apps.md, "The first row of every app: ON OFF … TOP ✕"; reference MANTRA_SOUND_RECORDER `TopRow`.) **Status:** done 31.10.2026, v4: the first row ON OFF … Stem Separation … TOP PERMISSIONS ✕ in the title bar beside the traffic lights (new app/TopRow.swift, AppKit; the window gets .fullSizeContentView, a hidden transparent title). Every word is a real NSButton with an Accessibility identifier: OFF `off` quits the app, TOP `top` floats the window (UserDefaults `onTop`, applied at launch), PERMISSIONS `permissions` moved up from the song row and still shown only while Accessibility is missing, ✕ `close` closes the window only: so the app no longer quits on its last window (applicationShouldTerminateAfterLastWindowClosed false, the Dock click brings the window back). The app had no QUIT. New `--shot <png>` draws the page off screen and lists its identifiers (off top permissions close). Checked by that shot; not opened, because the app takes the front on launch and was not running.
