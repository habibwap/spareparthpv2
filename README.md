# Sparepart Stock (Flutter + Firebase)

A simple app for managing phone sparepart stock with **categories (folders)** and **items**. 
Data is stored per Google account using **Firebase Authentication (Google Sign-In)** and **Cloud Firestore**.

## Features
- Login with Google
- Category list (LCD, Baterai, Tombol, dll)
- Sparepart CRUD inside each category (name, stock, buy price)
- Live sync to Firestore, offline capable
- Simple report (total stock value per category)

## Quick Start

1. **Install Flutter & Dart** (3.3+).  
2. **Create a Firebase project** at https://console.firebase.google.com
3. Enable **Authentication → Google** sign-in method.
4. Enable **Cloud Firestore** (in production or test mode as you wish).
5. Add Android app (and optionally iOS) to Firebase and download **google-services.json** (Android).
6. Add the file to: `android/app/google-services.json`.
7. Run **FlutterFire** to generate `lib/firebase_options.dart`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

> This will create `lib/firebase_options.dart`. The code imports it.

8. Update **Gradle** config as shown in the included files (`android/build.gradle` and `android/app/build.gradle`). 
9. Run the app:

```bash
flutter pub get
flutter run
```

## Firestore Data Model

```
users (collection)
 └─ {userId} (document)
    └─ categories (collection)
       └─ {categoryId} (document: { name, createdAt })
          └─ spareparts (collection)
             └─ {sparepartId} (document: { name, stock, price, createdAt })
```

## Notes
- You must add your own Firebase config files; the project won't run without them.
- Offline persistence is enabled by default in the Firestore Flutter SDK.