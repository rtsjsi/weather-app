# Weather

A cross-platform weather app (Android, iOS, Web) built with Flutter. Uses **Open-Meteo** for weather and search — **no API key required**.

## Features

- **Current weather** — Temperature, feels-like, humidity, wind
- **5-day forecast** — Daily outlook
- **City search** — Search by city name
- **Current location** — Use device GPS (with permission)
- **Pull to refresh** — Update weather data
- **Light & dark theme** — Follows system setting

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.5.0+)
- For release builds: Android Studio (Android), Xcode (iOS, macOS only)

## Setup and run

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app** (no API key needed)
   ```bash
   flutter run
   ```
   For web in Chrome:
   ```bash
   flutter run -d chrome
   ```

3. **Build for web** (output in `build/web/`)
   ```bash
   flutter build web --release
   ```

---

## Deploy to Vercel (push to Git, that's it)

No API keys or tokens. Connect the repo and push.

1. **Push this project to GitHub** (if it isn't already there).

2. **Go to [vercel.com](https://vercel.com)** → Sign in → **Add New…** → **Project**.

3. **Import your GitHub repo** (e.g. `weather-app`). Click **Import**.

4. **Leave the settings as they are.** The repo's `vercel.json` already tells Vercel to install Flutter, run `flutter build web --release`, and use `build/web` as the output.

5. **Deploy.** Vercel will build (first time can take a few minutes) and give you a live URL.

After that, **every push to your default branch** (e.g. `main`) will trigger a new build and deploy. No GitHub Actions, no secrets.

---

## Deploy to App Store (iOS)

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Choose your **Team** and set a unique **Bundle Identifier** (e.g. `com.yourcompany.weather`).
4. Add app icon and launch screen if needed.
5. Build and archive:
   ```bash
   flutter build ipa
   ```
6. Upload the `.ipa` via Xcode Organizer or Transporter, then submit in App Store Connect.

## Deploy to Play Store (Android)

1. Create a signing keystore (one time):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (do not commit; add to `.gitignore`):
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Build the app bundle:
   ```bash
   flutter build appbundle
   ```
4. Upload the `.aab` from `build/app/outputs/bundle/release/` in Play Console.

## Project structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/    # Open-Meteo API URLs (no key)
│   └── theme/
├── models/        # Weather, forecast, location
├── services/      # Weather (Open-Meteo), location, geocoding
└── features/
    ├── weather/   # Main screen, provider, weather icon
    └── search/    # City search
```

## License

MIT
