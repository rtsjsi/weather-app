# Weather App

A cross-platform weather information app built with Flutter. Targets Android (Play Store) first, with iOS (App Store) support in phase 2.

## Features

- **Current weather** - Temperature, condition, humidity, wind for your location
- **5-day forecast** - Basic outlook
- **Location search** - Search by city name
- **Auto-detect location** - Use device GPS for default view
- **Offline messaging** - Clear error messages when network is unavailable

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.5.0 or higher)
- [OpenWeatherMap API key](https://openweathermap.org/api) (free tier: 1,000 calls/day)
- Android Studio / Xcode for building

## Setup

1. **Clone or navigate to the project:**
   ```bash
   cd D:\Cursor_Projects\weather-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Get an OpenWeatherMap API key:**
   - Sign up at https://openweathermap.org/api
   - Copy your API key

4. **Run the app** (pass your API key):
   ```bash
   flutter run --dart-define=WEATHER_API_KEY=your_api_key_here
   ```

   Or for Android release build:
   ```bash
   flutter build appbundle --dart-define=WEATHER_API_KEY=your_api_key_here
   ```

## Project Structure

```
lib/
├── main.dart              # App entry
├── app.dart               # Root widget, providers
├── core/
│   ├── theme/             # App theme
│   └── config/            # Constants, API config
├── features/
│   ├── weather/           # Weather screen, provider
│   └── search/            # City search
├── services/              # API, location, geocoding
└── models/                # Data models
```

## Android Release (Play Store)

1. **Create a signing keystore:**
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`** (add to .gitignore):
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```

3. **Update `android/app/build.gradle`** to use signing config for release.

4. **Build app bundle:**
   ```bash
   flutter build appbundle --dart-define=WEATHER_API_KEY=your_key
   ```

5. **Play Console:** Upload the `.aab` from `build/app/outputs/bundle/release/`

## iOS Release (Phase 2)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing with your Apple Developer account
3. Build: `flutter build ipa --dart-define=WEATHER_API_KEY=your_key`
4. Upload via Xcode Organizer or Transporter

## API Key Security

Never commit your API key. Use:
- `--dart-define=WEATHER_API_KEY=xxx` at build/run time
- Or environment variables in CI/CD
- Or a secrets management solution for production

## License

MIT
