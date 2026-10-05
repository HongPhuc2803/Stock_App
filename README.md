# SmartStock

Ứng dụng quản lý cửa hàng được xây dựng bằng Flutter và Firebase, hỗ trợ quản lý sản phẩm, tồn kho, bán hàng tại quầy (POS), đơn hàng, khách hàng và nhân viên.

## Tính năng chính

- **Tài khoản:** đăng ký cửa hàng, đăng nhập bằng email/mật khẩu, đặt lại mật khẩu và cập nhật hồ sơ.
- **Sản phẩm:** quản lý danh mục, sản phẩm, biến thể và hình ảnh lưu trên Firebase Storage.
- **Kho hàng:** xem tồn kho, nhập hàng, điều chỉnh số lượng và tra cứu lịch sử giao dịch kho.
- **POS và đơn hàng:** giỏ hàng, giảm giá, thanh toán, lịch sử đơn hàng và hóa đơn PDF.
- **Khách hàng và nhân viên:** quản lý thông tin khách hàng, tài khoản nhân viên và vai trò.
- **Dashboard và báo cáo:** theo dõi doanh thu, lợi nhuận, đơn hàng, sản phẩm bán chạy; chia sẻ báo cáo PDF và sao chép dữ liệu CSV.
- **Cài đặt và thông báo:** cấu hình cửa hàng, tùy chọn thông báo, trung tâm thông báo và cảnh báo kết nối mạng.

## Vai trò người dùng

| Vai trò | Các màn hình chính |
| --- | --- |
| Chủ cửa hàng (`OWNER`) | Dashboard, sản phẩm, danh mục, POS, kho, đơn hàng, báo cáo, khách hàng, nhân viên và cài đặt cửa hàng |
| Nhân viên bán hàng (`STAFF`) | POS, tra cứu sản phẩm, đơn hàng, khách hàng và cài đặt cá nhân |
| Quản lý kho (`WAREHOUSE_MANAGER`) | Tồn kho, nhập hàng, điều chỉnh kho, lịch sử kho và cài đặt cá nhân |

Ứng dụng điều hướng theo vai trò và sử dụng `storeId` để gắn dữ liệu với cửa hàng. Quyền truy cập dữ liệu được quy định trong [firestore.rules](firestore.rules) và [storage.rules](storage.rules).

## Công nghệ và cấu trúc

- **Flutter / Dart:** giao diện và logic ứng dụng; ràng buộc Dart SDK là `^3.10.4`.
- **Riverpod:** quản lý trạng thái và cung cấp dependency.
- **GoRouter:** điều hướng và kiểm tra phiên đăng nhập/vai trò.
- **Firebase:** Authentication, Cloud Firestore, Storage; tích hợp thêm Messaging, Analytics và Crashlytics tùy nền tảng.
- **Tiện ích:** `pdf`, `printing`, `image_picker`, `intl`, `connectivity_plus`.

```text
lib/
  main.dart                # Khởi tạo Firebase và ứng dụng
  firebase_options.dart    # Cấu hình Firebase theo nền tảng
  app/                     # App, router, providers và điều hướng theo vai trò
  core/                    # Theme, định dạng, lỗi, dịch vụ và widget dùng chung
  features/                # Các mô-đun nghiệp vụ
    auth/                  # Xác thực
    products/              # Sản phẩm và danh mục
    inventory/             # Quản lý kho
    pos/                   # Bán hàng tại quầy
    orders/                # Đơn hàng và hóa đơn
    customers/             # Khách hàng
    employees/             # Nhân viên
    dashboard/             # Tổng quan cửa hàng
    reports/               # Báo cáo và xuất dữ liệu
    notifications/         # Thông báo
    settings/              # Hồ sơ và cài đặt
test/                      # Unit test và widget test
firestore.rules            # Quyền truy cập Firestore
firestore.indexes.json     # Chỉ mục truy vấn Firestore
storage.rules              # Quyền truy cập Storage
firebase.json              # Cấu hình Firebase CLI
```

Các mô-đun được tách thành `data`, `domain` và `presentation` khi cần: repository triển khai truy cập dữ liệu, entity/interface mô tả nghiệp vụ, provider và screen phục vụ giao diện.

## Cài đặt và khởi chạy

### 1. Chuẩn bị môi trường

- Flutter SDK có Dart tương thích với [pubspec.yaml](pubspec.yaml).
- Chrome để chạy web; Android SDK và emulator/thiết bị thật để chạy Android.
- Nếu chạy Windows desktop, cài bộ công cụ phát triển desktop C++ của Visual Studio và bật **Developer Mode** để hỗ trợ symlink cho plugin.
- Nếu chạy iOS/macOS, chuẩn bị máy Mac với Xcode và CocoaPods.
- Khi cấu hình Firebase: cần Node.js, Firebase CLI, FlutterFire CLI và quyền truy cập Firebase project.

Từ thư mục gốc dự án:

```powershell
flutter doctor -v
flutter pub get
flutter devices
```

### 2. Cấu hình Firebase

Repository đã có `lib/firebase_options.dart`. Khi sử dụng Firebase project riêng, tạo lại cấu hình cho các nền tảng cần chạy:

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

Trong Firebase Console, bật **Authentication → Email/Password**, tạo **Cloud Firestore** và **Storage**. Đảm bảo các cấu hình Dart/native cùng trỏ tới project đã chọn.

Triển khai rules và indexes của repository vào project đó; thay `YOUR_PROJECT_ID` bằng ID thực tế:

```powershell
firebase deploy --project YOUR_PROJECT_ID --only "firestore:rules,firestore:indexes,storage"
```

Lệnh trên cập nhật cấu hình trên Firebase project được chỉ định. Không đưa service-account JSON hoặc private key vào repository.

### 3. Chạy ứng dụng

Chạy trên Chrome:

```powershell
flutter run -d chrome
```

Hoặc chọn thiết bị từ kết quả `flutter devices`, thay `DEVICE_ID` bằng ID tương ứng:

```powershell
flutter run -d DEVICE_ID
```

Windows desktop:

```powershell
flutter run -d windows
```

Đăng ký trong ứng dụng sẽ tạo một cửa hàng mới và tài khoản `OWNER`. Sau đó thêm sản phẩm, nhập kho và thử tạo đơn hàng qua POS; tạo nhân viên từ màn hình quản lý nhân viên của chủ cửa hàng.

## Kiểm tra và build

```powershell
flutter analyze
flutter test
flutter build web --release
```

Bộ test hiện có kiểm tra giỏ hàng, model người dùng/cửa hàng, định dạng tiền tệ, trạng thái giao diện, điều hướng thích ứng, CSV và một số cấu hình Firebase/Android. Các kiểm tra nội dung rules chưa thay thế kiểm thử quyền truy cập thực tế bằng Firebase Emulator.

Để build Android phát hành, tạo `android/key.properties` với cấu hình upload keystore:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=PATH_TO_UPLOAD_KEYSTORE
```

Thay các giá trị mẫu bằng cấu hình thực tế; dùng đường dẫn dạng `C:/keys/upload-keystore.jks` trên Windows. File cấu hình và keystore đã được Git bỏ qua. Sau khi cấu hình ký:

```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
```

Giữ lại thư mục symbol theo từng bản phát hành để phục vụ phân tích lỗi.

## Giới hạn hiện tại

- Firebase options đã có cho web, Android, iOS, macOS và Windows; Linux chưa được cấu hình. Cần kiểm tra khả năng hỗ trợ từng plugin trên nền tảng triển khai.
- Messaging và Crashlytics chỉ được khởi tạo có điều kiện trên Android/iOS/macOS; luồng push notification vẫn cần hoàn thiện đăng ký/luân chuyển token và cấu hình APNs cho iOS.
- CSV hiện được sao chép vào clipboard; chưa có luồng lưu/chia sẻ file CSV hoàn chỉnh.
- Có cảnh báo mất kết nối; chưa có hàng đợi nghiệp vụ offline riêng cho thao tác đơn hàng và kho.
- Cần kiểm thử phân quyền, truy cập chéo cửa hàng và các luồng bán hàng/kho trên môi trường Firebase trước khi phát hành.
