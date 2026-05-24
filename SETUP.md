# Setup — what's done and what you need to do

> Everything in **Part 1** is finished. **Part 2** is the stuff that physically needs
> you (downloads, account signups, plugging your phone in). I can't do those for you
> remotely. Follow the steps top to bottom.

---

## ✅ Part 1 — Already done for you

All of these were built and verified to work in this session:

| Done | What |
|------|------|
| ✅ | Python venv at `e:\Tic Tac Toe APP\venv` with Django 5.2, DRF, Channels, JWT, django-redis |
| ✅ | Django project `tictactoe\` with `accounts` and `game` apps |
| ✅ | Custom User model, JWT auth (register / login / me / refresh) |
| ✅ | Game models, AI bots (Easy / Medium / Hard minimax), services, REST APIs |
| ✅ | WebSocket consumers: matchmaking + per-game room + chat |
| ✅ | PostgreSQL database `tictactoe_db` migrated (creds in `tictactoe\.env`) |
| ✅ | Upstash Redis wired in for Channels pub/sub + Django cache (verified roundtrip) |
| ✅ | Full Flutter app source in `flutter_app\lib\` (16 Dart files: auth, AI, multiplayer, lobby, leaderboard, profile, history, chat) |
| ✅ | Deployment configs: `Procfile`, `railway.json`, `render.yaml`, `runtime.txt`, `.env.example` |

---

## 🟡 Part 2 — You need to do these (in order)

### Step 1 — Verify the backend runs

```powershell
cd "e:\Tic Tac Toe APP\tictactoe"
..\venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

Open http://127.0.0.1:8000/ in a browser. You should see:

```json
{"status": "ok", "service": "tictactoe"}
```

Leave this terminal running.

(Optional) Create an admin user to browse `/admin/`:
```powershell
..\venv\Scripts\python.exe manage.py createsuperuser
```

### Step 2 — Install Flutter SDK

1. Download from **https://docs.flutter.dev/get-started/install/windows** (~1 GB)
2. Extract the zip to `C:\src\flutter` (or anywhere — just **NOT** in `C:\Program Files\`, it breaks).
3. Add `C:\src\flutter\bin` to your **PATH** environment variable.
4. New PowerShell window, run:
   ```powershell
   flutter --version
   flutter doctor
   ```

   `flutter doctor` will tell you what's still missing. You'll likely need Android Studio for the Android toolchain — install it next.

### Step 3 — Install Android Studio

1. Download from **https://developer.android.com/studio** (~1 GB).
2. Run the installer with defaults.
3. On first launch, it offers to install the Android SDK — accept.
4. Open **Tools → SDK Manager → SDK Tools** tab, tick:
   - Android SDK Command-line Tools (latest)
   - Android SDK Build-Tools
   - Android Emulator
5. Accept Android licenses:
   ```powershell
   flutter doctor --android-licenses
   ```
   Press `y` to all.
6. Re-run `flutter doctor` until everything is ✓ (except the iOS row — we don't need iOS on Windows).

### Step 4 — Create an Android Virtual Device (or use a real phone)

**Option A — Emulator:**
1. Android Studio → **Device Manager** → **Create Virtual Device**.
2. Pick "Pixel 7" → System Image (Android 14, x86_64) → Finish.
3. Click ▶ to boot the emulator.

**Option B — Real phone (faster):**
1. On phone: Settings → About → tap "Build number" 7 times → unlocks Developer Options.
2. Developer Options → enable **USB Debugging**.
3. Plug into PC via USB. Tap "Allow USB debugging" on the phone popup.
4. `flutter devices` should show your phone.

> **Note:** On a real phone the default `10.0.2.2` API URL won't work — that's emulator-only.
> Find your PC's LAN IP (`ipconfig`, look for "IPv4 Address" on your WiFi adapter, e.g. `192.168.1.42`).
> Then **launch the app with that IP** (Step 6 shows how).

### Step 5 — Initialize the Flutter project (one-time)

The Dart source code is ready, but the native Android shell needs to be generated:

```powershell
cd "e:\Tic Tac Toe APP\flutter_app"
flutter create . --project-name tictactoe_app --platforms=android
flutter pub get
```

`flutter create .` adds the `android/`, `ios/`, etc. folders **without** touching your `lib/` or `pubspec.yaml`. Confirm `lib/main.dart` is still the file I wrote (it should be — `flutter create` skips existing files in `lib/`).

Also, allow plain HTTP (cleartext) in dev so the emulator can reach Django over `http://`:

Edit `flutter_app/android/app/src/main/AndroidManifest.xml`, inside the `<application>` tag, add:
```xml
android:usesCleartextTraffic="true"
```

### Step 6 — Run the app

**With the emulator (default URL `http://10.0.2.2:8000`):**
```powershell
cd "e:\Tic Tac Toe APP\flutter_app"
flutter run
```

**With a real phone (replace `192.168.1.42` with your PC IP):**
```powershell
flutter run --dart-define=API_BASE=http://192.168.1.42:8000 --dart-define=WS_BASE=ws://192.168.1.42:8000
```

Make sure the Django server in Step 1 is bound to `0.0.0.0:8000` (not `127.0.0.1`) so the phone can reach it.

You should land on the login screen. Tap **Sign up**, create a user, and you're in.

### Step 7 — Test the full flow

1. **Solo vs AI** — Home → Play vs AI → Hard. Try to win. You can't (minimax is perfect).
2. **Multiplayer** — Sign up a SECOND user (use another emulator / phone, or just two PowerShell `flutter run` sessions on the same machine). Both tap **Quick Match**. They should be paired and play live.
3. **Stats** — Open Profile after a game. Wins/losses/draws should update.
4. **Leaderboard** — Should list users ordered by wins.
5. **Chat** — During a multiplayer match, tap the chat icon top-right.

### Step 8 — Build a release APK

```powershell
cd "e:\Tic Tac Toe APP\flutter_app"
flutter build apk --release --dart-define=API_BASE=https://YOUR-DEPLOYED-BACKEND --dart-define=WS_BASE=wss://YOUR-DEPLOYED-BACKEND
```

The APK lands at `build/app/outputs/flutter-apk/app-release.apk`. Copy it to your phone and install (you'll need to enable "Install from Unknown Sources").

For a **signed** release (required for Play Store), follow https://docs.flutter.dev/deployment/android#signing-the-app — needs you to generate a keystore and edit `android/app/build.gradle`.

### Step 9 — Deploy backend to Railway

1. Sign up at **https://railway.app** (GitHub login is easiest).
2. New Project → **Deploy from GitHub repo** (push the `tictactoe/` folder to a repo first).
3. Add Variables in Railway dashboard:
   - `SECRET_KEY` — generate a random 50+ char string
   - `DEBUG` — `False`
   - `ALLOWED_HOSTS` — `*` (or your actual host)
   - `DATABASE_URL` — Railway will auto-create one if you add a Postgres plugin
   - `REDIS_URL` — paste the Upstash URL from your `.env`
   - `CORS_ALLOWED_ORIGINS` — `*` (lock down later)
4. Railway auto-detects `Procfile` and `requirements.txt`. Deploys take ~2 min.
5. Click the deployed URL → should show the health-check JSON.
6. Update your Flutter app's `--dart-define=API_BASE=` to that URL for the release build.

---

## 🛠 Troubleshooting

| Symptom | Fix |
|---|---|
| `flutter run` says "no devices" | Run `flutter devices`. If empty: start the emulator or check USB debugging. |
| App shows blank / "Connection refused" | Backend not running, or wrong IP. Check `flutter_app/lib/config.dart` and your `--dart-define` flags. |
| Login works but multiplayer hangs | WebSocket URL wrong. `WS_BASE` must match `API_BASE` host (just `ws://` instead of `http://`). |
| "CLEARTEXT communication not permitted" | You skipped the `usesCleartextTraffic` change in Step 5. |
| `psycopg2.OperationalError` on backend start | Postgres not running. Start your local Postgres service. |
| Emulator boots forever | Cold-boot it: Device Manager → ⋮ → Wipe Data. |

---

## 📁 Where everything lives

| File | What |
|---|---|
| `tictactoe/.env` | Local Postgres + Upstash Redis credentials (gitignored) |
| `tictactoe/.env.example` | Template for the above (commit this) |
| `tictactoe/tictactoe/settings.py` | All Django config — reads from .env |
| `tictactoe/tictactoe/asgi.py` | HTTP + WebSocket entry point |
| `tictactoe/game/consumers.py` | WebSocket logic (matchmaking + game room) |
| `tictactoe/game/logic.py` | Pure Tic Tac Toe rules + minimax AI |
| `flutter_app/lib/config.dart` | Where to point the Flutter app (API URL) |
| `flutter_app/lib/main.dart` | App entry — wires Provider + theme + splash |
| `flutter_app/lib/screens/` | All 10 screens |

That's the whole project. You're 30 minutes of tool-installs away from a working APK. Good luck. 🎯
