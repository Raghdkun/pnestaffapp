// Firebase options for the PNE Staff App (project: staffapp-d0c7d).
// Authored from the google-services.json / GoogleService-Info.plist provided by
// the Firebase console. Re-run `flutterfire configure` to regenerate if the
// Firebase project or registered apps change.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform. `bootstrap` passes
/// `DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp` inside a
/// guard, so unconfigured platforms simply run without push.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ignore: no_default_cases
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOTpRFUiw6T0syr-xvLdxS4h3PuxzvfOs',
    appId: '1:848843009018:android:f6dbb182dec8b73e0ad243',
    messagingSenderId: '848843009018',
    projectId: 'staffapp-d0c7d',
    storageBucket: 'staffapp-d0c7d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDPSrdMijyRhk8k3EI4nDQYb9iAhd53iwY',
    appId: '1:848843009018:ios:523a5664b00e3a3f0ad243',
    messagingSenderId: '848843009018',
    projectId: 'staffapp-d0c7d',
    storageBucket: 'staffapp-d0c7d.firebasestorage.app',
    iosBundleId: 'com.pneunited.pnestaffapp',
  );
}
