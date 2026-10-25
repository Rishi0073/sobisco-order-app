# Sobisco Order App (Flutter)

Amazon-style wholesale order app for Sobisco distributor. Same features as the
HTML version, rebuilt in Flutter (Android / Web).

## Features
- All 99 products with **stock levels** from the Abhirami sheet (9 JUL).
  Out-of-stock items shown in red; toggle **"In stock only"** to hide them.
- Search by code or name, category tabs (Biscuits / Cakes / Toast / Noodles).
- **Box** + **Chain** quantity steppers on every product card.
- Cart saved on device (survives app restart) via `shared_preferences`.
- Shop name field with **autocomplete** from previously used shops.
- **WhatsApp** export (`url_launcher`) with date + totals summary.
- **Copy** order to clipboard, **Clear cart**, clear-after-send prompt.
- No prices anywhere.

## Run
```bash
cd sobisco_order
flutter pub get
flutter run            # runs on a connected device/emulator, or chrome
```

## Build an installable Android APK (for the phone)
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```
Copy that `app-release.apk` to the phone and install it.

## Build for web
```bash
flutter build web      # output: build/web/
```

## Updating stock
Edit the `kProducts` list in `lib/main.dart` — change the third value
(the stock box count) for any product. `0` marks it out of stock.
