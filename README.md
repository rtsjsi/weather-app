# Weather

A cross-platform weather app built with Flutter for **Android**, **iOS**, and **Web**, ready to ship to App Store and Play Store.

## Features

- **Current weather** — Temperature, condition, feels-like, humidity, wind
- **5-day forecast** — Daily outlook
- **City search** — Search by city name
- **Current location** — Use device GPS (with permission)
- **Pull to refresh** — Update weather data
- **Light & dark theme** — Follows system setting

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.5.0+)
- [OpenWeatherMap API key](https://openweathermap.org/api) (free tier: 1,000 calls/day)
- For release builds: Android Studio (Android), Xcode (iOS, macOS only)

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Get an OpenWeatherMap API key** from https://openweathermap.org/api

3. **Run the app** (defaults to your connected device or Chrome for web):
   ```bash
   flutter run --dart-define=WEATHER_API_KEY=your_api_key_here
   ```
   **Web:** run in Chrome or Edge:
   ```bash
   flutter run -d chrome --dart-define=WEATHER_API_KEY=your_api_key_here
   ```
   **Build for web** (output in `build/web/`):
   ```bash
   flutter build web --dart-define=WEATHER_API_KEY=your_api_key_here
   ```

## Project structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/    # API URL, app name, API key (dart-define)
│   └── theme/     # Light/dark theme
├── models/        # Weather, forecast, location
├── services/      # Weather API, location, geocoding
└── features/
    ├── weather/   # Main screen, provider, weather icon
    └── search/    # City search screen
```

## Deploy to Vercel (Web)

1. **One-time:** Create a Vercel account and a project (e.g. import this repo and cancel the first build, or run locally: `flutter build web --dart-define=WEATHER_API_KEY=xxx`, then `cd build/web && npx vercel` and follow the prompts). Copy your **Project ID** and **Org ID** from the project’s Settings → General.

2. **GitHub repo secrets** (Settings → Secrets and variables → Actions):  
   - `WEATHER_API_KEY` — OpenWeatherMap API key  
   - `VERCEL_TOKEN` — Vercel → Settings → Access Tokens → Create  
   - `VERCEL_ORG_ID` — Team/org ID (optional; for consistent project linking)  
   - `VERCEL_PROJECT_ID` — Project ID (optional; for consistent project linking)

3. **Push to `main`** — the GitHub Action builds Flutter web and deploys to Vercel.

**Manual deploy:** Build locally, then deploy the output folder:
```bash
flutter build web --release --dart-define=WEATHER_API_KEY=your_key
cd build/web && npx vercel --prod
```

## Deploy to App Store (iOS)

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Choose your **Team** (Apple Developer account) and set a unique **Bundle Identifier** (e.g. `com.yourcompany.weather`).
4. Add app icon and launch screen assets in **Runner/Assets.xcassets** and **LaunchScreen.storyboard** if needed.
5. Build and archive:
   ```bash
   flutter build ipa --dart-define=WEATHER_API_KEY=your_key
   ```
6. Open the generated `.ipa` in Xcode (**Window → Organizer**) or use **Transporter** to upload to App Store Connect.
7. In App Store Connect, create the app, fill metadata, and submit for review.

**Note:** Location usage is already declared in `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription`).

## Deploy to Play Store (Android)

1. **Create a signing keystore** (once per app):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`** (do not commit; add to `.gitignore`):
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
   Place `upload-keystore.jks` in `android/app/` or set `storeFile` to its path.

3. **Build app bundle:**
   ```bash
   flutter build appbundle --dart-define=WEATHER_API_KEY=your_key
   ```

4. **Upload to Play Console:** Use the `.aab` from `build/app/outputs/bundle/release/`. Create the app in Play Console, set store listing, and submit for review.

**Note:** Permissions (`INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) are already in `android/app/src/main/AndroidManifest.xml`.

## API key security

- Do **not** commit your API key.
- Use `--dart-define=WEATHER_API_KEY=xxx` when running or building.
- In CI/CD, use environment variables or a secrets manager and pass the key via `--dart-define`.

## Version and identifiers

- **Version:** Set in `pubspec.yaml` (`version: 1.0.0+1` → name `1.0.0`, build number `1`).
- **Android:** `applicationId` in `android/app/build.gradle` (default: `com.weatherapp.weather_app`). Change if you need a unique package name for the Play Store.
- **iOS:** Bundle ID in Xcode (default: `com.weatherapp.weatherApp`). Must be unique for the App Store.

## License

MIT
