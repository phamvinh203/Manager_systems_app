class ApiUrl {
  static const String baseUrl = 'http://10.0.2.2:4000/api/';

  // auth endpoints
  static const String login = '${baseUrl}auth/login';
  static const String register = '${baseUrl}auth/register';

  // employee endpoints
  // GET /api/employees - Lấy danh sách tất cả nhân viên (có pagination: page, limit)
  static const String employees = '${baseUrl}employees';

  // GET /api/employees/:id - Lấy chi tiết nhân viên theo ID
  static String getEmployeeById(int id) => '${baseUrl}employees/$id';

  // POST /api/employees - Tạo nhân viên mới
  static const String createEmployee = '${baseUrl}employees';

  // PUT /api/employees/:id - Cập nhật thông tin nhân viên
  static String updateEmployee(int id) => '${baseUrl}employees/$id';

  // DELETE /api/employees/:id - Xóa nhân viên
  static String deleteEmployee(int id) => '${baseUrl}employees/$id';
}