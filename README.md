# 🛡️ Guardian AI — Trợ Lý An Toàn Cá Nhân & Cứu Hộ Khẩn Cấp Bằng Trí Tuệ Nhân Tạo

> **Dự án Khởi nghiệp Đổi mới Sáng tạo: Giải pháp bảo vệ an toàn chủ động 24/7, tự động phát hiện nguy hiểm bằng Edge AI và kết nối cứu hộ tức thì.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B?logo=flutter)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-blue)]()
[![State Management](https://img.shields.io/badge/Architecture-Riverpod%20%2B%20Clean%20Architecture-brightgreen)]()
[![Edge AI](https://img.shields.io/badge/Edge%20AI-Google%20YAMNet%20TFLite-purple)](https://tfhub.dev/google/yamnet/1)
[![Backend Live](https://img.shields.io/badge/Backend-FastAPI%20%2B%20Render%20Live-orange)](https://guardian-ai-backend-srdi.onrender.com/health)

---

## 🌟 1. Bối cảnh & Tầm nhìn Khởi nghiệp (The Problem & The Vision)

### 🚨 Vấn đề nhức nhối của xã hội (The Pain Points)
Trong xã hội hiện đại, nguy cơ mất an toàn cá nhân luôn tiềm ẩn:
* **Bạo lực & Quấy rối đường phố:** Phụ nữ, học sinh, sinh viên và người lao động thường xuyên phải di chuyển một mình qua những cung đường vắng vào ban đêm.
* **Tai nạn & Sự cố y tế bất ngờ:** Người cao tuổi sống một mình hoặc người có tiền sử bệnh tim mạch đột ngột bị ngất xỉu, đột quỵ mà không thể gọi cứu hộ.
* **Tài xế công nghệ & Người làm ca đêm:** Đối mặt với nguy cơ cướp giật, hành hung trong lúc làm việc.
* **"Khoảng lặng sinh tử" (The Golden 10 Seconds):** Khi xảy ra biến cố hoặc bị khống chế, nạn nhân **chỉ có 3 đến 5 giây để phản ứng** hoặc **hoàn toàn mất khả năng thao tác** (bị giật điện thoại, bị trói, bất tỉnh). Các ứng dụng SOS truyền thống thất bại vì yêu cầu người dùng phải tự mở máy, bấm số 113/115 hoặc tự gõ tin nhắn cầu cứu.

### 💡 Giải pháp đột phá từ Guardian AI (Our Innovation)
**Guardian AI** được sinh ra với sứ mệnh trở thành một **"Người vệ sĩ kỹ thuật số 24/7"**, chuyển dịch phương thức bảo vệ từ **BỊ ĐỘNG** sang **CHỦ ĐỘNG**:
1. **Lắng nghe và phát hiện thông minh (Edge AI):** Ứng dụng tự động nhận diện tiếng la hét, tiếng khóc cầu cứu, tiếng kính vỡ, tiếng súng/nổ ngay trên thiết bị mà người dùng không cần chạm vào máy.
2. **Cơ chế đếm ngược an toàn (Smart Safety Check):** Tự động báo động và gửi tọa độ GPS cho người thân nếu người dùng đi taxi/về khuya mà không xác nhận an toàn đúng giờ.
3. **Mã PIN chống cưỡng bức độc quyền (Duress PIN):** Đánh lừa kẻ tấn công khi bị ép tắt báo động, ngầm gửi cảnh báo mức ĐỎ đến mạng lưới cứu trợ.
4. **Bảo vệ quyền riêng tư tuyệt đối (Privacy-First):** AI xử lý cục bộ trên RAM điện thoại, không lưu trữ và không gửi âm thanh sinh hoạt đời thường lên đám mây.

---

## 🎯 2. Tổng hợp các Tính năng Cốt lõi (Detailed Feature Breakdown)

Dưới đây là chi tiết toàn bộ các module tính năng đã được hiện thực hóa hoàn chỉnh trong hệ sinh thái Guardian AI:

```
                             HỆ SINH THÁI GUARDIAN AI
                                       │
      ┌────────────────┬───────────────┴───────────────┬────────────────┐
      ▼                ▼                               ▼                ▼
[AI Audio Shield] [Smart Safety Check]           [One-Tap SOS]    [Medical Profile]
  - Edge YAMNet    - Lịch trình đếm ngược         - Còi hú & Flash - Nhóm máu, Dị ứng
  - Lọc tiếng ồn   - Tự động SOS khi hết giờ      - Chống cưỡng bức- Bệnh lý nền
  - Privacy First  - Template đi xe/về khuya      - Duress PIN     - Gửi kèm cấp cứu
```

---

### 🔊 Tính năng 1: AI Audio Shield — Lá Chắn Âm Thanh Thời Gian Thực
* **Mô tả:** Hệ thống sử dụng mô hình học sâu **Google YAMNet (TensorFlow Lite)** chạy trực tiếp trên thiết bị (On-device Edge AI) để phân loại âm thanh xung quanh thành 521 nhãn âm học.
* **Các âm thanh nguy hiểm được nhận diện tự động:**
  * 😱 **Tiếng la hét (Screaming / Shout / Yell)**
  * 😭 **Tiếng khóc lóc, kêu cứu (Distress Cry / Wail)**
  * 🪟 **Tiếng kính vỡ (Glass Shatter)**
  * 💥 **Tiếng súng, tiếng nổ (Gunshot / Explosion)**
  * 🚨 **Còi báo động khẩn cấp (Siren / Environmental Alarm)**
* **Bảo vệ quyền riêng tư (Privacy-First):** Âm thanh môi trường chỉ được lưu tạm thời trên bộ nhớ đệm xoay vòng (Ring Buffer RAM 4 giây). Nếu không phát hiện nguy hiểm, dữ liệu bị ghi đè và hủy ngay lập tức. Âm thanh đời thường KHÔNG BAO GIỜ bị gửi lên Internet.
* **Bộ lọc chống báo động giả thông minh (Noise Rejection & Cooldown):** Thuật toán Temporal Aggregator kết hợp Cooldown Manager loại trừ chính xác tiếng ho, tiếng cười nói thông thường hoặc âm thanh tivi để không làm phiền người dùng.

---

### ⏱️ Tính năng 2: Smart Safety Check — Giám Sát Lộ Trình & Đếm Ngược An Toàn
* **Mô tả:** Dành cho các tình huống người dùng chuẩn bị bước vào môi trường rủi ro: Đi taxi/xe ôm công nghệ một mình, đi bộ qua ngõ vắng về đêm, gặp gỡ người lạ, đi làm thêm ca muộn.
* **Cách thức hoạt động:**
  1. Người dùng chọn một mẫu lịch trình định sẵn (*Đi taxi ban đêm - 15 phút, Đi dạo đêm - 30 phút, Gặp đối tác mới - 45 phút*) hoặc tự tạo thời lượng hẹn giờ.
  2. Màn hình đếm ngược trực quan hiển thị trạng thái và thời gian còn lại.
  3. Khi hết giờ, ứng dụng rung chuông nhắc nhở người dùng bấm nút **"Tôi an toàn"**.
  4. Người dùng có thể linh hoạt **Gia hạn thời gian** nếu chuyến đi kéo dài hơn dự kiến.
* **Cơ chế Cứu sinh Tự động (Fail-safe Auto SOS):**
  * Nếu hết giờ và qua thời gian ân hạn 60 giây (Grace Period) mà người dùng **KHÔNG phản hồi** (dấu hiệu đã bị bất tỉnh, đột quỵ, hoặc bị khống chế giật mất điện thoại):
  * **Hệ thống sẽ TỰ ĐỘNG kích hoạt trạng thái SOS khẩn cấp**, bật định vị GPS và gửi tin báo động cứu hộ ngay lập tức tới người thân!

---

### 🚨 Tính năng 3: One-Tap SOS — Kích Hoạt Báo Động Tức Thì
* **Kích hoạt siêu tốc:** Nút SOS nổi bật tại trung tâm màn hình, hỗ trợ kích hoạt khẩn cấp chỉ với 1 chạm.
* **Đếm ngược an toàn 5 giây:** Đi kèm âm thanh bíp cảnh báo và thanh tiến trình cho phép người dùng bấm hủy kịp thời nếu lỡ tay chạm nhầm.
* **Còi báo động âm lượng cực đại (Strobe Siren):** Phát âm thanh còi cứu thương/báo động dồn dập ở mức âm lượng cao nhất để làm kẻ xấu giật mình, hoảng sợ và bỏ chạy.
* **Đèn pin nhấp nháy liên tục (Strobe Flashlight):** Tự động điều khiển đèn flash điện thoại nhấp nháy theo tần số cao để thu hút sự chú ý của người đi đường xung quanh và hỗ trợ lực lượng cứu hộ định vị trong bóng tối.
* **Bảo vệ quyền riêng tư 100% (Zero Cloud Storage):** Hệ thống không lưu trữ hay tải file âm thanh lên đám mây, triệt tiêu mọi nguy cơ lộ lọt dữ liệu giọng nói và bảo đảm tính bảo mật cá nhân tuyệt đối.

---

### 🤫 Tính năng 4: Duress PIN — Cơ Chế Mã PIN Chống Cưỡng Bức Độc Quyền
*(Điểm sáng tạo công nghệ độc đáo được Hội đồng giám khảo & Nhà đầu tư đánh giá rất cao)*

* **Tình huống thực tế:** Khi nạn nhân bị kẻ cướp, kẻ bắt cóc hoặc hung thủ khống chế và ép buộc: *"Mở điện thoại tắt ngay cái chuông báo động đi không tao giết!"*.
* **Giải pháp của Guardian AI: Cơ chế mã PIN kép:**
  * 🟢 **Safe PIN (Mã an toàn, ví dụ: `1234`):** Nhập khi người dùng thực sự an toàn -> Hệ thống tắt còi, kết thúc phiên SOS bình thường.
  * 🔴 **Duress PIN (Mã cưỡng bức, ví dụ: `9999`):** Nhập khi người dùng đang bị đe dọa, ép buộc:
    * **Trên màn hình điện thoại:** Ứng dụng lập tức tắt còi hú, tắt đèn flash và hiển thị thông báo "Đã hủy phiên SOS" như bình thường để **đánh lừa kẻ tấn công**, giúp kẻ xấu tin rằng nạn nhân đã quy phục và không gây tổn hại thân thể cho nạn nhân.
    * **Ngầm bên dưới hệ thống (Silent Escalation):** Backend lập tức ghi nhận trạng thái `DURESS_PIN`, kích hoạt chuông báo động đỏ mức cao nhất và âm thầm gửi tin khẩn cấp tới người thân & cơ quan chức năng:  
      ⚠️ **"CẢNH BÁO NGUY HIỂM: Nạn nhân vừa nhập mã cưỡng bức dưới sự uy hiếp của hung thủ! Vị trí hiện tại: [Link Google Maps]"**.
* **Bảo mật tuyệt đối:** Mã PIN được băm bằng thuật toán **Bcrypt (Cost Factor = 10)** với salt ngẫu nhiên, không lưu plaintext, vô hiệu hóa vĩnh viễn mã mặc định ngay khi đổi mã mới.

---

### 📲 Tính năng 5: Mạng Lưới Cứu Trợ Đa Kênh & Telegram Bot Dispatcher
* **Danh bạ khẩn cấp phân tầng:** Cho phép thiết lập danh sách người thân, bạn bè với các cấp độ ưu tiên (Ưu tiên 1, Ưu tiên 2, Ưu tiên 3).
* **Thông báo cứu trợ siêu tốc qua Telegram Bot:**
  * Tin nhắn thông báo tức thì chỉ trong vòng 1 - 2 giây.
  * Tự động gửi **tọa độ GPS chính xác kèm đường link Google Maps** chỉ đường trực tiếp tới vị trí nạn nhân.
  * Đính kèm thông tin y tế sinh tử và phân cấp mức độ rủi ro khẩn cấp.
* **Phím gọi khẩn cấp 1 chạm:** Tích hợp phím tắt quay số nhanh tới các tổng đài cứu hộ khẩn cấp quốc gia:
  * 🚓 **113:** Cảnh sát phản ứng nhanh
  * 🚒 **114:** Cứu hỏa & Cứu nạn cứu hộ
  * 🚑 **115:** Cấp cứu y tế

---

### 🩺 Tính năng 6: Medical Profile — Hồ Sơ Y Tế Sinh Tử
* Lưu trữ hồ sơ y tế cốt lõi ngay trên ứng dụng:
  * **Nhóm máu** (A, B, AB, O, Rh+, Rh-)
  * **Tiền sử dị ứng thuốc & thực phẩm** (VD: Dị ứng Penicillin, Aspirin...)
  * **Bệnh lý nền mãn tính** (Hen suyễn, Tim mạch, Đái tháo đường, Động kinh...)
  * **Thuốc đang sử dụng định kỳ**
  * **Số điện thoại bác sĩ riêng hoặc người bảo hộ y tế**
* Khi xảy ra tai nạn hoặc người dùng ngất xỉu, thông tin này được đính kèm vào bản tin cứu hộ giúp nhân viên y tế / người qua đường cấp cứu đúng cách ngay trong "thời gian vàng", tránh sốc phản vệ hoặc truyền nhầm nhóm máu.

---

### 🌐 Tính năng 7: Đa Ngôn Ngữ & Đa Nền Tảng (Cross-platform Responsive)
* **Song ngữ toàn diện:** Hỗ trợ hoàn chỉnh **Tiếng Việt** và **Tiếng Anh** (bản địa hóa chuẩn `.arb`).
* **Hỗ trợ giao diện tối/sáng (Dark/Light Mode):** Tự động thích ứng theo hệ thống hoặc tùy chọn thủ công.
* **Chạy mượt trên mọi thiết bị:** Tối ưu từ màn hình điện thoại thông minh (Android, iOS) cho đến giao diện máy tính bảng và trình duyệt Web (Web SPA deploy trên Vercel).

---

## 🏗️ 3. Kiến trúc Công nghệ Frontend (Flutter Clean Architecture)

Frontend được phát triển theo mô hình **Clean Architecture 3 lớp kết hợp Feature-first**:

```
frontend/lib/
├── app/                     # Cấu hình App, Routing (GoRouter), Theme, Localization
├── core/                    # Hạ tầng lõi tái sử dụng
│   ├── constants/           # ApiConstants, StorageKeys
│   ├── device/              # Tương tác phần cứng thiết bị
│   │   ├── audio/           # YAMNet TFLite, Audio Recorder, RingBuffer, AudioPlayer
│   │   ├── flashlight/      # Điều khiển đèn Flash nhấp nháy
│   │   ├── location/        # Dịch vụ định vị GPS Geolocator
│   │   └── phone/           # Trình quay số điện thoại khẩn cấp
│   ├── network/             # Dio HTTP Client, Interceptor gắn Token, Refresh Token
│   └── storage/             # FlutterSecureStorage mã hóa an toàn trên thiết bị
├── features/                # Các tính năng nghiệp vụ độc lập
│   ├── auth/                # Đăng ký, đăng nhập, quản lý mã PIN
│   ├── contacts/            # Quản lý danh bạ người thân khẩn cấp
│   ├── home/                # Màn hình chính, Widget SOS, Quick Tools
│   ├── profile/             # Thông tin cá nhân, Cài đặt ngôn ngữ, Theme
│   ├── safety_check/        # Quản lý template & đếm ngược an toàn
│   └── sos/                 # Phiên SOS, Giao diện còi hú, Xác thực Safe/Duress PIN
└── shared/                  # UI Kit dùng chung (Buttons, Cards, Badges, Responsive Wrapper)
```

---

## 💼 4. Tiềm năng Thị trường & Mô hình Kinh doanh (Business & Market Impact)

### 📈 Quy mô thị trường (Market Opportunity)
* **Thị trường mục tiêu:** Hơn **70 triệu người dùng smartphone tại Việt Nam** và hơn **400 triệu người dùng tại khu vực Đông Nam Á**.
* **Phân khúc khách hàng trọng tâm:**
  * **Phụ nữ & Trẻ em:** Nhu cầu tự vệ và an tâm khi đi lại một mình.
  * **Người cao tuổi & Bệnh nhân mãn tính:** Cần công cụ phát hiện ngã, đột quỵ và cứu hộ y tế tức thời.
  * **Tài xế công nghệ & Người lao động tự do (Gig Economy):** Hơn 1 triệu tài xế Grab, Be, ShopeeFood, Shipper di chuyển liên tục ban đêm.

### 💰 Chiến lược Thương mại hóa (Revenue Model)
1. **Mô hình B2C (Freemium):**
   * *Bản Miễn Phí (Free Tier):* Sử dụng đầy đủ tính năng cốt lõi (SOS 1 chạm, Safety Check cơ bản, Còi hú, 1 liên hệ khẩn cấp).
   * *Bản Cao Cấp (Premium Subscription - 29.000đ/tháng hoặc 299.000đ/năm):* Kết nối không giới hạn người thân, ưu tiên phân tích Audio AI nâng cao, tích hợp bảo hiểm tai nạn cá nhân.
2. **Mô hình B2B (Doanh nghiệp & Trường học):**
   * Bán gói giải pháp bảo đảm an toàn cho các tập đoàn gọi xe công nghệ (Grab, Be, Gojek, Xanh SM) tích hợp bảo vệ tài xế của họ.
   * Cung cấp giải pháp an toàn sinh viên cho các trường Đại học, Ký túc xá, Ban quản lý tòa nhà chung cư.
3. **Mô hình B2G (Chính phủ & Thành phố Thông minh - Smart City):**
   * Kết nối luồng dữ liệu cảnh báo với trung tâm điều hành cứu hộ 113/115 của đô thị thông minh, góp phần nâng cao an ninh trật tự xã hội.

---

## 🚀 5. Hướng dẫn Cài đặt & Trải nghiệm

### Yêu cầu môi trường
* Flutter SDK: `>= 3.19.0`
* Dart SDK: `>= 3.3.0`
* Trình duyệt Chrome hoặc thiết bị Android/iOS có camera/micro.

### Khởi chạy Local
```bash
# 1. Di chuyển vào thư mục frontend
cd frontend

# 2. Cài đặt các packages
flutter pub get

# 3. Tạo file cấu hình môi trường (.env)
cp .env.example .env
# File .env đã được cấu hình sẵn trỏ tới Backend Production:
# API_BASE_URL=https://guardian-ai-backend-srdi.onrender.com/api/v1
# WS_BASE_URL=wss://guardian-ai-backend-srdi.onrender.com/api/v1/realtime/ws

# 4. Khởi chạy trên trình duyệt Chrome (Web)
flutter run -d chrome

# Hoặc khởi chạy trên thiết bị di động thật
flutter run
```

### Build bản Web tĩnh deploy Vercel
```bash
flutter build web --release
cd build/web
npx vercel --prod
```

---

## 🏆 6. Đội ngũ Phát triển & Thông điệp Dự án

> *"Công nghệ chỉ thực sự có ý nghĩa khi nó bảo vệ sinh mạng và sự bình an của con người."*

Dự án **Guardian AI** là kết tinh của niềm đam mê công nghệ, tinh thần trách nhiệm xã hội và khát vọng khởi nghiệp của những người trẻ Việt Nam. Chúng tôi tin rằng Guardian AI không chỉ là một sản phẩm phần mềm, mà là **tấm khiên bảo vệ cho hàng triệu gia đình**.

* **Liên hệ & Hợp tác đầu tư:** Guardian AI Team
* **Demo Backend API:** [https://guardian-ai-backend-srdi.onrender.com/health](https://guardian-ai-backend-srdi.onrender.com/health)
* **Swagger API Docs:** [https://guardian-ai-backend-srdi.onrender.com/docs](https://guardian-ai-backend-srdi.onrender.com/docs)

---
*© 2026 Guardian AI — Công nghệ vì sự an toàn của con người.*
