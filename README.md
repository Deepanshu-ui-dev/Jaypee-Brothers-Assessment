# 💸 FinTrack — Premium Personal Finance Tracker

<div align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img alt="Hive" src="https://img.shields.io/badge/Hive-Offline%20First-FFCA28?style=for-the-badge&logo=hive&logoColor=black" />
  <img alt="Riverpod" src="https://img.shields.io/badge/Riverpod-State%20Management-1A1A1A?style=for-the-badge" />
  <img alt="Premium UI" src="https://img.shields.io/badge/UI%2FUX-Glassmorphism-7C3AED?style=for-the-badge" />
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-0CA75B?style=for-the-badge" />
</div>

<br>

> FinTrack is a sophisticated, high-performance Flutter application designed to provide a **premium, state-of-the-art personal finance tracking experience**. Built with a severe focus on fluid UI, high-impact design, and robust local state management — it completely reimagines how you interact with your financial data.

**FinTrack is 100% Offline-First.** No loading spinners, no network requests — everything is instantaneous.

---

## ✨ UI/UX Design Philosophy

This application is engineered to feel **tactile, alive, and profoundly premium** — inspired by the "Invisible UI" principle used in world-class fintech apps:

| Principle | Implementation |
|---|---|
| **Glassmorphism & Depth** | `BackdropFilter` blurs on the floating nav pill and sheets; soft tinted glow shadows instead of harsh drop shadows |
| **Tactile Haptics** | Every core interaction triggers physical feedback — `lightImpact` for navigation, `mediumImpact` for saves/deletes, `selectionClick` for toggles |
| **Fluid Animations** | `BouncingButton` press-shrink, `AnimatedNumber` rolling counters, staggered list entries via `flutter_staggered_animations`, spring-curve progress bars |
| **Micro-Interactions** | Sliding income/expense toggle pill, pulsing FAB, animated budget progress bars that grow on first render |
| **Adaptive Layout** | Floating glassmorphic nav pill on mobile; two-column sidebar layout on desktop/web |

---

## 🚀 Key Features

### 💳 Dashboard
- **Balance Card** — gradient card with today's spend, animated sparkline, vs-yesterday comparison, and top category callout
- **Daily Insight Banner** — AI-style weekly spending insight (% above/below personal average)
- **Budget Alert Banner** — real-time warnings when any category nears or exceeds its monthly limit
- **Browse Categories** — horizontally scrollable filter chips with transaction drill-down

### 📊 Analytics
- **Daily Spending Line Chart** — smooth bezier curves for the current month via `fl_chart`
- **Spending Breakdown** — donut-style category breakdown with ranked list
- **6-Month Trend Bar Chart** — income vs expense comparison across the last 6 months
- **Month Summary Card** — net income/expense/balance with vs-last-month percentage delta

### 💰 Budget Goals
- **Gradient summary card** — total spent vs remaining with an animated overall progress bar
- **Per-category budget cards** — green → amber → red progress bars as limits approach
- **Smart status labels** — "X% used", "Almost there", "Budget exceeded!" with colour coding
- **Set Budget Sheet** — big centered amount input with preset chips (1K, 5K, 10K…) and dynamic currency

### 🧾 Transactions
- **Grouped by date** with net daily total label per group header
- **Summary bar** showing filtered income, expense, and count totals
- **Swipe-to-delete** with animated removal and UNDO snackbar
- **Advanced filtering** — All / Income / Expense + category chip + live search
- **Add/Edit sheet** — borderless amount input, iOS-style form rows, haptic feedback throughout

### ⚙️ Settings & Profile
- **Gradient profile hero card** with streak badge and initials avatar
- **Streak & entries stat cards** — gamification layer to build daily habits
- **Theme switcher** (System / Light / Dark) via `CupertinoSlidingSegmentedControl`
- **Notifications toggle**, **Biometric lock toggle**
- **CSV export** of all transactions via `ExportService`

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) SDK 3.22+ |
| **State Management** | [Riverpod](https://riverpod.dev/) — `StateNotifierProvider`, `Provider`, `StateProvider` |
| **Local Database** | [Hive](https://docs.hivedb.dev/) — NoSQL TypeAdapters, synchronous reads/writes |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) — declarative, deep-linkable |
| **Charting** | [fl_chart](https://pub.dev/packages/fl_chart) — bezier line charts, bar charts |
| **Animations** | `flutter_staggered_animations`, native `AnimationController` + `TweenAnimationBuilder` |
| **Notifications** | `flutter_local_notifications` + `timezone` |
| **Security** | `local_auth` biometric lock |
| **Internationalisation** | `intl` — dynamic locale & currency symbol via `NumExtension` |

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── app.dart              # Root widget, theme, currency initialisation
│   └── router.dart           # GoRouter config, AppShell (mobile + desktop nav)
├── core/
│   ├── constants/            # AppColors design system, AppTextStyles
│   ├── extensions/           # NumExtension (asCurrency, compactCurrency), DateExtensions
│   ├── utils/                # Breakpoints, Validators
│   └── widgets/              # BouncingButton, AnimatedNumber, BottomPadding
├── data/
│   ├── models/               # Hive TypeAdapters: Transaction, Category, Budget, User
│   ├── repositories/         # CRUD wrappers over Hive boxes
│   └── services/             # ExportService, HiveService, NotificationService
├── presentation/
│   ├── dashboard/            # Dashboard screen + BalanceCard, BrowseCategories widgets
│   ├── transactions/         # Transactions list, Add/Edit sheet, FilterChipsBar
│   ├── analytics/            # Charts: DailyLineChart, MonthlyBarChart, CategoryBreakdown
│   ├── budget/               # BudgetScreen + SetBudgetSheet
│   ├── settings/             # Settings & ProfileScreen
│   └── onboarding/           # Local onboarding flow
└── providers/                # All Riverpod providers (transactions, budget, auth, theme…)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable — 3.22+)
- Android Studio / VS Code with Flutter plugin

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Deepanshu-ui-dev/Jaypee-Brothers-Assessment.git
   cd Fintracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run code generation** (Hive adapters):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**:
   ```bash
   # Android / iOS (recommended for haptics & 60fps blurs)
   flutter run

   # Linux desktop
   flutter run -d linux

   # Web
   flutter run -d chrome
   ```

> **Tip:** Run on a **physical device** to experience the full haptic feedback engine and silky-smooth glassmorphism blurs. Emulators do not simulate haptics accurately.

---

## 🔑 Design Tokens

The entire app derives from a single `AppColors` design token class in [`lib/core/constants/app_colors.dart`](lib/core/constants/app_colors.dart) that adapts to dark/light mode automatically:

```dart
// Primary palette
Color get primary    => const Color(0xFF7C3AED); // Electric Violet
Color get secondary  => const Color(0xFF3B82F6); // Electric Blue

// Semantic
Color get incomeGreen => const Color(0xFF10B981); // Emerald
Color get expenseRed  => const Color(0xFFF43F5E); // Rose
```

All currency formatting is dynamic via `NumExtension.activeCurrencySymbol` — configured from the user's profile at startup.

---

<p align="center">
  <b>Developed with ❤️ by Deepanshu Kaushik</b><br>
  <sub>Jaypee Brothers Assessment — 2026</sub>
</p>
