# eCRM Pro

Ứng dụng quản lý khách hàng (eCRM) đa nền tảng được xây dựng bằng Flutter & Node.js, hỗ trợ cả iOS và Android.

---

## Tính năng

### Người dùng
- Đăng nhập / Đăng ký bằng Email & Mật khẩu
- Xác thực OTP tự động (OTP Autofill)
- Bảo mật sinh trắc học (Local Auth)
- Phát hiện thiết bị đã root/jailbreak
- Tìm kiếm sản phẩm (hỗ trợ tìm kiếm bằng giọng nói)
- Lọc sản phẩm theo danh mục
- Xem chi tiết sản phẩm & đánh giá (Rating)
- Deal of the Day
- Giỏ hàng
- Thanh toán qua Google Pay / Apple Pay
- Địa chỉ giao hàng (Buy Now)
- Xem danh sách đơn hàng & trạng thái
- Chat thời gian thực (Socket.IO)
- Camera & quay video
- Đăng xuất tự động theo timeout

### Admin Panel
- Xem tất cả sản phẩm
- Thêm / Xóa sản phẩm (tải ảnh lên Cloudinary)
- Chỉnh sửa thông tin sản phẩm
- Quản lý đơn hàng & cập nhật trạng thái
- Xem doanh thu tổng hợp
- Biểu đồ doanh thu theo danh mục
- Quản lý chi nhánh (thêm / sửa / xóa Branch)
- Đăng bài (Posts)
- Cài đặt hệ thống

### Branch (Chi nhánh)
- Quản lý sản phẩm riêng của chi nhánh (thêm / sửa / xóa)
- Xem đơn hàng liên quan đến sản phẩm của chi nhánh
- Cập nhật trạng thái đơn hàng
- Xem báo cáo doanh thu riêng theo danh mục
- Chat thời gian thực với người dùng (end-to-end encrypted)

---

## Cấu trúc dự án

```
flutter-ecrm/
├── lib/
│   ├── common/          # Widget dùng chung (BottomBar, ...)
│   ├── constants/       # Biến toàn cục, tiện ích, xử lý lỗi
│   ├── CustomUI/        # Custom UI components
│   ├── features/        # Tính năng theo module
│   │   ├── account/
│   │   ├── address/
│   │   ├── admin/
│   │   ├── auth/
│   │   ├── camera/
│   │   ├── cart/
│   │   ├── chat/
│   │   ├── home/
│   │   ├── order_details/
│   │   ├── product_details/
│   │   ├── search/
│   │   └── splash/
│   ├── helper/          # EncryptionHelper, ...
│   ├── models/          # Data models (User, Product, ...)
│   ├── providers/       # State management (Provider)
│   ├── router.dart      # Named routes
│   └── main.dart
├── server/              # Backend Node.js
│   ├── routes/          # auth, admin, product, user, branch, message
│   ├── models/          # Mongoose models
│   ├── middlewares/     # JWT auth middleware
│   ├── SocketIO/        # Socket.IO handlers
│   └── index.js
└── assets/
    ├── images/
    ├── icons/
    ├── applepay.json
    └── gpay.json
```

---

## Cài đặt & Chạy dự án

### Yêu cầu
- Flutter `2.10.5` (quản lý qua [FVM](https://fvm.app/))
- Node.js >= 14
- MongoDB Atlas hoặc local instance
- Tài khoản Cloudinary

### Cấu hình

1. **MongoDB**: Tạo cluster, lấy URI kết nối và thay vào `server/index.js`.

2. **Backend URL**: Mở `lib/constants/global_variables.dart`, cập nhật biến `uri`:
   ```dart
   // Production (Render)
   String uri = 'https://ecrm-server.onrender.com';
   
   // Local development
   // String uri = 'http://<your-ip>:3000';
   ```

3. **Cloudinary**: Tạo project, bật *unsigned upload*, sau đó cập nhật `Cloud Name` và `Upload Preset` trong `lib/features/admin/services/admin_services.dart`.

4. **Encrypted SharedPreferences**: Kiểm tra khóa mã hóa tại `lib/helper/encryption_helper.dart`.

---

### Chạy Server (Node.js)

```bash
cd server
npm install
npm run dev    # Chế độ phát triển (nodemon)
# hoặc
npm start      # Chạy một lần
```

### Chạy Client (Flutter)

```bash
# Cài dependencies
fvm flutter pub get

# Chạy ứng dụng
fvm flutter run

# Mở iOS Simulator (macOS)
open -a Simulator
```

---

## Công nghệ sử dụng

| Phía | Công nghệ |
|------|-----------|
| **Client** | Flutter, Provider, Dio/HTTP, Socket.IO Client, Cloudinary, Pay (Google/Apple Pay), Speech-to-Text, Camera, Local Auth, Encrypt |
| **Server** | Node.js, Express, Mongoose, MongoDB, Socket.IO, JWT, bcryptjs, Nodemailer |
| **Storage** | Cloudinary (media), MongoDB Atlas (data), Encrypted SharedPreferences (local) |

---

## Bảo mật

- Token JWT cho xác thực API
- Dữ liệu nhạy cảm mã hóa bằng AES (RSA key exchange) trước khi lưu local
- Kiểm tra thiết bị jailbreak/root khi khởi động
- Xác thực sinh trắc học (Face ID / Fingerprint)
- Tự động đăng xuất theo timeout không hoạt động

---

## Phiên bản

- App: `1.0.0+1`
- Flutter SDK: `2.10.5` (FVM)
- Dart SDK: `>=2.16.2 <3.0.0`