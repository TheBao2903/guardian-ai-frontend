# 🏛️ GUARDIAN AI — FRONTEND MOBILE ARCHITECTURE

> **Document Status:** CANONICAL ARCHITECTURE SPECIFICATION & RULES  
> **Target Platform:** Flutter (iOS / Android)  
> **Architectural Pattern:** Feature-First + Pragmatic Clean Architecture + Strict Dependency Boundaries  
> **Target Audience:** Core Engineers & AI Coding Agents  
> **Rule Enforcement:** Mọi thay đổi mã nguồn trên client mobile BẮT BUỘC phải tuân thủ tài liệu này. KHÔNG ĐƯỢC shortcut, bypass layer hoặc code ngoài ranh giới quy định.

---

## 1. Architecture Overview (Tổng quan Kiến trúc)

Guardian AI là ứng dụng an toàn cá nhân khẩn cấp (Personal Safety & Emergency), yêu cầu tính sẵn sàng, độ tin cậy và sự ổn định cực cao.

Hệ thống tuân theo mô hình **Feature-First kết hợp Clean Architecture nhẹ** (Pragmatic Clean Architecture). Không lạm dụng enterprise boilerplate, nhưng duy trì **Ranh giới phụ thuộc nghiêm ngặt (Strict Dependency Boundaries)** để ngăn chặn spaghetti code, triệt tiêu God classes, và đảm bảo AI/kỹ sư không thể đặt code sai vị trí.

### Triết lý Cốt lõi:
1. **Emergency-First & Zero-Failure in Critical Paths:** Logic kích hoạt SOS, còi hú, định vị và gửi cảnh báo phải phân tách tuyệt đối khỏi giao diện, không bị crash bởi lỗi render UI.
2. **Unidirectional Dependency Flow:** Phụ thuộc chỉ đi một chiều hướng tâm về Domain hoặc từ Presentation/Data vào Domain.
3. **No Infrastructure Leakage in UI:** Mọi chi tiết kỹ thuật (Dio, WebSocket, Secure Storage, Hardware Sensors) bị cô lập sau abstraction contract (Interfaces / Repositories).
4. **Feature Isolation:** Mỗi tính năng là một module khép kín; không chia sẻ logic nội bộ của feature này cho feature khác một cách tùy tiện.

---

## 2. Project Directory Structure (Cấu trúc Thư mục)

Cấu trúc chuẩn của toàn bộ frontend được quy định như sau:

```text
frontend/
├── ARCHITECTURE.md                 # Tài liệu luật kiến trúc chính thức (Source of Truth)
├── pubspec.yaml                    # Quản lý dependencies & assets
├── analysis_options.yaml           # Linter rules nghiêm ngặt
├── README.md                       # Hướng dẫn setup môi trường & chạy app
│
├── assets/                         # Static assets (Icon, Ảnh, Âm thanh còi hú, Font)
│   ├── icons/
│   ├── images/
│   ├── sounds/                     # siren_alarm.mp3, countdown_beep.wav
│   └── fonts/
│
└── lib/
    ├── main.dart                   # Entry point duy nhất của ứng dụng
    │
    ├── app/                        # Cấu hình cấp ứng dụng (Global Application Layer)
    │   ├── app.dart                # Root MaterialApp widget
    │   ├── router/                 # GoRouter configuration & navigation guards
    │   │   ├── app_router.dart     # Router instance & route trees
    │   │   ├── route_names.dart    # Hằng số tên route (tránh magic string)
    │   │   └── route_guards.dart   # Guard chuyển hướng (Auth check, Onboarding)
    │   ├── theme/                  # Design System Tokens (evondevKit Design System)
    │   │   ├── app_theme.dart      # ThemeData Light & Dark
    │   │   ├── app_colors.dart     # Palette tokens (--primary, --surface, --danger...)
    │   │   ├── app_typography.dart # Inter scale, font sizes, weights, line heights
    │   │   ├── app_spacing.dart    # Spacing 4px, 8px, 12px, 16px, 24px, 32px
    │   │   └── app_radius.dart     # Radius 12px (rounded-xl) chuẩn F1
    │   └── config/                 # Environment variables & Application flavor
    │       └── app_config.dart
    │
    ├── core/                       # Kỹ thuật dùng chung (Cross-cutting Technical Concerns)
    │   ├── constants/              # Hằng số kỹ thuật toàn cục
    │   │   ├── app_constants.dart
    │   │   ├── api_constants.dart  # API Endpoints, Timeouts
    │   │   └── storage_keys.dart   # Khóa lưu Secure Storage
    │   ├── error/                  # Chuẩn hóa lỗi & thất bại
    │   │   ├── app_exception.dart  # NetworkException, AuthException, DeviceException...
    │   │   └── failure.dart        # Failure objects trả về cho Presentation
    │   ├── network/                # HTTP & Realtime infrastructure
    │   │   ├── api_client.dart     # Dio client configuration
    │   │   ├── api_interceptor.dart# Token Refresh & Retry Interceptor
    │   │   └── websocket_client.dart# Quản lý kết nối & stream WebSocket
    │   ├── storage/                # Lưu trữ bảo mật
    │   │   └── secure_storage.dart # Wrapper an toàn quanh Keychain / Keystore
    │   ├── device/                 # Khả năng phần cứng (Capabilities, KHÔNG chứa business rule)
    │   │   ├── location/           # GPS LocationProvider capability
    │   │   ├── audio/              # EmergencyAudioPlayer capability (còi hú)
    │   │   ├── flashlight/         # FlashlightController capability (đèn chớp)
    │   │   └── phone/              # PhoneDialer capability (gọi 113/115)
    │   └── utils/                  # Tiện ích thuần kỹ thuật (Pure helper functions)
    │       ├── date_time_utils.dart
    │       ├── distance_utils.dart
    │       └── validators.dart
    │
    ├── shared/                     # UI components dùng chung (ĐÃ XÁC MINH DÙNG Ở ĐA FEATURE)
    │   ├── widgets/                # UI widgets không mang nghiệp vụ (evondevKit rules)
    │   │   ├── app_button.dart     # 4 variants: primary, secondary, outline, danger
    │   │   ├── app_card.dart       # Flat card viền tóc 1px, không bóng lố
    │   │   ├── app_text_field.dart # Input nền surface, viền border-strong
    │   │   ├── app_badge.dart      # Status badge (success, warning, error)
    │   │   └── app_banner.dart     # In-page alert banner
    │   ├── loading/                # Trạng thái tải chuẩn
    │   │   ├── app_loading.dart
    │   │   └── app_skeleton.dart
    │   └── extensions/             # Extensions trên BuildContext, String, DateTime
    │       └── context_extensions.dart
    │
    └── features/                   # Tính năng nghiệp vụ độc lập (Feature-First)
        ├── auth/                   # Xác thực (Đăng nhập, Đăng ký, Quản lý Session)
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        ├── home/                   # Màn hình điều phối chính (Shell / Bottom Navigation)
        │   └── presentation/
        ├── sos/                    # Tính năng SOS toàn diện (Trigger, Active SOS, Cancel)
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        ├── safety_check/           # Hẹn giờ an toàn (Timer, Templates, Auto-escalation)
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        ├── contacts/               # Vòng tròn khẩn cấp (10 người thân, Telegram link)
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        └── profile/                # Hồ sơ cá nhân & Thông tin y tế (Medical Profile)
            ├── data/
            ├── domain/
            └── presentation/
```

---

## 3. Layer Responsibilities (Trách nhiệm của từng Tầng)

| Tầng (Layer) | Trách nhiệm chính | Được phép Import | TUYỆT ĐỐI CẤM Import |
| :--- | :--- | :--- | :--- |
| **Presentation** | Hiển thị giao diện, tiếp nhận cử chỉ người dùng, bind state từ Controller/Notifier, gọi Use Cases. | `Domain`, `Shared`, `App Theme`, `Flutter UI`, `Riverpod` | `Data Layer` (DataSources, Models), `Dio`, `Storage directly`, `Geolocator directly` |
| **Domain** | Trung tâm nghiệp vụ: chứa Entities, Value Objects, Use Cases, Repository Contracts (Interfaces). | **Thuần Dart** (Dart SDK core, Foundation nếu cần annotations) | `Flutter UI`, `BuildContext`, `Riverpod`, `Dio`, `Data Layer`, `Core/Network` |
| **Data** | Xử lý dữ liệu ngoại vi: Models (DTOs), DataSources (REST, WS, Cache), Repository Implementations. | `Domain`, `Core` (Network, Storage, Device capability), HTTP clients | `Presentation`, `Flutter UI Widgets`, `BuildContext` |
| **Core** | Hạ tầng công nghệ thấp, thiết bị, tiện ích toàn cục không mang tính nghiệp vụ riêng lẻ. | Thư viện bên thứ 3 (Dio, Geolocator, Audios), Dart core | Bất kỳ code nào từ `features/` |
| **Shared** | Các visual components dùng chung trên toàn hệ sinh thái app. | `Flutter UI`, `App Theme`, `Core Utils` | `Domain/Data/Presentation` của bất kỳ feature nào |

---

## 4. Dependency Rules (Quy tắc Phụ thuộc — QUAN TRỌNG NHẤT)

Nguyên lý hướng tâm bất biến:
```text
┌──────────────────────────────────────────────┐
│              Presentation Layer              │
│       (Screens, Widgets, Controllers)        │
└──────────────────────┬───────────────────────┘
                       │ Phụ thuộc (Calls)
                       ▼
┌──────────────────────────────────────────────┐
│                 Domain Layer                 │
│      (Entities, UseCases, Repositories)      │
└──────────────────────▲───────────────────────┘
                       │ Hiện thực hóa (Implements)
┌──────────────────────┴───────────────────────┐
│                  Data Layer                  │
│       (DataSources, Models/DTOs, Impls)      │
└──────────────────────────────────────────────┘
```

### Luật Bất Khả Kháng:
1. **Presentation $\rightarrow$ Domain**: UI chỉ nói chuyện với Domain thông qua Use Case hoặc Repository Contract (thông qua Controller).
2. **Data $\rightarrow$ Domain**: Data Layer hiện thực hóa (`implements`) các Repository Contract được khai báo trong Domain.
3. **Domain KHÔNG phụ thuộc ai**: Domain không bao giờ import code từ Data, Presentation, hay framework cụ thể.
4. **Không có đường tắt (No Shortcut)**: Không bao giờ được phép đi tắt từ `Presentation` sang `Data` hoặc từ `UI` trực tiếp đến `DataSource / API Client`.

---

## 5. Presentation Layer Rules

Thư mục chuẩn bên trong mỗi feature:
```text
features/<feature_name>/presentation/
├── screens/             # Các màn hình hoàn chỉnh (Page-level widgets)
├── widgets/             # Widget con chỉ phục vụ cho feature này
└── providers/           # Riverpod Notifiers / Controllers & State definitions
```

### Quy tắc:
1. **Trách nhiệm của Screen/Widget:** Chỉ render UI từ `state` và gửi các intent/sự kiện của người dùng tới `Controller`.
2. **Trách nhiệm của Controller:**
   - Nhận tương tác từ UI.
   - Kích hoạt Use Case tương ứng.
   - Chuyển đổi Domain Result / Failure thành UI State (`loading`, `data`, `error`, `empty`).
   - KHÔNG gọi HTTP/API trực tiếp.
3. **Không tính toán nghiệp vụ trong UI:** Mọi logic so sánh, validate phức tạp, filter dữ liệu phải nằm ở Use Case hoặc Entity methods.

---

## 6. Domain Layer Rules

Thư mục chuẩn:
```text
features/<feature_name>/domain/
├── entities/            # Business models thuần khiết (Bất biến - Immutable)
├── repositories/        # Abstract contracts / Interfaces
└── usecases/            # Mỗi file đại diện cho 1 hành động nghiệp vụ duy nhất
```

### Quy tắc:
1. **Tính thuần khiết:** Domain là mã nguồn Dart thuần túy (`pure Dart`). KHÔNG import `package:flutter/...`, KHÔNG import `flutter_riverpod`, KHÔNG import `dio`.
2. **Repository là Interface:**
   ```dart
   // GOOD (domain/repositories/safety_check_repository.dart)
   abstract class SafetyCheckRepository {
     Future<Either<Failure, SafetyCheck>> startSafetyCheck({
       required int durationMinutes,
       String? note,
     });
   }
   ```
   Domain không quan tâm data đến từ REST API, Firebase Firestore hay mock memory.
3. **Quy tắc Single Responsibility cho Use Case:** Mỗi Use Case chỉ làm đúng 1 nhiệm vụ và có phương thức `call(...)` hoặc `execute(...)`.

---

## 7. Data Layer Rules

Thư mục chuẩn:
```text
features/<feature_name>/data/
├── datasources/         # RemoteDataSource (REST/WS), LocalDataSource (Cache/DB)
├── models/              # DTOs, JSON Serialization (fromJson / toJson)
└── repositories/        # Triển khai thực tế của Domain Repository
```

### Quy tắc:
1. **Tách biệt Model (DTO) và Entity:**
   - Model (ví dụ `SafetyCheckModel`) chứa logic parse JSON (`fromJson`, `toJson`), xử lý trường null, format ngày giờ từ server.
   - Model có phương thức `.toEntity()` để ánh xạ sang Domain Entity.
   - Không được dùng trực tiếp Model của API làm Domain Entity nếu backend thay đổi schema thường xuyên.
2. **Datasource chỉ lo kết nối:** DataSource nhận params nguyên thủy hoặc DTO, gọi `ApiClient` và trả về Model hoặc quăng `AppException`. DataSource không bọc `Failure`.
3. **Repository Impl quản lý lỗi:** `RepositoryImpl` bắt `AppException` từ DataSource và map thành `Failure` để trả về cho Domain Use Case.

---

## 8. Core Layer Rules (Rất Nghiêm Ngặt)

`core/` chỉ dành cho hạ tầng kỹ thuật xuyên suốt dự án.

### Ranh giới Cốt lõi:
1. **CẤM đưa feature logic vào Core:**
   - ❌ `core/services/sos_service.dart` (SAI - vì SOS là nghiệp vụ).
   - ❌ `core/services/contact_manager.dart` (SAI - vì Contact là nghiệp vụ).
   - ✅ `core/device/location/location_service.dart` (ĐÚNG - vì chỉ cung cấp GPS thô).
   - ✅ `core/network/api_client.dart` (ĐÚNG - vì là HTTP client dùng chung).
2. **Nguyên tắc "Nếu chỉ 1 feature dùng $\rightarrow$ KHÔNG vào Core":** Bất kỳ util hoặc helper nào chỉ dùng cho 1 feature thì phải nằm trong feature đó.

---

## 9. Shared Layer Rules

`shared/` chỉ chứa các UI Component và Utilities đã được xác minh là dùng chung trên nhiều màn hình khác nhau và **hoàn toàn vô tính nghiệp vụ (zero business context)**.

### Ranh giới Cốt lõi:
- ✅ `shared/widgets/app_button.dart`: Nút bấm đa năng chuẩn evondevKit.
- ✅ `shared/widgets/app_card.dart`: Thẻ phẳng viền 1px chuẩn evondevKit.
- ❌ `shared/widgets/sos_action_button.dart`: SAI - Đây là nút kích hoạt SOS, phải nằm trong `features/sos/presentation/widgets/`.
- ❌ `shared/widgets/safety_timer_card.dart`: SAI - Phải nằm trong `features/safety_check/presentation/widgets/`.

---

## 10. State Management Rules (Riverpod)

1. **Phạm vi sử dụng:** Riverpod CHỈ được dùng trong `presentation/` (và tầng `app/` để wire global dependencies như `ApiClient`, `SecureStorage`).
2. **Cấu trúc Provider:**
   - Khởi tạo Provider cho DataSource $\rightarrow$ RepositoryImpl $\rightarrow$ UseCases $\rightarrow$ Controller.
   - UI Widget chỉ `watch` hoặc `read` StateNotifier / AsyncNotifier Controller.
3. **CẤM God Provider:** Không được tạo một provider đơn lẻ quản lý toàn bộ trạng thái của ứng dụng (ví dụ: `AppGlobalProvider`). Mỗi controller quản lý phạm vi hẹp của màn hình hoặc flow của mình.

---

## 11. API & Networking Rules

1. **Cấu trúc URL & Versioning:** Mọi REST calls tuân thủ prefix `/api/v1` từ backend.
2. **Không gọi API từ UI:**
   ```text
   UI Screen / Widget
          │ (1. User tap)
          ▼
   Controller / Notifier
          │ (2. Trigger)
          ▼
   UseCase
          │ (3. Execute)
          ▼
   Repository Contract
          │ (4. Call)
          ▼
   Repository Implementation
          │ (5. Fetch)
          ▼
   Remote DataSource
          │ (6. Request)
          ▼
   ApiClient (Dio)
   ```
3. **Tự động làm mới phiên (Silent Refresh Token):**
   - Mọi API call 401 do `TOKEN_EXPIRED` phải được chặn tại `core/network/api_interceptor.dart`.
   - Interceptor âm thầm gửi `POST /api/v1/auth/refresh` bằng refresh token lưu trong `SecureStorage`.
   - Sau khi có access token mới, ghi đè vào storage và tự động retry request gốc mà người dùng không bị văng ra màn hình đăng nhập.

---

## 12. Device & Hardware Rules

Mọi tương tác phần cứng thiết bị (GPS, Audio Player, Flashlight, Call Dialer) phải tuân theo 2 cấp:

1. **Cấp Năng Lực (Device Capability - trong `core/device/`):**
   - Chỉ chịu trách nhiệm giao tiếp với OS qua plugins (`geolocator`, `audioplayers`, `torch_light`, `url_launcher`).
   - Cung cấp API kỹ thuật: `getCurrentPosition()`, `playAudio(file)`, `toggleFlashlight(bool)`.
   - Hoàn toàn KHÔNG biết khi nào thì SOS, khi nào thì cảnh báo.
2. **Cấp Nghiệp Vụ (Feature Domain & UseCase):**
   - `features/sos/domain/usecases/trigger_sos_usecase.dart` sẽ gọi repository/device interfaces để kết hợp: lấy GPS + hú còi + chớp đèn theo kịch bản khẩn cấp của Guardian AI.

---

## 13. Routing & Navigation Rules

1. **Vị trí tập trung:** Mọi cấu hình định tuyến đặt tại `app/router/app_router.dart` sử dụng `GoRouter`.
2. **Không dùng Magic Strings:** Tên các routes phải được định nghĩa thành hằng số tại `app/router/route_names.dart`.
3. **Route Guards:** Guard kiểm tra phiên đăng nhập (Auth Guard) hoặc quyền truy cập được cấu hình tập trung trong `route_guards.dart`, không rải rác logic kiểm tra trong từng `build()` của màn hình.

---

## 14. Error Handling & Failure Mapping

Mọi exception ngoại vi phải được chuẩn hóa qua 2 tầng:

1. **`AppException` (Kỹ thuật - `core/error/app_exception.dart`):**
   - `NetworkException` (lỗi mất mạng, timeout, server 500).
   - `AuthException` (hết hạn refresh token, thông tin đăng nhập sai).
   - `DeviceException` (người dùng từ chối cấp quyền GPS/Microphone).
2. **`Failure` (Nghiệp vụ - `core/error/failure.dart`):**
   - DataSource quăng `AppException`.
   - RepositoryImpl bắt `AppException` và chuyển đổi (`map`) thành `Failure` thân thiện để trả về cho Domain Use Case (ví dụ: `ServerFailure(message)`, `PermissionFailure(message)`).
   - Controller nhận `Failure` và hiển thị thông báo phù hợp lên UI qua `AppBanner` hoặc Dialog. **Tuyệt đối không để crash hoặc hiển thị raw Dio stack trace lên màn hình người dùng.**

---

## 15. Dependency Injection Architecture

Dự án sử dụng Riverpod như IoC Container:
```dart
// 1. Core Services
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(secureStorageProvider)));

// 2. Feature DataSources
final safetyCheckRemoteDataSourceProvider = Provider<SafetyCheckRemoteDataSource>(
  (ref) => SafetyCheckRemoteDataSource(ref.watch(apiClientProvider)),
);

// 3. Feature Repositories (Interface binded to Impl)
final safetyCheckRepositoryProvider = Provider<SafetyCheckRepository>(
  (ref) => SafetyCheckRepositoryImpl(ref.watch(safetyCheckRemoteDataSourceProvider)),
);

// 4. Feature UseCases
final startSafetyCheckUseCaseProvider = Provider<StartSafetyCheckUseCase>(
  (ref) => StartSafetyCheckUseCase(ref.watch(safetyCheckRepositoryProvider)),
);

// 5. Presentation Controller
final safetyCheckControllerProvider = StateNotifierProvider<SafetyCheckController, SafetyCheckState>(
  (ref) => SafetyCheckController(ref.watch(startSafetyCheckUseCaseProvider)),
);
```

---

## 16. Quy tắc khi Thêm Feature Mới (New Feature Checklist)

Trước khi viết bất kỳ dòng mã nào cho feature mới, kỹ sư / AI agent BẮT BUỘC trả lời và thực hiện theo 8 bước:

- [ ] **Bước 1: Xác định Domain Boundary:** Feature này giải quyết bài toán nghiệp vụ gì? Có thuộc tính năng hiện có (như SOS, Safety Check) hay là tính năng mới độc lập?
- [ ] **Bước 2: Định nghĩa Domain Entities:** Tạo các thực thể bất biến trong `features/<feature>/domain/entities/`.
- [ ] **Bước 3: Khai báo Repository Contract:** Tạo interface abstract trong `features/<feature>/domain/repositories/`.
- [ ] **Bước 4: Viết Use Cases:** Tạo các use cases tương ứng trong `features/<feature>/domain/usecases/`.
- [ ] **Bước 5: Xây dựng Data Layer:** Tạo Model (DTO), Remote/Local DataSource và Repository Implementation trong `features/<feature>/data/`.
- [ ] **Bước 6: Thiết lập Presentation State & Controller:** Tạo StateNotifier/AsyncNotifier trong `features/<feature>/presentation/providers/`.
- [ ] **Bước 7: Thiết kế UI Widgets & Screens:** Xây dựng màn hình bằng cách tái sử dụng `shared/widgets/` và token từ `app/theme/`.
- [ ] **Bước 8: Kiểm tra lại Dependency Rules:** Đảm bảo Domain không dính Flutter/Dio, Presentation không gọi DataSource.

---

## 17. Naming Conventions (Quy ước Đặt tên)

| Loại File / Lớp | Quy ước đặt tên file | Quy ước đặt tên Class | Ví dụ |
| :--- | :--- | :--- | :--- |
| **Screen / Page** | `<name>_screen.dart` | `<Name>Screen` | `safety_check_screen.dart` |
| **Widget riêng** | `<name>_widget.dart` / `<name>.dart` | `<Name>Widget` | `safety_countdown_widget.dart` |
| **Controller** | `<name>_controller.dart` | `<Name>Controller` | `safety_check_controller.dart` |
| **State** | `<name>_state.dart` | `<Name>State` | `safety_check_state.dart` |
| **Entity** | `<name>.dart` | `<Name>` | `safety_check.dart` |
| **Use Case** | `<verb>_<noun>_usecase.dart` | `<Verb><Noun>UseCase` | `start_safety_check_usecase.dart` |
| **Repo Interface**| `<name>_repository.dart` | `<Name>Repository` | `safety_check_repository.dart` |
| **Repo Impl** | `<name>_repository_impl.dart` | `<Name>RepositoryImpl` | `safety_check_repository_impl.dart` |
| **DataSource** | `<name>_remote_data_source.dart` | `<Name>RemoteDataSource`| `safety_check_remote_data_source.dart` |
| **Model / DTO** | `<name>_model.dart` | `<Name>Model` | `safety_check_model.dart` |

---

## 18. Forbidden Patterns (Những Mẫu BỊ CẤM TUYỆT ĐỐI)

Mọi code review hoặc linter check phát hiện các mẫu sau sẽ bị **TỪ CHỐI NGAY LẬP TỨC**:

```text
❌ CẤM 1: Screen hoặc Widget gọi API trực tiếp (ví dụ: Dio().post(...), apiClient.get(...)).
❌ CẤM 2: Widget gọi trực tiếp Repository Implementation hoặc DataSource.
❌ CẤM 3: Screen hoặc Component truy cập trực tiếp SecureStorage hoặc SharedPreferences.
❌ CẤM 4: Screen hoặc Component gọi trực tiếp thư viện phần cứng (ví dụ: Geolocator.getCurrentPosition).
❌ CẤM 5: Domain Layer import 'package:dio', 'package:http' hoặc 'package:flutter/...'.
❌ CẤM 6: Domain Layer import Riverpod.
❌ CẤM 7: Core Layer chứa logic nghiệp vụ của Feature (ví dụ: core/sos_service.dart).
❌ CẤM 8: Shared Layer chứa component đặc thù của một Feature (ví dụ: shared/sos_button.dart).
❌ CẤM 9: Controller kiêm nhiệm gọi HTTP API, parse JSON và xử lý socket (God Controller).
❌ CẤM 10: Tạo thư mục 'services/', 'helpers/', 'managers/' cấp cao nhất trong lib/ để chứa code không rõ nguồn gốc.
❌ CẤM 11: Tách các flow phụ của cùng một nghiệp vụ thành các features độc lập bị trùng lặp (ví dụ: tách 'home_sos' và 'active_sos' thành 2 features riêng).
❌ CẤM 12: Hard-code mã màu hex hoặc kích thước margin/padding tùy tiện trong UI thay vì dùng AppColors và AppSpacing.
```

---

## 19. Ví dụ Minh Họa Cụ Thể (BAD vs GOOD)

### Tình huống: Bắt đầu hẹn giờ an toàn (Safety Check Timer)

#### ❌ CÁCH VIẾT SAI (BAD - Spaghetti / Layer Bypass)
```dart
// features/safety_check/presentation/screens/safety_check_screen.dart
class SafetyCheckScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // TỘI ÁC KIẾN TRÚC:
        // 1. UI gọi trực tiếp Dio API
        // 2. UI tự lấy token từ SecureStorage
        // 3. UI tự bắt DioException
        // 4. Hardcode endpoint & mã màu
        final token = await FlutterSecureStorage().read(key: 'token');
        try {
          final res = await Dio().post(
            'http://localhost:8000/api/v1/safety-check',
            data: {'duration_minutes': 30},
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
          if (res.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bật thành công')));
          }
        } on DioException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.message}')));
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC70036)), // Hardcoded color
      child: Text('Bắt đầu'),
    );
  }
}
```

#### ✅ CÁCH VIẾT ĐÚNG (GOOD - Clean Architecture Boundaries)

```dart
// 1. UI LAYER (Screen chỉ trigger Controller)
// features/safety_check/presentation/screens/safety_check_screen.dart
class SafetyCheckScreen extends ConsumerWidget {
  const SafetyCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyCheckControllerProvider);

    return AppButton(
      label: 'Bắt đầu',
      isLoading: state.isLoading,
      variant: AppButtonVariant.danger,
      onPressed: () {
        ref.read(safetyCheckControllerProvider.notifier).startTimer(durationMinutes: 30);
      },
    );
  }
}

// 2. PRESENTATION CONTROLLER
// features/safety_check/presentation/providers/safety_check_controller.dart
class SafetyCheckController extends StateNotifier<SafetyCheckState> {
  final StartSafetyCheckUseCase _startUseCase;

  SafetyCheckController(this._startUseCase) : super(const SafetyCheckState.initial());

  Future<void> startTimer({required int durationMinutes}) async {
    state = const SafetyCheckState.loading();
    final result = await _startUseCase(durationMinutes: durationMinutes);
    result.fold(
      (failure) => state = SafetyCheckState.error(failure.message),
      (safetyCheck) => state = SafetyCheckState.active(safetyCheck),
    );
  }
}

// 3. DOMAIN USECASE (Thuần túy nghiệp vụ)
// features/safety_check/domain/usecases/start_safety_check_usecase.dart
class StartSafetyCheckUseCase {
  final SafetyCheckRepository _repository;

  StartSafetyCheckUseCase(this._repository);

  Future<Either<Failure, SafetyCheck>> call({required int durationMinutes}) {
    if (durationMinutes <= 0) {
      return Future.value(Left(ValidationFailure('Thời gian hẹn giờ phải lớn hơn 0')));
    }
    return _repository.startSafetyCheck(durationMinutes: durationMinutes);
  }
}

// 4. DOMAIN REPOSITORY CONTRACT (Interface thuần túy)
// features/safety_check/domain/repositories/safety_check_repository.dart
abstract class SafetyCheckRepository {
  Future<Either<Failure, SafetyCheck>> startSafetyCheck({required int durationMinutes});
}

// 5. DATA REPOSITORY IMPLEMENTATION (Map DTO sang Entity, map Exception sang Failure)
// features/safety_check/data/repositories/safety_check_repository_impl.dart
class SafetyCheckRepositoryImpl implements SafetyCheckRepository {
  final SafetyCheckRemoteDataSource _remoteDataSource;

  SafetyCheckRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, SafetyCheck>> startSafetyCheck({required int durationMinutes}) async {
    try {
      final model = await _remoteDataSource.startTimer(durationMinutes);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi kích hoạt Safety Check'));
    }
  }
}

// 6. DATA SOURCE (Chỉ giao tiếp HTTP qua ApiClient)
// features/safety_check/data/datasources/safety_check_remote_data_source.dart
class SafetyCheckRemoteDataSource {
  final ApiClient _apiClient;

  SafetyCheckRemoteDataSource(this._apiClient);

  Future<SafetyCheckModel> startTimer(int durationMinutes) async {
    final response = await _apiClient.post(
      ApiConstants.safetyCheckStart,
      data: {'duration_minutes': durationMinutes},
    );
    return SafetyCheckModel.fromJson(response.data);
  }
}
```

---

## 20. Implementation & Quality Checklist

Trước khi hoàn thành bất kỳ pull request hoặc code task nào, hãy rà soát:

1. **Architecture Boundary:** Mã nguồn có tuân thủ sơ đồ phân tầng ở Mục 2 & 4 không?
2. **Forbidden Patterns:** Đã kiểm tra danh sách 12 điều cấm kỵ ở Mục 18 chưa?
3. **Design System Consistency:** Các components có dùng `AppColors`, `AppSpacing`, `AppRadius` từ evondevKit không? Có màu nào bị hardcode không?
4. **Error Handling:** Đã bọc `Failure` đầy đủ chưa? Có raw exception nào rò rỉ lên UI không?
5. **No God Files:** Có file nào vượt quá 400 dòng mã hoặc ôm đồm nhiều trách nhiệm không?
6. **Token Persistence:** Các tác vụ mạng có đi qua `ApiClient` có interceptor auto-refresh token không?
7. **Semantic Color Compliance:** Tuyệt đối không hard-code `Colors.red`, `Colors.green`, `Colors.yellow` hoặc `Color(0xFF...)`; bắt buộc dùng `context.colors` hoặc `AppColors`.

---

## 21. Color System (Hệ Thống Màu Sắc Semantic)

Quy định chuẩn hóa hệ thống màu sắc cho toàn bộ ứng dụng Personal Safety / Guardian AI.

### 21.1. Color Palette & Tỷ lệ Phân bổ Thị giác (Visual Ratio)
Giao diện tuân thủ quy tắc 4 nhóm màu với tỷ lệ phân bổ:
- **⚪ Neutral / White (~70%):** Chiếm đa số diện tích (Nền ứng dụng, Card, BottomSheet, Input, Divider, Text). Mang lại cảm giác sạch sẽ, bình tĩnh, tin cậy.
- **🟢 Green (~20%):** Màu nhận diện thương hiệu chính & trạng thái an toàn (Primary Action, Normal, Safe, Confirmed, Healthy GPS).
- **🔴 Red (~5%):** Màu khẩn cấp tuyệt đối (SOS Trigger, Active SOS Alert, Cancel Emergency Action). **TUYỆT ĐỐI KHÔNG dùng Red làm màu chủ đạo của app hay biến toàn bộ màn hình Home thành đỏ.**
- **🟡 Yellow (~5%):** Cảnh báo & Chú ý (Safety Check sắp hết giờ, GPS yếu, Chờ xác nhận, Chưa cấp quyền). Không dùng Yellow cho Emergency.

| Nhóm Màu | Token Name | Light Hex | Dark Hex | Ý nghĩa & Ứng dụng |
| :--- | :--- | :--- | :--- | :--- |
| **Primary (Safe)** | `primary` | `#16A34A` | `#4ADE80` | Nút chính (Bắt đầu, Lưu), trạng thái "Bạn đang an toàn", GPS OK. |
| | `primaryLight` | `#DCFCE7` | `#143823` | Nền Badge "Đang hoạt động", nền Banner an toàn. |
| | `primaryDark` | `#15803D` | `#22C55E` | Trạng thái nhấn, chữ tương phản cao trên nền sáng. |
| **Danger (SOS)** | `danger` | `#DC2626` | `#F87171` | Nút SOS khổng lồ, Banner báo động đỏ, Nút Dừng SOS khẩn cấp. |
| | `dangerLight` | `#FEE2E2` | `#3A1B1D` | Nền cảnh báo nguy hiểm, Badge "SOS Đang kích hoạt". |
| | `dangerDark` | `#B91C1C` | `#EF4444` | Header Active SOS, nút trạng thái nhấn khẩn cấp. |
| **Warning** | `warning` | `#D97706` | `#FBBF24` | Trạng thái "Sắp hết hạn", Mạng/GPS yếu, Contact chờ xác nhận. |
| | `warningLight` | `#FEF3C7` | `#382A12` | Nền Badge cảnh báo, nền Banner lưu ý. |
| | `warningDark` | `#B45309` | `#F59E0B` | Chữ cảnh báo tương phản cao. |
| **Neutrals** | `background` | `#F8FAF9` | `#0F1511` | Nền Scaffold toàn app (xám ngả xanh dịu mắt, không dùng #FFF chói). |
| | `surface` | `#FFFFFF` | `#17201B` | Nền Card, Dialog, Modal, Input. |
| | `textPrimary` | `#17201B` | `#F1F5F2` | Chữ tiêu đề và nội dung chính (WCAG AAA). |
| | `textSecondary`| `#66736B` | `#94A399` | Chữ phụ, caption, placeholder (WCAG AA). |
| | `border` | `#DDE5DF` | `#26332B` | Viền tóc 1px card, divider ngăn cách. |
| | `borderStrong` | `#BCC7BF` | `#384A3F` | Viền ô nhập (Input), viền nút Secondary. |
| | `disabled` | `#AAB5AE` | `#4D5E53` | Chữ/Icon của phần tử vô hiệu hóa. |
| | `disabledBg` | `#E8ECE9` | `#1D2620` | Nền nút/phần tử vô hiệu hóa. |

### 21.2. Phân cấp Màu Nút Bấm (Button Hierarchy)
- **Primary Button (Green):** Dùng cho hành động mang tính xây dựng, an toàn: "Bắt đầu Safety Check", "Xác nhận", "Lưu liên hệ", "Check in an toàn".
- **Danger Button (Red):** Dành riêng cho tình huống khẩn cấp: "Kích hoạt SOS" (3s hold), "Dừng SOS", "Hủy bỏ khẩn cấp".
- **Secondary Button:** Nền `surface` hoặc trong suốt, viền `borderStrong`, chữ `textPrimary`. Dùng cho hành động phụ.
- **Ghost Button:** Trong suốt hoàn toàn, chỉ có chữ/icon.
- **Warning Button:** Chỉ dùng khi hành động thực sự mang tính cảnh báo nguy cơ cao.

### 21.3. Ánh xạ Màu theo Feature (Feature Color Mapping)
1. **Home Screen:**
   - Ngôn ngữ thị giác: **White / Neutral + Green**.
   - Trạng thái bình thường: Badge "🟢 Bạn đang an toàn", Card Safety Check màu xanh dịu mắt.
   - Nút SOS: Điểm nhấn màu Đỏ (`danger`) duy nhất nổi bật ở vị trí chiến lược, không làm đỏ toàn màn hình.
2. **SOS Screen:**
   - Bình thường: Nền Neutral + Nút tròn SOS đỏ với hiệu ứng sóng lan tỏa.
   - Khi Active SOS: Header đỏ đậm (`dangerDark`), Banner đỏ nhẹ (`dangerLight`), thông tin tọa độ/thời gian trên nền thẻ trắng/neutral, Nút Dừng SOS màu đỏ viền/solid rõ ràng.
3. **Safety Check:**
   - Trạng thái An toàn (Safe/Active): Green (`primary`).
   - Trạng thái Sắp hết hạn (Warning < 5 phút): Yellow (`warning`).
   - Trạng thái Quá hạn / Kích hoạt SOS (Critical): Red (`danger`).
   - *Templates:* Giữ giao diện Neutral thống nhất, màu sắc chỉ biểu thị **trạng thái**, không tô màu rực rỡ theo từng loại template (Hiking, Working Late,...).
4. **Emergency Contacts (Vòng tròn an toàn):**
   - Đã xác nhận Telegram/SĐT: Badge Xanh (`primary`).
   - Chờ phản hồi: Badge Vàng (`warning`).
   - Lỗi gửi thông báo: Badge Đỏ (`danger`).
5. **Bottom Navigation Bar:**
   - Tab Active: `primary` (Green).
   - Tab Inactive: `textSecondary`.
   - Tab SOS có thể có chấm indicator màu đỏ nhẹ, không đổi màu toàn bộ thanh bar.

### 21.4. Cách sử dụng trong Mã nguồn
- **Cách 1 (Khuyên dùng trong Widget):** Truy cập qua extension:
  ```dart
  final colors = context.colors;
  Container(color: colors.primaryLight, child: Text('An toàn', style: TextStyle(color: colors.primaryDark)));
  ```
- **Cách 2 (Static constants khi cần):** `AppColors.primary`, `AppColors.danger`.
- **CẤM:** Tuyệt đối không dùng `Colors.green`, `Colors.red`, `Colors.yellow`, `Color(0xFF...)` trong code UI của Feature.

### 21.5. Dark Mode Architecture & Night Safety Philosophy (Kiến trúc Chế độ Tối)
Hệ thống Dark Mode của Guardian AI được thiết kế đặc thù cho bài toán **An toàn cá nhân ban đêm (Nighttime Emergency)**:

1. **Triệt tiêu chói lóa ban đêm (Anti-Glare / Deep Forest Tint):**
   - Không sử dụng màu đen tuyền tuyệt đối `#000000` (OLED Black) vì khi người dùng gặp nguy hiểm trong đêm tối, bật điện thoại sẽ bị chói mắt và làm mất khả năng quan sát xung quanh.
   - Sử dụng nền Deep Forest Tint (`#0F1511`) xám sẫm ngả xanh an toàn, dịu mắt và duy trì thích ứng bóng tối của đồng tử.

2. **Phân tầng bề mặt theo Sắc độ (Surface Elevation without Shadows):**
   - Trong Dark Mode, hiệu ứng đổ bóng mờ (`BoxShadow`) không thể hiện được độ sâu. Hệ thống phân tầng bằng 3 bậc màu bề mặt:
     $$\text{Scaffold Background (\#0F1511)} \;<\; \text{Card / Input Surface (\#17201B)} \;<\; \text{Dialog / Sheet Overlay (\#1E2922)}$$
   - Viền tóc 1px (`darkBorder: #26332B`) thay thế bóng để tạo ranh giới sắc nét cho các khối.

3. **Điều chỉnh Tông màu Trạng thái (Vibrancy Tuning):**
   - Màu Green đổi từ `#16A34A` (Light 600) $\rightarrow$ `#4ADE80` (Dark 400).
   - Màu Red đổi từ `#DC2626` (Light 600) $\rightarrow$ `#F87171` (Dark 400).
   - Màu Yellow đổi từ `#D97706` (Light 600) $\rightarrow$ `#FBBF24` (Dark 400).
   - *Lý do:* Tông 400 sáng rõ trên nền sẫm, đảm bảo nhìn thấy ngay lập tức tình trạng SOS hoặc an toàn mà không bị bão hòa quá mức.

4. **Đảo màu Tương phản Nút bấm (Automatic Contrast Switching):**
   - Khi ở Light Mode: Nền Green-600 đi cùng chữ trắng (`onPrimary: #FFFFFF`).
   - Khi ở Dark Mode: Nền Green-400 đi cùng chữ đen sẫm (`darkOnPrimary: #0F1511`), đạt tỷ lệ tương phản cực đại **> 11:1 (chuẩn WCAG AAA)**.
   - Tương tự cho `onDanger` và `onWarning`, tự động đảo bảo đảm không bao giờ xuất hiện chữ trắng mờ trên nền nút sáng.

5. **Đồng bộ System Overlays:**
   - Khi ở Dark Mode, thanh trạng thái (Status Bar) tự động đổi icon sang màu trắng (`Brightness.light`) thông qua `appBarTheme` cấu hình tập trung tại `app_theme.dart`.

---

## 22. Internationalization (i18n) Architecture

Quy định cấu trúc đa ngôn ngữ cho toàn bộ ứng dụng Personal Safety / Guardian AI.

### 22.1. Supported Locales & Fallback Strategy
- **Ngôn ngữ hỗ trợ:**
  - `vi`: Tiếng Việt (Vietnamese) — Ngôn ngữ mặc định chính thức.
  - `en`: Tiếng Anh (English).
- **Chiến lược chọn ngôn ngữ khởi tạo:**
  $$\text{User Preference (SecureStorage)} \;\longrightarrow\; \text{Device Locale (nếu hỗ trợ)} \;\longrightarrow\; \text{Fallback ('vi')}$$
  Không bao giờ để lộ key thô hoặc chữ `null` trên giao diện người dùng.

### 22.2. Vị trí Lưu trữ & Quy ước Đặt Key (ARB Resources)
Tài nguyên dịch đặt tập trung tại:
```text
lib/l10n/
├── app_en.arb   # Template chuẩn tiếng Anh kèm descriptions & placeholders
└── app_vi.arb   # Bản dịch tiếng Việt
```

#### Quy tắc đặt Key:
1. **Key mang tính Semantic, không phụ thuộc vào câu chữ:**
   - ✅ `homeStatusSafe`: "Bạn đang an toàn" / "You are safe"
   - ✅ `sosActivate`: "KÍCH HOẠT SOS" / "ACTIVATE SOS"
   - ✅ `safetyCheckExpiringSoon`: "Sắp hết thời gian xác nhận" / "Check-in Expiring Soon"
   - ❌ `banDangAnToan`, `youAreSafe` (SAI - phụ thuộc ngôn ngữ cụ thể).
2. **Tái sử dụng các Common Action Keys:** Các thao tác chung (`cancel`, `confirm`, `save`, `retry`, `delete`, `close`, `back`, `edit`) dùng chung key, không tạo `homeCancel`, `sosCancel`, `profileCancel`.
3. **Dynamic Interpolation & Pluralization:** Sử dụng placeholders trong ARB file, không cộng chuỗi thủ công:
   ```json
   "safetyCheckMinutesRemaining": "Còn {minutes} phút",
   "@safetyCheckMinutesRemaining": {
     "description": "Số phút còn lại",
     "placeholders": { "minutes": { "type": "int" } }
   }
   ```

### 22.3. Cách Truy cập trong UI
Truy cập thông qua `context.l10n`:
```dart
// Trong Widget:
Text(context.l10n.homeStatusSafe)
Text(context.l10n.safetyCheckMinutesRemaining(15))
```

### 22.4. Quản lý Trạng thái & Persistence (Language Switching)
- Quản lý qua Riverpod: `localeProvider` (`StateNotifier<Locale>`).
- Khi người dùng đổi ngôn ngữ trong `LanguageSelectorSheet`:
  - `LocaleController.setLocale(newLocale)` cập nhật `state`.
  - Tự động ghi vào `SecureStorage` với key `StorageKeys.languageCode`.
  - Toàn bộ cây widget tự động rebuild reactive mà **không làm mất navigation stack hay reset màn hình**.
- Không tạo Domain UseCase/Repository chỉ để đổi ngôn ngữ cục bộ (UI preference concern).

### 22.5. Xử lý Lỗi & Thông báo Hệ thống (Error Localization)
- Backend error / Infrastructure exceptions (`AppException`) trả về semantic code/failure (`LocationUnavailable`, `NetworkUnavailable`, `PermissionDenied`).
- Presentation map semantic failure thành chuỗi localized thông qua `context.l10n`:
  ```dart
  if (failure is LocationFailure) {
    showError(context.l10n.errorLocationUnavailable);
  }
  ```
- Không bao giờ render trực tiếp chuỗi exception tiếng Anh kỹ thuật từ Dio lên màn hình người dùng.

### 22.6. Quy trình Thêm Ngôn ngữ Mới
Khi thêm ngôn ngữ mới (ví dụ: `ja`, `ko`):
1. Tạo `lib/l10n/app_<lang>.arb`.
2. Khai báo locale mới trong `supportedLocales` và `supportedLanguageCodes`.
3. Cập nhật các bản dịch và test giao diện text expansion.
4. **Tuyệt đối không phải sửa đổi bất kỳ logic nghiệp vụ nào của các feature SOS, Safety Check hay Contacts.**

---

## 23. Emergency UX & Safety Check Specifications

Quy chuẩn kỹ thuật và trải nghiệm cho quy trình khẩn cấp (SOS) và hẹn giờ an toàn (Safety Check):

### 23.1. Cơ chế Hủy Báo động SOS bằng Mã PIN 4 Số (SOS Cancellation Policy)
1. **Bắt buộc xác thực Mã PIN 4 Số Cố định:**
   - Để hủy một phiên SOS đang hoạt động (`Active SOS`), người dùng **BẮT BUỘC** phải nhập đúng mã PIN 4 số bảo vệ (được lưu an toàn trong `SecureStorage` với key `StorageKeys.sosPinCode`).
   - *Lý do an toàn:* Ngăn chặn tuyệt đối tình huống kẻ tấn công ép nạn nhân bấm nút hủy hoặc điện thoại bị người lạ nhặt được bấm tắt báo động.
2. **Xử lý Sinh trắc học (Biometrics / FaceID / TouchID):**
   - Sinh trắc học chỉ đóng vai trò là **tùy chọn phụ trợ (optional fallback)** nếu thiết bị thật có phần cứng và đã đăng ký thành công.
   - **Mã PIN 4 số là chuẩn cốt lõi (Core Fallback):** Đảm bảo ứng dụng chạy và kiểm thử độc lập 100% trên cả Simulator / Android Emulator mà không bị chặn bởi các ràng buộc chứng chỉ iOS / Android Keystore.
3. **Phản hồi khi nhập sai:** Khi nhập sai mã PIN, hệ thống rung haptic cảnh báo, báo lỗi đỏ và KHÔNG hủy phiên SOS. Vị trí và âm thanh vẫn tiếp tục được phát tán tới 10 người thân Telegram.

### 23.2. Cấu trúc Mẫu Hẹn giờ An toàn (Safety Check Template Structure)
Mỗi mẫu Safety Check (Đi về nhà, Làm khuya, Thể thao ngoài trời, Đi xe đường dài) phải tuân thủ cấu trúc lựa chọn thời gian đồng bộ:
1. **5 Mốc thời gian cố định (Fixed Presets):**
   - Dạng nút chọn nhanh (Quick Chips / Segmented), giúp kích hoạt chỉ trong **1 chạm**.
   - Ví dụ các mốc chuẩn hóa: `15 phút`, `30 phút`, `45 phút`, `60 phút`, `90 phút` (hoặc các mốc phù hợp đặc thù của từng template).
2. **1 Mốc Tùy chỉnh (Custom Duration):**
   - Nút hoặc ô nhập `Tùy chỉnh (Custom)` cho phép người dùng tự điền số phút mong muốn (với ràng buộc kiểm tra hợp lệ: tối thiểu 1 phút, tối đa 24 giờ / 1440 phút).
3. **Quy tắc Giao diện:**
   - Các mốc thời gian hiển thị gọn gàng, trạng thái chọn có viền `primary` và nền `primaryLight`.
   - Giữ giao diện thẻ phẳng viền tóc 1px, không tô mỗi mẫu một màu sặc sỡ làm mất tính nghiêm túc của ứng dụng an toàn.

---

## 24. Responsive & Cross-Device Adaptation Architecture

Đặc tả tiêu chuẩn tương thích giao diện và trải nghiệm đa thiết bị cho toàn bộ hệ sinh thái Guardian AI:

### 24.1. Hệ thống Breakpoints & Nhận diện Thiết bị
Quy định phân lớp kích thước màn hình theo [`AppBreakpoints`](file:///d:/Projects/Guardian_AI/frontend/lib/shared/responsive/app_breakpoints.dart):
- **Compact Mobile (`width < 380px`):** Dành cho iPhone SE (375px), iPhone Mini, các dòng Android giá rẻ.
  - Padding lề giảm còn `12px`.
  - Nút SOS điều chỉnh đường kính về `150px` để không đẩy tràn màn hình.
- **Standard Mobile (`380px <= width < 600px`):** Chuẩn mực cho iPhone 13-16 (390px - 440px), Samsung Galaxy S21-S24, Google Pixel.
  - Padding lề chuẩn `16px`.
  - Nút SOS đường kính chuẩn `175px`.
- **Tablet / iPad / Foldable (`width >= 600px`):** Dành cho iPad Mini, iPad Pro, máy tính bảng Android, màn hình gập mở rộng.
  - **Giới hạn Độ rộng Nội dung (Content Max-Width Cap):** Toàn bộ nội dung chính phải được bọc trong `ConstrainedBox(maxWidth: 520px)` và căn giữa màn hình (`Center`).
  - *Lý do:* Giữ trọn công thái học (Thumb Zone) 1 tay, tránh tình trạng nút SOS bị phóng đại khổng lồ bẹt dúm và mắt người dùng phải lia ngang mệt mỏi.

### 24.2. Bảo vệ Vùng An toàn (Safe Area Safeguard)
- **iOS:** Tự động né Notch, Dynamic Island phía trên và thanh vuốt Home Indicator phía dưới thông qua `SafeArea`.
- **Android:** Tự động né camera nốt ruồi (Punch-hole) và thanh điều hướng 3 nút ảo cũ (Soft Navigation Keys).
- Tuyệt đối không để nút bấm SOS hoặc các nút hành động nằm đè lên thanh Home Bar gây trượt ngón tay khi vuốt.

### 24.3. Bảo vệ Cỡ chữ Hệ thống (Text Scaling Clamp)
- Người dùng lớn tuổi hoặc mắt kém thường bật cỡ chữ 150% - 200% trong cài đặt trợ năng OS.
- Ứng dụng cấu hình `TextScaler.linear(scale.clamp(0.85, 1.25))` tại `MaterialApp.builder` để đảm bảo:
  - Chữ vẫn to rõ theo nhu cầu của người dùng.
  - Không bao giờ bị lỗi tràn viền (RenderFlex overflow) hoặc làm chữ trên nút SOS bị rớt dòng.

### 24.4. Quy tắc Không Cuộn Ngang (Zero Horizontal Scrolling)
- Áp dụng triệt để quy tắc `R1`: Toàn bộ màn hình không bao giờ được phép xuất hiện thanh cuộn ngang ngoài ý muốn ở độ rộng tối thiểu 360px - 375px.
- Mọi danh sách thẻ hoặc bộ đếm nếu dài phải cuộn dọc hoặc cuộn ngang bên trong khung riêng (`overflow-x-auto`) có padding nội bộ hợp lệ.





