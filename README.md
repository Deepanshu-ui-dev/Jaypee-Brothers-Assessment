# 💸 FinTrack: Premium Personal Finance Tracker

<div align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img alt="Riverpod" src="https://img.shields.io/badge/Riverpod-State%20Management-1A1A1A?style=for-the-badge" />
  <img alt="Vercel" src="https://img.shields.io/badge/Vercel-Web%20Deployment-000000?style=for-the-badge&logo=vercel&logoColor=white" />
</div>

<br>

FinTrack is a sophisticated, high-performance Flutter application designed to
provide a premium personal finance tracking experience across **Mobile** and
**Desktop/Web**. Built with a focus on fluid UI, high-impact design, and robust
state management, it offers a beautifully adaptive aesthetic.

## ✨ Key Features

- **Adaptive Cross-Platform Design**: Fully responsive UI featuring a bottom
  navigation pill for mobile devices, and an expansive two-column sidebar layout
  for desktop/web.
- **Premium UI/UX**: Overlapping Bento-style dashboard metrics, glassmorphic
  effects, and vibrant emerald gradients (`#0CA75B`).
- **Micro-Animations**: Elastic splash transitions, pulsing primary actions, and
  smooth context-aware list animations.
- **Smart Analytics**: Monthly spending breakdown, automated weekly insights,
  and interactive bar charts.
- **Theme-Aware Architecture**: 100% reactive typography and icon tints that
  adapt instantly to Light and Dark modes.
- **Robust Transaction Management**: Categorized spending, income tracking, and
  real-time balance calculations.
- **Persistence & Security**: Offline-first data persistence via Firestore
  caching (Android/iOS) and secure Firebase authentication.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK 3.22.0+)
- **State Management**: [Riverpod](https://riverpod.dev/) (Functional & Reactive
  state)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router) (Declarative
  deep-linkable routing)
- **Database Backend**:
  [Firebase Cloud Firestore & Auth](https://firebase.google.com/)
- **Typography & Assets**: Plus Jakarta Sans via Google Fonts, custom vector
  iconography.
- **Web Deployment**: Configured via `vercel_build.sh` for seamless CD/CI on
  Vercel.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase Project configured for Android/iOS/Web
- Android Studio / VS Code

### Local Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Deepanshu-ui-dev/Jaypee-Brothers-Assessment.git
   cd Fintracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Environment Setup**: Create a `.env` file in the root directory. Add your
   Firebase Web API keys here:
   ```env
   FIREBASE_API_KEY=your_api_key
   FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   FIREBASE_APP_ID=your_app_id
   ```

4. **Firebase Platform Config**: Ensure your `google-services.json` (Android)
   and `GoogleService-Info.plist` (iOS) are correctly placed in their respective
   `app/` directories.

5. **Run the application**:
   ```bash
   # Run for mobile
   flutter run

   # Run for web
   flutter run -d chrome
   ```

### 🌐 Vercel Web Deployment

This project includes a custom `vercel_build.sh` script to automate Flutter web
deployment on Vercel.

1. Import the repository into your Vercel dashboard.
2. Override the **Build Command** to: `bash vercel_build.sh`
3. Override the **Output Directory** to: `build/web`
4. Add the 6 `FIREBASE_*` keys in Vercel's **Environment Variables** settings.
5. Deploy! Vercel will automatically inject the `env` values and build the
   `flutter web --release` bundle.

## 📂 Project Structure

```text
lib/
├── app/          # Core App Shell & GoRouter configuration
├── core/         # Extensions, Colors, Breakpoints, Constants
├── data/         # Models, Repositories (Firestore), Services
├── presentation/ # Responsive Screens & UI Widgets
└── providers/    # Riverpod Logic & Business State
```

---

<p align="center">
  <b>Developed with ❤️ by Deepanshu Kaushik</b>
</p>
