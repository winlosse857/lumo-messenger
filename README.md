# Lumo

Lumo is an Android-first messenger prototype built with Flutter and Dart.

## Current status

**v0.1 — UI foundation**

- Dark interface with cyan and violet accents
- Bottom navigation: Chats, Contacts, Settings, Profile
- Empty chat state and initial screen layout
- No real messaging or account system is connected yet

## Tech stack

- Flutter
- Dart
- Material 3

Firebase (authentication, database, and file storage) may be integrated in a later phase after the UI foundation is tested.

## Run locally

1. Install the Flutter SDK and Android Studio.
2. Clone this repository:
   ```bash
   git clone https://github.com/winlosse857/lumo-messenger.git
   cd lumo-messenger
   ```
3. Generate the Android platform scaffolding (the repository currently contains the Flutter app source):
   ```bash
   flutter create . --platforms=android
   ```
4. Fetch packages and run:
   ```bash
   flutter pub get
   flutter run
   ```

## Project structure

```
lib/
  main.dart
pubspec.yaml
```

## Roadmap

- [ ] Android app shell and visual identity
- [ ] Registration and sign-in
- [ ] User profiles and contacts
- [ ] One-to-one messaging
- [ ] Image and file sharing
- [ ] Group chats
- [ ] Push notifications
- [ ] Security and privacy review

## License

No license has been added yet. Until one is chosen, all rights are reserved by the repository owner.
