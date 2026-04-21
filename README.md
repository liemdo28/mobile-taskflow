# TaskFlow Mobile App

## 📱 Overview

**TaskFlow Mobile** is the official Flutter application for the TaskFlow system, supporting both Android and iOS platforms.

> **Backend API**: `E:/Project/Master/dashboard.bakudanramen.com/` (exposes `/api/v1/*` endpoints)

## 🏗️ Architecture

```
┌──────────────────────────────┐
│  Flutter Mobile App          │
│  mobile_taskflow/lib/        │
│  ├── core/     (network,     │
│  │             storage, theme)│
│  ├── features/ (auth, tasks, │
│  │             dashboard...)  │
│  └── shared/   (models,       │
│                services)      │
└──────────┬───────────────────┘
           │ HTTPS / REST API
           ▼
┌──────────────────────────────┐
│  PHP Backend                 │
│  dashboard.bakudanramen.com │
│  /api/v1/* (API endpoints)   │
└──────────┬───────────────────┘
           │ MySQL
           ▼
┌──────────────────────────────┐
│  MySQL Database (shared)    │
│  taskflow_db                │
└──────────────────────────────┘
```

## 🔌 Tech Stack

| Layer        | Technology                  |
|--------------|-----------------------------|
| Framework    | Flutter (Dart)              |
| State Mgmt   | Riverpod                    |
| HTTP Client  | Dio                         |
| Local Store  | FlutterSecureStorage        |
| Notifications| Firebase Cloud Messaging    |
| Backend      | PHP (REST API)              |
| Database     | MySQL                       |

## 🔌 API Endpoints

All endpoints are prefixed with `/api/v1/`:

| Method | Endpoint              | Description               |
|--------|-----------------------|---------------------------|
| POST   | `/auth/login`         | User login                |
| POST   | `/auth/register`     | User registration         |
| POST   | `/auth/refresh`      | Refresh access token      |
| POST   | `/auth/logout`       | User logout               |
| GET    | `/auth/me`            | Get current user info     |
| GET    | `/tasks`              | List all tasks            |
| POST   | `/tasks`              | Create a new task         |
| GET    | `/tasks/{id}`         | Get task details          |
| PUT    | `/tasks/{id}`         | Update a task             |
| PATCH  | `/tasks/{id}/status`  | Update task status        |
| PATCH  | `/tasks/{id}/assign`  | Assign task to a user      |
| GET    | `/me/tasks`          | Get my assigned tasks      |
| GET    | `/notifications`     | List notifications        |
| GET    | `/dashboard/summary`  | Dashboard statistics       |
| GET    | `/calendar`          | Calendar view             |
| POST   | `/upload`             | Upload a file              |
| GET    | `/sync/poll`         | Sync polling               |

## 🗂️ Project Structure

```
mobile_taskflow/
├── lib/
│   ├── main.dart                    ← Entry point
│   ├── core/
│   │   ├── config/env.dart          ← API URL and app config
│   │   ├── constants/               ← Colors, strings, endpoints
│   │   ├── network/api_client.dart  ← Dio HTTP client
│   │   ├── storage/                 ← Secure storage utilities
│   │   ├── theme/                   ← Dark/Light theme definitions
│   │   └── utils/                   ← Date and helper utilities
│   ├── features/
│   │   ├── auth/                    ← Login and registration
│   │   ├── dashboard/               ← Home dashboard
│   │   ├── tasks/                   ← Task list, detail, and creation
│   │   ├── calendar/                ← Calendar view
│   │   ├── inbox/                   ← Notifications / inbox
│   │   └── profile/                 ← Profile and settings
│   └── shared/
│       ├── models/models.dart       ← Data models
│       ├── providers.dart           ← Riverpod providers
│       └── services/                ← API service layer
└── pubspec.yaml
```

## 🚀 How to Run

### 1. Install Flutter
```bash
# Windows: https://docs.flutter.dev/get-started/install/windows
# macOS: https://docs.flutter.dev/get-started/install/macos

flutter doctor
```

### 2. Install Dependencies
```bash
cd E:/Project/Master/mobile_taskflow
flutter pub get
```

### 3. Run the App
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d iPhone

# Production build
flutter build apk --release
flutter build ipa --release
```

### 4. Build Release APK
```bash
flutter build apk --release -t lib/main_prod.dart
```

## 📋 Database Migration

Run the migration to create tables for the mobile API:

```bash
mysql -u liemdo -p taskflow_db < sql/schema_mobile_v1.sql
```

Alternatively, migrations run automatically when the app first calls the API (auto-migrate).

## 🔐 Security

- Access/refresh tokens are stored in `FlutterSecureStorage` (iOS Keychain / Android Keystore)
- API enforces HTTPS in production
- Login rate limit: 5 attempts per 15 minutes
- Tokens are automatically refreshed before expiration

## 🌐 API URL Configuration

| Environment   | URL                                  |
|---------------|--------------------------------------|
| Development   | `http://localhost:8888`              |
| Android Emulator | `http://10.0.2.2:8888`            |
| iOS Simulator | `http://localhost:8888`              |
| Production    | `https://dashboard.bakudanramen.com` |

Override the URL in `lib/core/config/env.dart`:
```dart
static const String apiBaseUrl = 'https://dashboard.bakudanramen.com';
```

## 📲 Push Notifications

Firebase setup required:

1. Create a Firebase project
2. Download `google-services.json` → `android/app/`
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Cloud Messaging in Firebase console

## ✅ Pre-Release Checklist

- [ ] Migration has been run on production DB
- [ ] Production API URL is configured
- [ ] Firebase config files are in place
- [ ] Tested on both Android and iOS
- [ ] Play Store: internal testing track created
- [ ] App Store: TestFlight build submitted

## 📝 Developer Notes

- The app uses **Riverpod** for state management — all providers are centralized in `lib/shared/providers.dart`.
- API calls go through a shared `ApiClient` (Dio-based) in `lib/core/network/`.
- Both light and dark themes are supported and defined in `lib/core/theme/`.
- The app auto-migrates the database schema on first API call, so no manual migration is strictly required in development.
- For hot reload during development: save changes and the app will refresh automatically. A full restart is only needed when modifying `main.dart` or `pubspec.yaml`.
