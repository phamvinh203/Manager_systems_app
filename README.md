# 📱 Employee Manager - Ứng dụng Quản lý Nhân sự

## 1. Giới thiệu

###  Mục tiêu
**Employee Manager** là ứng dụng di động (Flutter) hỗ trợ doanh nghiệp quản lý nhân sự một cách hiệu quả, giúp quản lý:
- Tài khoản & phân quyền
- Hồ sơ nhân sự
- Phòng ban & chức vụ
- Chấm công
- Nghỉ phép
- Giao & theo dõi công việc (TASK)

###  Đối tượng sử dụng
| Vai trò | Quyền hạn |
|---------|-----------|
| **ADMIN** | Quản lý toàn bộ hệ thống, CRUD nhân viên, tạo task phòng ban |
| **HR** | Quản lý nhân viên, xem tất cả đơn nghỉ phép, xem các task phòng ban |
| **MANAGER** | Duyệt/từ chối đơn nghỉ phép của nhân viên trong team, thêm nhân sự vào các task của team |
| **EMPLOYEE** | Chấm công, tạo đơn nghỉ phép, xem thông tin cá nhân, làm các task được giao |

---

## 2. Các module chính
### 1. Authencation & User
- Đăng nhập, đăng xuất
- phân quyền theo role
- Liên kết User ↔ Employee
### 2. Employee (Nhân sự)
- Hồ sơ nhân viên
- Thông tin cá nhân & công việc
- Trạng thái làm việc
- Liên kết phòng ban & chức vụ
### 3. Department & Position
- Quản lý phòng ban
- Gán manager cho phòng ban
- Quản lý chức vụ theo phòng ban
### 4. Attendance (Chấm công)
- Check-in / check-out
- Theo dõi giờ làm việc
### 5. Leave Management (Nghỉ phép)
- Tạo đơn xin nghỉ
- Duyệt / từ chối đơn
- Quản lý số dư nghỉ phép
- Theo dõi lịch sử nghỉ
### 6. Task Managemen
- Giao task theo phòng ban
- Giao cho nhiều nhân viên
- Theo dõi tiến độ & trạng thái
- Review & approval

---

## 3. Kiến trúc hệ thống

### 🏗️ Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                   │
│  ┌─────────────────────────────────────────────────┐    │
│  │                PRESENTATION LAYER               │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────────────┐  │    │
│  │  │ Screens │  │ Widgets │  │ BLoC (State Mgmt)│ │    │
│  │  └─────────┘  └─────────┘  └─────────────────┘  │    │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                               │
│  ┌──────────────────────▼──────────────────────────┐    │
│  │                 DOMAIN LAYER                    │    │
│  │  ┌──────────────┐      ┌──────────────────────┐ │    │
│  │  │ Repositories │      │      Models          │ │    │
│  │  └──────────────┘      └──────────────────────┘ │    │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                               │
│  ┌──────────────────────▼──────────────────────────┐    │
│  │                  DATA LAYER                     │    │
│  │  ┌───────────┐  ┌─────────────┐  ┌───────────┐  │    │
│  │  │ DioClient │  │Interceptors │  │  Storage  │  │    │
│  │  └───────────┘  └─────────────┘  └───────────┘  │    │
│  └──────────────────────┬──────────────────────────┘    │
└─────────────────────────┼───────────────────────────────┘
                          │ HTTP (REST API)
                          ▼
              ┌───────────────────────┐
              │   BACKEND API SERVER  │
              │ (http://10.0.2.2:4000)│
              └───────────────────────┘
```
---
## 4. Workflow nghiệp vụ chính
- Nhân sự
  + HR tạo nhân viên
  + → Gán phòng ban & chức vụ
  + → (Tuỳ chọn) tạo tài khoản User

- Chấm công
  + Employee check-in
  + → check-out
  + → hệ thống tính tổng giờ

- Nghỉ phép
  + Employee tạo đơn
  + → Manager/HR duyệt
  + → Cập nhật LeaveBalance

- Task
  + Manager/HR tạo task
  + → Giao cho nhân viên
  + → Nhân viên cập nhật tiến độ
  + → Manager review & approve

---
## 5. Mô hình dữ liệu (tóm tắt)
- User ── 1 ↔ 1 ── Employee
- Employee ── n ↔ 1 ── Department
- Department ── 1 ↔ 1 ── Manager (Employee)

- Employee ── n ── Attendance
- Employee ── n ── LeaveRequest
- Employee ── n ── TaskAssignment ── n ── Task


## 6. Cài đặt & Chạy dự án

### 📋 Yêu cầu hệ thống

| Công cụ | Phiên bản | Ghi chú |
|---------|-----------|---------|
| Flutter | ≥ 3.9.0 | `flutter --version` |
| Dart | ≥ 3.9.0 | Đi kèm Flutter |
| Android Studio | Latest | Hoặc VS Code |
| Android SDK | API 21+ | Android 5.0 trở lên |
| iOS | 12.0+ | Chỉ macOS |

### Các bước cài đặt

#### Bước 1: Clone project
```bash
git clone <repository-url>
cd mobile
```

#### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

#### Bước 3: Cấu hình API URL
Mở file `lib/core/network/api_url.dart` và cập nhật `baseUrl`:

```dart
class ApiUrl {
  // static const String baseUrl = 'http://<YOUR_IP>:4000/api/';
}
```
