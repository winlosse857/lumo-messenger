# Lumo

Lumo is an Android-first messenger prototype built with Flutter and Dart.

## Current status

**v0.2 — Firebase Authentication foundation**

- Dark interface with cyan and violet accents
- Email/password registration and sign-in screens
- Firebase Authentication session handling
- Profile screen with account email and sign-out
- Chat list is still a UI placeholder; messaging is not connected yet

## Tech stack

- Flutter / Dart
- Firebase Core
- Firebase Authentication

## Firebase setup

1. Install Flutter and Android Studio.
2. Create a Firebase project in the Firebase console.
3. Add an Android app to that Firebase project. Use the Android application ID from your generated Android project.
4. Enable **Email/Password** under Firebase Authentication → Sign-in method.
5. From the project root, install and run the FlutterFire tools:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Select your Firebase project and Android platform. This generates `lib/firebase_options.dart`.
6. Fetch packages and run:

   ```bash
   flutter pub get
   flutter run
   ```

The generated `firebase_options.dart` contains project-specific identifiers and is intentionally not committed here. Do not put service-account credentials or private keys in the mobile app.

## Generate Android project files

This repository currently contains the Flutter source but not the native Android wrapper. If needed, generate it before configuring Firebase:

```bash
flutter create . --platforms=android
```

## Roadmap

- [x] Initial dark UI and navigation
- [x] Email/password authentication foundation
- [ ] User profiles stored in Firestore
- [ ] Contacts and one-to-one messaging
- [ ] Image and file sharing
- [ ] Group chats
- [ ] Push notifications
- [ ] Security and privacy review

## License

No license has been added yet. Until one is chosen, all rights are reserved by the repository owner.
