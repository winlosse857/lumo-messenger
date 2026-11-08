# Lumo

Android-first messenger prototype built with Flutter and Dart.

## Current status

**v0.3 — Phone authentication foundation**

- Dark interface with cyan and violet accents
- Phone-number registration and sign-in using SMS verification
- Firebase Authentication session handling
- Profile displays the verified phone number
- Chat list is a UI placeholder; messaging is not connected yet

## Firebase setup

1. Create a Firebase project and add your Android app.
2. In Firebase Console, open **Authentication → Sign-in method** and enable **Phone**.
3. Check SMS region settings, quotas, and any billing requirements for your Firebase plan.
4. Install FlutterFire CLI and configure the app:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Select the Firebase project and Android platform. This generates `lib/firebase_options.dart`.
5. Run:

   ```bash
   flutter pub get
   flutter run
   ```

This repository does not include the generated `firebase_options.dart` or Android native wrapper. If needed, generate Android files with `flutter create . --platforms=android` before configuring FlutterFire. Do not commit service-account credentials or private keys.

## Roadmap

- [x] Initial dark UI and navigation
- [x] Phone-number authentication foundation
- [ ] User profiles stored in Firestore
- [ ] Contacts and one-to-one messaging
- [ ] Image and file sharing
- [ ] Group chats
- [ ] Push notifications
- [ ] Security and privacy review

## License

No license has been added yet. Until one is chosen, all rights are reserved by the repository owner.
