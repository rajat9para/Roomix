# Roomix (PG Finder App)

Roomix is a Flutter + Node.js application that helps students find PGs/rooms, messes, utilities, events, and roommates around campus. It includes authentication, profiles, marketplace, lost & found, chat, and a campus map experience powered by TomTom static maps.

## Key Features
- Room/PG listings with images and contact actions
- Mess menus and services
- Lost & found posts
- Events and marketplace
- Roommate finder with profiles and chat
- Utilities directory with categories and reviews
- Campus map with TomTom static map previews and filtering

## Tech Stack
- Frontend: Flutter (Provider, Dio, GoRouter)
- Backend: Node.js + Express + MongoDB (Mongoose)
- Auth: Firebase + JWT
- Maps: TomTom Static Map + Search + Geocoding APIs
- Media: Cloudinary

## Project Structure (High Level)
- `lib/` Flutter app source
- `backend/` Node.js API server
- `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/` platform targets

## How the Map Works
The app uses TomTom REST APIs (static maps and search). This avoids embedding the native SDK in Flutter while keeping map previews and marker rendering stable.

TomTom API key is referenced in:
- `lib/services/map_service.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Build Notes (Android Studio)
See `buildonandstd.txt` for complete Android Studio setup, build, and troubleshooting steps.

## Local Development (Quick)
1. Start backend API:
   - `cd backend`
   - `npm install`
   - `npm start`
2. Run Flutter app:
   - `flutter pub get`
   - `flutter run`

## Environment Variables (Backend)
Set these in a `.env` file inside `backend/`:
- `MONGO_URI`
- `JWT_SECRET`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`
- `MAIL_USER`
- `MAIL_PASS`
- `FIREBASE_PROJECT_ID` (optional, default already set)

