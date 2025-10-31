#!/usr/bin/env bash
# Start script for local development (Flutter web)
flutter clean
flutter pub get
flutter run -d chrome
