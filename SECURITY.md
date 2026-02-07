# Security Guidelines - Roomix Project

## Critical Security Fixes Implemented

### 1. ✅ Backend Secrets Management

**Status**: FIXED - `backend/.env` is now excluded from version control

**What was done:**
- Removed `backend/.env` from git history (credentials exposed)
- Added `backend/.env` to `.gitignore` (prevents future commits)
- Created `backend/.env.example` with placeholder values only
- Verified all config files use `process.env` to read secrets

**What you must do NOW:**
1. **Rotate all credentials immediately:**
   ```bash
   # Database: Change MongoDB password in MongoDB Atlas
   # JWT: Generate new secret
   openssl rand -base64 32
   
   # Cloudinary: Regenerate API key in Cloudinary dashboard
   # Gmail: Generate new app password (via account.google.com)
   ```

2. **Update production environment variables:**
   - Backend server environment > Add new `MONGO_URI` with new password
   - Add new `JWT_SECRET` 
   - Add new `CLOUDINARY_API_KEY` and `CLOUDINARY_API_SECRET`
   - Add new `MAIL_PASS` (Gmail app password)

3. **Never commit secrets:**
   - Always use `.env.example` as template
   - Copy to `.env` and fill with real values
   - `.env` is in `.gitignore` and should never be committed

---

### 2. ✅ Map API Key Consistency

**Status**: FIXED - Updated all references from TomTom to MapMyIndia

**What was changed:**
- `dart-defines.json`: Updated to use `MAPMYINDIA_API_KEY` (was `TOMTOM_API_KEY`)
- `.env.example`: Updated to use `MAPMYINDIA_API_KEY` (was `TOMTOM_API_KEY`)
- Code already uses MapMyIndia consistently
- Build commands now reference correct key name

**Files updated:**
- ✅ `dart-defines.json`
- ✅ `.env.example`
- ✅ `lib/services/map_service.dart` (already correct)
- ✅ `android/app/build.gradle.kts` (already correct)
- ✅ `android/app/src/main/AndroidManifest.xml` (already correct)

**Build commands now use:**
```bash
# Development
flutter run --dart-define=MAPMYINDIA_API_KEY=39d53f99a81043a0a39c99c71b798d5d

# Android release
flutter build apk --release --dart-define=MAPMYINDIA_API_KEY=39d53f99a81043a0a39c99c71b798d5d

# Web release
flutter build web --release --dart-define=MAPMYINDIA_API_KEY=39d53f99a81043a0a39c99c71b798d5d
```

---

### 3. ✅ Firebase Configuration

**Status**: FIXED - Created `firebase_options.dart` and updated `main.dart`

**What was done:**
- Created `lib/firebase_options.dart` with platform-specific Firebase configs
- Updated `lib/main.dart` to use `DefaultFirebaseOptions.currentPlatform`
- Added proper error handling for Firebase initialization
- Environment variables properly configured for web

**Setup required:**

1. **Get Firebase credentials** (from Firebase Console):
   - Go to: https://console.firebase.google.com
   - Project Settings > Your apps > Web
   - Copy all 6 values:
     - API Key
     - Auth Domain
     - Project ID
     - Storage Bucket
     - Messaging Sender ID
     - App ID

2. **Update `lib/firebase_options.dart`:**
   - Replace placeholder values in `web` constant with real credentials
   - Ensure `android`, `ios`, `macos`, `windows` constants have real values

3. **Pass credentials when building:**
   ```bash
   # Web deployment
   flutter build web --release \
     --dart-define=FIREBASE_API_KEY=YOUR_API_KEY \
     --dart-define=FIREBASE_AUTH_DOMAIN=YOUR_AUTH_DOMAIN \
     --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT_ID \
     --dart-define=FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID \
     --dart-define=FIREBASE_APP_ID=YOUR_APP_ID
   ```

4. **For Android/iOS:**
   - Ensure `google-services.json` is in `android/app/`
   - Ensure `GoogleService-Info.plist` is in `ios/Runner/`
   - Run: `flutterfire configure`

5. **Add authorized domains** (Firebase Console):
   - Authentication > Settings > Authorized domains
   - Add: `localhost:8000` (development)
   - Add: `roomix-username.vercel.app` (Vercel)
   - Add: Your custom domain

---

## File Structure - No Secrets in Repository

```
roomix/
├── backend/
│   ├── .env            ← ⛔ EXCLUDED from git (.gitignore)
│   └── .env.example    ← ✅ Template with placeholders only
│
├── lib/
│   ├── firebase_options.dart    ← Configs with env var fallbacks
│   └── main.dart                ← Platform-specific initialization
│
├── .env.example        ← Template for Flutter env vars
├── dart-defines.json   ← Build-time constants reference
└── ... rest of project
```

---

## Checklist Before Deployment

### Credentials
- [ ] All production secrets in `.env` (not committed)
- [ ] MongoDB password rotated
- [ ] JWT secret rotated  
- [ ] Cloudinary keys rotated
- [ ] Gmail app password updated
- [ ] Firebase credentials obtained and stored in `firebase_options.dart`

### Environment Variables
- [ ] Backend server has all required env vars
- [ ] CI/CD has secrets in environment variables (not in code)
- [ ] Build commands include `--dart-define` flags for sensitive keys
- [ ] Web builds pass Firebase credentials via dart-defines

### Firebase Setup
- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Firebase project created and apps registered
- [ ] Authorized domains added for web URLs
- [ ] Firestore security rules configured
- [ ] Authentication methods enabled (Email/Password, Google)

### API Consistency
- [ ] All map references use `MAPMYINDIA_API_KEY`
- [ ] Build commands use correct dart-defines
- [ ] `.env.example` has all required variables
- [ ] Documentation updated with current API key names

---

## Emergency: Credentials Leaked

If you accidentally commit credentials:

1. **Immediately rotate the key:**
   ```bash
   # Generate new JWT secret
   openssl rand -base64 32
   
   # Regenerate MongoDB password
   # Regenerate Cloudinary API Key
   # Generate new Gmail app password
   ```

2. **Remove from git history:**
   ```bash
   # Remove file from history (careful: irreversible)
   git filter-branch --tree-filter 'rm -f backend/.env' HEAD
   git push --force
   ```

3. **Update all services with new credentials**

4. **Document in git commit message** what was done

---

## Regular Security Maintenance

- [ ] Review `.gitignore` quarterly (ensure secrets excluded)
- [ ] Rotate API keys every 6 months
- [ ] Audit Firebase security rules monthly
- [ ] Check for hardcoded secrets: `grep -r "secret\|password\|key" lib/`
- [ ] Update dependencies: `flutter pub upgrade`
- [ ] Enable 2FA on all service accounts

---

## References

- Firebase Security: https://firebase.google.com/docs/rules
- Environment Variables: https://12factor.net/config
- OWASP Secrets: https://owasp.org/www-project-top-ten/
- Git Security: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
