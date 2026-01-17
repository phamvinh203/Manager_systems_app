class ApiUrl {
  static const String baseUrl = 'http://10.0.2.2:4000/api/';

  // auth endpoints
  static const String login = '${baseUrl}auth/login';
  static const String register = '${baseUrl}auth/register';

  // employee endpoints
  // GET /api/employees - Lấy danh sách tất cả nhân viên (có pagination: page, limit)
  static const String employees = '${baseUrl}employees';

  // GET /api/employees/:userId - Lấy thông tin chi tiết của nhân viên theo userId khi login
  static String getByUserId(int userId) => '${baseUrl}employees/$userId';

  // POST /api/employees - Tạo nhân viên mới (Chỉ ADMIN và HR)
  static const String createEmployee = '${baseUrl}employees';

  // PUT /api/employees/:id - Cập nhật thông tin nhân viên (Chỉ ADMIN và HR)
  static String updateEmployee(int id) => '${baseUrl}employees/$id';

  // DELETE /api/employees/:id - Xóa nhân viên (Chỉ ADMIN)
  static String deleteEmployee(int id) => '${baseUrl}employees/$id';

  // department endpoints
  static const String getDepartments = '${baseUrl}departments';
  // positions endpoints
  static const String getPositions = '${baseUrl}positions';

  // attendance endpoints
  static const String checkIn = '${baseUrl}attendance/check-in';
  static const String checkOut = '${baseUrl}attendance/check-out';
  static const String meAttendance = '${baseUrl}attendance/me';
  static const String allAttendance = '${baseUrl}attendance';

  // leave request endpoints
  static const String leaveRequests = '${baseUrl}leave/requests';
  static const String myLeaveRequests = '${baseUrl}leave/requests/me';
  static const String myIdLeaveRequests = '${baseUrl}leave/requests';
  // hủy đơn nghỉ phép phía user khi đơn chưa được duyệt
  static String cancelLeaveRequest(String requestId) => '${baseUrl}leave/requests/$requestId/cancel';

  
  // manager endpoints
  static const String teamLeaveRequests = '${baseUrl}leave/requests/team';
  // manager phê duyệt hoặc từ chối đơn nghỉ phép
  static String approveLeaveRequest(String requestId) => '${baseUrl}leave/requests/$requestId/approve';
  static String rejectLeaveRequest(String requestId) => '${baseUrl}leave/requests/$requestId/reject';

  // hr endpoints
  static const String allLeaveRequests = '${baseUrl}leave/requests/all';
}
