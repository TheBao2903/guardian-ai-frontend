# Deploy Flutter web bằng Git trên Vercel

Repo này chứa trực tiếp `pubspec.yaml`, `lib/`, `web/`, `vercel.json`.

## Cấu hình project

- Root Directory: để mặc định (gốc repo), không nhập `frontend` hoặc `build/web`.
- Framework Preset: Other.
- Build Command: `bash scripts/vercel-build.sh` (đã khai báo trong vercel.json).
- Output Directory: `build/web` (đã khai báo trong vercel.json).
- Không cần commit thư mục build; Vercel tạo nó trong mỗi lần build.

Script tải Flutter 3.47.6, chạy pub get và build web. Nó tạo file `.env` rỗng
nếu thiếu để đáp ứng asset trong pubspec.yaml. URL backend được truyền bằng
`--dart-define`, không cần commit `.env`.

Backend mặc định trùng cấu hình frontend hiện tại:

```text
API_BASE_URL=https://guardian-ai-backend-srdi.onrender.com/api/v1
WS_BASE_URL=wss://guardian-ai-backend-srdi.onrender.com/api/v1/realtime/ws
```

Có thể đổi hai giá trị này trong Vercel Environment Variables. Nếu chỉ đặt
API_BASE_URL, script suy ra WS_BASE_URL từ URL đó.

## Áp dụng

1. Commit và push `vercel.json`, `scripts/vercel-build.sh`, `.gitattributes`
   lên nhánh deploy.
2. Tạo deployment mới từ commit đó. Redeploy một commit cũ sẽ không có bản sửa.
3. Build Logs phải hiển thị `Flutter web build complete: build/web`.
4. Deployment Output phải có `index.html`, `flutter_bootstrap.js`, `main.dart.js`
   ở gốc output, cùng `assets/` và `canvaskit/`.
5. Chờ deployment Ready rồi mở URL production. Nếu chỉ deployment preview mới
   hoạt động, kiểm tra production domain đã trỏ tới deployment mới hay chưa.

Chỉ chạy Vercel CLI trực tiếp trong `build/web` là một luồng deploy tĩnh khác;
không áp dụng cấu hình build source ở gốc repo cho thư mục output đó.
