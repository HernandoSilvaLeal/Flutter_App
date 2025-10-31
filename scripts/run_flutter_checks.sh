#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Ejecutando: flutter pub get"
if command -v flutter >/dev/null 2>&1; then
  flutter pub get | tee flutter_pub_get.log
  echo "flutter pub get completado (ver flutter_pub_get.log)"
else
  echo "ERROR: 'flutter' no está en PATH. Instala Flutter y vuelve a intentarlo." | tee flutter_pub_get.log
fi

echo "\nEjecutando: flutter doctor --summary"
if command -v flutter >/dev/null 2>&1; then
  flutter doctor --summary | tee flutter_doctor_summary.log
  echo "flutter doctor completado (ver flutter_doctor_summary.log)"
else
  echo "ERROR: 'flutter' no está en PATH. Instala Flutter y vuelve a intentarlo." | tee flutter_doctor_summary.log
fi

echo "Logs generados en: $ROOT/flutter_pub_get.log y $ROOT/flutter_doctor_summary.log"

exit 0
