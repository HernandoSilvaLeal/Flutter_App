#!/usr/bin/env bash
set -euo pipefail

echo "Instrucciones para configurar FlutterFire CLI y generar firebase configs (ejecutar localmente)"
echo
echo "1) Instala FlutterFire CLI"
echo "   dart pub global activate flutterfire_cli"
echo
echo "2) Añade dart pub global a PATH si no está (ejemplo Windows):"
echo "   export PATH=\"\$PATH:~/.pub-cache/bin\""
echo
echo "3) Ejecuta FlutterFire configure para web (reemplaza PROJECT_ID):"
echo "   flutterfire configure --project=YOUR_PROJECT_ID --platforms=web"
echo "   # Esto generará lib/firebase_options.dart y web/firebase.json"
echo
echo "4) Luego en la raíz del proyecto ejecuta:" 
echo "   flutter pub get"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run -d chrome"

echo "Si hay errores, pega aquí las últimas 50 líneas del log y los archivos generados lib/firebase_options.dart y web/firebase.json"
