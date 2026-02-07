# Roomix - PG Finder & Roommate Matcher

A cross-platform Flutter application for finding PG accommodations and matching with compatible roommates.

## Overview

Roomix helps students and professionals:
- Search for PG accommodations with advanced filtering
- Find and connect with compatible roommates
- Save favorite listings and profiles  
- Message other users directly
- Get real-time push notifications
- Manage user preferences and bookmarks

## Technology Stack

**Frontend**: Flutter 3.16.5+ | Provider | Firebase | Cloudinary  
**Backend**: Node.js + Express | MongoDB | Firebase Admin SDK | Cloudinary  
**Maps**: MapMyIndia APIs | Static Maps | Geocoding  
**Platforms**: Android | iOS | Web | Windows  

## Directory Structure

```
roomix/
├── lib/                    # Flutter app source code
│   ├── main.dart          # App entry point
│   ├── screens/           # UI pages/screens
│   ├── services/          # API & Firebase services
│   ├── providers/         # State management (Provider)
│   ├── models/            # Data models
│   ├── widgets/           # Reusable UI components
│   └── constants/         # Configuration & constants
├── android/               # Android native code
├── ios/                   # iOS native code
├── web/                   # Web resources
├── backend/               # Node.js/Express API server
│   ├── server.js
│   ├── config/            # Database configuration
│   ├── controllers/       # API request handlers
│   ├── models/            # Data schemas
│   ├── routes/            # API endpoints
│   └── package.json
├── pubspec.yaml           # Flutter dependencies
└── assets/                # Images & resources
```

## Features

- **Authentication**: Email/Password, Google Sign-In
- **Room Search**: Advanced filtering, search, ratings & reviews
- **Roommate Matching**: Compatibility scoring, user profiles
- **Bookmarks**: Save and manage favorite listings
- **Messaging**: Direct chat with other users
- **Notifications**: Real-time FCM push notifications
- **Events**: Create and manage campus events
- **Lost & Found**: Post and search for lost items
- **Marketplace**: Buy/sell items section
- **User Profiles**: Account settings and preferences

## Setup & Quick Start

### Prerequisites
- Flutter SDK 3.16.5+
- Android Studio or Xcode
- Node.js & npm
- Firebase Project

### Run Flutter App
```bash
flutter pub get
flutter run
```

### Run Backend
```bash
cd backend
npm install
npm start
```

## Build & Deployment

- **Android Build**: See `buildonandroid.txt` for detailed Android Studio build instructions
- **Web Deployment (Vercel)**: See `buildvercel.txt` for step-by-step Vercel deployment guide

## Environment Variables

**Backend** (.env file):
```
MONGO_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_key
CLOUDINARY_API_SECRET=your_cloudinary_secret
MAIL_USER=your_email
MAIL_PASS=your_email_password
```

**Flutter** (MapMyIndia API):
```bash
flutter run --dart-define=MAPMYINDIA_API_KEY=39d53f99a81043a0a39c99c71b798d5d
```

## Files

- `README.md` - Project overview (this file)
- `buildonandroid.txt` - Android build guide
- `buildvercel.txt` - Vercel web deployment guide
- `LICENSE` - MIT License

---

For build instructions, see `buildonandroid.txt` (Android) or `buildvercel.txt` (Web/Vercel).

