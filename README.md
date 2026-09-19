# ConnectCall — README

> A 1-to-1 audio and video calling app built with Flutter, following Clean Architecture.

---

## 📱 Project Description

**ConnectCall** is a real-time 1-to-1 communication app that lets users sign up, browse contacts, and place or receive audio and video calls. It demonstrates end-to-end Flutter development — UI, state management, navigation, backend integration, and real-time communication via a production-grade calling SDK.

**Tagline:** *Connect with anyone, anywhere.*

---

## ✨ Features

### Authentication
- Email / password login
- Registration with name, email, password, and confirm password
- Persistent session (auto-login on app relaunch)
- Logout

### Users & Contacts
- Browse all registered users
- Online / offline presence indicator
- Search users by name (case-insensitive, debounced)
- View user profile (name, email, online status, avatar)
- Edit profile (display name, profile picture)
- Frequent / recent contacts

### Calling
- **1-to-1 audio call** with mute/unmute, speaker on/off, and end call
- **1-to-1 video call** with mute/unmute, camera on/off, front/rear camera switch, and end call
- Incoming call screen with accept / decline actions
- Call duration timer and connection status indicator
- Reject, missed, busy, ended, and disconnected state handling

### Call History
- Full list of past calls
- Per record: contact name, call type (audio/video), date & time, duration, incoming/outgoing direction, and missed-call indicator

### UI / UX
- Splash screen with logo, app name, and loading state
- Bottom navigation: Contacts · Calls · Profile
- Light theme (dark theme–ready architecture)
- Loading, error, and empty states across all screens
- Responsive layout for phones and tablets
- English localization (i18n-ready for Arabic and other languages)

### Permissions
- Runtime permission requests for microphone and camera
- Graceful handling of granted / denied / permanently denied states
- Redirect to app settings when permission is permanently denied

### Error Handling
- Friendly messages for: no internet, camera denied, mic denied, call connection failure, user offline, call rejected
- No silent crashes; every failure path surfaces a message or retry action
---
## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (stable) |
| Language | Dart |
| State Management | Cubit (`flutter_bloc`) |
| DI | `get_it` + `injectable` |
| Backend | Firebase (Authentication + Cloud Firestore) |
| Calling SDK | Agora RTC Engine *(see "Why Agora" below)* |
| Localization | `flutter_localizations` + ARB files |
| Image Loading | `cached_network_image` |

> **Flutter version:** `3.41.6` (stable channel)  
> **Dart SDK:** `^3.11.4`
---
## 🏗️ Architecture

The app follows **Clean Architecture**, with each feature split into three layers — `data`, `domain`, and `presentation` — under `lib/features/`. Shared concerns live in `lib/config/` (base types, DI, models, entities) and `lib/core/` (resources, routes, theme, permissions, utils).

lib/
├── main.dart
├── firebase_options.dart
│
├── config/
│   ├── base_response/         # BaseResponse<T> — SuccessResponse | ErrorResponse
│   ├── base_state/            # BaseState<T> — isLoading / errorMessage / data
│   ├── di/                    # get_it + injectable setup (di.dart, di.config.dart)
│   ├── entities/              # Pure domain entities (user, contact, call)
│   ├── models/                # DTOs with fromJson / toJson / toEntity
│   └── modules/               # External service modules (Firebase, Agora)
│
├── core/
│   ├── permissions/           # Runtime mic/camera permission handling
│   ├── resources/             # App assets and color tokens
│   ├── routes/                # Route names and route generator
│   ├── theme/                 # ThemeData builder
│   ├── token_generation/      # Agora token helper
│   ├── ui_utils/              # Dialog helpers (loading, messages)
│   └── validators/            # Form field validators
│
├── features/
│   ├── auth/
│   │   ├── login/             # data · domain · presentation
│   │   └── register/          # data · domain · presentation
│   ├── calls/                 # audio, video, incoming, history
│   ├── contacts/              # contacts list
│   ├── home/                  # bottom-nav shell
│   ├── profile/               # view / edit profile, logout
│   ├── search/                # search users
│   └── splash/                # splash + auth-state check
│
└── l10n/
    ├── app_en.arb
    ├── app_localizations.dart
    └── app_localizations_en.dart


Each feature folder follows the same shape:
<feature>/
├── data/
│   ├── data_sources/remote/   # *_remote_data_source_contract.dart + _impl.dart
│   └── repos/                 # *_repo_impl.dart
├── domain/
│   ├── repos/                 # *_repo_contract.dart
│   └── use_cases/             # one file per business action
└── presentation/
    ├── views/
    │   ├── screens/           # *_screen.dart
    │   └── widgets/           # feature-local widgets
    └── view_model/            # *_events.dart · *_states.dart · *_view_model.dart


---

### Layer responsibilities

- **Data** — talks to Firebase / Agora, returns `BaseResponse<T>` (`SuccessResponse` | `ErrorResponse`).
- **Domain** — pure Dart: `Entity` classes, repo contracts, one use case per action.
- **Presentation** — `Cubit` per screen. Each Cubit exposes a `doIntent(Event)` method and emits a `State` derived from `BaseState<T>` (carries `isLoading`, `errorMessage`, `data`).

### Why this structure?
- **Testability** — Use cases and repos are easy to mock.
- **Separation** — UI never touches Firebase or Agora directly.
- **Scalability** — Adding a feature = add a slice across the three layers without touching unrelated code.
---
## 🎨 Theming

The app currently ships with a **light theme only**. The theming layer is structured so a dark theme can be added with minimal impact:

- `core/resources/app_colors.dart` — semantic color tokens (e.g. `primaryColor`, `greyColor`) referenced everywhere instead of hardcoded `Colors.*` values.
- `core/theme/app_theme.dart` — a single `ThemeData` builder; adding a dark variant only requires defining a parallel `ThemeData` and passing it to `MaterialApp.darkTheme` along with a `themeMode`.
- No screen hardcodes raw colors or text styles; every widget pulls from `Theme.of(context)` and `AppColors`.

---

## 🌐 Localization

The app currently ships with **English only**, but is fully wired for additional languages:

- All user-facing strings live in `lib/l10n/app_en.arb` and are accessed via `AppLocalizations.of(context)!.key`.
- `flutter_localizations` is enabled in `MaterialApp`.
- Adding Arabic (or any other language) is a matter of:
  1. Creating `lib/l10n/app_ar.arb` with translated values.
  2. Registering the locale in `l10n.yaml` / `MaterialApp.supportedLocales`.
  3. Nothing else in the codebase needs to change — there are no hardcoded English strings in widgets.
  ---
  ## 🔌 Backend Used

**Firebase** — chosen for zero-ops setup and native Flutter support:

- **Firebase Authentication** — email/password sign-up and sign-in.
- **Cloud Firestore** — collections:
  - `users/{userId}` — profile, presence (`isOnline`, `lastSeen`)
  - `calls/{callId}` — call signaling document (caller, callee, type, status, timestamps)
  - `call_history/{userId}/entries/{entryId}` — per-user history

Presence is maintained by writing `isOnline: true` on sign-in / app resume and `isOnline: false` + `lastSeen` on sign-out / background.

> **Note:** Firestore is currently running in **test mode** — this is intended for development only. Production deployment requires proper security rules (see *Setup Instructions*).
---
## 📞 Calling SDK Used

**Agora RTC Engine** — chosen over WebRTC, ZEGOCLOUD, Stream, and LiveKit for the following reasons:

| Criterion | Why Agora wins here |
|---|---|
| Time to first working call | A working 1-to-1 call is achievable in hours, not days |
| Cross-platform reliability | Consistent behavior on Android and iOS |
| Audio/video controls | Mute, camera toggle, and camera switch are first-class APIs |
| Scalability path | Same SDK extends to group calls with minimal change |
| Flutter support | Official, actively maintained `agora_rtc_engine` package |
| Network quality | Built-in `onRtcStats` and `onNetworkQuality` callbacks |

**Signaling flow:**
1. Caller creates a Firestore doc in `calls/` with `status: 'calling'`, `type: 'audio'|'video'`, a randomly generated `channelName`, and the callee ID.
2. Callee listens on `calls` where `calleeId == myId && status == 'calling'` — a new doc triggers the incoming call screen.
3. On accept, both parties join the Agora channel with the same `channelName`.
4. Either party updates the doc to `status: 'ended'` on hang-up; both clients stop listening and clean up.

**Controls implemented:**
- `muteLocalAudioStream` — mute/unmute
- `enableLocalVideo` / `muteLocalVideoStream` — camera on/off
- `switchCamera` — front/rear toggle
- `enableSpeakerphone` — audio routing (audio call only)
- `leaveChannel` — end call

---
## ⚙️ Setup Instructions

### Prerequisites
- Flutter `3.41.6` stable (or compatible)
- Dart `^3.11.4`
- Android Studio (Android build tested; iOS build requires macOS + Xcode)
- A Firebase project
- An Agora developer account

> **Platform focus:** the app was developed and tested on **Android** (Windows development machine). The codebase is platform-agnostic and iOS builds are supported in principle, but the iOS build has not been verified as part of this deliverable.

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/IslamRamzy444/contacting_app.git
   cd contacting_app
2. **Install dependencies**
   ```bash
   flutter pub get
3. **Configure Firebase**
   - Create a Firebase project in the console.
   - Enable **Email/Password** authentication.
   - Create a **Cloud Firestore** database (start in test mode for development).
   - Add an Android app with your package name and download `google-services.json` → place in `android/app/`.
   - Run:
     ```bash
     flutterfire configure
  - This generates `firebase_options.dart` and wires the app to your project.
4. **Configure Agora**
   - Create an Agora project → get your **App ID** (and a temporary **Token** if you enable token auth).
   - Open `lib/core/token_generation/agora_token_helper.dart` and fill in the values:
     ```dart
     class AgoraTokenHelper {
       static const String appId = '<YOUR_AGORA_APP_ID>';
       static const String appCertificate = '<YOUR_AGORA_APP_CERTIFICATE>';

       static String generate({
         required String channelName,
         required int uid,
         int expirationInSeconds = 3600,
       }) {
         return RtcTokenBuilder.buildTokenWithUid(
           appId: appId,
           appCertificate: appCertificate,
           channelName: channelName,
           uid: uid,
           tokenExpireSeconds: expirationInSeconds,
         );
       }
     }
     ```
    - Also update the App ID in `CallViewModel` (it holds a local copy used when joining a channel):

     ```dart
     // lib/features/calls/presentation/view_model/call_view_model.dart
     static const _agoraAppId = '<YOUR_AGORA_APP_ID>';
     ```
 5. **Firestore security rules**
   For development, the project uses Firestore's **test mode** rules. Before any production deployment, replace them with proper rules, e.g.:
   - A user can read/write only their own profile.
   - A user can read/write call docs only if they are the caller or callee.
   - Call history is readable only by its owner.

   Deploy rules with:
   ```bash
   firebase deploy --only firestore:rules
```
6. **Run the app**
   ```bash
   flutter run
7. **Build an Android APK**
   ```bash
   flutter build apk --release
   # Output: build/app/outputs/flutter-apk/app-release.apk
8. **(Optional) iOS build**
   Requires macOS + Xcode. On a Mac:
   ```bash
   flutter build ipa
> **Note:** Not verified in this deliverable due to the Windows-only development environment.
---
## 🔐 Environment Variables / Configuration

| Key | Location | Notes |
|---|---|---|
| `AGORA_APP_ID` | `lib/core/token_generation/agora_token_helper.dart` | Also mirrored in `CallViewModel._agoraAppId` |
| `AGORA_APP_CERTIFICATE` | `lib/core/token_generation/agora_token_helper.dart` | Used to generate per-channel RTC tokens |
| Firebase config | `google-services.json` / `firebase_options.dart` | Managed by `flutterfire` |

**Recommended for real deployments:** move the Agora App ID and App Certificate out of source and inject them via `--dart-define` or a `.env` file loaded by `flutter_dotenv`, and never commit them.
---
## 📸 Demo

A short screen recording demonstrating the full flow:

📹 [Watch the demo](https://drive.google.com/file/d/1d9arVtaM4fmEAyHjoq443_CuA_sUA5XE/view?usp=sharing)

Covered in the demo:
1. Login
2. User list (Contacts screen)
3. Start audio call
4. Receive call on second device
5. Accept call
6. Mute / unmute
7. End call
8. Start video call
9. Camera on/off + switch camera
10. Call history
---
## 🧠 AI Tools Used

AI assistance was used during development as a **pair-programming aid** — for scaffolding, debugging, refactoring, and documentation. Every AI-generated snippet was read, adapted to this project's architecture (`BaseResponse`, `BaseState`, `Cubit` + `doIntent`), and tested on a real device. All code in the repository is under the author's responsibility and can be explained line-by-line in a technical review.

| Tool | Version | Used For |
|---|---|---|
| **DeepSeek** | `deepseek-chat` (V3) | Boilerplate refactors (search feature, use cases, Cubits) and README structure |
| **Claude** | **Opus 5** | Debugging the Agora connection issue the author could not solve independently; UI polish suggestions; edge-case reviews (permissions, error states); README wording |

**Disclosure summary:**
- The **project skeleton and Clean Architecture layout were designed by the author**; AI was used for scaffolding, refinement, and review.
- The **Agora connection issue** was resolved with the help of **Claude Opus 5** after the author was unable to solve it independently.
- No proprietary or licensed code was pasted verbatim into the project.
---
## ⚠️ Known Limitations

- **Theming** — light theme only for now; dark theme is planned and the theming layer is already structured to support it.
- **Localization** — English only for now; additional languages (Arabic, etc.) are planned and the i18n layer is already wired up.
- **Platform coverage** — developed and tested on Android. iOS builds are supported in principle but unverified (Windows-only dev machine).
- **Firestore rules** — running in test mode; not production-ready.
- **Presence accuracy** — Firestore online status updates on sign-in / sign-out and app lifecycle; abrupt kills may leave a stale "online" flag until the next session.
- **Call recording** — not implemented; Agora recording is server-side only and requires a paid plan.
- **Group calling** — not implemented; the SDK supports it, but the UI and signaling are 1-to-1.
- **Screen sharing** — not implemented.
- **Token security** — the demo uses Agora App ID + App Certificate in source. Production should issue per-channel tokens from a trusted backend.
- **Search scalability** — search fetches the user list and filters client-side; fine for small datasets but not for a large user base. The planned upgrade is a lowercased `nameLower` field with a Firestore prefix query.
- **Push notifications** — not implemented; the app does not yet receive incoming call notifications when fully backgrounded.
- **iOS background incoming calls** — not implemented; would require an Apple Push Notification key and `VoIP` entitlements.
---
## 📋 Feature Checklist

All of the following are implemented and verified on Android:

- [x] Application launches successfully
- [x] User can log in
- [x] Users / contacts are displayed
- [x] User can initiate an audio call
- [x] Another user can receive the call
- [x] Call can be accepted / rejected
- [x] Audio can be muted / unmuted
- [x] Call can be ended
- [x] User can initiate a video call
- [x] Camera can be enabled / disabled
- [x] Front / rear camera can be switched
- [x] Video call can be ended
- [x] Call history is displayed
- [x] Permissions are handled
- [x] Basic errors are handled
- [x] APK can be installed and tested
---
## 🎁 Future Planned Items

Implemented:
- [x] **Recent contacts** — frequently called users surfaced at the top of the Contacts screen
- [x] **Network quality indicator** — shown during a call using Agora's `onNetworkQuality` callback

Planned but not yet implemented:
- [ ] Dark mode (theming layer already prepared)
- [ ] Arabic localization (i18n layer already prepared)
- [ ] Push notifications for incoming calls
- [ ] Group calling
- [ ] Screen sharing
- [ ] Call recording
- [ ] Block user
---
## 🗺️ Roadmap

1. Dark theme (theming layer already prepared).
2. Arabic localization + additional languages (i18n layer already prepared).
3. Push notifications for incoming calls, including background handling.
4. Agora token server + short-lived tokens per channel.
5. Group calls via Agora's multi-user channel API.
6. Server-side call recording.
7. Server-side search with Firestore indexes and `nameLower`.
8. Block user + reporting.
9. End-to-end encrypted signalling payloads.
10. iOS build verification.

---

## 📄 License

Code is provided for evaluation and portfolio purposes. Feel free to reach out with any questions.
---
## 👤 Author

**Islam Ramzy**  
Flutter Developer  
📧 [islamramzy2@gmail.com](mailto:islamramzy2@gmail.com) · 🔗 [LinkedIn](https://www.linkedin.com/in/islamramzy/) · 💻 [GitHub](https://github.com/IslamRamzy444)
