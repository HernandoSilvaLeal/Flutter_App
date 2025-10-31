# Flutter_App

Este repositorio contiene un scaffold mínimo para el demo "Citas MVP" (Flutter + Firebase).

Runbook rápido (minuto a minuto)

T-60 → T-50: Proyecto base + dependencias
1. Crear proyecto Flutter:

	 flutter create cita_mvp
	 cd cita_mvp
	 git init && git add . && git commit -m "chore: flutter scaffold"
	 flutter pub add firebase_core firebase_auth cloud_firestore intl

Android (Firebase)

- Crear proyecto en Firebase Console.
- Añadir app Android (usar applicationId de android/app/build.gradle).
- Descargar google-services.json → colocar en android/app/.
- Añadir en android/build.gradle:

	dependencies { classpath 'com.google.gms:google-services:4.3.15' }

- Añadir en android/app/build.gradle:

	apply plugin: 'com.google.gms.google-services'

T-50 → T-40: Bootstrap de app (ya incluído en `lib/main.dart`)

T-40 → T-30: Modelos y seed (`lib/src/data/models.dart`, `lib/src/data/services_seed.dart`)

T-30 → T-20: Auth + Router (`lib/src/auth/auth_screen.dart`, `lib/src/home/home_router.dart`)

T-20 → T-10: Cliente (`lib/src/client/client_home.dart`)

T-10 → T-0: Prestador (`lib/src/provider/provider_home.dart`)

Reglas Firestore (demo seguras)

Pegar en Firestore Rules (console):

rules_version = '2';
service cloud.firestore {
	match /databases/{db}/documents {
		function signedIn(){ return request.auth!=null; }
		function isClient(){ return signedIn() && get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role=="client"; }
		function isProvider(){ return signedIn() && get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role=="provider"; }

		match /users/{uid} { allow read, write: if signedIn() && request.auth.uid==uid; }
		match /appointments/{id} {
			allow create: if isClient() && request.resource.data.clientId==request.auth.uid;
			allow read: if (isClient() && resource.data.clientId==request.auth.uid)
							 || (isProvider() && resource.data.providerId in ["", request.auth.uid]);
			allow update: if (isClient() && resource.data.clientId==request.auth.uid)
								 || (isProvider() && (resource.data.providerId in ["", request.auth.uid]));
			allow delete: if false;
		}
	}
}

Comandos finales

	flutter run
	# Para APK rápida:
	flutter build apk --debug

Guion corto demo (90s)

1. Registrar cliente → login → elegir servicio → agendar fecha/hora → “Cita creada”.
2. Cerrar sesión → login como prestador → ver “Pendientes” → Aceptar.
3. Mostrar “Mis citas (prestador)” con estado accepted.

Prompts cortos para Copilot (usar tal cual)

AuthScreen:

"Generate a Flutter StatefulWidget AuthScreen with email/password login and sign up, fields: name, phone (only on sign up), role dropdown (client/provider). On signup create user doc in Firestore (users/{uid}). Minimal UI, single file."

HomeRouter:

"Create a HomeRouter widget that streams Firestore users/{uid} and routes to ProviderHome or ClientHome based on role."

ClientHome:

"Build ClientHome with dropdown of 4 local services, date+time picker, button to create appointment in Firestore (status=pending, providerId=''), and a StreamBuilder list of my appointments ordered by scheduledFor."

ProviderHome:

"Build ProviderHome with two lists: pending (status=pending and providerId in ['', myUid]) and mine (providerId=myUid, status in [accepted,pending]). Buttons to accept (set providerId=myUid, status=accepted) or reject."

Plan B si Firebase falla

Si Firebase da problemas: simular datos en memoria para la demo visual y mover la integración Firebase a la rama `feature/firebase`.

