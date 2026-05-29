# FinTrack: Premium Personal Finance Tracker

FinTrack is a sophisticated, high-performance Flutter application designed to
provide a premium personal finance tracking experience. Built with a focus on
fluid UI, high-impact design, and robust state management, it offers a
zero-elevation aesthetic with advanced theme awareness.

## ✨ Features

- **Premium UI/UX**: Overlapping Bento-style dashboard, glassmorphic navigation
  bar, and vibrant emerald gradients.
- **Micro-Animations**: Elastic splash transitions, pulsing primary actions, and
  smooth context-aware animations.
- **Smart Analytics**: Monthly spending breakdown, automated daily insights, and
  interactive bar charts.
- **Theme-Aware Architecture**: 100% reactive typography and icon tints that
  adapt instantly to Light and Dark modes.
- **Robust Transaction Management**: Categorized spending, income tracking, and
  real-time balance calculations.
- **Persistence & Security**: Offline-first data persistence via Firestore
  caching and secure authentication.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK 3.22.0+)
- **State Management**: [Riverpod](https://riverpod.dev/) (Functional &
  Reactive)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative
  Routing)
- **Database**:
  [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore) (with
  offline caching)
- **Typography**: [Google Fonts](https://fonts.google.com/) (Plus Jakarta Sans)
- **Utilities**: Environment variable management via `flutter_dotenv`.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Java Development Kit (JDK) 17+
- Android Studio / VS Code

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Deepanshu-ui-dev/Jaypee-Brothers-Assessment-.git
   cd Fintracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Environment Setup**: Create a `.env` file in the root directory and add
   your Firebase configurations if applicable (refer to `.env.example`).

4. **Firebase Configuration**: Ensure your `google-services.json` (Android) and
   `GoogleService-Info.plist` (iOS) are correctly placed in their respective
   platform directories.

5. **Run the application**:
   ```bash
   flutter run --no-tree-shake-icons
   ```

   To build for production (APK):
   ```bash
   flutter build apk --no-tree-shake-icons
   ```

## 📂 Project Structure

```text
lib/
├── app/          # Navigation & Central Theme
├── core/         # Extensions, Colors, Styles, Constants
├── data/         # Models, Repositories, Services
├── presentation/ # Screens, Widgets, Fragments
└── providers/    # Riverpod Logic & Business State
```

## 📦 Deployment Note

The project has been sanitized for submission. Hardcoded secrets have been moved
to environment variables, and the repository follows a semantic commit history
for clarity and professional auditing.

---

**Developed with ❤️ by Deepanshu Kaushik**
