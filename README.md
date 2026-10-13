# Pulse Gym — Cross-Platform Workout & Nutrition App (iOS & Android)

A full-featured gym mobile application built with **Flutter** and **Firebase**, featuring role-based portals for **Gym Members (Clients)** and **Personal Trainers (Coaches)**.

---

## 📱 Features Overview

### 1. Gym Member / Client Portal
* **Live Workout Tracker:** Active set-by-set workout session with elapsed timer, rest interval tracking, weight (kg) and rep logging, and completion checkmarks.
* **Nutrition & Macro Tracking:** Daily calorie target calculation, protein, carbohydrate, and fat progress bars, meal logging (Breakfast, Lunch, Dinner, Snacks), and water intake tracker (+250ml quick-add).
* **Progress & Weekly Check-ins:** Weight delta comparison (starting vs. current), body fat percentage tracking, and weekly check-in submissions to assigned personal trainers.
* **Trainer-Assigned Workouts:** Instant 1-tap start for custom routines crafted by the coach.

### 2. Personal Trainer / Coach Portal
* **Client Roster & Compliance:** Real-time client adherence percentages, last active session timestamp, and current body weight.
* **Workout Program Builder:** Build multi-day split routines (sets, rep targets, rest periods, exercise selection) and assign them directly to clients.
* **Check-in Review Center:** Review weekly client check-in reports and send feedback notes.

### 3. Built-In Instant Demo Mode
* Test both **Client** and **Trainer** experiences immediately without needing to configure Firebase credentials upfront.

---

## 🏗️ Architecture & Project Structure

```
gym_app/
├── pubspec.yaml                 # Dependencies (Flutter, Firebase, Provider, etc.)
├── firestore.rules              # Role-Based Firestore Security Rules
├── lib/
│   ├── main.dart                # App entrypoint & Auth Gatekeeper
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart  # Electric Lime & Dark gym theme palette
│   │   │   └── app_theme.dart   # High-contrast Material 3 theme
│   │   ├── models/
│   │   │   ├── user_model.dart          # Member vs. Trainer profiles
│   │   │   ├── exercise_model.dart      # Catalog of exercises
│   │   │   ├── workout_plan_model.dart  # Routines & multi-day splits
│   │   │   ├── workout_log_model.dart   # Sets, reps, weight logs & volume
│   │   │   ├── nutrition_model.dart     # Macro goals, meals, food items
│   │   │   └── check_in_model.dart      # Photos, weights, coach feedback
│   │   └── services/
│   │       ├── auth_service.dart        # Auth & role management
│   │       ├── workout_service.dart     # Active workout session & timers
│   │       ├── nutrition_service.dart   # Food & hydration sync
│   │       └── trainer_service.dart     # Client roster & routine builder
│   └── ui/
│       ├── auth/
│       │   ├── login_screen.dart        # Login & demo mode selector
│       │   └── register_screen.dart     # Role selection (Member / Trainer)
│       ├── client/
│       │   ├── client_main_screen.dart      # Bottom navigation
│       │   ├── client_dashboard_screen.dart # Daily summary & prompt
│       │   ├── workout_tracker_screen.dart  # Active set logger & timer
│       │   ├── nutrition_screen.dart        # Meals & macros
│       │   └── progress_screen.dart         # Check-in submissions
│       └── trainer/
│           ├── trainer_main_screen.dart     # Trainer navigation
│           ├── client_roster_screen.dart    # Client list & compliance
│           ├── program_builder_screen.dart  # Routine template builder
│           └── checkin_review_screen.dart   # Coach reviews & feedback
```

---

## 🚀 Getting Started on macOS

### Step 1: Install Flutter SDK
If Flutter is not yet installed on your Mac, run:
```bash
brew install --cask flutter
```
Verify the installation:
```bash
flutter doctor
```

### Step 2: Open and Set Workspace
1. In Antigravity / your IDE, open the directory:
   `/Users/chetandesai/.gemini/antigravity/scratch/gym_app`
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Step 3: Configure Firebase (Optional for Cloud Sync)
1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Link your Firebase project:
   ```bash
   flutterfire configure
   ```
3. Deploy the included Firestore Security Rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Step 4: Run the App
* **On iOS Simulator:**
  ```bash
  open -a Simulator
  flutter run -d ios
  ```
* **On Android Emulator:**
  ```bash
  flutter run -d android
  ```
* **On Chrome / Web:**
  ```bash
  flutter run -d chrome
  ```
