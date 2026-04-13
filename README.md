# TaskFlow Mobile App

## 📱 Giới thiệu

**TaskFlow Mobile** là ứng dụng Flutter chính thức cho hệ thống TaskFlow, hỗ trợ Android và iOS.

> **Backend API**: `E:/Project/Master/dashboard.bakudanramen.com/` (đã có `/api/v1/*`)

## 🏗️ Kiến trúc

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

## 🔌 API Endpoints

Tất cả endpoints đều prefix `/api/v1/`:

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| POST | `/auth/login` | Đăng nhập |
| POST | `/auth/register` | Đăng ký |
| POST | `/auth/refresh` | Refresh token |
| POST | `/auth/logout` | Đăng xuất |
| GET | `/auth/me` | Thông tin user |
| GET | `/tasks` | Danh sách task |
| POST | `/tasks` | Tạo task |
| GET | `/tasks/{id}` | Chi tiết task |
| PUT | `/tasks/{id}` | Cập nhật task |
| PATCH | `/tasks/{id}/status` | Đổi trạng thái |
| PATCH | `/tasks/{id}/assign` | Giao task |
| GET | `/me/tasks` | Task của tôi |
| GET | `/notifications` | Thông báo |
| GET | `/dashboard/summary` | Dashboard stats |
| GET | `/calendar` | Calendar view |
| POST | `/upload` | Upload file |
| GET | `/sync/poll` | Sync polling |

## 🗂️ Cấu trúc Flutter

```
mobile_taskflow/
├── lib/
│   ├── main.dart                    ← Entry point
│   ├── core/
│   │   ├── config/env.dart          ← API URL, config
│   │   ├── constants/               ← Colors, strings, endpoints
│   │   ├── network/api_client.dart  ← Dio HTTP client
│   │   ├── storage/                 ← Secure storage
│   │   ├── theme/                   ← Dark/Light theme
│   │   └── utils/                   ← Date utils
│   ├── features/
│   │   ├── auth/                    ← Login, Register
│   │   ├── dashboard/               ← Home dashboard
│   │   ├── tasks/                   ← Task list, detail, create
│   │   ├── calendar/                ← Calendar view
│   │   ├── inbox/                   ← Notifications
│   │   └── profile/                 ← Profile, settings
│   └── shared/
│       ├── models/models.dart       ← Data models
│       ├── providers.dart           ← Riverpod providers
│       └── services/                ← API services
└── pubspec.yaml
```

## 🚀 Cách chạy

### 1. Cài Flutter
```bash
# Windows: https://docs.flutter.dev/get-started/install/windows
# macOS: https://docs.flutter.dev/get-started/install/macos

flutter doctor
```

### 2. Cài dependencies
```bash
cd E:/Project/Master/mobile_taskflow
flutter pub get
```

### 3. Chạy app
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d iPhone

# Production build
flutter build apk --release
flutter build ipa --release
```

### 4. Build release APK
```bash
flutter build apk --release -t lib/main_prod.dart
```

## 📋 Database Migration

Chạy migration để tạo bảng cho mobile API:

```bash
mysql -u liemdo -p taskflow_db < sql/schema_mobile_v1.sql
```

Hoặc migration sẽ tự chạy khi app gọi API lần đầu (auto-migrate).

## 🔐 Bảo mật

- Token lưu trong `FlutterSecureStorage` (Keychain iOS / Keystore Android)
- API yêu cầu HTTPS (force ở production)
- Rate-limit login: 5 attempts / 15 phút
- Token auto-refresh khi hết hạn

## 🌐 API URL

| Environment | URL |
|------------|-----|
| Development | `http://localhost:8888` |
| Android Emulator | `http://10.0.2.2:8888` |
| iOS Simulator | `http://localhost:8888` |
| Production | `https://dashboard.bakudanramen.com` |

Đổi URL trong `lib/core/config/env.dart`:
```dart
static const String apiBaseUrl = 'https://dashboard.bakudanramen.com';
```

## 📲 Push Notifications

Cần cài Firebase:
1. Tạo Firebase project
2. Download `google-services.json` → `android/app/`
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Cloud Messaging

## ✅ Checklist trước release

- [ ] Migration đã chạy trên production DB
- [ ] API URL production đã đổi
- [ ] Firebase config đã thêm
- [ ] Test trên Android + iOS
- [ ] Play Store: tạo internal testing track
- [ ] App Store: tạo TestFlight
