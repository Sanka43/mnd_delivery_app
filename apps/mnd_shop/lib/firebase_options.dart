// Same Firebase project as mnd_customer. Register Android app
// com.mnd.delivery.mnd_shop in Firebase Console if you use a dedicated app ID.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdlFujMKRnSui11__e28Amz_v8WW6i_UA',
    appId: '1:856195988916:web:REPLACE_WITH_WEB_APP_ID_FROM_FIREBASE_CONSOLE',
    messagingSenderId: '856195988916',
    projectId: 'masterndelivery-3cb92',
    authDomain: 'masterndelivery-3cb92.firebaseapp.com',
    storageBucket: 'masterndelivery-3cb92.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdlFujMKRnSui11__e28Amz_v8WW6i_UA',
    appId: '1:856195988916:android:a3ce0765a6335a35c986e1',
    messagingSenderId: '856195988916',
    projectId: 'masterndelivery-3cb92',
    storageBucket: 'masterndelivery-3cb92.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdlFujMKRnSui11__e28Amz_v8WW6i_UA',
    appId: '1:856195988916:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '856195988916',
    projectId: 'masterndelivery-3cb92',
    storageBucket: 'masterndelivery-3cb92.firebasestorage.app',
    iosBundleId: 'com.mnd.delivery.mndShop',
  );
}
