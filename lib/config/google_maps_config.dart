/// Google Maps (native SDK) **requires** API keys on iOS and Android.
/// Without them, iOS often **crashes the whole app** as soon as [GoogleMap] is built.
///
/// **Before setting this to `true`:**
/// - **iOS:** Add `GMSApiKey` in `ios/Runner/Info.plist` (Maps SDK for iOS enabled in Google Cloud).
/// - **Android:** Add `com.google.android.geo.API_KEY` in `android/app/src/main/AndroidManifest.xml`.
///
/// Keep `false` until both are set — then the delivery screen uses a safe placeholder instead of [GoogleMap].
const bool kGoogleMapsEnabled = false;
