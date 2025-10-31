#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_BUILD="$ROOT/android/build.gradle"
APP_BUILD="$ROOT/android/app/build.gradle"
GS_JSON="$ROOT/android/app/google-services.json"

echo "Configurador de Firebase Android — comprobando archivos..."

if [ ! -d "$ROOT/android" ]; then
  echo "ERROR: No existe la carpeta android/. Ejecuta 'flutter create .' en la raíz del proyecto y vuelve a ejecutar este script." >&2
  exit 2
fi

if [ ! -f "$ANDROID_BUILD" ]; then
  echo "ERROR: $ANDROID_BUILD no encontrado." >&2
  exit 2
fi

if [ ! -f "$APP_BUILD" ]; then
  echo "ERROR: $APP_BUILD no encontrado." >&2
  exit 2
fi

echo "1) Añadiendo classpath 'com.google.gms:google-services:4.3.15' si falta..."
if grep -q "com.google.gms:google-services" "$ANDROID_BUILD"; then
  echo " - classpath ya presente"
else
  awk '/dependencies \{/ && c==0 {print; print "        classpath \"com.google.gms:google-services:4.3.15\""; c=1; next} {print}' "$ANDROID_BUILD" > "$ANDROID_BUILD.tmp" && mv "$ANDROID_BUILD.tmp" "$ANDROID_BUILD"
  echo " - classpath añadido"
fi

echo "2) Verificando android/app/build.gradle: minSdkVersion >=21, compileSdkVersion >=34, plugin google-services"

# Ensure compileSdkVersion >=34
if grep -q "compileSdkVersion [0-9]\+" "$APP_BUILD"; then
  cur=$(grep -oE "compileSdkVersion [0-9]+" "$APP_BUILD" | head -1 | grep -oE "[0-9]+")
  if [ "$cur" -lt 34 ]; then
    echo " - Actualizando compileSdkVersion $cur -> 34"
    sed -E -i "s/compileSdkVersion [0-9]+/compileSdkVersion 34/" "$APP_BUILD"
  else
    echo " - compileSdkVersion ok ($cur)"
  fi
else
  echo " - No se encontró compileSdkVersion; por favor añade compileSdkVersion 34 en android/app/build.gradle" >&2
fi

# Ensure minSdkVersion >=21
if grep -q "minSdkVersion [0-9]\+" "$APP_BUILD"; then
  cur=$(grep -oE "minSdkVersion [0-9]+" "$APP_BUILD" | head -1 | grep -oE "[0-9]+")
  if [ "$cur" -lt 21 ]; then
    echo " - Actualizando minSdkVersion $cur -> 21"
    sed -E -i "s/minSdkVersion [0-9]+/minSdkVersion 21/" "$APP_BUILD"
  else
    echo " - minSdkVersion ok ($cur)"
  fi
else
  echo " - No se encontró minSdkVersion; por favor añade minSdkVersion 21 en defaultConfig de android/app/build.gradle" >&2
fi

# Enable multiDex if not present
if grep -q "multiDexEnabled true" "$APP_BUILD"; then
  echo " - multiDexEnabled ya habilitado"
else
  echo " - Habilitando multiDexEnabled true en defaultConfig"
  awk '/defaultConfig \{/{print; print "        multiDexEnabled true"; f=1; next} {print}' "$APP_BUILD" > "$APP_BUILD.tmp" && mv "$APP_BUILD.tmp" "$APP_BUILD"
fi

# Add apply plugin at end if missing
if grep -q "com.google.gms.google-services" "$APP_BUILD"; then
  echo " - google-services plugin ya aplicado"
else
  echo "apply plugin: 'com.google.gms.google-services'" >> "$APP_BUILD"
  echo " - plugin google-services añadido al final de android/app/build.gradle"
fi

echo "3) Comprueba google-services.json"
if [ -f "$GS_JSON" ]; then
  echo " - google-services.json encontrado"
else
  echo "# FALTA google-services.json" > "$ROOT/android/app/google-services.json.MISSING.txt"
  echo " - google-services.json NO encontrado. He creado un archivo android/app/google-services.json.MISSING.txt con nota." 
fi

echo "Proceso terminado. Ahora ejecuta en tu máquina:"
echo "  flutter pub get"
echo "  flutter doctor --summary"
echo "  flutter run"

exit 0
